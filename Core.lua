-- Easy Flight Map
-- 비행 조련사와 대화하면, 다른 애드온 아이콘이 하나도 없는 전용 창에 비행 지점과
-- 목적지 이름·요금·소요 시간을 보여줍니다.
-- Shows flight points with name, cost and flight time in a clean, separate map window.

local ADDON_NAME = ...

local floor, ceil, min, max, sqrt, abs = math.floor, math.ceil, math.min, math.max, math.sqrt, math.abs

local DONATE_URL = "https://buymeacoffee.com/qqhrqqhr2"

---------------------------------------------------------------------------
-- 문자열 (클라이언트 언어에 따라 자동)
---------------------------------------------------------------------------
local L
if GetLocale() == "koKR" then
    L = {
        TITLE        = "Easy Flight Map · 비행 지도",
        CURRENT      = "현재 위치",
        FARE         = "요금",
        TIME         = "시간",
        FREE         = "무료",
        COST_UNKNOWN = "미확인",
        TIME_UNKNOWN = "미측정",
        CLICK        = "클릭하면 비행합니다",
        STOPS        = "경유 %d곳",
        UNREACHABLE  = "연결된 비행 경로 없음",
        UNDISCOVERED = "비행 경로 미발견",
        HINT         = "클릭: 비행   드래그: 창 이동   Ctrl+휠: 크기",
        ON           = "켜짐",
        OFF          = "꺼짐",
        ART_WORLD    = "세계 지도",
        ART_TAXI     = "기본 비행 지도",
        SEC          = "%d초",
        MIN          = "%d분",
        MIN_SEC      = "%d분 %d초",
        APPROX       = "약 %s",
        TT_TIME      = "소요 시간: %s",
        TT_EST       = "예상 시간: %s",
        TT_EST_NOTE  = "한 번 날아가면 실제 시간이 기록됩니다",
        BAR_SOON     = "곧 도착",
        SETTINGS     = "설정",
        HEAD_BASIC   = "기본",
        HEAD_MAP     = "지도 표시",
        HEAD_FLIGHT  = "비행 중",
        OPT_ENABLED  = "전용 비행 지도 사용",
        OPT_SKIP     = "대화창 없이 바로 지도 열기",
        OPT_SKIP_SUB = "Shift를 누른 채 말을 걸면 대화창이 나옵니다",
        OPT_LABELS   = "목적지 이름·요금·시간 표시",
        OPT_CROP     = "비행 지점 부분만 크게 보기",
        OPT_ALL      = "미발견·미연결 비행 지점도 표시",
        OPT_ART      = "세계 지도 그림 사용 (끄면 기본 비행 지도 그림)",
        OPT_SCALE    = "창 크기",
        OPT_ALPHA    = "창 투명도",
        OPT_FONT     = "글자 크기",
        OPT_BAR      = "남은 비행 시간 막대 표시",
        OPT_BAR_SUB  = "막대는 드래그해서 옮길 수 있습니다",
        OPT_ALERT    = "도착하면 소리와 작업 표시줄 깜빡임으로 알림",
        OPT_CONFIRM  = "비행 전 확인 창 표시",
        CONFIRM_TITLE = "이 목적지로 비행할까요?",
        CONFIRM_FLY = "비행",
        CONFIRM_CANCEL = "취소",
        CONFIRM_CHANGED = "요금이 변경되었습니다. 다시 확인해 주세요.",
        BTN_DEFAULT  = "기본 비행 지도로 보기",
        BTN_DONATE   = "후원하기",
        DONATE_TITLE = "Easy Flight Map 후원",
        DONATE_TEXT  = "도움이 되셨다면 커피 한 잔으로 응원해 주세요!\nCtrl+C로 복사해서 인터넷 주소창에 붙여 넣으면 됩니다.",
        MSG_RECORDED = "비행 시간 기록: %s → %s",
        MSG_ENABLED  = "전용 비행 지도: %s",
        MSG_SCALE    = "창 크기: %d%%",
        MSG_ALPHA    = "창 투명도: %d%%",
        MSG_CROP     = "비행 지점 부분만 확대: %s",
        MSG_ALL      = "미발견·미연결 비행 지점 표시: %s",
        MSG_ART      = "지도 그림: %s",
        MSG_LABELS   = "지도에 이름·요금·시간 표시: %s",
        MSG_SKIP     = "비행 조련사 대화창 건너뛰기: %s",
        MSG_BAR      = "남은 비행 시간 막대: %s",
        MSG_ALERT    = "도착 알림: %s",
        MSG_RESET    = "창 위치와 크기를 초기화했습니다.",
        MSG_ERROR    = "오류가 나서 기본 비행 지도를 표시합니다: %s",
        HELP = {
            "/efm config  - 설정 창 열기",
            "/efm on | off  - 전용 비행 지도 켜기/끄기",
            "/efm skip  - 대화창 건너뛰고 바로 지도 열기 켜기/끄기 (Shift: 대화창 보기)",
            "/efm labels  - 지도에 이름·요금·시간 표시 켜기/끄기",
            "/efm scale 50~120  - 창 크기(%)",
            "/efm alpha 0~70  - 창 투명도(%)",
            "/efm bar  - 남은 비행 시간 막대 켜기/끄기",
            "/efm alert  - 도착 알림 켜기/끄기",
            "/efm reset  - 창 위치와 크기 초기화",
            "/efm donate  - 후원 주소 보기",
        },
    }
else
    L = {
        TITLE        = "Flight Map",
        CURRENT      = "You are here",
        FARE         = "Fare",
        TIME         = "Time",
        FREE         = "Free",
        COST_UNKNOWN = "Unknown",
        TIME_UNKNOWN = "Not recorded",
        CLICK        = "Click to fly",
        STOPS        = "%d stop(s)",
        UNREACHABLE  = "No connected flight path",
        UNDISCOVERED = "Flight path not discovered",
        HINT         = "Click: fly   Drag: move   Ctrl+Wheel: size",
        ON           = "on",
        OFF          = "off",
        ART_WORLD    = "world map",
        ART_TAXI     = "default flight map",
        SEC          = "%ds",
        MIN          = "%dm",
        MIN_SEC      = "%dm %ds",
        APPROX       = "~%s",
        TT_TIME      = "Flight time: %s",
        TT_EST       = "Estimated time: %s",
        TT_EST_NOTE  = "The real time is recorded after you fly it once",
        BAR_SOON     = "Arriving",
        SETTINGS     = "Settings",
        HEAD_BASIC   = "General",
        HEAD_MAP     = "Map",
        HEAD_FLIGHT  = "In flight",
        OPT_ENABLED  = "Use the Easy Flight Map window",
        OPT_SKIP     = "Skip the dialog and open the map directly",
        OPT_SKIP_SUB = "Hold Shift while talking to see the dialog",
        OPT_LABELS   = "Show destination name, cost and time",
        OPT_CROP     = "Zoom to flight points",
        OPT_ALL      = "Show unreachable points",
        OPT_ART      = "Use world map art (off: default flight map art)",
        OPT_SCALE    = "Window size",
        OPT_ALPHA    = "Window transparency",
        OPT_FONT     = "Text size",
        OPT_BAR      = "Show remaining flight time bar",
        OPT_BAR_SUB  = "Drag the bar to move it",
        OPT_ALERT    = "Play a sound and flash the taskbar on arrival",
        OPT_CONFIRM  = "Confirm before flying",
        CONFIRM_TITLE = "Fly to this destination?",
        CONFIRM_FLY = "Fly",
        CONFIRM_CANCEL = "Cancel",
        CONFIRM_CHANGED = "The fare changed. Please confirm again.",
        BTN_DEFAULT  = "Show default flight map",
        BTN_DONATE   = "Donate",
        DONATE_TITLE = "Support Easy Flight Map",
        DONATE_TEXT  = "If this helps you, a coffee would make my day!\nPress Ctrl+C to copy, then paste it into your browser.",
        MSG_RECORDED = "Flight time recorded: %s -> %s",
        MSG_ENABLED  = "Easy Flight Map: %s",
        MSG_SCALE    = "Window size: %d%%",
        MSG_ALPHA    = "Window transparency: %d%%",
        MSG_CROP     = "Zoom to flight points: %s",
        MSG_ALL      = "Show unreachable points: %s",
        MSG_ART      = "Map art: %s",
        MSG_LABELS   = "Name/cost/time labels: %s",
        MSG_SKIP     = "Skip flight master dialog: %s",
        MSG_BAR      = "Remaining flight time bar: %s",
        MSG_ALERT    = "Arrival alert: %s",
        MSG_RESET    = "Window position and size reset.",
        MSG_ERROR    = "Error, showing the default flight map instead: %s",
        HELP = {
            "/efm config  - open settings",
            "/efm on | off  - enable/disable Easy Flight Map",
            "/efm skip  - toggle skipping the flight master dialog (Shift: show it)",
            "/efm labels  - toggle name/cost/time labels on the map",
            "/efm scale 50-120  - window size (%)",
            "/efm alpha 0-70  - window transparency (%)",
            "/efm bar  - toggle the remaining flight time bar",
            "/efm alert  - toggle the arrival alert",
            "/efm reset  - reset window position and size",
            "/efm donate  - show the donation link",
        },
    }
end

---------------------------------------------------------------------------
-- 설정
---------------------------------------------------------------------------
local DB
local defaults = {
    enabled         = true,
    skipGossip      = true,     -- 비행 조련사 대화창 건너뛰고 바로 지도 열기
    art             = "taxi",   -- Use the stock taxi map and its own coordinates together.
    crop            = false,    -- 기본은 지도 전체 표시; 주변 확대는 선택 사항
    showUnreachable = true,
    labels          = true,     -- 지도에 이름·요금·시간 표시
    labelSize       = 12,
    scale           = 1.0,
    alpha           = 1.0,      -- 창 불투명도 (1 = 투명하지 않음)
    flightBar       = true,     -- 비행 중 남은 시간 막대
    arrivalAlert    = true,     -- 도착 알림
    confirmFlight   = false,
    point           = nil,
    barPoint        = nil,
}

local function FiniteNumber(v)
    return type(v) == "number" and v == v and abs(v) < math.huge
end
local function ValidPoint(pt)
    local a = {TOP=true,BOTTOM=true,LEFT=true,RIGHT=true,CENTER=true,TOPLEFT=true,TOPRIGHT=true,BOTTOMLEFT=true,BOTTOMRIGHT=true}
    return type(pt)=="table" and a[pt[1]] and a[pt[2]] and FiniteNumber(pt[3]) and FiniteNumber(pt[4])
end
local function InitDB()
    if type(EasyFlightMapDB) ~= "table" then EasyFlightMapDB = {} end
    DB = EasyFlightMapDB
    for k, v in pairs(defaults) do
        if type(DB[k]) ~= type(v) then DB[k] = v end
    end
    if type(DB.times) ~= "table" then DB.times = {} end              -- "출발 > 도착" = 초
    if type(DB.flightSpeeds) ~= "table" then DB.flightSpeeds = {} end
    if type(DB.calib) ~= "table" then DB.calib = { t = 0, d = 0 } end -- 예상 시간 보정용 (초, 야드)
    DB.scale = FiniteNumber(DB.scale) and max(0.5,min(1.2,DB.scale)) or defaults.scale
    DB.alpha = FiniteNumber(DB.alpha) and max(0.3,min(1,DB.alpha)) or defaults.alpha
    -- Existing installs inherited automatic cropping. Show the complete map
    -- once on upgrade, then preserve any explicit choice made afterward.
    if DB.fullMapRevision ~= 1 then
        DB.crop = false
        DB.fullMapRevision = 1
    end
    -- Upgrade once so this build visibly shows destination information.
    -- Later user choices (including hiding labels) are preserved on reload.
    if DB.destinationUI ~= 1 then
        DB.labels = true
        if FiniteNumber(DB.labelSize) then DB.labelSize = max(12, DB.labelSize) end
        DB.destinationUI = 1
    end
    DB.labelSize = FiniteNumber(DB.labelSize) and max(8,min(14,floor(DB.labelSize))) or defaults.labelSize
    -- Flight-map positions are not C_Map world-map positions.
    -- Preserve old measured times but keep them in their original key namespace.
    DB.art = "taxi"
    if DB.taxiDataRevision ~= 2 then
        DB.calib = {t=0,d=0}
        DB.taxiDataRevision = 2
    end
    if not ValidPoint(DB.point) then DB.point=nil end
    if not ValidPoint(DB.barPoint) then DB.barPoint=nil end
    if not (FiniteNumber(DB.calib.t) and DB.calib.t>=0 and FiniteNumber(DB.calib.d) and DB.calib.d>=0) then DB.calib={t=0,d=0} end
end

local function Print(text)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ccffEasy Flight Map|r: " .. tostring(text))
end

---------------------------------------------------------------------------
-- 상수
---------------------------------------------------------------------------
local MEDIA = "Interface\\AddOns\\" .. (ADDON_NAME or "EasyFlightMap") .. "\\Media\\"

local CONTINENT = (Enum and Enum.UIMapType and Enum.UIMapType.Continent) or 2
local FPS = Enum and Enum.FlightPathState
local FPS_CURRENT     = (FPS and FPS.Current) or 0
local FPS_REACHABLE   = (FPS and FPS.Reachable) or 1
local FPS_UNREACHABLE = (FPS and FPS.Unreachable) or 2

local ICON_FILE = {
    CURRENT   = MEDIA .. "Pin-Current",
    REACHABLE = MEDIA .. "Pin-Flight",
    DISTANT   = MEDIA .. "Pin-Distant",
}
local ICON_FALLBACK = {
    CURRENT   = "Interface\\TaxiFrame\\UI-Taxi-Icon-Green",
    REACHABLE = "Interface\\TaxiFrame\\UI-Taxi-Icon-White",
    DISTANT   = "Interface\\TaxiFrame\\UI-Taxi-Icon-White",
}
local ICON_COLOR = {
    CURRENT   = { 0.2, 1.0, 0.2 },
    REACHABLE = { 1.0, 0.85, 0.4 },
    DISTANT   = { 0.5, 0.5, 0.5 },
}
local GLOW_FILE = MEDIA .. "Pin-Glow"
local GEAR_FILE = MEDIA .. "Gear"
local RING_FILE = MEDIA .. "Pin-Selected"

local BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local PAD, TITLE_H, FOOT_H = 10, 30, 22
local PIN_SIZE, PIN_SIZE_CURRENT = 22, 26
local MIN_WIDTH = 340

local BLIZZARD_FRAMES = { "TaxiFrame", "FlightMapFrame" }

---------------------------------------------------------------------------
-- 상태
---------------------------------------------------------------------------
local Main, Viewport, LabelLayer, TitleText
local tilePool, pinPool, linePool, labelPool = {}, {}, {}, {}
local cur = { open = false }
local HoverLayer
local RefreshFareLabel
local hover = { segments = {}, total = 0 }
local snap          -- 마지막으로 연 비행 조련사의 비행 지점 정보
local hidden = {}
local ToggleSettingsPopup, CloseSettingsPopup   -- 아래 "설정 창"에서 정의

---------------------------------------------------------------------------
-- 유틸
---------------------------------------------------------------------------
local function ShortName(name)
    return (name and name:match("^([^,]+)")) or name or "?"
end

local function FormatTime(sec, approx)
    sec = floor(sec + 0.5)
    if approx then
        return L.APPROX:format(L.MIN:format(max(1, floor(sec / 60 + 0.5))))
    end
    if sec < 60 then return L.SEC:format(sec) end
    local m, s = floor(sec / 60), sec % 60
    if s == 0 then return L.MIN:format(m) end
    return L.MIN_SEC:format(m, s)
end

local function FormatClock(sec)
    sec = max(0, floor(sec + 0.5))
    return ("%d:%02d"):format(floor(sec / 60), sec % 60)
end

local function CoinText(cost, size)
    if not FiniteNumber(cost) or cost < 0 then return L.COST_UNKNOWN end
    cost = floor(cost)
    if cost == 0 then return L.FREE end
    size = FiniteNumber(size) and max(8, min(16, floor(size))) or 12
    local gold, silver, copper = floor(cost / 10000), floor(cost / 100) % 100, cost % 100
    local parts = {}
    local function add(value, kind)
        if value > 0 then
            local texture = "Interface\\MoneyFrame\\UI-" .. kind .. "Icon"
            parts[#parts + 1] = ("%d|T%s:%d:%d:0:0|t"):format(value, texture, size, size)
        end
    end
    add(gold, "Gold")
    add(silver, "Silver")
    add(copper, "Copper")
    return table.concat(parts, " ")
end

local function SetFontSize(fs, size)
    local fo = _G.GameFontHighlightSmall
    if fo and fo.GetFont and fs.SetFont then
        local file, _, flags = fo:GetFont()
        if file then fs:SetFont(file, size, flags or "") end
    end
end

---------------------------------------------------------------------------
-- 비행 지점 데이터
---------------------------------------------------------------------------
local function NodeTypeOf(slot, st)
    if TaxiNodeGetType then
        local t = TaxiNodeGetType(slot)
        if t then return t end
    end
    if st == FPS_CURRENT then return "CURRENT" end
    if st == FPS_REACHABLE then return "REACHABLE" end
    if st == FPS_UNREACHABLE then return "DISTANT" end
    return "NONE"
end

local function PosXY(p)
    if type(p) ~= "table" then return end
    if p.GetXY then return p:GetXY() end
    return p.x, p.y
end

local function ContinentMapID()
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo) then return end
    local id = C_Map.GetBestMapForUnit("player")
    for _ = 1, 10 do
        if not id then return end
        local info = C_Map.GetMapInfo(id)
        if not info then return end
        if info.mapType == CONTINENT then return id end
        if info.mapType and info.mapType < CONTINENT then return end
        id = info.parentMapID
    end
end

-- Modern taxi metadata supplies node IDs and the stock fare. Its map
-- positions are deliberately never used to place pins on the taxi artwork.
local function UpdateTaxiMetadata(s)
    if not (s and s.list and s.bySlot) then return end
    for _, e in ipairs(s.list) do e.nodeID, e.apiCost, e.undiscovered = nil, nil, nil end
    if not (s.taxiMapID and C_TaxiMap and C_TaxiMap.GetAllTaxiNodes) then return end
    local ok, nodes = pcall(C_TaxiMap.GetAllTaxiNodes, s.taxiMapID)
    if not ok or type(nodes) ~= "table" then return end
    local seen = {}
    for _, n in ipairs(nodes) do
        local e = type(n) == "table" and s.bySlot[n.slotIndex]
        if e and n.name == e.name and NodeTypeOf(e.slot, n.state) == e.type then
            if seen[e.slot] then
                e.nodeID, e.apiCost = nil, nil
            else
                if FiniteNumber(n.nodeID) and n.nodeID > 0 then e.nodeID = n.nodeID end
                if FiniteNumber(n.cost) and n.cost >= 0 then e.apiCost = floor(n.cost) end
            end
            seen[e.slot] = true
        end
    end
    -- Discovery is separate from reachability. Join only by validated node ID
    -- and name; world-map positions must not alter the flight-map layout.
    if C_TaxiMap.GetTaxiNodesForMap then
        local valid, points = pcall(C_TaxiMap.GetTaxiNodesForMap, s.mapID or s.taxiMapID)
        if valid and type(points) == "table" then
            local byID, duplicates = {}, {}
            for _, n in ipairs(points) do
                if type(n) == "table" and FiniteNumber(n.nodeID) then
                    if byID[n.nodeID] then duplicates[n.nodeID] = true end
                    byID[n.nodeID] = n
                end
            end
            for _, e in ipairs(s.list) do
                local n = e.nodeID and byID[e.nodeID]
                if n and not duplicates[e.nodeID] and n.name == e.name and type(n.isUndiscovered) == "boolean" then
                    e.undiscovered = n.isUndiscovered
                end
            end
        end
    end
end

local function FlightPathStatus(node)
    return node and node.undiscovered == true and L.UNDISCOVERED or L.UNREACHABLE
end

local function FlightSpeedMultiplier()
    if not (C_Traits and C_Traits.GetConfigIDByTreeID and C_Traits.GetNodeInfo) then return 1 end
    local ok, config = pcall(C_Traits.GetConfigIDByTreeID, 1188)
    if not ok or not config then return 1 end
    local valid, node = pcall(C_Traits.GetNodeInfo, config, 110300)
    if valid and type(node) == "table" and (tonumber(node.activeRank) or 0) > 0 then return 1.2 end
    return 1
end

local function RouteDistance(e, s)
    if not (e.segs and #e.segs > 0 and #e.segs == e.hops) then return end
    local total = 0
    local paths = EasyFlightMapRouteDistances or {}
    for _, seg in ipairs(e.segs) do
        local a, b = s.bySlot[seg[1]].nodeID, s.bySlot[seg[2]].nodeID
        local yards = a and b and paths[a] and paths[a][b]
        if not FiniteNumber(yards) or yards <= 0 then return end
        total = total + yards
    end
    return total
end

-- Read after the stock UI has initialized its route cache.
local function NativeFare(e)
    if not (e and e.type == "REACHABLE") then return end
    if TaxiNodeName and TaxiNodeName(e.slot) ~= e.name then return end
    if TaxiNodeGetType and TaxiNodeGetType(e.slot) ~= "REACHABLE" then return end
    local routes
    if GetNumRoutes then
        local ok, value = pcall(GetNumRoutes, e.slot)
        if not ok or not FiniteNumber(value) or value < 1 then return end
        routes = value
    end
    local value = e.apiCost
    local ok = FiniteNumber(value)
    if not ok and TaxiNodeCost then ok, value = pcall(TaxiNodeCost, e.slot) end
    if ok and FiniteNumber(value) and value >= 0 then
        -- Zero is free only after a live route exists. An uninitialized
        -- route must not become a fabricated free flight.
        if value > 0 or (routes and e.segs and #e.segs == routes) then return floor(value) end
    end
end

local function NearestByTaxi(list, tx, ty)
    if not (tx and ty) then return end
    local best, bestD = nil, 0.0005 * 0.0005
    local ambiguous = false
    for _, n in ipairs(list) do
        if n.tx then
            local dx, dy = n.tx - tx, n.ty - ty
            local d = dx * dx + dy * dy
            if best and abs(d-bestD) < 1e-10 then ambiguous = true
            elseif d < bestD then best, bestD, ambiguous = n, d, false end
        end
    end
    if not ambiguous then return best end
end

-- slot까지 가는 경로를 {출발 slot, 도착 slot} 구간 목록으로
local function RouteSlots(slot, s)
    local out = {}
    local n = GetNumRoutes and GetNumRoutes(slot) or 0
    if not FiniteNumber(n) or n < 1 or n > 64 then return out end
    local sxf, syf = TaxiGetSrcX, TaxiGetSrcY
    local dxf, dyf = TaxiGetDestX or TaxiGetDstX, TaxiGetDestY or TaxiGetDstY
    for hop = 1, n do
        local a, b
        if TaxiGetNodeSlot then
            a = TaxiGetNodeSlot(slot, hop, true)
            b = TaxiGetNodeSlot(slot, hop, false)
        end
        if not (a and s.bySlot[a] and b and s.bySlot[b]) then
            a, b = nil, nil
            if sxf and syf and dxf and dyf then
                local na = NearestByTaxi(s.list, sxf(slot, hop), syf(slot, hop))
                local nb = NearestByTaxi(s.list, dxf(slot, hop), dyf(slot, hop))
                a, b = na and na.slot, nb and nb.slot
            end
        end
        if a and b and a ~= b then out[#out + 1] = { a, b } end
    end
    -- Never connect unrelated or partially matched flight points.
    if #out ~= n or not s.currentSlot or out[1][1] ~= s.currentSlot or out[#out][2] ~= slot then return {} end
    for i=2,#out do if out[i-1][2] ~= out[i][1] then return {} end end
    return out
end

-- A client may expose taxi Y from the top or from the bottom. Read the
-- stock buttons in screen space first instead of assuming the old API.
local function RegionScale(region)
    if region.GetEffectiveScale then return region:GetEffectiveScale() end
    local parent = region.GetParent and region:GetParent()
    if parent and parent.GetEffectiveScale then return parent:GetEffectiveScale() end
    return 1
end

local function StockTaxiRect()
    for _, name in ipairs({"TaxiMap", "TaxiFrameInsetBg"}) do
        local region = _G[name]
        if region and region.GetLeft and region.GetTop and region.GetWidth and region.GetHeight then
            local left, top = region:GetLeft(), region:GetTop()
            local width, height = region:GetWidth(), region:GetHeight()
            local scale = RegionScale(region)
            if FiniteNumber(left) and FiniteNumber(top) and FiniteNumber(width) and FiniteNumber(height)
                and width > 1 and height > 1 and FiniteNumber(scale) and scale > 0 then
                return left * scale, top * scale, width * scale, height * scale
            end
        end
    end
end

local function ResolveTaxiLayout(s)
    local left, top, width, height = StockTaxiRect()
    local topVotes, bottomVotes = 0, 0
    for _, e in ipairs(s.list) do
        e.plotX, e.plotY = nil, nil
        if left and FiniteNumber(e.tx) and FiniteNumber(e.ty) then
            local button = _G["TaxiButton" .. e.slot]
            if button and button.GetCenter and (not button.IsShown or button:IsShown())
                and (not button.GetID or button:GetID() == e.slot) then
                local bx, by = button:GetCenter()
                local scale = RegionScale(button)
                if FiniteNumber(bx) and FiniteNumber(by) and FiniteNumber(scale) and scale > 0 then
                    local x, y = (bx * scale - left) / width, (top - by * scale) / height
                    local direct, inverted = abs(y - e.ty), abs(y - (1 - e.ty))
                    if x >= 0 and x <= 1 and y >= 0 and y <= 1
                        and abs(x - e.tx) + min(direct, inverted) < 0.04 then
                        e.plotX, e.plotY = x, y
                        if direct + 0.05 < inverted then topVotes = topVotes + 1
                        elseif inverted + 0.05 < direct then bottomVotes = bottomVotes + 1 end
                    end
                end
            end
        end
    end
    s.flipTaxiY = bottomVotes > topVotes
    s.layoutSource = (topVotes + bottomVotes > 0) and "stock-buttons" or "taxi-api-top"
    for _, e in ipairs(s.list) do
        if not e.plotX and FiniteNumber(e.tx) and FiniteNumber(e.ty)
            and e.tx >= 0 and e.tx <= 1 and e.ty >= 0 and e.ty <= 1 then
            e.plotX = e.tx
            -- The supplied Forever screenshots establish top-origin fallback.
            -- Invert only when the stock UI provides evidence for that client.
            e.plotY = s.flipTaxiY and (1 - e.ty) or e.ty
        end
    end
end

-- 비행 조련사 창이 열렸을 때 모든 정보를 한 번에 읽어 둔다
local function TakeSnapshot()
    local s = { bySlot = {}, list = {} }
    local count = NumTaxiNodes and NumTaxiNodes() or 0
    for i = 1, count do
        local t = NodeTypeOf(i)
        if t ~= "NONE" then
            local tx, ty
            if TaxiNodePosition then tx, ty = TaxiNodePosition(i) end
            local e = {
                slot = i, type = t, tx = tx, ty = ty,
                name = (TaxiNodeName and TaxiNodeName(i)) or "?",
                -- Fare is read below, after GetNumRoutes has prepared the route.
                cost = nil,
            }
            s.bySlot[i] = e
            s.list[#s.list + 1] = e
            if t == "CURRENT" then s.current, s.currentSlot = e.name, e.slot end
        end
    end

    -- Map ID is metadata only. Resolve orientation against the stock UI.
    s.mapID = ContinentMapID()
    if GetTaxiMapID then
        local ok,id = pcall(GetTaxiMapID)
        if ok then s.taxiMapID = id end
    end
    ResolveTaxiLayout(s)
    for _, e in ipairs(s.list) do
        if e.type == "REACHABLE" then e.hops = GetNumRoutes and GetNumRoutes(e.slot) or 0 end
    end
    UpdateTaxiMetadata(s)
    s.speedMultiplier = FlightSpeedMultiplier()
    s.speedKey = tostring(s.taxiMapID or s.mapID or "taxi") .. ":" .. (UnitFactionGroup and UnitFactionGroup("player") or "?")

    -- Prepare each route before reading its fare; don't project the
    -- distorted taxi-map artwork to world yards or estimate time from it.
    for _, e in ipairs(s.list) do
        if e.type == "REACHABLE" then
            e.segs = RouteSlots(e.slot, s)
            e.dist = RouteDistance(e, s)
            e.cost = NativeFare(e)
            local route={"native-taxi-v2", tostring(s.taxiMapID or s.mapID or "taxi"), UnitFactionGroup and UnitFactionGroup("player") or "?", s.current or "?"}
            for _,seg in ipairs(e.segs) do route[#route+1]=s.bySlot[seg[1]].name..">"..s.bySlot[seg[2]].name end
            if #e.segs == 0 then route[#route+1]="unresolved-hops:"..tostring(e.hops) end
            route[#route+1]=e.name
            route[#route+1]="speed:" .. tostring(s.speedMultiplier)
            e.timeKey=table.concat(route," | ")
        end
    end
    return s
end

-- Exact completed routes take priority. Otherwise sum the directed game
-- path lengths and divide by calibrated speed, never taxi-map pixels.
local function FlightTime(e)
    if not (snap and snap.current and e) then return end
    local rec = DB.times[e.timeKey]
    if FiniteNumber(rec) and rec >= 5 and rec <= 3600 then return rec, true end
    if FiniteNumber(e.dist) and e.dist > 0 then
        local speed = DB.flightSpeeds[snap.speedKey]
        if not FiniteNumber(speed) or speed < 8 or speed > 120 then speed = 30.4 end
        local duration = e.dist / (speed * (snap.speedMultiplier or 1))
        if FiniteNumber(duration) and duration > 0 and duration <= 3600 then
            return max(1, floor(duration + 0.5)), false
        end
    end
end

---------------------------------------------------------------------------
-- 비행 중: 남은 시간 막대, 도착 알림, 비행 시간 기록
---------------------------------------------------------------------------
local Bar
local pending

local function SaveBarPosition()
    local p, _, rp, x, y = Bar:GetPoint(1)
    if p then DB.barPoint = { p, rp, x, y } end
end

local function CreateBar()
    if Bar then return end
    Bar = CreateFrame("Frame", "EasyFlightMapBar", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    Bar:SetSize(250, 32)
    Bar:SetFrameStrata("MEDIUM")
    Bar:SetClampedToScreen(true)
    Bar:SetMovable(true)
    Bar:EnableMouse(true)
    Bar:RegisterForDrag("LeftButton")
    Bar:SetScript("OnDragStart", function(self) self:StartMoving() end)
    Bar:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveBarPosition()
    end)
    if Bar.SetBackdrop then
        Bar:SetBackdrop(BACKDROP)
        Bar:SetBackdropColor(0.05, 0.05, 0.07, 0.9)
        Bar:SetBackdropBorderColor(0.75, 0.62, 0.35, 1)
    end
    local icon = Bar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(22, 22)
    icon:SetPoint("LEFT", Bar, "LEFT", 6, 0)
    if icon:SetTexture(ICON_FILE.REACHABLE) == false then icon:SetTexture(ICON_FALLBACK.REACHABLE) end

    local sb = CreateFrame("StatusBar", nil, Bar)
    sb:SetPoint("TOPLEFT", Bar, "TOPLEFT", 32, -7)
    sb:SetPoint("BOTTOMRIGHT", Bar, "BOTTOMRIGHT", -7, 7)
    sb:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    sb:SetStatusBarColor(0.86, 0.64, 0.2)
    sb:SetMinMaxValues(0, 1)
    local sbg = sb:CreateTexture(nil, "BACKGROUND")
    sbg:SetAllPoints()
    sbg:SetColorTexture(0, 0, 0, 0.55)
    Bar.status = sb

    Bar.dest = sb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    Bar.dest:SetPoint("LEFT", sb, "LEFT", 5, 0)
    Bar.dest:SetJustifyH("LEFT")
    Bar.time = sb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    Bar.time:SetPoint("RIGHT", sb, "RIGHT", -5, 0)
    Bar.time:SetJustifyH("RIGHT")

    Bar:ClearAllPoints()
    local pt = DB.barPoint
    if type(pt) == "table" and pt[1] then
        Bar:SetPoint(pt[1], UIParent, pt[2] or pt[1], pt[3] or 0, pt[4] or 0)
    else
        Bar:SetPoint("TOP", UIParent, "TOP", 0, -140)
    end
    Bar:Hide()
end

local function UpdateBar(now)
    if not (Bar and pending and pending.start) then return end
    local elapsed = now - pending.start
    if pending.total and pending.total > 0 then
        local remain = pending.total - elapsed
        Bar.status:SetValue(min(1, elapsed / pending.total))
        if remain <= 0 then
            Bar.time:SetText(L.BAR_SOON)
        elseif pending.recorded then
            Bar.time:SetText(FormatClock(remain))
        else
            Bar.time:SetText(L.APPROX:format(FormatClock(remain)))
        end
    else
        Bar.status:SetValue(1)
        Bar.time:SetText(FormatClock(elapsed))
    end
end

local function ShowBar()
    if not (DB.flightBar and pending) then return end
    CreateBar()
    Bar.dest:SetText(ShortName(pending.dest))
    Bar.status:SetValue(0)
    Bar:Show()
    UpdateBar(pending.start or GetTime())
end

local function HideBar()
    if Bar then Bar:Hide() end
end

local function ArrivalAlert()
    if not DB.arrivalAlert then return end
    if PlaySound then
        local id = (SOUNDKIT and SOUNDKIT.READY_CHECK) or 8960
        pcall(PlaySound, id, "Master")
    end
    if FlashClientIcon then pcall(FlashClientIcon) end
end

local watcher = CreateFrame("Frame")
watcher:Hide()
local acc = 0
watcher:SetScript("OnUpdate", function(self, elapsed)
    acc = acc + (elapsed or 0)
    if acc < 0.1 then return end
    acc = 0
    if not pending then
        HideBar()
        self:Hide()
        return
    end
    local now = GetTime()
    local onTaxi = UnitOnTaxi("player")
    if not pending.start then
        if onTaxi then
            pending.start = now
            ShowBar()
        elseif now - pending.t0 > 15 then
            pending = nil
            self:Hide()
        end
    elseif onTaxi then
        UpdateBar(now)
    else
        local dur = now - pending.start
        local arrived=not pending.earlyLanding
        if arrived and pending.mapID and pending.mx and C_Map and C_Map.GetPlayerMapPosition then
            local ok,pos=pcall(C_Map.GetPlayerMapPosition,pending.mapID,"player")
            if ok and pos then
                local x,y=PosXY(pos)
                if x and y then arrived=(x-pending.mx)^2+(y-pending.my)^2<=0.02^2 end
            end
        end
        if arrived and dur >= 5 and dur <= 3600 and DB then
            local new = floor(dur + 0.5)
            local old = DB.times[pending.key]
            DB.times[pending.key] = new
            if pending.dist and pending.dist > 0 then
                DB.calib.t = DB.calib.t + dur
                DB.calib.d = DB.calib.d + pending.dist
                local measured = pending.dist / dur / (pending.speedMultiplier or 1)
                local previous = DB.flightSpeeds[pending.speedKey]
                if not FiniteNumber(previous) or previous < 8 or previous > 120 then previous = nil end
                if measured >= 8 and measured <= 120 and
                    (not FiniteNumber(previous) or (measured >= previous * .75 and measured <= previous * 1.33)) then
                    DB.flightSpeeds[pending.speedKey] = FiniteNumber(previous) and
                        (previous * .75 + measured * .25) or measured
                end
            end
            if not old or abs(old - new) >= 3 then
                Print(L.MSG_RECORDED:format(ShortName(pending.dest), FormatTime(dur)))
            end
            ArrivalAlert()
        end
        pending = nil
        HideBar()
        self:Hide()
    end
end)

if hooksecurefunc and TakeTaxiNode then
    hooksecurefunc("TakeTaxiNode", function(slot)
        local e = snap and snap.bySlot[slot]
        if not (e and e.type == "REACHABLE" and snap.current and GetTime and UnitOnTaxi) then return end
        local total, recorded = FlightTime(e)
        pending = {
            key = e.timeKey, dest = e.name, dist = e.dist,
            mapID=snap.mapID,mx=e.mx,my=e.my,
            speedKey=snap.speedKey, speedMultiplier=snap.speedMultiplier,
            total = total, recorded = recorded, t0 = GetTime(),
        }
        acc = 0
        watcher:Show()
    end)
end

if hooksecurefunc and TaxiRequestEarlyLanding then
    hooksecurefunc("TaxiRequestEarlyLanding", function()
        if pending then pending.earlyLanding = true end
    end)
end

---------------------------------------------------------------------------
-- 지도 그림
---------------------------------------------------------------------------
local taxiArtProbe
local function TaxiArt()
    local w, h = TAXI_MAP_WIDTH or 316, TAXI_MAP_HEIGHT or 352
    local file, l, t, r, b
    local tm = _G.TaxiMap
    if tm and tm.GetTexture then
        file = tm:GetTexture()
        if tm.GetSize then
            local sw, sh = tm:GetSize()
            if sw and sw > 0 and sh and sh > 0 then w, h = sw, sh end
        end
        if file and tm.GetTexCoord then
            local ulx, uly, _, _, _, _, lrx, lry = tm:GetTexCoord()
            if ulx and lrx then l, t, r, b = ulx, uly, lrx, lry end
        end
    end
    if not file and SetTaxiMap then
        if not taxiArtProbe then
            local frame = CreateFrame("Frame", nil, UIParent)
            frame:Hide()
            taxiArtProbe = frame:CreateTexture(nil, "BACKGROUND")
        end
        SetTaxiMap(taxiArtProbe)
        file = taxiArtProbe:GetTexture()
        if file and taxiArtProbe.GetTexCoord then
            local ulx, uly, _, _, _, _, lrx, lry = taxiArtProbe:GetTexCoord()
            l,t,r,b = ulx,uly,lrx,lry
        end
    end
    local tile = { x0 = 0, y0 = 0, x1 = w, y1 = h, u0 = l or 0, u1 = r or 1, v0 = t or 0, v1 = b or 1 }
    if file then
        tile.file = file
    else
        return
    end
    return { w = w, h = h, tiles = { tile } }
end

---------------------------------------------------------------------------
-- 기본 비행 창 숨기기 / 되돌리기
---------------------------------------------------------------------------
local function DisableMouseTree(f, store)
    if f.IsProtected and f:IsProtected() then return end
    if f.IsMouseEnabled and f:IsMouseEnabled() then
        store[f] = true
        f:EnableMouse(false)
    end
    if f.GetChildren then
        for _, c in ipairs({ f:GetChildren() }) do
            DisableMouseTree(c, store)
        end
    end
end

local function HideBlizzard()
    for _, name in ipairs(BLIZZARD_FRAMES) do
        local f = _G[name]
        if f and f:IsShown() and not hidden[f] then
            local saved = { mouse = {}, alpha = f:GetAlpha() }
            hidden[f] = saved
            f:SetAlpha(0)
            DisableMouseTree(f, saved.mouse)
        end
    end
end

local function RestoreBlizzard()
    for f, saved in pairs(hidden) do
        for c in pairs(saved.mouse) do
            if not (c.IsProtected and c:IsProtected()) then c:EnableMouse(true) end
        end
        f:SetAlpha(saved.alpha)
        hidden[f] = nil
    end
end

---------------------------------------------------------------------------
-- 그리기
---------------------------------------------------------------------------
-- 지도 좌표 -> 창 안 좌표 (오른쪽 +, 아래쪽 +)
local function ToView(nx, ny)
    return (nx * cur.W - cur.cx0) * cur.s, (ny * cur.H - cur.cy0) * cur.s
end

local function Visible(node)
    -- Obsolete client rows are still retained in the route graph. Hide only
    -- unavailable zzOLD destinations; a live flight must remain usable.
    if node.type == "DISTANT" and type(node.name) == "string" and node.name:lower():match("^%s*zzold") then return false end
    return node.x and (node.type ~= "DISTANT" or DB.showUnreachable)
end

local function ComputeCrop(W, H, nodes)
    if not DB.crop or not nodes then return 0, 0, W, H end
    local huge = math.huge
    local minX, minY, maxX, maxY = huge, huge, -huge, -huge
    for _, n in ipairs(nodes) do
        if Visible(n) then
            local px, py = n.x * W, n.y * H
            minX, maxX = min(minX, px), max(maxX, px)
            minY, maxY = min(minY, py), max(maxY, py)
        end
    end
    if minX == huge then return 0, 0, W, H end
    local m = max(W, H) * 0.05
    local mx = DB.labels and (m + 70) or m
    local function fit(a, b, minLen, total)
        if b - a < minLen then
            local c = (a + b) / 2
            a, b = c - minLen / 2, c + minLen / 2
        end
        if a < 0 then b, a = b - a, 0 end
        if b > total then a, b = a - (b - total), total end
        if a < 0 then a = 0 end
        return a, b
    end
    local x0, x1 = fit(minX - mx, maxX + mx, W * (DB.labels and 0.5 or 0.35), W)
    local y0, y1 = fit(minY - m, maxY + m, H * 0.45, H)
    return x0, y0, x1, y1
end

-- Labels use buttons so hovering the name, fare or time selects the same node.
local function StyleLabel(lb, selected)
    if not lb then return end
    local kind = lb.node and lb.node.type
    local dimmed = hover.pin and not selected
    lb.frame:SetAlpha(dimmed and 0.48 or 1)
    if lb.leader then
        lb.leader:SetThickness(selected and 3 or 1)
        lb.leader:SetColorTexture(1, 0.86, 0.44, selected and 1 or (dimmed and 0.07 or 0.22))
    end
    lb.info:SetTextColor(selected and 1 or 0.85, selected and 0.96 or 0.86, selected and 0.84 or 0.88)
    if lb.region then lb.region:SetTextColor(selected and 0.95 or 0.57, selected and 0.88 or 0.62, selected and 0.66 or 0.68) end
    lb.accent:SetWidth(selected and 4 or 2)
    if selected then
        lb.frame:SetBackdropColor(0.20, 0.12, 0.025, 1)
        lb.frame:SetBackdropBorderColor(1, 0.90, 0.46, 1)
        lb.accent:SetColorTexture(1, 0.79, 0.34, 1)
        lb.name:SetTextColor(1, 0.92, 0.69)
    else
        lb.frame:SetBackdropColor(0.025, 0.04, 0.065, kind == "DISTANT" and 0.70 or 0.86)
        lb.frame:SetBackdropBorderColor(0.42, 0.36, 0.22, kind == "DISTANT" and 0.3 or 0.6)
        if kind == "CURRENT" then
            lb.accent:SetColorTexture(0.35, 0.86, 0.52, 0.95)
            lb.name:SetTextColor(0.55, 1, 0.65)
        elseif kind == "DISTANT" then
            lb.accent:SetColorTexture(0.40, 0.45, 0.51, 0.60)
            lb.name:SetTextColor(0.66, 0.69, 0.73)
        else
            lb.accent:SetColorTexture(0.86, 0.66, 0.32, 0.95)
            lb.name:SetTextColor(1, 0.82, 0.2)
        end
    end
end

local function HideLines()
    for _, ln in ipairs(linePool) do ln.glow:Hide(); ln.core:Hide() end
    if HoverLayer and HoverLayer.sparks then
        for _, spark in ipairs(HoverLayer.sparks) do spark:Hide() end
    end
    hover.segments, hover.total = {}, 0
end

local function ClearHover()
    local pin = hover.pin
    hover.pin, hover.source = nil, nil
    if pin then
        pin.ring:Hide()
        pin.glow:Hide()
        pin.icon:ClearAllPoints()
        pin.icon:SetPoint("CENTER")
        pin.icon:SetSize(pin.baseSize or PIN_SIZE, pin.baseSize or PIN_SIZE)
    end
    for _,lb in ipairs(labelPool) do StyleLabel(lb,false) end
    for _,p in ipairs(pinPool) do
        if p.node then
            p:SetAlpha(p.node.type=="DISTANT" and 0.8 or 1)
            if Viewport then p:SetFrameLevel(Viewport:GetFrameLevel()+(p.node.type=="CURRENT" and 8 or (p.node.type=="DISTANT" and 5 or 6))) end
        end
    end
    HideLines()
    if HoverLayer then
        HoverLayer:SetScript("OnUpdate", nil)
        HoverLayer:Hide()
    end
    if GameTooltip and GameTooltip:GetOwner() == (pin and pin.tooltipOwner) then GameTooltip:Hide() end
end

local function AcquireLine(i)
    local ln = linePool[i]
    if not ln then
        if not HoverLayer.CreateLine then return end
        ln = { glow = HoverLayer:CreateLine(nil, "ARTWORK", nil, -1),
               core = HoverLayer:CreateLine(nil, "ARTWORK", nil, 0) }
        ln.glow:SetThickness(11)
        ln.glow:SetColorTexture(1, 0.60, 0.12, 0.34)
        ln.core:SetThickness(3)
        ln.core:SetColorTexture(1, 0.90, 0.50, 1)
        linePool[i] = ln
    end
    return ln
end

local function DrawRoute(node)
    HideLines()
    if node.type ~= "REACHABLE" or not node.segs then return end
    local used = 0
    for _, seg in ipairs(node.segs) do
        local a, b = cur.bySlot[seg[1]], cur.bySlot[seg[2]]
        if a and b and a.x and b.x then
            local x1, y1 = ToView(a.x, a.y)
            local x2, y2 = ToView(b.x, b.y)
            local length = sqrt((x2 - x1)^2 + (y2 - y1)^2)
            if length > 0.01 then
                used = used + 1
                hover.segments[used] = { x1=x1, y1=y1, x2=x2, y2=y2, length=length }
                hover.total = hover.total + length
                local ln = AcquireLine(used)
                if ln then
                    for _, part in ipairs({ln.glow, ln.core}) do
                        part:SetStartPoint("TOPLEFT", Viewport, x1, -y1)
                        part:SetEndPoint("TOPLEFT", Viewport, x2, -y2)
                        part:Show()
                    end
                end
            end
        end
    end
end

-- The distance follows the actual hop segments supplied by the client.
local function RoutePoint(distance)
    for _, seg in ipairs(hover.segments) do
        if distance <= seg.length then
            local u = distance / seg.length
            return seg.x1 + (seg.x2-seg.x1)*u, seg.y1 + (seg.y2-seg.y1)*u
        end
        distance = distance - seg.length
    end
end

local function UpdateHover(_, dt)
    local pin = hover.pin
    if not (pin and pin.node and pin:IsShown() and cur.open) then ClearHover(); return end
    hover.elapsed = (hover.elapsed or 0) + min(dt or 0, 0.1)
    local t = hover.elapsed
    local pulse = (math.sin(t * 3.2) + 1) / 2
    local ringSize = (pin.baseSize or PIN_SIZE) + 25 + pulse * 8
    pin.ring:SetSize(ringSize, ringSize)
    pin.ring:SetAlpha(0.88 + pulse * 0.12)
    pin.glow:SetAlpha(0.25 + pulse * 0.15)
    if pin.ring.SetRotation then pin.ring:SetRotation(t * 0.30) end
    local grow = 1 + 0.28 * min(1, t / 0.14)
    pin.icon:SetSize(pin.baseSize * grow, pin.baseSize * grow)
    for i, spark in ipairs(HoverLayer.sparks) do
        if hover.total > 0 then
            local distance = (t * 110 + (i-1) * hover.total / 3) % hover.total
            local x, y = RoutePoint(distance)
            if x then
                spark:ClearAllPoints()
                spark:SetPoint("CENTER", Viewport, "TOPLEFT", x, -y)
                spark:SetAlpha(i == 1 and 0.95 or 0.65)
                spark:Show()
            else spark:Hide() end
        else spark:Hide() end
    end
end

local function Pin_OnEnter(self)
    local pin = self.pin or self
    local node = pin.node
    if not (node and cur.open and HoverLayer) then return end
    if TaxiNodeName and TaxiNodeName(node.slot) ~= node.name then ClearHover(); return end
    if node.type == "REACHABLE" then
        if snap then UpdateTaxiMetadata(snap) end
        node.cost = NativeFare(node)
        if RefreshFareLabel then RefreshFareLabel(pin) end
    end
    if hover.pin ~= pin then
        ClearHover()
        hover.pin, hover.elapsed = pin, 0
        for _,lb in ipairs(labelPool) do StyleLabel(lb,lb.pin==pin) end
        for _,p in ipairs(pinPool) do if p.node then p:SetAlpha(p==pin and 1 or 0.5) end end
        pin:SetFrameLevel(Viewport:GetFrameLevel()+12)
        local r, g, b = 1, 0.79, 0.31
        if node.type == "CURRENT" then r,g,b = 0.42,1,0.63
        elseif node.type ~= "REACHABLE" then r,g,b = 0.64,0.72,0.82 end
        pin.ring:SetVertexColor(r,g,b)
        pin.glow:SetVertexColor(r,g,b)
        pin.ring:Show(); pin.glow:Show()
        DrawRoute(node)
        HoverLayer:SetScript("OnUpdate", UpdateHover)
        HoverLayer:Show()
        UpdateHover(HoverLayer, 0)
    end
    hover.source, pin.tooltipOwner = self, self
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(node.name, 1, 0.90, 0.63)
    if node.type == "CURRENT" then
        GameTooltip:AddLine(L.CURRENT, 0.4, 1, 0.6)
    elseif node.type == "REACHABLE" then
        GameTooltip:AddLine(CoinText(node.cost, 12), 1, 1, 1)
        local sec, recorded = FlightTime(node)
        if sec then
            if recorded then GameTooltip:AddLine(L.TT_TIME:format(FormatTime(sec)), 1, 1, 1)
            else
                GameTooltip:AddLine(L.TT_EST:format(FormatTime(sec, true)), 0.86, 0.84, 0.75)
                GameTooltip:AddLine(L.TT_EST_NOTE, 0.6, 0.6, 0.6)
            end
        else
            GameTooltip:AddLine(L.TIME .. ": " .. L.TIME_UNKNOWN, 0.8, 0.8, 0.8)
            GameTooltip:AddLine(L.TT_EST_NOTE, 0.6, 0.6, 0.6)
        end
        if node.hops and node.hops > 1 then GameTooltip:AddLine(L.STOPS:format(node.hops - 1), 0.8, 0.8, 0.8) end
        GameTooltip:AddLine(L.CLICK, 0.4, 0.8, 1)
    else GameTooltip:AddLine(FlightPathStatus(node), 0.6, 0.6, 0.6) end
    GameTooltip:Show()
end

local function Pin_OnLeave(self)
    if hover.source == self then ClearHover() end
end

local FlightConfirm
local function CanFly(node)
    return cur.open and node and node.type == "REACHABLE" and TakeTaxiNode
        and (not TaxiNodeGetType or TaxiNodeGetType(node.slot)=="REACHABLE")
        and (not TaxiNodeName or TaxiNodeName(node.slot)==node.name)
end
local function ConfirmDetails(node,fare)
    local sec,recorded=FlightTime(node)
    return node.name .. "\n\n" .. CoinText(fare,12) .. "   " .. L.TIME .. " " .. (sec and FormatTime(sec,not recorded) or L.TIME_UNKNOWN)
end
local function ShowFlightConfirm(node)
    if not FlightConfirm then
        local f=CreateFrame("Frame","EasyFlightMapConfirm",UIParent,BackdropTemplateMixin and "BackdropTemplate" or nil)
        f:SetSize(380,200);f:SetPoint("CENTER",UIParent,"CENTER",0,0)
        f:SetFrameStrata("FULLSCREEN_DIALOG");f:EnableMouse(true);f:SetClampedToScreen(true)
        f:SetBackdrop(BACKDROP);f:SetBackdropColor(.035,.045,.06,1);f:SetBackdropBorderColor(1,.82,.3,1)
        f.title=f:CreateFontString(nil,"OVERLAY","GameFontNormal")
        f.title:SetPoint("TOP",f,"TOP",0,-16);f.title:SetText(L.CONFIRM_TITLE)
        f.details=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        f.details:SetPoint("TOP",f,"TOP",0,-43);f.details:SetWidth(350)
        f.notice=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        f.notice:SetPoint("BOTTOM",f,"BOTTOM",0,52);f.notice:SetWidth(350);f.notice:SetTextColor(1,.7,.2)
        f.accept=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
        f.accept:SetSize(120,24);f.accept:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",50,16);f.accept:SetText(L.CONFIRM_FLY)
        f.cancel=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
        f.cancel:SetSize(120,24);f.cancel:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-50,16);f.cancel:SetText(L.CONFIRM_CANCEL)
        f.cancel:SetScript("OnClick",function() f:Hide() end)
        f.accept:SetScript("OnClick",function()
            local request=f.request
            if not request then return end
            if not CanFly(request.node) or cur.generation~=request.generation or snap~=request.snapshot then f:Hide();return end
            if snap then UpdateTaxiMetadata(snap) end
            local fare=NativeFare(request.node)
            if fare~=request.fare then
                request.fare=fare;f.details:SetText(ConfirmDetails(request.node,fare));f.notice:SetText(L.CONFIRM_CHANGED)
                return
            end
            f:Hide();TakeTaxiNode(request.node.slot)
        end)
        f:SetScript("OnHide",function() f.request=nil end)
        FlightConfirm=f
    end
    if snap then UpdateTaxiMetadata(snap) end
    local fare=NativeFare(node)
    FlightConfirm.request={node=node,fare=fare,generation=cur.generation,snapshot=snap}
    FlightConfirm.details:SetText(ConfirmDetails(node,fare));FlightConfirm.notice:SetText("")
    FlightConfirm:Show()
end
local function Pin_OnClick(self)
    local node = (self.pin or self).node
    if CanFly(node) then
        if DB and DB.confirmFlight then ShowFlightConfirm(node) else TakeTaxiNode(node.slot) end
    end
end

local function CreatePin()
    local b = CreateFrame("Button", nil, Viewport)
    b:SetSize(PIN_SIZE, PIN_SIZE)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("CENTER")
    b.icon:SetSize(PIN_SIZE, PIN_SIZE)
    b.baseSize = PIN_SIZE
    b.glow = b:CreateTexture(nil, "BACKGROUND")
    b.glow:SetTexture(GLOW_FILE)
    b.glow:SetBlendMode("ADD")
    b.glow:SetPoint("CENTER")
    b.glow:SetSize(52, 52)
    b.glow:Hide()
    b.ring = b:CreateTexture(nil, "OVERLAY")
    if b.ring:SetTexture(RING_FILE) == false then b.ring:SetTexture(GLOW_FILE) end
    b.ring:SetBlendMode("ADD")
    b.ring:SetPoint("CENTER")
    b.ring:SetSize(43, 43)
    b.ring:Hide()
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    if hl:SetTexture(GLOW_FILE) == false then hl:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Highlight") end
    hl:SetBlendMode("ADD")
    hl:SetPoint("CENTER")
    b.hl = hl
    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", Pin_OnClick)
    b:SetScript("OnEnter", Pin_OnEnter)
    b:SetScript("OnLeave", Pin_OnLeave)
    b:SetScript("OnHide", function(self)
        if hover.pin == self then ClearHover() end
    end)
    return b
end

local function SetPinIcon(pin, kind)
    if pin.icon:SetTexture(ICON_FILE[kind] or ICON_FILE.REACHABLE) ~= false then return end
    if pin.icon:SetTexture(ICON_FALLBACK[kind] or ICON_FALLBACK.REACHABLE) ~= false then return end
    local c = ICON_COLOR[kind] or ICON_COLOR.REACHABLE
    pin.icon:SetColorTexture(c[1], c[2], c[3], 1)
end

---------------------------------------------------------------------------
-- 이름·요금·시간 글씨
---------------------------------------------------------------------------
local LABEL_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1, insets = {left=1, right=1, top=1, bottom=1},
}
local function CreateLabel()
    local lb = {}
    lb.frame = CreateFrame("Button", nil, LabelLayer, BackdropTemplateMixin and "BackdropTemplate" or nil)
    lb.frame:SetBackdrop(LABEL_BACKDROP)
    lb.frame:RegisterForClicks("LeftButtonUp")
    lb.frame:SetScript("OnEnter", Pin_OnEnter)
    lb.frame:SetScript("OnLeave", Pin_OnLeave)
    lb.frame:SetScript("OnClick", Pin_OnClick)
    lb.frame:SetScript("OnHide", Pin_OnLeave)
    lb.accent = lb.frame:CreateTexture(nil, "ARTWORK")
    lb.accent:SetPoint("TOPLEFT", 1, -1)
    lb.accent:SetPoint("BOTTOMLEFT", 1, 1)
    lb.accent:SetWidth(2)
    lb.name = lb.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lb.name:SetJustifyH("LEFT")
    lb.name:SetShadowOffset(1, -1)
    lb.region = lb.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lb.region:SetJustifyH("LEFT")
    lb.region:SetTextColor(0.57, 0.62, 0.68)
    lb.region:SetShadowOffset(1, -1)
    lb.info = lb.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lb.info:SetJustifyH("LEFT")
    lb.info:SetTextColor(0.85, 0.86, 0.88)
    lb.info:SetShadowOffset(1, -1)
    if LabelLayer.CreateLine then
        lb.leader = LabelLayer:CreateLine(nil, "ARTWORK")
        lb.leader:SetThickness(1)
        lb.leader:Hide()
    end
    return lb
end

local function HideLabel(lb)
    lb.frame:Hide()
    lb.info:Hide()
    lb.region:Hide()
    if lb.leader then lb.leader:Hide() end
    if lb.pin then lb.pin.label = nil end
    lb.pin, lb.node, lb.frame.pin = nil, nil, nil
end

local function DestinationInfo(node, size)
    if node.type == "CURRENT" then return L.CURRENT end
    if node.type ~= "REACHABLE" then return FlightPathStatus(node) end
    local sec, recorded = FlightTime(node)
    local time = sec and FormatTime(sec, not recorded) or L.TIME_UNKNOWN
    return CoinText(node.cost, size) .. "   " .. L.TIME .. " " .. time
end

RefreshFareLabel = function(pin)
    local lb = pin.label
    if not lb or not lb.node then return end
    lb.info:SetText(DestinationInfo(lb.node, lb.fontSize or DB.labelSize or 12))
end

local function SplitDestinationName(name)
    name = name or "?"
    local destination, region = name:match("^(.-)%s*%((.-)%)%s*$")
    if not destination then destination, region = name:match("^([^,]+),%s*(.+)$") end
    if not destination then destination, region = name:match("^(.-)%s*·%s*(.+)$") end
    return destination or name, region or ""
end

local function RectOverlap(ax,ay,aw,ah,bx,by,bw,bh)
    local w,h=min(ax+aw,bx+bw)-max(ax,bx),min(ay+ah,by+bh)-max(ay,by)
    return w>0 and h>0 and w*h or 0
end

local function RenderLabels(shown)
    for _,lb in ipairs(labelPool) do HideLabel(lb) end
    if not DB.labels then return end
    local vw,vh=Viewport:GetSize()
    local order={}
    for _,item in ipairs(shown) do order[#order+1]=item end
    table.sort(order,function(a,b)
        if a.py~=b.py then return a.py<b.py end
        return a.node.slot<b.node.slot
    end)
    local size=DB.labelSize or 12
    while size>8 and #shown*(size*16+16)*(size*3+10)>vw*vh*.55 do size=size-1 end
    local placed={}
    for i,item in ipairs(order) do
        local lb=labelPool[i]
        if not lb then lb=CreateLabel();labelPool[i]=lb end
        local node=item.node
        lb.pin,lb.node,lb.frame.pin=item.pin,node,item.pin
        lb.fontSize=size;item.pin.label=lb
        SetFontSize(lb.name,size);SetFontSize(lb.region,max(8,size-2));SetFontSize(lb.info,size)
        local destination,region=SplitDestinationName(node.name)
        lb.name:SetText(destination);lb.region:SetText(region);lb.info:SetText(DestinationInfo(node,size))
        for _,fs in ipairs({lb.name,lb.region,lb.info}) do fs:SetWidth(0) end
        local w=min(max(lb.name:GetStringWidth(),lb.region:GetStringWidth(),lb.info:GetStringWidth())+16,vw*.42)
        local h=size*3+10
        local px,py,r=item.px,item.py,item.r+16
        local bestX,bestY,bestScore
        local function consider(x,y)
            x=min(max(x,0),max(0,vw-w));y=min(max(y,0),max(0,vh-h))
            local ex,ey=min(max(px,x),x+w),min(max(py,y),y+h)
            local dx,dy=ex-px,ey-py
            local score=dx*dx+dy*dy*1.3
            if (px<vw/2 and x+w<px) or (px>=vw/2 and x>px) then score=score+80 end
            if bestScore and score>=bestScore then return end
            -- Pin clearance is a hard constraint, including other destinations.
            for _,other in ipairs(shown) do
                local radius=other.r+14
                if RectOverlap(x,y,w,h,other.px-radius,other.py-radius,radius*2,radius*2)>0 then return end
            end
            for _,p in ipairs(placed) do score=score+250*RectOverlap(x-2,y-2,w+4,h+4,p[1],p[2],p[3],p[4]) end
            if not bestScore or score<bestScore then bestX,bestY,bestScore=x,y,score end
        end
        -- The same horizontal and vertical offsets are tried for every pin.
        for _,dy in ipairs({0,-h-4,h+4,-2*(h+4),2*(h+4)}) do
            consider(px+r,py-h/2+dy);consider(px-r-w,py-h/2+dy)
        end
        consider(px-w/2,py-r-h);consider(px-w/2,py+r)
        -- Search only point-free rectangles, never trading a hidden pin for
        -- a smaller distance. The fallback is deterministic on every render.
        for y=0,max(0,vh-h),12 do
            for x=0,max(0,vw-w),16 do consider(x,y) end
            consider(vw-w,y)
        end
        for x=0,max(0,vw-w),16 do consider(x,vh-h) end
        if bestX then
            placed[#placed+1]={bestX,bestY,w,h}
            lb.layoutX,lb.layoutY=bestX,bestY
            lb.frame:ClearAllPoints();lb.frame:SetPoint("TOPLEFT",LabelLayer,"TOPLEFT",bestX,-bestY)
            lb.frame:SetSize(w,h);lb.frame:SetFrameLevel(LabelLayer:GetFrameLevel()+1)
            for _,fs in ipairs({lb.name,lb.region,lb.info}) do
                fs:SetWidth(w-16)
                if fs.SetWordWrap then fs:SetWordWrap(false) end
                if fs.SetMaxLines then fs:SetMaxLines(1) end
                fs:ClearAllPoints()
            end
            lb.name:SetPoint("TOPLEFT",lb.frame,"TOPLEFT",8,-4)
            lb.region:SetPoint("TOPLEFT",lb.frame,"TOPLEFT",8,-(size+6))
            lb.info:SetPoint("TOPLEFT",lb.frame,"TOPLEFT",8,-(size*2+7))
            if lb.leader then
                local ex,ey=min(max(px,bestX),bestX+w),min(max(py,bestY),bestY+h)
                local dx,dy=ex-px,ey-py
                local distance=sqrt(dx*dx+dy*dy)
                lb.leader:SetStartPoint("TOPLEFT",Viewport,px+dx*(item.r+3)/distance,-(py+dy*(item.r+3)/distance))
                lb.leader:SetEndPoint("TOPLEFT",Viewport,ex,-ey);lb.leader:Show()
            end
            StyleLabel(lb,false);lb.region:Show();lb.info:Show();lb.frame:Show()
        else
            -- No pin may be covered, even on an exceptionally crowded map.
            -- Its complete destination information is still available on hover.
            HideLabel(lb)
        end
    end
end

local function ApplyAlpha()
    if Main then Main:SetAlpha(DB.alpha or 1) end
end

local function Render()
    local art, nodes = cur.art, cur.nodes
    if not art or not nodes then return end
    ClearHover()
    local W, H = art.w, art.h
    local x0, y0, x1, y1 = ComputeCrop(W, H, nodes)
    local cw, ch = x1 - x0, y1 - y0
    local uw, uh = UIParent:GetWidth(), UIParent:GetHeight()
    local maxHeight=uh*.95-TITLE_H-FOOT_H
    local s=(uh*.78*DB.scale)/ch
    s=min(s,(uw*.92-2*PAD)/cw,maxHeight/ch)
    cur.s,cur.cx0,cur.cy0,cur.W,cur.H=s,x0,y0,W,H
    local vw,vh=cw*s,ch*s
    Viewport:ClearAllPoints();Viewport:SetPoint("TOP",Main,"TOP",0,-TITLE_H)
    Viewport:SetSize(vw,vh)
    LabelLayer:ClearAllPoints();LabelLayer:SetPoint("TOPLEFT",Viewport,"TOPLEFT",0,0)
    LabelLayer:SetSize(vw,vh)
    Main:SetSize(max(vw+2*PAD,MIN_WIDTH),vh+TITLE_H+FOOT_H);Main:SetScale(1)
    ApplyAlpha()

    -- 지도 그림 (보이는 부분만 잘라서)
    for _, t in ipairs(tilePool) do t:Hide() end
    local used = 0
    for _, tile in ipairs(art.tiles) do
        local ix0, iy0 = max(tile.x0, x0), max(tile.y0, y0)
        local ix1, iy1 = min(tile.x1, x1, W), min(tile.y1, y1, H)
        if ix1 > ix0 and iy1 > iy0 then
            used = used + 1
            local tex = tilePool[used]
            if not tex then
                tex = Viewport:CreateTexture(nil, "BACKGROUND", nil, 1)
                tilePool[used] = tex
            end
            if tile.taxi then SetTaxiMap(tex) else tex:SetTexture(tile.file) end
            local tw, th = tile.x1 - tile.x0, tile.y1 - tile.y0
            local du, dv = tile.u1 - tile.u0, tile.v1 - tile.v0
            tex:SetTexCoord(
                tile.u0 + du * (ix0 - tile.x0) / tw, tile.u0 + du * (ix1 - tile.x0) / tw,
                tile.v0 + dv * (iy0 - tile.y0) / th, tile.v0 + dv * (iy1 - tile.y0) / th)
            tex:ClearAllPoints()
            tex:SetPoint("TOPLEFT", Viewport, "TOPLEFT", (ix0 - x0) * s, -(iy0 - y0) * s)
            tex:SetSize((ix1 - ix0) * s, (iy1 - iy0) * s)
            tex:Show()
        end
    end

    -- 비행 지점
    for _, p in ipairs(pinPool) do p:Hide(); p.node = nil end
    local shown = {}
    local k = 0
    local baseLevel = Viewport:GetFrameLevel()
    LabelLayer:SetFrameLevel(baseLevel + 3)
    HoverLayer:SetFrameLevel(baseLevel + 2)
    for _, node in ipairs(nodes) do
        if Visible(node) then
            k = k + 1
            local pin = pinPool[k]
            if not pin then
                pin = CreatePin()
                pinPool[k] = pin
            end
            pin.node = node
            local size = (node.type == "CURRENT") and PIN_SIZE_CURRENT or PIN_SIZE
            pin:SetSize(size, size)
            pin.baseSize = size
            pin.icon:SetSize(size, size)
            pin.hl:SetSize(size * 1.9, size * 1.9)
            SetPinIcon(pin, node.type)
            local distant = (node.type == "DISTANT")
            pin:SetAlpha(distant and 0.8 or 1)
            pin:SetFrameLevel(baseLevel + ((node.type == "CURRENT") and 8 or (distant and 5 or 6)))
            local px, py = ToView(node.x, node.y)
            pin:ClearAllPoints()
            pin:SetPoint("CENTER", Viewport, "TOPLEFT", px, -py)
            pin:Show()
            shown[#shown + 1] = { pin = pin, node = node, px = px, py = py, r = size / 2 }
        end
    end
    RenderLabels(shown)
    HideLines()
end

---------------------------------------------------------------------------
-- 창 만들기
---------------------------------------------------------------------------
local function SavePosition()
    local p, _, rp, x, y = Main:GetPoint(1)
    if p then DB.point = { p, rp, x, y } end
end

local function ApplyPosition()
    Main:ClearAllPoints()
    local pt = DB.point
    if type(pt) == "table" and pt[1] then
        Main:SetPoint(pt[1], UIParent, pt[2] or pt[1], pt[3] or 0, pt[4] or 0)
    else
        Main:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

local function CloseAll()
    if CloseTaxiMap then CloseTaxiMap() end
    local tf = _G.TaxiFrame
    if tf and tf:IsShown() and HideUIPanel then HideUIPanel(tf) end
    if Main then Main:Hide() end
    RestoreBlizzard()
end

local function CreateUI()
    if Main then return end

    Main = CreateFrame("Frame", "EasyFlightMapFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    Main:Hide()
    Main:SetFrameStrata("HIGH")
    Main:SetToplevel(true)
    Main:SetClampedToScreen(true)
    Main:SetMovable(true)
    Main:EnableMouse(true)
    Main:RegisterForDrag("LeftButton")
    Main:SetScript("OnDragStart", function(self) self:StartMoving() end)
    Main:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    Main:SetScript("OnHide", function()
        CloseSettingsPopup()
        ClearHover()
        if FlightConfirm then FlightConfirm:Hide() end
        if GameTooltip:IsShown() then GameTooltip:Hide() end
    end)
    if Main.SetBackdrop then
        Main:SetBackdrop(BACKDROP)
        Main:SetBackdropColor(0.05, 0.05, 0.07, 0.95)
        Main:SetBackdropBorderColor(0.75, 0.62, 0.35, 1)
    end

    TitleText = Main:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    TitleText:SetPoint("TOP", Main, "TOP", 0, -10)
    TitleText:SetText(L.TITLE)

    local close = CreateFrame("Button", nil, Main, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", Main, "TOPRIGHT", 2, 2)
    close:SetScript("OnClick", CloseAll)

    local gear = CreateFrame("Button", "EasyFlightMapGearButton", Main)
    gear:SetSize(22, 22)
    gear:SetPoint("TOPLEFT", Main, "TOPLEFT", 8, -5)
    gear:SetNormalTexture(GEAR_FILE)
    gear:SetPushedTexture(GEAR_FILE)
    local pushed = gear:GetPushedTexture()
    if pushed then pushed:SetVertexColor(0.7, 0.7, 0.7) end
    gear:SetHighlightTexture(GEAR_FILE, "ADD")
    gear:SetScript("OnClick", function() ToggleSettingsPopup() end)
    gear:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L.SETTINGS, 1, 0.82, 0)
        GameTooltip:Show()
    end)
    gear:SetScript("OnLeave", function(self)
        if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
    end)

    Viewport = CreateFrame("Frame", nil, Main)
    Viewport:SetPoint("TOP", Main, "TOP", 0, -TITLE_H)
    if Viewport.SetClipsChildren then Viewport:SetClipsChildren(true) end
    local bg = Viewport:CreateTexture(nil, "BACKGROUND", nil, -8)
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 1)
    Viewport:EnableMouseWheel(true)
    Viewport:SetScript("OnMouseWheel", function(_, delta)
        if not IsControlKeyDown() then return end
        DB.scale = max(0.5, min(1.2, floor((DB.scale + delta * 0.05) * 20 + 0.5) / 20))
        Render()
    end)

    LabelLayer = CreateFrame("Frame", nil, Main)
    LabelLayer:EnableMouse(false)
    HoverLayer = CreateFrame("Frame", nil, Viewport)
    HoverLayer:SetAllPoints(Viewport)
    HoverLayer:EnableMouse(false)
    HoverLayer.sparks = {}
    for i = 1, 3 do
        local spark = HoverLayer:CreateTexture(nil, "OVERLAY")
        spark:SetTexture(GLOW_FILE)
        spark:SetBlendMode("ADD")
        spark:SetSize(i == 1 and 16 or 11, i == 1 and 16 or 11)
        spark:Hide()
        HoverLayer.sparks[i] = spark
    end
    HoverLayer:Hide()

    local hint = Main:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("BOTTOM", Main, "BOTTOM", 0, 7)
    hint:SetText(L.HINT)

    ApplyPosition()
end

---------------------------------------------------------------------------
-- 열기 / 닫기
---------------------------------------------------------------------------
local function Build()
    if not snap or #snap.list == 0 then return false end
    local art, kind = TaxiArt(), "taxi"
    if not art then return false end

    local nodes = {}
    for _, e in ipairs(snap.list) do
        if FiniteNumber(e.plotX) and FiniteNumber(e.plotY) then
            e.x, e.y = e.plotX, e.plotY
        elseif FiniteNumber(e.tx) and FiniteNumber(e.ty) and e.tx >= 0 and e.tx <= 1 and e.ty >= 0 and e.ty <= 1 then
            e.x, e.y = e.tx, snap.flipTaxiY and (1 - e.ty) or e.ty
        else
            e.x, e.y = nil, nil
        end
        if e.x then nodes[#nodes + 1] = e end
    end
    if #nodes == 0 then return false end

    cur.nodes, cur.art, cur.artKind, cur.bySlot = nodes, art, kind, snap.bySlot

    local title = L.TITLE
    local mapID = snap.mapID or ContinentMapID()
    if mapID and C_Map and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(mapID)
        if info and info.name and info.name ~= "" then title = title .. " - " .. info.name end
    end
    TitleText:SetText(title)
    Render()
    return true
end

local function Open()
    if not (DB and DB.enabled and cur.open) then
        RestoreBlizzard()
        return
    end
    local ok, res = pcall(function()
        CreateUI()
        return Build()
    end)
    if ok and res then
        HideBlizzard()
        Main:Show()
    else
        if Main then Main:Hide() end
        RestoreBlizzard()
        if not ok then Print(L.MSG_ERROR:format(tostring(res))) end
    end
end

local function Close()
    if Main then Main:Hide() end
    RestoreBlizzard()
    cur.nodes, cur.art, cur.bySlot = nil, nil, nil
end

---------------------------------------------------------------------------
-- 후원
---------------------------------------------------------------------------
local DonateFrame
local function ShowDonate()
    if not DonateFrame then
        local f = CreateFrame("Frame", "EasyFlightMapDonate", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
        f:SetSize(340, 120)
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
        f:SetFrameStrata("FULLSCREEN_DIALOG")
        f:EnableMouse(true)
        f:SetMovable(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        if f.SetBackdrop then
            f:SetBackdrop(BACKDROP)
            f:SetBackdropColor(0.05, 0.05, 0.07, 0.97)
            f:SetBackdropBorderColor(0.75, 0.62, 0.35, 1)
        end
        local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOP", f, "TOP", 0, -12)
        title:SetText(L.DONATE_TITLE)
        local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("TOP", title, "BOTTOM", 0, -8)
        text:SetWidth(310)
        text:SetText(L.DONATE_TEXT)
        local eb = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        eb:SetSize(280, 20)
        eb:SetPoint("BOTTOM", f, "BOTTOM", 0, 16)
        eb:SetAutoFocus(false)
        eb:SetText(DONATE_URL)
        eb:SetScript("OnTextChanged", function(self, userInput)
            if userInput then
                self:SetText(DONATE_URL)
                self:HighlightText()
            end
        end)
        eb:SetScript("OnEscapePressed", function() f:Hide() end)
        eb:SetScript("OnEnterPressed", function() f:Hide() end)
        eb:SetScript("OnMouseUp", function(self) self:HighlightText() end)
        f.eb = eb
        local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 2, 2)
        DonateFrame = f
    end
    DonateFrame:Show()
    DonateFrame.eb:SetText(DONATE_URL)
    DonateFrame.eb:SetFocus()
    DonateFrame.eb:HighlightText()
end

---------------------------------------------------------------------------
-- 설정 창 (지도 창의 톱니바퀴 버튼, 게임 설정 > 애드온)
---------------------------------------------------------------------------
local function Refresh()
    if Main and Main:IsShown() and cur.open then Build() end
end

local function SetEnabled(on)
    DB.enabled = on and true or false
    if not DB.enabled then
        if Main then Main:Hide() end
        RestoreBlizzard()
    elseif cur.open then
        Open()
    end
end

local function ApplyBarSetting()
    if not DB.flightBar then HideBar() elseif pending and pending.start then ShowBar() end
end

local SETTINGS = {
    { kind = "header", label = "HEAD_BASIC" },
    { kind = "check",  key = "enabled",         label = "OPT_ENABLED" },
    { kind = "check",  key = "skipGossip",      label = "OPT_SKIP", sub = "OPT_SKIP_SUB" },
    { kind = "check",  key = "confirmFlight",   label = "OPT_CONFIRM" },
    { kind = "header", label = "HEAD_MAP" },
    { kind = "check",  key = "labels",          label = "OPT_LABELS" },
    { kind = "check",  key = "crop",            label = "OPT_CROP" },
    { kind = "check",  key = "showUnreachable", label = "OPT_ALL" },
    { kind = "slider", key = "scale",     label = "OPT_SCALE", min = 50, max = 120, step = 5, fmt = "%d%%" },
    { kind = "slider", key = "alpha",     label = "OPT_ALPHA", min = 0,  max = 70,  step = 5, fmt = "%d%%" },
    { kind = "slider", key = "labelSize", label = "OPT_FONT",  min = 8,  max = 14,  step = 1, fmt = "%d" },
    { kind = "header", label = "HEAD_FLIGHT" },
    { kind = "check",  key = "flightBar",       label = "OPT_BAR", sub = "OPT_BAR_SUB" },
    { kind = "check",  key = "arrivalAlert",    label = "OPT_ALERT" },
}

-- 화면에 보이는 값 <-> 저장 값
local function GetOpt(key)
    if key == "art" then return DB.art == "world" end
    if key == "scale" then return floor(DB.scale * 100 + 0.5) end
    if key == "alpha" then return floor((1 - DB.alpha) * 100 + 0.5) end
    if key == "labelSize" then return DB.labelSize end
    return DB[key] and true or false
end

local function SetOpt(key, value)
    if key == "enabled" then
        SetEnabled(value)
    elseif key == "art" then
        DB.art = "taxi"
        Refresh()
    elseif key == "scale" then
        DB.scale = value / 100
        if Main and Main:IsShown() then Render() end
    elseif key == "alpha" then
        DB.alpha = 1 - value / 100
        ApplyAlpha()
    elseif key == "labelSize" then
        DB.labelSize = value
        if Main and Main:IsShown() then Render() end
    elseif key == "flightBar" then
        DB.flightBar = value and true or false
        ApplyBarSetting()
    else
        DB[key] = value and true or false
        Refresh()
    end
end

local function CreateSlider(parent, width)
    local s = CreateFrame("Slider", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    s:SetOrientation("HORIZONTAL")
    s:SetSize(width, 16)
    if s.SetHitRectInsets then s:SetHitRectInsets(0, 0, -6, -6) end
    if s.SetBackdrop then
        s:SetBackdrop({
            bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
            edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 3, right = 3, top = 6, bottom = 6 },
        })
    end
    s:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    s:EnableMouse(true)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
    return s
end

-- parent 안에 설정 항목을 만들고, 화면 값을 다시 읽는 함수와 마지막 y를 돌려준다
local function BuildSettings(parent, x, y, width)
    local controls = {}
    for _, opt in ipairs(SETTINGS) do
        if opt.kind == "header" then
            local h = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            h:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y - 4)
            h:SetText(L[opt.label])
            local line = parent:CreateTexture(nil, "ARTWORK")
            line:SetColorTexture(0.75, 0.62, 0.35, 0.4)
            line:SetSize(width, 1)
            line:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y - 20)
            y = y - 26
        elseif opt.kind == "check" then
            local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
            cb:SetSize(24, 24)
            cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x - 2, y)
            local text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            text:SetPoint("LEFT", cb, "RIGHT", 2, 1)
            text:SetWidth(width - 30)
            text:SetJustifyH("LEFT")
            text:SetText(L[opt.label])
            y = y - 26
            if opt.sub then
                local sub = cb:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                sub:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -2)
                sub:SetWidth(width - 30)
                sub:SetJustifyH("LEFT")
                sub:SetText(L[opt.sub])
                y = y - 12
            end
            cb.optKey = opt.key
            cb:SetScript("OnClick", function(self)
                SetOpt(self.optKey, self:GetChecked() and true or false)
            end)
            controls[#controls + 1] = cb
        elseif opt.kind == "slider" then
            local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 2, y - 4)
            label:SetText(L[opt.label])
            local value = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            value:SetPoint("TOPRIGHT", parent, "TOPLEFT", x + width - 2, y - 4)
            local s = CreateSlider(parent, width - 8)
            s:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 4, y - 22)
            s:SetMinMaxValues(opt.min, opt.max)
            s:SetValueStep(opt.step)
            s.optKey, s.valueText, s.fmt, s.step, s.isSlider = opt.key, value, opt.fmt, opt.step, true
            s:SetScript("OnValueChanged", function(self, v)
                v = floor(v / self.step + 0.5) * self.step
                self.valueText:SetText(self.fmt:format(v))
                if self.updating then return end
                if v ~= GetOpt(self.optKey) then SetOpt(self.optKey, v) end
            end)
            controls[#controls + 1] = s
            y = y - 46
        end
    end
    local function refresh()
        for _, c in ipairs(controls) do
            local v = GetOpt(c.optKey)
            if c.isSlider then
                c.updating = true
                c:SetValue(v)
                c.valueText:SetText(c.fmt:format(v))
                c.updating = false
            else
                c:SetChecked(v)
            end
        end
    end
    return refresh, y
end

local Popup, popupRefresh, popupDefaultBtn
CloseSettingsPopup = function()
    if Popup then Popup:Hide() end
end
ToggleSettingsPopup = function()
    if not Popup then
        Popup = CreateFrame("Frame", "EasyFlightMapSettings", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
        Popup:SetFrameStrata("DIALOG")
        Popup:EnableMouse(true)
        if Popup.SetBackdrop then
            Popup:SetBackdrop(BACKDROP)
            Popup:SetBackdropColor(0.05, 0.05, 0.07, 0.97)
            Popup:SetBackdropBorderColor(0.75, 0.62, 0.35, 1)
        end
        local title = Popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", Popup, "TOPLEFT", 14, -12)
        title:SetText(L.SETTINGS)
        local close = CreateFrame("Button", nil, Popup, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", Popup, "TOPRIGHT", 2, 2)
        local bottom
        popupRefresh, bottom = BuildSettings(Popup, 14, -34, 272)

        popupDefaultBtn = CreateFrame("Button", nil, Popup, "UIPanelButtonTemplate")
        popupDefaultBtn:SetSize(272, 22)
        popupDefaultBtn:SetPoint("TOPLEFT", Popup, "TOPLEFT", 14, bottom - 6)
        popupDefaultBtn:SetText(L.BTN_DEFAULT)
        popupDefaultBtn:SetScript("OnClick", function()
            Popup:Hide()
            if Main then Main:Hide() end
            RestoreBlizzard()
        end)
        local donate = CreateFrame("Button", nil, Popup, "UIPanelButtonTemplate")
        donate:SetSize(272, 22)
        donate:SetPoint("TOPLEFT", Popup, "TOPLEFT", 14, bottom - 32)
        donate:SetText(L.BTN_DONATE)
        donate:SetScript("OnClick", ShowDonate)

        Popup:SetSize(300, -bottom + 66)
        Popup:Hide()
    end
    if Popup:IsShown() then
        Popup:Hide()
    else
        Popup:ClearAllPoints()
        Popup:SetPoint("TOPLEFT", Main, "TOPRIGHT", 4, 0)
        popupRefresh()
        if cur.open then popupDefaultBtn:Enable() else popupDefaultBtn:Disable() end
        Popup:Show()
    end
end

local OptionsPanel
local function RegisterOptionsPanel()
    local panel = CreateFrame("Frame")
    panel.name = "Easy Flight Map"
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText("Easy Flight Map")
    local refresh, bottom = BuildSettings(panel, 16, -44, 420)
    local donate = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    donate:SetSize(160, 22)
    donate:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, bottom - 8)
    donate:SetText(L.BTN_DONATE)
    donate:SetScript("OnClick", ShowDonate)
    panel:SetScript("OnShow", refresh)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        panel.category = category
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
    return panel
end

local function OpenOptionsPanel()
    if not OptionsPanel then return end
    if Settings and Settings.OpenToCategory and OptionsPanel.category then
        local c = OptionsPanel.category
        Settings.OpenToCategory((c.GetID and c:GetID()) or c.ID)
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
        InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
    end
end

---------------------------------------------------------------------------
-- 비행 조련사 대화창 건너뛰기
---------------------------------------------------------------------------
local TAXI_GOSSIP_ICON = 132057   -- Interface\\GossipFrame\\TaxiGossipIcon

local function IsTaxiOption(o)
    if type(o) ~= "table" then return false end
    if o.type == "taxi" then return true end
    for _, ic in ipairs({ o.icon or false, o.overrideIconID or false }) do
        if ic == TAXI_GOSSIP_ICON then return true end
        if type(ic) == "string" and ic:lower():find("taxigossipicon", 1, true) then return true end
    end
    return false
end

local function OnGossipShow()
    if not (DB and DB.enabled and DB.skipGossip) then return end
    if IsShiftKeyDown and IsShiftKeyDown() then return end
    local G = C_GossipInfo
    if not (G and G.GetOptions and G.SelectOption) then return end
    -- 퀘스트를 주거나 받는 조련사면 대화창을 그대로 보여준다
    local avail = G.GetNumAvailableQuests and G.GetNumAvailableQuests() or 0
    local active = G.GetNumActiveQuests and G.GetNumActiveQuests() or 0
    if avail > 0 or active > 0 then return end
    local opts = G.GetOptions()
    if type(opts) ~= "table" then return end
    for i, o in ipairs(opts) do
        if IsTaxiOption(o) then
            G.SelectOption(o.gossipOptionID or i)
            return
        end
    end
end

---------------------------------------------------------------------------
-- 이벤트
---------------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("TAXIMAP_OPENED")
ev:RegisterEvent("TAXIMAP_CLOSED")
ev:RegisterEvent("GOSSIP_SHOW")
ev:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON_NAME then
            InitDB()
            OptionsPanel = RegisterOptionsPanel()

        end
    elseif event == "TAXIMAP_OPENED" then
        cur.open = true
        cur.generation = (cur.generation or 0) + 1
        local generation = cur.generation
        -- Capture only after the stock TAXIMAP_OPENED handlers finish.
        local function capture()
            if not cur.open or cur.generation ~= generation then return end
            local ok, data = pcall(TakeSnapshot)
            snap = ok and data or nil
            if not ok then Print(L.MSG_ERROR:format(tostring(data))) end
            if DB and DB.enabled then Open() end
        end
        C_Timer.After(0, capture)
        -- A bounded second read covers late map/route initialization.
        C_Timer.After(0.10, capture)
    elseif event == "TAXIMAP_CLOSED" then
        cur.open = false
        cur.generation = (cur.generation or 0) + 1
        Close()
    elseif event == "GOSSIP_SHOW" then
        OnGossipShow()
    end
end)

---------------------------------------------------------------------------
-- 명령어
---------------------------------------------------------------------------
local function OnOff(v) return v and L.ON or L.OFF end

local function Toggle(key, msg)
    SetOpt(key, not DB[key])
    Print(msg:format(OnOff(DB[key])))
end

SLASH_EASYFLIGHTMAP1 = "/efm"
SLASH_EASYFLIGHTMAP2 = "/easyflightmap"
SLASH_EASYFLIGHTMAP3 = "/비행지도"
SlashCmdList.EASYFLIGHTMAP = function(msg)
    msg = ((msg or ""):gsub("^%s+", ""):gsub("%s+$", ""))
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    cmd = (cmd or ""):lower()
    local num = tonumber(rest)
    if cmd == "on" or cmd == "off" then
        SetEnabled(cmd == "on")
        Print(L.MSG_ENABLED:format(OnOff(DB.enabled)))
    elseif cmd == "config" or cmd == "설정" then
        OpenOptionsPanel()
    elseif cmd == "skip" then
        Toggle("skipGossip", L.MSG_SKIP)
    elseif cmd == "labels" then
        Toggle("labels", L.MSG_LABELS)
    elseif cmd == "crop" then
        Toggle("crop", L.MSG_CROP)
    elseif cmd == "all" then
        Toggle("showUnreachable", L.MSG_ALL)
    elseif cmd == "bar" then
        Toggle("flightBar", L.MSG_BAR)
    elseif cmd == "alert" then
        Toggle("arrivalAlert", L.MSG_ALERT)
    elseif cmd == "art" then
        SetOpt("art", DB.art ~= "world")
        Print(L.MSG_ART:format(DB.art == "world" and L.ART_WORLD or L.ART_TAXI))
    elseif cmd == "scale" then
        if num then
            if num <= 2 then num = num * 100 end   -- 0.8 처럼 입력해도 됨
            SetOpt("scale", max(50, min(120, num)))
        end
        Print(L.MSG_SCALE:format(GetOpt("scale")))
    elseif cmd == "alpha" then
        if num then SetOpt("alpha", max(0, min(70, num))) end
        Print(L.MSG_ALPHA:format(GetOpt("alpha")))
    elseif cmd == "reset" then
        DB.point, DB.barPoint, DB.scale = nil, nil, 1.0
        if Bar then Bar:ClearAllPoints();Bar:SetPoint("TOP",UIParent,"TOP",0,-140) end
        if Main then ApplyPosition() end
        Print(L.MSG_RESET)
        Refresh()
    elseif cmd == "donate" then
        ShowDonate()
    else
        Print(L.MSG_ENABLED:format(OnOff(DB.enabled)))
        for _, line in ipairs(L.HELP) do
            DEFAULT_CHAT_FRAME:AddMessage("  " .. line)
        end
    end
end
