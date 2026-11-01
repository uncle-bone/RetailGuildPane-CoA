local addon=CreateFrame("Frame")
local db,frame,content,rows,mode
local function text(parent,x,y,width)
 local f=parent:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
 f:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y);f:SetWidth(width);f:SetJustifyH("LEFT");return f
end
local function button(label,x,y,fn)
 local b=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
 b:SetWidth(145);b:SetHeight(24);b:SetPoint("TOPLEFT",frame,"TOPLEFT",x,y)
 b:SetText(label);b:SetScript("OnClick",fn)
end
local function clear()
 for _,row in ipairs(rows) do row:Hide() end
 content:SetText("")
end
local function roster()
 mode="roster";clear()
 if not IsInGuild or not IsInGuild() then content:SetText("You are not in a guild.");return end
 local n=GetNumGuildMembers and GetNumGuildMembers() or 0
 local shown=0
 for i=1,n do
  local name,rank,rankIndex,level,class,zone,note,officer,online,status,classFile=GetGuildRosterInfo(i)
  if name and (online or db.offline) and string.find(string.lower(name),string.lower(db.search or ""),1,true) then
   shown=shown+1
   if shown<=13 then
    local row=rows[shown]
    if not row then row=text(frame,195,-102-(shown-1)*22,545);rows[shown]=row end
    local token=classFile or class
    local c=RAID_CLASS_COLORS and RAID_CLASS_COLORS[token]
    local prefix=c and string.format("|cff%02x%02x%02x",c.r*255,c.g*255,c.b*255) or "|cffffffff"
    row:SetText((online and "|cff55dd88● |r" or "|cff888888● |r")..prefix..name.."|r  "..(level or "?").."  "..(rank or "").."  "..(zone or ""))
    row:Show()
   end
  end
 end
 if shown==0 then content:SetText("No matching guild members.") end
end
local function info()
 mode="info";clear()
 if not IsInGuild or not IsInGuild() then content:SetText("You are not in a guild.");return end
 local guild=GetGuildInfo and GetGuildInfo("player") or "Guild"
 local motd=GetGuildRosterMOTD and GetGuildRosterMOTD() or ""
 local description=GetGuildInfoText and GetGuildInfoText() or ""
 content:SetText((guild or "Guild").."\n\nMessage of the day:\n"..(motd or "").."\n\nInformation:\n"..(description or ""))
end
local function chat()
 mode="chat";clear();content:SetText("Guild chat — captured during this session")
 for i=math.max(1,#db.chat-12),#db.chat do
  local row=rows[#rows+1]
  if not row then row=text(frame,195,-104-(#rows)*22,540);rows[#rows+1]=row end
  row:SetText(db.chat[i]);row:Show()
 end
end
local function open()
 if not frame then
  frame=CreateFrame("Frame","RetailGuildPaneWindow",UIParent)
  frame:SetWidth(770);frame:SetHeight(465);frame:SetPoint("CENTER");frame:SetFrameStrata("DIALOG")
  frame:SetMovable(true);frame:EnableMouse(true);frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart",function(self)self:StartMoving()end)
  frame:SetScript("OnDragStop",function(self)self:StopMovingOrSizing()end)
  frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=24,insets={left=8,right=8,top=8,bottom=8}})
  text(frame,20,-23,690):SetText("GUILD & COMMUNITY  |cff66ccffConquest Reborn|r")
  content=text(frame,195,-75,540);rows={}
  button("Roster",20,-85,roster);button("Guild Info",20,-120,info);button("Guild Chat",20,-155,chat)
  button("Refresh roster",20,-190,function()if GuildRoster then GuildRoster()end roster()end)
  button("Offline: toggle",20,-225,function()db.offline=not db.offline;roster()end)
  button("Original guild UI",20,-260,function()frame:Hide();if ToggleFriendsFrame then ToggleFriendsFrame(3)elseif FriendsFrame then ShowUIPanel(FriendsFrame)end end)
  button("Close",20,-295,function()frame:Hide()end)
  text(frame,20,-346,155):SetText("Search guild members")
  local search=CreateFrame("EditBox",nil,frame,"InputBoxTemplate")
  search:SetWidth(145);search:SetHeight(22);search:SetPoint("TOPLEFT",frame,"TOPLEFT",25,-366);search:SetAutoFocus(false)
  search:SetScript("OnTextChanged",function(self)db.search=self:GetText();if mode=="roster"then roster()end end)
  text(frame,195,-405,500):SetText("Type a guild message and press Enter")
  local input=CreateFrame("EditBox",nil,frame,"InputBoxTemplate")
  input:SetWidth(510);input:SetHeight(22);input:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",205,24);input:SetAutoFocus(false)
  input:SetScript("OnEnterPressed",function(self)
   local message=self:GetText()
   if message~="" and IsInGuild and IsInGuild()then SendChatMessage(message,"GUILD")end
   self:SetText("");self:ClearFocus()
  end)
  table.insert(UISpecialFrames,"RetailGuildPaneWindow")
 end
 if frame:IsShown()then frame:Hide()else frame:Show();roster()end
end
SLASH_RETAILGUILDPANE1="/rgp"
SlashCmdList.RETAILGUILDPANE=open
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("CHAT_MSG_GUILD")
addon:RegisterEvent("GUILD_ROSTER_UPDATE")
addon:SetScript("OnEvent",function(self,event,...)
 if event=="ADDON_LOADED"then
  if (...)~="RetailGuildPane-CoA"then return end
  RetailGuildPaneDB=RetailGuildPaneDB or {}
  db=RetailGuildPaneDB;db.chat=db.chat or {};db.search=db.search or ""
 elseif event=="CHAT_MSG_GUILD"and db then
  local message,sender=...
  table.insert(db.chat,(sender or "?")..": "..(message or ""))
  while #db.chat>80 do table.remove(db.chat,1)end
  if frame and frame:IsShown()and mode=="chat"then chat()end
 elseif event=="GUILD_ROSTER_UPDATE"and frame and frame:IsShown()and mode=="roster"then roster()end
end)
