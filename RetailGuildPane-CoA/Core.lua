-- RetailGuildPane-CoA: 3.3.5a / Conquest Reborn
local A=CreateFrame("Frame")
local db,ui,active="chat"
local updatingScroll=false
local members,visible={},{}
local lastRoster=0
local function label(parent,size,color)
 local f=parent:CreateFontString(nil,"OVERLAY",size or "GameFontNormal")
 if color then f:SetTextColor(unpack(color)) end
 f:SetJustifyH("LEFT");return f
end
local function panel(parent,w,h,x,y,bg)
 local f=CreateFrame("Frame",nil,parent)
 f:SetSize(w,h);f:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
 f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
 f:SetBackdropColor(unpack(bg or {0.065,0.08,0.12,0.97}))
 f:SetBackdropBorderColor(0.25,0.32,0.43,1)
 return f
end
local function action(parent,name,w,h,fn)
 local b=CreateFrame("Button",nil,parent)
 b:SetSize(w,h)
 b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=10})
 b:SetBackdropColor(0.13,0.18,0.26,0.95);b:SetBackdropBorderColor(0.27,0.36,0.47)
 b.caption=label(b,"GameFontNormalSmall");b.caption:SetPoint("CENTER");b.caption:SetText(name)
 b:SetScript("OnEnter",function(self)self:SetBackdropColor(0.22,0.32,0.46,1)end)
 b:SetScript("OnLeave",function(self)self:SetBackdropColor(0.13,0.18,0.26,0.95)end)
 b:SetScript("OnClick",fn);return b
end
local function rosterRequest()
 if not IsInGuild or not IsInGuild() then return end
 local t=GetTime and GetTime() or 0
 if t-lastRoster>12 and GuildRoster then lastRoster=t;GuildRoster() end
end
local function scan()
 members={}
 if not GetNumGuildMembers or not GetGuildRosterInfo then return end
 for i=1,GetNumGuildMembers() do
  local name,rank,rankIndex,level,class,zone,note,officer,online,status,classFile=GetGuildRosterInfo(i)
  if name then table.insert(members,{name=name,rank=rank or "",rankIndex=rankIndex,level=level or 0,class=classFile or class,zone=zone or "",note=note or "",online=online,index=i})end
 end
 table.sort(members,function(a,b)
  if a.online~=b.online then return a.online end
  return string.lower(a.name)<string.lower(b.name)
 end)
end
local function setScroll(scroll,total,shown)
 local max=math.max(0,total-shown)
 scroll:SetMinMaxValues(0,max)
 if scroll:GetValue()>max then
  updatingScroll=true;scroll:SetValue(max);updatingScroll=false
 end
end
local renderRoster,renderChat,renderInfo
renderRoster=function()
 if not ui then return end
 scan()
 local filtered={}
 local q=string.lower(db.search or "")
 local onlineCount=0
 for _,m in ipairs(members) do
  if m.online then onlineCount=onlineCount+1 end
  if (m.online or db.offline) and (q=="" or string.find(string.lower(m.name),q,1,true)) then table.insert(filtered,m)end
 end
 ui.count:SetText(onlineCount.." online  /  "..#members.." members")
 setScroll(ui.rosterScroll,#filtered,10)
 local offset=math.floor(ui.rosterScroll:GetValue()+0.5)
 for i,row in ipairs(ui.memberRows) do
  local m=filtered[i+offset]
  if m then
   local color=RAID_CLASS_COLORS and RAID_CLASS_COLORS[m.class]
   local hex=color and string.format("|cff%02x%02x%02x",color.r*255,color.g*255,color.b*255) or "|cffc8d4e5"
   row.text:SetText((m.online and "|cff53d49b● |r" or "|cff737b89● |r")..hex..m.name.."|r  |cff95a4b9"..m.level.."  "..m.rank.."|r")
   row:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:AddLine(m.name)
    GameTooltip:AddLine("Rank: "..m.rank,0.8,0.85,1)
    GameTooltip:AddLine("Zone: "..m.zone,0.8,0.85,1)
    if m.note~="" then GameTooltip:AddLine(m.note,1,0.9,0.6,true)end
    GameTooltip:Show()
   end)
   row:SetScript("OnLeave",function()GameTooltip:Hide()end)
   row:SetScript("OnClick",function()
    if ChatFrame_OpenChat then ChatFrame_OpenChat("/w "..m.name.." ")end
   end)
   row:Show()
  else row:Hide()end
 end
end
renderChat=function()
 if not ui or not db then return end
 local history=db.history or {}
 setScroll(ui.chatScroll,#history,14)
 local offset=math.floor(ui.chatScroll:GetValue()+0.5)
 local start=math.max(1,#history-13-offset)
 for i,row in ipairs(ui.chatRows) do
  local msg=history[start+i-1]
  if msg then row:SetText(msg);row:Show()else row:Hide()end
 end
end
renderInfo=function()
 if not ui then return end
 local guild=GetGuildInfo and GetGuildInfo("player") or nil
 ui.guildTitle:SetText(guild or "No Guild")
 ui.motd:SetText((GetGuildRosterMOTD and GetGuildRosterMOTD()) or "No message of the day.")
 ui.description:SetText((GetGuildInfoText and GetGuildInfoText()) or "No guild information available.")
end
local function selectTab(tab)
 active=tab
 ui.chatArea:SetShown(tab=="chat")
 ui.infoArea:SetShown(tab=="info")
 ui.tabChat:SetBackdropColor(tab=="chat" and 0.22 or 0.10,tab=="chat" and 0.35 or 0.15,tab=="chat" and 0.48 or 0.22,1)
 ui.tabInfo:SetBackdropColor(tab=="info" and 0.22 or 0.10,tab=="info" and 0.35 or 0.15,tab=="info" and 0.48 or 0.22,1)
 renderInfo()
 if tab=="chat" then rosterRequest();renderRoster();renderChat()end
end
local function build()
 ui={}
 local w=CreateFrame("Frame","RetailGuildPaneWindow",UIParent)
 ui.window=w;w:SetSize(980,620);w:SetPoint("CENTER");w:SetFrameStrata("DIALOG")
 w:SetMovable(true);w:EnableMouse(true);w:RegisterForDrag("LeftButton")
 w:SetScript("OnDragStart",function(self)self:StartMoving()end)
 w:SetScript("OnDragStop",function(self)self:StopMovingOrSizing()end)
 w:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",edgeSize=22,insets={left=8,right=8,top=8,bottom=8}})
 w:SetBackdropColor(0.045,0.065,0.10,0.98)
 local header=panel(w,945,50,17,-16,{0.08,0.12,0.18,1})
 local title=label(header,"GameFontNormalLarge");title:SetPoint("LEFT",header,"LEFT",18,0);title:SetText("|cffd7bd81GUILD & COMMUNITIES|r")
 local close=action(header,"X",30,28,function()w:Hide()end);close:SetPoint("RIGHT",header,"RIGHT",-10,0)
 local side=panel(w,224,528,17,-75,{0.07,0.105,0.16,1})
 local guildName=label(side,"GameFontNormalLarge");guildName:SetPoint("TOPLEFT",side,"TOPLEFT",16,-22);guildName:SetWidth(195)
 ui.guildTitle=guildName
 local subtitle=label(side,"GameFontNormalSmall");subtitle:SetPoint("TOPLEFT",side,"TOPLEFT",16,-58);subtitle:SetText("|cff98a9beYOUR GUILD|r")
 local ornament=side:CreateTexture(nil,"ARTWORK");ornament:SetTexture("Interface\\GuildFrame\\GuildLogo")
 ornament:SetSize(120,120);ornament:SetPoint("TOP",side,"TOP",0,-100)
 local motdTitle=label(side,"GameFontNormal");motdTitle:SetPoint("TOPLEFT",side,"TOPLEFT",15,-270);motdTitle:SetText("MESSAGE OF THE DAY")
 local motd=label(side,"GameFontHighlightSmall");motd:SetPoint("TOPLEFT",side,"TOPLEFT",15,-297);motd:SetWidth(193);motd:SetHeight(105);motd:SetJustifyV("TOP");ui.motd=motd
 local original=action(side,"Original Guild Window",188,30,function()
  w:Hide();if ToggleFriendsFrame then ToggleFriendsFrame(3)elseif FriendsFrame then ShowUIPanel(FriendsFrame)end
 end);original:SetPoint("BOTTOM",side,"BOTTOM",0,20)
 local right=panel(w,711,528,251,-75,{0.06,0.09,0.135,1})
 ui.tabChat=action(right,"CHAT & ROSTER",160,35,function()selectTab("chat")end)
 ui.tabChat:SetPoint("TOPLEFT",right,"TOPLEFT",15,-13)
 ui.tabInfo=action(right,"GUILD INFO",160,35,function()selectTab("info")end)
 ui.tabInfo:SetPoint("LEFT",ui.tabChat,"RIGHT",8,0)
 ui.chatArea=CreateFrame("Frame",nil,right);ui.chatArea:SetAllPoints(right)
 ui.infoArea=CreateFrame("Frame",nil,right);ui.infoArea:SetAllPoints(right)
 local chatBox=panel(ui.chatArea,430,417,14,-63,{0.045,0.065,0.095,1})
 local chatHeader=label(chatBox,"GameFontNormal");chatHeader:SetPoint("TOPLEFT",chatBox,"TOPLEFT",13,-12);chatHeader:SetText("Guild Chat")
 ui.chatRows={}
 for i=1,14 do
  local row=label(chatBox,"GameFontHighlightSmall")
  row:SetPoint("TOPLEFT",chatBox,"TOPLEFT",12,-40-(i-1)*24);row:SetWidth(386);row:SetHeight(23)
  ui.chatRows[i]=row
 end
 local scroll=CreateFrame("Slider",nil,chatBox,"OptionsSliderTemplate")
 scroll:SetOrientation("VERTICAL");scroll:SetSize(14,325);scroll:SetPoint("RIGHT",chatBox,"RIGHT",-8,-5)
 scroll:SetMinMaxValues(0,0);scroll:SetValueStep(1);scroll:SetValue(0)
 scroll:SetScript("OnValueChanged",function()if not updatingScroll then renderChat()end end);ui.chatScroll=scroll
 local input=CreateFrame("EditBox",nil,ui.chatArea,"InputBoxTemplate")
 input:SetSize(395,28);input:SetPoint("BOTTOMLEFT",ui.chatArea,"BOTTOMLEFT",28,15)
 input:SetAutoFocus(false);input:SetMaxLetters(255)
 input:SetScript("OnEnterPressed",function(self)
  local msg=self:GetText()
  if msg~="" and IsInGuild and IsInGuild() and SendChatMessage then SendChatMessage(msg,"GUILD")end
  self:SetText("");self:ClearFocus()
 end)
 local rosterBox=panel(ui.chatArea,246,455,455,-63,{0.045,0.065,0.095,1})
 ui.count=label(rosterBox,"GameFontNormalSmall");ui.count:SetPoint("TOPLEFT",rosterBox,"TOPLEFT",12,-12)
 local search=CreateFrame("EditBox",nil,rosterBox,"InputBoxTemplate")
 search:SetSize(207,23);search:SetPoint("TOPLEFT",rosterBox,"TOPLEFT",16,-39)
 search:SetAutoFocus(false);search:SetText(db.search or "")
 search:SetScript("OnTextChanged",function(self)db.search=self:GetText();ui.rosterScroll:SetValue(0);renderRoster()end)
 local offline=CreateFrame("CheckButton",nil,rosterBox,"UICheckButtonTemplate")
 offline:SetSize(22,22);offline:SetPoint("TOPLEFT",rosterBox,"TOPLEFT",8,-71);offline:SetChecked(db.offline)
 offline:SetScript("OnClick",function(self)db.offline=self:GetChecked() and true or false;renderRoster()end)
 local offLabel=label(rosterBox,"GameFontHighlightSmall");offLabel:SetPoint("LEFT",offline,"RIGHT",2,0);offLabel:SetText("Show offline members")
 ui.memberRows={}
 for i=1,10 do
  local row=CreateFrame("Button",nil,rosterBox)
  row:SetSize(208,30);row:SetPoint("TOPLEFT",rosterBox,"TOPLEFT",12,-108-(i-1)*31)
  row.text=label(row,"GameFontHighlightSmall");row.text:SetPoint("LEFT",row,"LEFT",2,0);row.text:SetWidth(205)
  ui.memberRows[i]=row
 end
 local rscroll=CreateFrame("Slider",nil,rosterBox,"OptionsSliderTemplate")
 rscroll:SetOrientation("VERTICAL");rscroll:SetSize(13,305);rscroll:SetPoint("RIGHT",rosterBox,"RIGHT",-9,-47)
 rscroll:SetMinMaxValues(0,0);rscroll:SetValueStep(1);rscroll:SetValue(0)
 rscroll:SetScript("OnValueChanged",function()if not updatingScroll then renderRoster()end end);ui.rosterScroll=rscroll
 local infoTitle=label(ui.infoArea,"GameFontNormalLarge");infoTitle:SetPoint("TOPLEFT",ui.infoArea,"TOPLEFT",25,-75);infoTitle:SetText("Guild Information")
 local desc=label(ui.infoArea,"GameFontHighlight");desc:SetPoint("TOPLEFT",ui.infoArea,"TOPLEFT",25,-115);desc:SetWidth(645);desc:SetHeight(250);desc:SetJustifyV("TOP");ui.description=desc
 local infoHelp=label(ui.infoArea,"GameFontHighlightSmall")
 infoHelp:SetPoint("BOTTOMLEFT",ui.infoArea,"BOTTOMLEFT",25,70)
 infoHelp:SetWidth(640);infoHelp:SetText("For guild ranks, permissions and guild logs, use the original guild window until client APIs are verified.")
 local openOriginal=action(ui.infoArea,"Open Guild Management",205,30,function()
  w:Hide();if ToggleFriendsFrame then ToggleFriendsFrame(3)elseif FriendsFrame then ShowUIPanel(FriendsFrame)end
 end);openOriginal:SetPoint("BOTTOMLEFT",ui.infoArea,"BOTTOMLEFT",25,22)
 table.insert(UISpecialFrames,"RetailGuildPaneWindow")
 selectTab("chat")
end
local function toggle()
 if not db then return end
 if not ui then build();return end
 if ui.window:IsShown()then ui.window:Hide()else ui.window:Show();selectTab(active)end
end
SLASH_RETAILGUILDPANE1="/rgp"
SlashCmdList.RETAILGUILDPANE=toggle
A:RegisterEvent("ADDON_LOADED")
A:RegisterEvent("PLAYER_ENTERING_WORLD")
A:RegisterEvent("GUILD_ROSTER_UPDATE")
A:RegisterEvent("GUILD_MOTD")
A:RegisterEvent("CHAT_MSG_GUILD")
A:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
A:SetScript("OnEvent",function(self,event,...)
 if event=="ADDON_LOADED" then
  if (...)~="RetailGuildPane-CoA"then return end
  RetailGuildPaneDB=RetailGuildPaneDB or {}
  db=RetailGuildPaneDB;db.history=db.history or db.chat or {};db.chat=nil
  db.search=db.search or "";if db.offline==nil then db.offline=false end
 elseif event=="PLAYER_ENTERING_WORLD"then rosterRequest()
 elseif event=="GUILD_ROSTER_UPDATE"then
  if ui and ui.window:IsShown()then renderRoster();renderInfo()end
 elseif event=="GUILD_MOTD"then if ui then renderInfo()end
 elseif (event=="CHAT_MSG_GUILD"or event=="CHAT_MSG_GUILD_ACHIEVEMENT")and db then
  local message,sender=...
  local stamp=date and date("%m/%d %H:%M") or ""
  table.insert(db.history,"|cff8194ad["..stamp.."]|r |cffb9d9ff"..(sender or "?").."|r: "..(message or ""))
  while #db.history>500 do table.remove(db.history,1)end
  if ui and ui.window:IsShown()then ui.chatScroll:SetValue(0);renderChat()end
 end
end)
