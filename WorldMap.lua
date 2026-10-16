local ADDON_NAME, Addon = ...
local PIN = "EasyFlightMapWorldPinTemplate"
local ko = GetLocale() == "koKR"
local text = ko and {
    title = "Easy Flight Map · 비행 조련사",
    toggle = "비행 조련사",
    move = "드래그 이동",
    openSettings = "클릭: 설정 펼치기/접기 · 드래그: 이동",
    toggleHelp = "세계지도와 대륙 지도의 비행 조련사 표시를 켜거나 끕니다.",
    alliance = "얼라이언스", horde = "호드", neutral = "중립(공용)",
    unknown = "진영 미확인", undiscovered = "비행 경로 미발견",
    enemy = "상대 진영 비행 조련사",
    visit = "비행하려면 해당 비행 조련사와 대화하세요",
} or {
    title = "Easy Flight Map · Flight master",
    toggle = "Flight masters",
    move = "Drag to move",
    openSettings = "Click: toggle settings · Drag: move",
    toggleHelp = "Show or hide flight masters on world and continent maps.",
    alliance = "Alliance", horde = "Horde", neutral = "Neutral",
    unknown = "Unknown faction", undiscovered = "Flight path not discovered",
    enemy = "Opposing faction flight master",
    visit = "Speak to this flight master to fly",
}
local factions = {
    [0] = {text.neutral, 1, 0.82, 0.2},
    [1] = {text.horde, 1, 0.2, 0.15},
    [2] = {text.alliance, 0.2, 0.6, 1},
}
local unknownFaction = {text.unknown, 0.7, 0.7, 0.7}
local provider, mapToggle
local factionToggles = {}
local function Enabled()
    return EasyFlightMapDB and EasyFlightMapDB.worldMapFlights ~= false
end
local function FactionSettings()
    if not EasyFlightMapDB then return end
    local group = UnitFactionGroup("player") or "Neutral"
    if type(EasyFlightMapDB.worldMapFactionFilters) ~= "table" then
        EasyFlightMapDB.worldMapFactionFilters = {}
    end
    local filters = EasyFlightMapDB.worldMapFactionFilters
    if type(filters[group]) ~= "table" then filters[group] = {} end
    local options = filters[group]
    local defaults = {[0] = true, [1] = group == "Horde", [2] = group == "Alliance"}
    for id = 0, 2 do
        if type(options[id]) ~= "boolean" then options[id] = defaults[id] end
    end
    return options
end
local function ShowFaction(id)
    local options = FactionSettings()
    return options and options[id] == true
end
local function Number(n)
    return type(n) == "number" and n == n and math.abs(n) < math.huge
end
local function XY(pos)
    if not pos then return end
    local x, y
    if pos.GetXY then x, y = pos:GetXY() else x, y = pos.x, pos.y end
    if Number(x) and Number(y) then return x, y end
end
local function Nodes(mapID)
    if not (C_TaxiMap and C_TaxiMap.GetTaxiNodesForMap) then return {} end
    local ok, nodes = pcall(C_TaxiMap.GetTaxiNodesForMap, mapID)
    return ok and type(nodes) == "table" and nodes or {}
end
local function Rect(child, parent)
    if not (C_Map and C_Map.GetMapRectOnMap) then return end
    local ok, left, right, top, bottom = pcall(C_Map.GetMapRectOnMap, child, parent)
    if ok and Number(left) and Number(right) and Number(top) and Number(bottom)
        and right > left and bottom > top then
        return left, right, top, bottom
    end
end

-- Coordinates from GetTaxiNodesForMap belong to its requested UI map.
-- TaxiNodePosition belongs to different artwork and must never be used here.
local function Collect(mapID)
    local result, seen = {}, {}
    local function Add(nodes, left, right, top, bottom)
        for _, n in ipairs(nodes) do
            if type(n) == "table" and type(n.name) == "string"
                and not n.name:lower():match("^zzold") then
                local x, y = XY(n.position)
                if x and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                    x, y = left + x * (right - left), top + y * (bottom - top)
                    local key = n.nodeID or (n.name .. ":" .. tostring(n.faction))
                    if not seen[key] and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                        seen[key] = true
                        result[#result + 1] = {node = n, x = x, y = y}
                    end
                end
            end
        end
    end
    Add(Nodes(mapID), 0, 1, 0, 1)
    local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    if not info then return result end
    local continentType = Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2
    -- World maps may not return taxi nodes directly. Project each continent
    -- through Blizzard's map rectangle, rather than guessing an offset.
    if info.mapType and info.mapType < continentType and C_Map.GetMapChildrenInfo then
        for _, child in ipairs(C_Map.GetMapChildrenInfo(mapID, continentType, true) or {}) do
            local l, r, t, b = Rect(child.mapID, mapID)
            if l then Add(Nodes(child.mapID), l, r, t, b) end
        end
    elseif info.mapType and info.mapType > continentType then
        -- Some zone maps only expose nodes on their parent continent.
        local parent = info
        for _ = 1, 10 do
            if not parent or parent.mapType == continentType or not parent.parentMapID or parent.parentMapID == 0 then break end
            parent = C_Map.GetMapInfo(parent.parentMapID)
        end
        if parent and parent.mapType == continentType then
            local l, r, t, b = Rect(mapID, parent.mapID)
            if l then Add(Nodes(parent.mapID), -l / (r-l), (1-l) / (r-l), -t / (b-t), (1-t) / (b-t)) end
        end
    end
    return result
end

EasyFlightMapWorldPinMixin = {}
function EasyFlightMapWorldPinMixin:OnLoad()
    self:UseFrameLevelType("PIN_FRAME_LEVEL_FLIGHT_POINT")
    self:SetScalingLimits(1, 1, 1)
    self:SetMouseClickEnabled(false)
    self:SetMouseMotionEnabled(true)
    self.Ring = self:CreateTexture(nil, "BACKGROUND")
    self.Ring:SetTexture("Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\Pin-Glow")
    self.Ring:SetPoint("CENTER")
    self.Ring:SetSize(20, 20)
    self.Icon = self:CreateTexture(nil, "ARTWORK")
    self.Icon:SetAllPoints()
end
function EasyFlightMapWorldPinMixin:OnAcquired(entry)
    self.node = entry.node
    local f = factions[self.node.faction] or unknownFaction
    self.Ring:SetVertexColor(f[2], f[3], f[4])
    local atlas = self.node.atlasName
    if atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
        self.Icon:SetAtlas(atlas)
    else
        self.Icon:SetTexture("Interface\\Minimap\\Tracking\\FlightMaster")
    end
    self:SetPosition(entry.x, entry.y)
end
function EasyFlightMapWorldPinMixin:OnMouseEnter()
    local n = self.node
    if not n then return end
    local f = factions[n.faction] or unknownFaction
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(n.name, 1, 0.82, 0)
    GameTooltip:AddLine(f[1], f[2], f[3], f[4])
    local player = UnitFactionGroup("player")
    local enemy = (n.faction == 1 and player == "Alliance") or (n.faction == 2 and player == "Horde")
    if enemy then
        GameTooltip:AddLine(text.enemy, 1, 0.3, 0.25)
    elseif n.isUndiscovered == true then
        GameTooltip:AddLine(text.undiscovered, 0.8, 0.8, 0.8)
    end
    GameTooltip:AddLine(text.visit, 0.8, 0.8, 0.8, true)
    GameTooltip:AddLine(text.title, 0.3, 0.8, 1)
    GameTooltip:Show()
end
function EasyFlightMapWorldPinMixin:OnMouseLeave()
    if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
end
function EasyFlightMapWorldPinMixin:OnReleased()
    self:OnMouseLeave()
    self.node = nil
    MapCanvasPinMixin.OnReleased(self)
end

local function SyncToggle()
    local options = FactionSettings()
    for id, checkbox in pairs(factionToggles) do
        checkbox:SetChecked(options and options[id] == true or false)
    end
    if mapToggle then mapToggle:SetChecked(Enabled() and true or false) end
    for _, checkbox in ipairs(Addon.WorldMapSettingControls or {}) do
        checkbox:SetChecked(Enabled() and true or false)
    end
end
local function CreateMapToggle()
    local parent = WorldMapFrame.GetCanvasContainer and WorldMapFrame:GetCanvasContainer() or WorldMapFrame
    local panel = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    panel:SetSize(28, 28)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetClampedToScreen(true)
    panel:SetFrameLevel(parent:GetFrameLevel() + 20)
    local menu = CreateFrame("Frame", nil, panel, BackdropTemplateMixin and "BackdropTemplate" or nil)
    menu:SetSize(324, 54)
    menu:SetFrameLevel(panel:GetFrameLevel() + 1)
    menu:EnableMouse(true)
    if menu.SetBackdrop then
        menu:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
        menu:SetBackdropColor(0.04, 0.04, 0.04, 0.92)
    end
    mapToggle = CreateFrame("CheckButton", nil, menu, "UICheckButtonTemplate")
    mapToggle:SetSize(26, 26)
    mapToggle:SetPoint("TOPLEFT", menu, "TOPLEFT", 2, 0)
    mapToggle:SetHitRectInsets(0, -112, 0, 0)
    local label = mapToggle:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", mapToggle, "RIGHT", 2, 0)
    label:SetText(text.toggle)
    mapToggle:SetScript("OnShow", SyncToggle)
    mapToggle:SetScript("OnClick", function(self)
        if not EasyFlightMapDB then return end
        EasyFlightMapDB.worldMapFlights = self:GetChecked() and true or false
        Addon.RefreshWorldMap()
    end)
    mapToggle:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text.title)
        GameTooltip:AddLine(text.toggleHelp, 1, 1, 1, true)
        for id = 2, 0, -1 do
            local f = factions[id]
            GameTooltip:AddLine(f[1], f[2], f[3], f[4])
        end
        GameTooltip:Show()
    end)
    mapToggle:SetScript("OnLeave", function(self)
        if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
    end)
    for index, id in ipairs({2, 1, 0}) do
        local cb = CreateFrame("CheckButton", nil, menu, "UICheckButtonTemplate")
        cb:SetSize(24, 24)
        cb:SetPoint("BOTTOMLEFT", menu, "BOTTOMLEFT", 2 + (index - 1) * 108, 2)
        cb:SetHitRectInsets(0, -78, 0, 0)
        cb.factionID = id
        local f = factions[id]
        local name = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        name:SetPoint("LEFT", cb, "RIGHT", 0, 0)
        name:SetText(f[1])
        name:SetTextColor(f[2], f[3], f[4])
        cb:SetScript("OnClick", function(self)
            local options = FactionSettings()
            if not options then return end
            options[self.factionID] = self:GetChecked() and true or false
            Addon.RefreshWorldMap()
        end)
        cb:SetScript("OnShow", SyncToggle)
        factionToggles[id] = cb
    end
    local function PositionMenu()
        local w, h = parent:GetWidth(), parent:GetHeight()
        if w <= 0 or h <= 0 then return end
        local ps, scale = parent:GetEffectiveScale(), panel:GetEffectiveScale()
        local left, top = panel:GetLeft(), panel:GetTop()
        if not left or not top then return end
        local x = left * scale / ps - parent:GetLeft()
        local y = top * scale / ps - parent:GetBottom()
        local mx = x + 34
        if mx + menu:GetWidth() > w then mx = x - menu:GetWidth() - 6 end
        mx = math.max(0, math.min(math.max(0, w - menu:GetWidth()), mx))
        y = math.max(math.min(menu:GetHeight(), h), math.min(h, y))
        menu:ClearAllPoints()
        menu:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", mx, y)
    end
    local function RestorePosition()
        local width, height = parent:GetWidth(), parent:GetHeight()
        if not Number(width) or not Number(height) or width <= 0 or height <= 0 then return end
        local point = EasyFlightMapDB and EasyFlightMapDB.worldMapControlPoint
        local x, y = 8, panel:GetHeight() + 8
        if type(point) == "table" and Number(point.x) and Number(point.y) then
            x, y = point.x * width, point.y * height
        end
        x = math.max(0, math.min(math.max(0, width - panel:GetWidth()), x))
        y = math.max(math.min(panel:GetHeight(), height), math.min(height, y))
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", x, y)
        PositionMenu()
    end
    local function SavePosition()
        if not EasyFlightMapDB then return end
        local scale, parentScale = panel:GetEffectiveScale(), parent:GetEffectiveScale()
        local left, top = panel:GetLeft(), panel:GetTop()
        local pl, pb, w, h = parent:GetLeft(), parent:GetBottom(), parent:GetWidth(), parent:GetHeight()
        if not (left and top and pl and pb and w > 0 and h > 0) then return end
        EasyFlightMapDB.worldMapControlPoint = {
            x = (left * scale / parentScale - pl) / w,
            y = (top * scale / parentScale - pb) / h,
        }
        RestorePosition()
    end
    local icon = CreateFrame("Button", nil, panel, BackdropTemplateMixin and "BackdropTemplate" or nil)
    icon:SetSize(28, 28)
    icon:SetPoint("CENTER", panel, "CENTER")
    if icon.SetBackdrop then
        icon:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = {left = 2, right = 2, top = 2, bottom = 2},
        })
        icon:SetBackdropColor(0.025, 0.025, 0.025, 0.95)
        icon:SetBackdropBorderColor(0.82, 0.65, 0.28, 1)
    end
    icon:SetNormalTexture("Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\WorldMapIcon")
    local artwork = icon:GetNormalTexture()
    artwork:SetTexCoord(0, 48/64, 0, 52/64)
    artwork:ClearAllPoints()
    artwork:SetPoint("TOPLEFT", icon, "TOPLEFT", 3, -3)
    artwork:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -3, 3)
    icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    icon:RegisterForDrag("LeftButton")
    icon:SetScript("OnEnter", function(self)
        if self.SetBackdropBorderColor then self:SetBackdropBorderColor(1, 0.83, 0.4, 1) end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text.title)
        GameTooltip:AddLine(text.openSettings, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    icon:SetScript("OnLeave", function(self)
        if self.SetBackdropBorderColor then self:SetBackdropBorderColor(0.82, 0.65, 0.28, 1) end
        if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
    end)
    local function UpdateCollapse()
        local folded = EasyFlightMapDB and EasyFlightMapDB.worldMapControlsCollapsed == true
        menu:SetShown(not folded)
        icon:SetShown(true)
        RestorePosition()
    end
    icon:SetScript("OnClick", function()
        if not EasyFlightMapDB or panel.dragging then return end
        EasyFlightMapDB.worldMapControlsCollapsed = not EasyFlightMapDB.worldMapControlsCollapsed
        UpdateCollapse()
    end)
    local function UpdateDrag()
        if not panel.dragging then return end
        local cx, cy = GetCursorPosition()
        local ps = parent:GetEffectiveScale()
        local x = (cx - panel.dragOffsetX) / ps - parent:GetLeft()
        local y = (cy - panel.dragOffsetY) / ps - parent:GetBottom()
        x = math.max(0, math.min(math.max(0, parent:GetWidth() - panel:GetWidth()), x))
        y = math.max(math.min(panel:GetHeight(), parent:GetHeight()), math.min(parent:GetHeight(), y))
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", x, y)
        PositionMenu()
    end
    local function StartDrag()
        local cx, cy = GetCursorPosition()
        local left, top = panel:GetLeft(), panel:GetTop()
        if not left or not top then return end
        local scale = panel:GetEffectiveScale()
        panel.dragOffsetX, panel.dragOffsetY = cx - left * scale, cy - top * scale
        panel.dragging = true
        panel:SetScript("OnUpdate", UpdateDrag)
    end
    icon:SetScript("OnDragStart", StartDrag)
    local function StopDrag()
        if not panel.dragging then return end
        UpdateDrag()
        panel.dragging = false
        panel:SetScript("OnUpdate", nil)
        SavePosition()
    end
    icon:SetScript("OnDragStop", StopDrag)
    panel:SetScript("OnHide", StopDrag)
    panel:SetScript("OnShow", function() UpdateCollapse(); SyncToggle() end)
    parent:HookScript("OnSizeChanged", function() if not panel.dragging then RestorePosition() end end)
    UpdateCollapse()
    Addon.WorldMapControlPanel = panel
    Addon.WorldMapSettingsIcon = icon
    Addon.WorldMapOptionsPanel = menu
    Addon.WorldMapFactionToggles = factionToggles
    Addon.WorldMapToggle = mapToggle
    SyncToggle()
end

local function Install()
    if provider or not (WorldMapFrame and WorldMapFrame.AddDataProvider
        and MapCanvasDataProviderMixin and MapCanvasPinMixin
        and C_TaxiMap and C_TaxiMap.GetTaxiNodesForMap) then return end
    for key, value in pairs(MapCanvasPinMixin) do
        if EasyFlightMapWorldPinMixin[key] == nil then EasyFlightMapWorldPinMixin[key] = value end
    end
    provider = CreateFromMixins(MapCanvasDataProviderMixin)
    provider.Collect = Collect
    function provider:RemoveAllData()
        self:GetMap():RemoveAllPinsByTemplate(PIN)
    end
    function provider:RefreshAllData()
        self:RemoveAllData()
        if not Enabled() then return end
        for _, entry in ipairs(Collect(self:GetMap():GetMapID())) do
            if ShowFaction(entry.node.faction) then
                self:GetMap():AcquirePin(PIN, entry)
            end
        end
    end
    function provider:OnShow()
        self:RegisterEvent("TAXI_NODE_STATUS_CHANGED")
        SyncToggle()
    end
    function provider:OnHide() self:UnregisterEvent("TAXI_NODE_STATUS_CHANGED") end
    function provider:OnEvent() self:RefreshAllData() end
    WorldMapFrame:AddDataProvider(provider)
    -- The stock provider only displays the player's faction. Remove its pins
    -- after each refresh while our complete, faction-coloured layer is active.
    -- This hook is restricted to this world map and restores stock pins when off.
    local function HookStock(_, stock)
        if not (FlightPointDataProviderMixin and stock ~= provider
            and stock.ShouldShowTaxiNode == FlightPointDataProviderMixin.ShouldShowTaxiNode)
            or stock.easyFlightMapHooked then return end
        stock.easyFlightMapHooked = true
        hooksecurefunc(stock, "RefreshAllData", function(p)
            if Enabled() and p:GetMap() == WorldMapFrame then
                WorldMapFrame:RemoveAllPinsByTemplate("FlightPointPinTemplate")
            end
        end)
    end
    for p in pairs(WorldMapFrame.dataProviders or {}) do HookStock(WorldMapFrame, p) end
    hooksecurefunc(WorldMapFrame, "AddDataProvider", HookStock)
    Addon.WorldMapProvider = provider
    CreateMapToggle()
    if WorldMapFrame:IsShown() then
        provider:OnShow()
        Addon.RefreshWorldMap()
    end
end
function Addon.RefreshWorldMap()
    Install()
    SyncToggle()
    if provider and WorldMapFrame:IsShown() then WorldMapFrame:RefreshAllDataProviders() end
end
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("UNIT_FACTION")
events:SetScript("OnEvent", function(_, event, name)
    if event == "UNIT_FACTION" then
        if name == "player" then Addon.RefreshWorldMap() end
    elseif event == "PLAYER_LOGIN" or name == ADDON_NAME or name == "Blizzard_WorldMap" then
        Install()
        SyncToggle()
    end
end)
