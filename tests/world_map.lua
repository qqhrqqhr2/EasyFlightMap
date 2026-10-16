-- Run from the repository root with Lua 5.1+.
local ns, callbacks = {}, {}
local function copy(...) local t={} for i=1,select('#',...) do for k,v in pairs(select(i,...)) do t[k]=v end end return t end
CreateFromMixins = copy
GetLocale = function() return 'koKR' end
UnitFactionGroup = function() return 'Horde' end
EasyFlightMapDB = {worldMapFlights=true,worldMapFactionFilters={Horde={[0]=true,[1]=true,[2]=true}}}
Enum = {UIMapType={World=1,Continent=2,Zone=3}}
MapCanvasPinMixin = {OnReleased=function() end}
MapCanvasDataProviderMixin = {
 OnAdded=function(self,map) self.map=map end,
 GetMap=function(self) return self.map end,
 RegisterEvent=function() end, UnregisterEvent=function() end,
 OnMapChanged=function(self) self:RefreshAllData() end,
}
local function control()
 local c={scripts={}}
 function c:RegisterEvent() end
 function c:SetScript(event,fn) self.scripts[event]=fn if event=="OnEvent" then callbacks[#callbacks+1]=fn end end
 function c:SetSize(w,h) self.width,self.height=w,h end
 function c:GetWidth() return self.width or 600 end
 function c:GetHeight() return self.height or 400 end
 function c:SetMovable() end
 function c:EnableMouse() end
 function c:RegisterForDrag() end
 function c:SetClampedToScreen() end
 function c:ClearAllPoints() end
 function c:GetEffectiveScale() return 1 end
 function c:GetLeft() return self.left or 60 end
 function c:GetTop() return self.top or 300 end
 function c:GetBottom() return 0 end
 function c:StartMoving() self.moving=true end
 function c:StopMovingOrSizing() self.moving=false end
 function c:SetShown(v) self.shown=v end
 function c:SetText(v) self.text=v end
 function c:SetNormalTexture() end
 function c:GetNormalTexture() return {SetTexCoord=function() end,ClearAllPoints=function() end,SetPoint=function() end} end
 function c:SetHighlightTexture() end
 function c:SetPoint(point,_,_,x,y) if point=="TOPLEFT" and x then self.left,self.top=x,y end end
 function c:SetFrameLevel() end
 function c:GetFrameLevel() return 10 end
 function c:SetBackdrop() end
 function c:SetBackdropColor() end
 function c:SetBackdropBorderColor() end
 function c:SetHitRectInsets() end
 function c:SetChecked(v) self.checked=v end
 function c:GetChecked() return self.checked end
 function c:CreateFontString() return {SetPoint=function() end, SetText=function() end, SetTextColor=function() end,SetScale=function() end,SetShown=function() end} end
 return c
end
local cursorX,cursorY=60,300
GetCursorPosition=function() return cursorX,cursorY end
CreateFrame=function() return control() end
hooksecurefunc=function(t,key,fn)
 local original=t[key]
 t[key]=function(...) local r=original(...) fn(...) return r end
end
local function node(id,faction,x,y,name)
 return {nodeID=id,faction=faction,position={x=x,y=y},name=name or 'node'..id,isUndiscovered=true}
end
local data={
 [1]={},
 [10]={node(1,1,.2,.3),node(2,2,.6,.7),node(3,0,.4,.5),node(4,1,.5,.5,'zzOLDPort'),node(9,9,.3,.3)},
 [20]={node(5,2,.5,.5)},
 [11]={node(1,1,.4,.4)},
}
local info={[1]={mapID=1,mapType=1},[10]={mapID=10,mapType=2,parentMapID=1},[20]={mapID=20,mapType=2,parentMapID=1},[11]={mapID=11,mapType=3,parentMapID=10}}
C_Map={GetMapInfo=function(id) return info[id] end,
 GetMapChildrenInfo=function() return {info[10],info[20]} end,
 GetMapRectOnMap=function(child,parent)
  if child==10 and parent==1 then return .1,.4,.2,.8 end
  if child==20 and parent==1 then return .6,.9,.2,.8 end
  if child==11 and parent==10 then return .1,.5,.1,.6 end
 end}
C_TaxiMap={GetTaxiNodesForMap=function(id) if id==99 then error('not available') end return data[id] or {} end}
local stock
WorldMapFrame={
 GetWidth=function() return 600 end,GetHeight=function() return 400 end,
 GetEffectiveScale=function() return 1 end,GetLeft=function() return 0 end,GetBottom=function() return 0 end,
 HookScript=function() end,GetFrameLevel=function() return 10 end,mapID=10,dataProviders={},pins={},
 AddDataProvider=function(self,p) self.dataProviders[p]=true p:OnAdded(self) end,
 GetMapID=function(self) return self.mapID end,
 IsShown=function() return true end,
 RemoveAllPinsByTemplate=function(self,key) self.pins[key]={} end,
 AcquirePin=function(self,key,n) self.pins[key]=self.pins[key] or {} table.insert(self.pins[key],n) end,
 RefreshAllDataProviders=function(self) for p in pairs(self.dataProviders) do p:RefreshAllData() end end,
}
FlightPointDataProviderMixin={ShouldShowTaxiNode=function() return true end,
 RefreshAllData=function(self) self:GetMap():AcquirePin('FlightPointPinTemplate',{}) end}
stock=copy(MapCanvasDataProviderMixin,FlightPointDataProviderMixin)
WorldMapFrame:AddDataProvider(stock)
assert(loadfile('WorldMap.lua'))('EasyFlightMap',ns)
callbacks[1](nil,'ADDON_LOADED','EasyFlightMap')
local p=assert(ns.WorldMapProvider)
local function near(a,b) assert(math.abs(a-b)<.00001,tostring(a)..' ~= '..tostring(b)) end
local nodes=p.Collect(10)
assert(#nodes==4) -- both factions, neutral and unknown, no obsolete node
local world=p.Collect(1)
assert(#world==5)
near(world[1].x,.16) near(world[1].y,.38)
near(world[5].x,.75)
local zone=p.Collect(11)
assert(#zone==3) -- native node wins; outside-zone continent nodes excluded
near(zone[1].x,.4)
assert(#p.Collect(99)==0)
-- Invalid coordinates do not produce pins; repeated IDs do not duplicate.
data[10][#data[10]+1]=node(1,1,.2,.3)
data[10][#data[10]+1]=node(7,1,0/0,.3)
data[10][#data[10]+1]=node(8,1,2,.3)
assert(#p.Collect(10)==4)
for _=1,2 do ns.RefreshWorldMap() end
assert(#WorldMapFrame.pins.EasyFlightMapWorldPinTemplate==3)
assert(#WorldMapFrame.pins.FlightPointPinTemplate==0)
EasyFlightMapDB.worldMapFlights=false
ns.RefreshWorldMap()
assert(#WorldMapFrame.pins.EasyFlightMapWorldPinTemplate==0)
assert(#WorldMapFrame.pins.FlightPointPinTemplate==1)
EasyFlightMapDB.worldMapFlights=true
ns.RefreshWorldMap()
assert(#WorldMapFrame.pins.EasyFlightMapWorldPinTemplate==3)
assert(#WorldMapFrame.pins.FlightPointPinTemplate==0)
-- The world map never invokes taxi actions, including opposite-faction pins.
TakeTaxiNode=function() error('world map must not fly') end
local lines={}
GameTooltip={SetOwner=function() end, SetText=function(_,s) lines[#lines+1]=s end,
 AddLine=function(_,s) lines[#lines+1]=s end, Show=function() end,
 IsOwned=function() return true end,Hide=function() end}
local pin=copy(EasyFlightMapWorldPinMixin)
pin.node=node(2,2,.2,.3)
pin:OnMouseEnter()
assert(lines[2]=='얼라이언스' and lines[3]=='상대 진영 비행 조련사')
print('PASS: factions, continent/world/zone projection, deduplication, invalid/API-error input, refresh, default restoration and tooltip')
-- Pin reuse must update faction badge, texture, tooltip and position.
local function visual()
 return {SetTexture=function(self,v) self.texture=v end,
 SetAtlas=function(self,v) self.atlas=v end,SetPoint=function() end,
 SetSize=function() end,SetAllPoints=function() end,
 SetScale=function() end,SetVertexColor=function(self,r,g,b) self.color={r,g,b} end,
 SetTextColor=function() end,SetText=function(self,v) self.text=v end}
end
local vpin=copy(EasyFlightMapWorldPinMixin,{
 UseFrameLevelType=function() end,SetScalingLimits=function() end,
 SetMouseClickEnabled=function(self,v) self.click=v end,
 SetMouseMotionEnabled=function() end,CreateTexture=visual,CreateFontString=visual,
 SetPosition=function(self,x,y) self.x,self.y=x,y end})
vpin:OnLoad()
assert(vpin.click==false)
C_Texture={GetAtlasInfo=function(a) return a=='valid' and {} or nil end}
vpin:OnAcquired({node=node(2,2,.3,.4),x=.3,y=.4})
assert(vpin.Badge==nil and vpin.Ring.color[3]==1)
vpin:OnAcquired({node=node(1,1,.5,.6),x=.5,y=.6})
assert(vpin.Ring.color[1]==1 and vpin.x==.5)
local n=node(3,0,.5,.6);n.atlasName='valid'
vpin:OnAcquired({node=n,x=.5,y=.6})
assert(vpin.Icon.atlas=='valid')
vpin:OnReleased()
assert(vpin.node==nil)
-- A late-loaded world map and addon must install exactly once.
local savedMap=WorldMapFrame
WorldMapFrame=nil
local late={}
assert(loadfile('WorldMap.lua'))('EasyFlightMap',late)
callbacks[2](nil,'PLAYER_LOGIN')
assert(late.WorldMapProvider==nil)
WorldMapFrame=savedMap
callbacks[2](nil,'ADDON_LOADED','Blizzard_WorldMap')
local installed=assert(late.WorldMapProvider)
callbacks[2](nil,'PLAYER_LOGIN')
assert(late.WorldMapProvider==installed)
print('PASS: pin reuse, native atlas/fallback, read-only mouse handling and late-load initialization')

-- Map checkbox and settings checkbox share one saved value in both directions.
local settingsCheck=control()
late.WorldMapSettingControls={settingsCheck}
local toggle=assert(late.WorldMapToggle)
toggle:SetChecked(false)
toggle.scripts.OnClick(toggle)
assert(EasyFlightMapDB.worldMapFlights==false and not settingsCheck:GetChecked())
assert(#WorldMapFrame.pins.EasyFlightMapWorldPinTemplate==0)
EasyFlightMapDB.worldMapFlights=true
late.RefreshWorldMap()
assert(toggle:GetChecked() and settingsCheck:GetChecked())
assert(#WorldMapFrame.pins.EasyFlightMapWorldPinTemplate==3)
EasyFlightMapDB.worldMapFlights=false
toggle.scripts.OnShow(toggle)
assert(not toggle:GetChecked())
print('PASS: map checkbox changes saved setting immediately; settings/map checkboxes synchronize and restore on show')

-- Fresh characters select their own faction plus neutral by default.
EasyFlightMapDB.worldMapFlights=true
EasyFlightMapDB.worldMapFactionFilters=nil
late.RefreshWorldMap()
local checks=late.WorldMapFactionToggles
assert(checks[1]:GetChecked() and checks[0]:GetChecked() and not checks[2]:GetChecked())
assert(#WorldMapFrame.pins.EasyFlightMapWorldPinTemplate==2)
checks[2]:SetChecked(true)
checks[2].scripts.OnClick(checks[2])
assert(#WorldMapFrame.pins.EasyFlightMapWorldPinTemplate==3)
UnitFactionGroup=function() return 'Alliance' end
callbacks[2](nil,'UNIT_FACTION','player')
assert(checks[2]:GetChecked() and checks[0]:GetChecked() and not checks[1]:GetChecked())
checks[0]:SetChecked(false)
checks[0].scripts.OnClick(checks[0])
assert(#WorldMapFrame.pins.EasyFlightMapWorldPinTemplate==1)
UnitFactionGroup=function() return 'Horde' end
callbacks[2](nil,'UNIT_FACTION','player')
assert(checks[0]:GetChecked() and checks[1]:GetChecked() and checks[2]:GetChecked())
print('PASS: own faction + neutral defaults, separate faction profiles, independent toggles and saved choices')

-- The original icon remains visible; the adjacent menu toggles independently.
local panel,icon,menu=late.WorldMapControlPanel,late.WorldMapSettingsIcon,late.WorldMapOptionsPanel
local before=EasyFlightMapDB.worldMapFactionFilters.Horde[0]
local x,y=panel.left,panel.top
icon.scripts.OnClick(icon)
assert(EasyFlightMapDB.worldMapControlsCollapsed==true and not menu.shown and icon.shown)
assert(EasyFlightMapDB.worldMapFactionFilters.Horde[0]==before)
near(panel.left,x);near(panel.top,y)
panel.scripts.OnShow(panel)
assert(not menu.shown and icon.shown)
icon.scripts.OnClick(icon)
assert(EasyFlightMapDB.worldMapControlsCollapsed==false and menu.shown and icon.shown)
near(panel.left,x);near(panel.top,y)
assert(panel.width==28 and menu.width==324)
assert(panel.scripts.OnDragStart==nil) -- drag only the icon
icon.scripts.OnDragStart(icon)
assert(panel.dragging and panel.scripts.OnUpdate)
cursorX,cursorY=-10000,-10000
panel.scripts.OnUpdate(panel)
near(panel.left,0);near(panel.top,28)
near(menu.left,34);near(menu.top,54)
cursorX,cursorY=10000,10000
panel.scripts.OnUpdate(panel)
near(panel.left,572);near(panel.top,400)
near(menu.left,242);near(menu.top,400) -- opens on left at the right map edge
icon.scripts.OnDragStop(icon)
assert(not panel.dragging and not panel.scripts.OnUpdate)
near(EasyFlightMapDB.worldMapControlPoint.x,572/600)
near(EasyFlightMapDB.worldMapControlPoint.y,1)
icon.scripts.OnClick(icon)
assert(not menu.shown and icon.shown)
icon.scripts.OnClick(icon)
assert(menu.shown and icon.shown)
near(panel.left,572);near(panel.top,400)
print('PASS: persistent original icon, same-icon menu toggle, icon-only drag, fixed icon position, inward menu layout and bounds')
