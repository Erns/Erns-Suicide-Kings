--[[
	Ern's Suicide Kings
	<Ern_SK_Main.lua>
	Original Creation Date:	7/18/2012
	Updated Date:			2/20/2014
	Contact:  Ern.Warcraft@gmail.com
	
	Refer to LICENSE.txt for the Apache License, Version 2.0.
	
	Copyright 2012-2014 Aaron Sayles.  All rights reserved.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
]]

--------------
-- GLOBALS
--------------
--Current max level
maxLevel = 90

-- Default position of minimap (SAVED)
ErnSK_MapPos = 45

-- Default All Lists (SAVED)
ErnSK_Lists = {}

-- Default Alt Lists (SAVED)
ErnSK_Alts = {}

--List/Player tracking
listAdded = {}
selectedList = ""
selectedPlayer = ""
bAbsentMode = false
absentPlayers = {}

--Player Bidding
playersBid = {}
playersFinalBid = {}
bBiddingOpen = false

--Button states
sButtonSelect = "Interface\\BUTTONS\\UI-Listbox-Highlight"
sButtonAbsent = "Interface\\BUTTONS\\UI-Listbox-Highlight2"
sButtonHighlight = "Interface\\BUTTONS\\UI-Panel-Button-YellowHighlight"

--Announcements
--sMajorAnnounceType = "SAY"
--sAnnounceType = "SAY"
sMajorAnnounceType = "RAID_WARNING"
sAnnounceType = "RAID"


--------------
-- LOCALS
--------------
--Frames Moved
local bMoved = false

--Syncing
local syncList = ""
local syncPlayers = ""
local syncAltJoinPlayer = ""
local syncAltJoinAlts = ""
-----------------------------
--
--	 GENERAL
--
-----------------------------
--Slash Cmd to Open
SLASH_ESK1 = '/esk'
function SlashCmdList.ESK(msg, editbox)
	ESK_Minimize()
end

--Intro: When game loads
function Intro(self)

	print("|cff00FF7F Ern's Suicide Kings!  Type |cffffffff /esk |cff00FF7F to use.")

	--Monitor events
	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("CHAT_MSG_RAID")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER")
	self:RegisterEvent("CHAT_MSG_PARTY")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
	self:RegisterEvent("CHAT_MSG_SAY")
	self:RegisterEvent("LOOT_CLOSED")
	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("LOOT_SLOT_CHANGED")
	self:RegisterEvent("LOOT_SLOT_CLEARED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LEAVING_WORLD")
	self:RegisterEvent("PLAYER_LOGIN")
	--self:RegisterEvent("UPDATE_MASTER_LOOT_LIST")
	
	

	--Register Add-On Event
	RegisterAddonMessagePrefix("ESK_BID")
	RegisterAddonMessagePrefix("ESK_LISTS_START")
	RegisterAddonMessagePrefix("ESK_LISTS_DATA")
	RegisterAddonMessagePrefix("ESK_LISTS_FINISH")
	RegisterAddonMessagePrefix("ESK_ALTS_START")
	RegisterAddonMessagePrefix("ESK_ALTS_KEY")
	RegisterAddonMessagePrefix("ESK_ALTS_VALUES")
	RegisterAddonMessagePrefix("ESK_ALTS_DATA")
	RegisterAddonMessagePrefix("ESK_ALTS_FINISH")
	
	--Respond to events
	self:SetScript("OnEvent", function(self, event, ...)
		local prefix, addonMSG = ...	--Addon chat
		local msg, author = ...			--Raid chat
		local method, partyID = GetLootMethod()

		if event == "CHAT_MSG_ADDON" then
			if prefix == "ESK_BID" then
				if (addonMSG == "WIN") then lootSoundClip(true) end
				if (addonMSG == "LOSE") then lootSoundClip(false) end
				if (addonMSG == "BID_SUBMIT") then 
					print("|cffff0000 <ESK ALERT> |cff00FF7F You have |cffffffff SUBMITTED |cff00FF7F your bid!")
				end
				if (addonMSG == "BID_CANCEL") then
					print("|cffff0000 <ESK ALERT> |cff00FF7F You have |cffffffff CANCELLED |cff00FF7F your bid!")
				end
				if (addonMSG == "BID_DUP") then 
					print("|cffff0000 <ESK ALERT> |cff00FF7F Bid |cffffffff IGNORED |cff00FF7F as you've already bidded!")
				end

			elseif prefix == "ESK_LISTS_START" then
				syncList = addonMSG
				syncPlayers = ""
				print ("|cffff0000 <ESK ALERT> |cff00FF7F Sync Data |cffffffff PENDING |cff00FF7F currently.")

			elseif prefix == "ESK_LISTS_DATA" then
				syncPlayers = syncPlayers .. addonMSG
				print ("|cffff0000 <ESK ALERT> |cff00FF7F Sync Data |cffffffff SENT |cff00FF7F just now.")
			
			elseif prefix == "ESK_LISTS_FINISH" then
				ErnSK_Lists[syncList] = syncPlayers
				loadMasterList()
				print ("|cffff0000 <ESK ALERT> |cff00FF7F Sync Data |cffffffff COMPLETED |cff00FF7F and saved.")

			elseif prefix == "ESK_ALTS_START" then
				syncAltJoinPlayer = ""
				syncAltJoinAlts = ""
				print ("|cffff0000 <ESK ALERT> |cff00FF7F Sync Data |cffffffff PENDING |cff00FF7F currently.")

			elseif prefix == "ESK_ALTS_KEY" then
				syncAltJoinPlayer = addonMSG
				syncAltJoinAlts = ""

			elseif prefix == "ESK_ALTS_VALUES" then
				syncAltJoinAlts = syncAltJoinAlts .. addonMSG
			
			elseif prefix == "ESK_ALTS_DATA" then
				ErnSK_Alts[syncAltJoinPlayer] = syncAltJoinAlts
				print ("|cffff0000 <ESK ALERT> |cff00FF7F Sync Data |cffffffff SENT |cff00FF7F just now.")

			elseif prefix == "ESK_ALTS_FINISH" then
				print ("|cffff0000 <ESK ALERT> |cff00FF7F Sync Data |cffffffff COMPLETED |cff00FF7F and saved.")

			end

		elseif (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" or event == "CHAT_MSG_SAY") then
			if bBiddingOpen then
				--Add realm name as needed (just players on same server)
				if (string.find(author, "-") == nil) then
					author = author .. "-" .. GetRealmName() 
				end

				--Bid received
				if msg == "1" then 
					local bMatch = false
					for key, _ in pairs(playersBid) do
						--Check for duplicate bids
						if playersBid[key] == author then
							bMatch = true
							SendAddonMessage("ESK_BID", "BID_DUP", "WHISPER", author)
							break
						end
					end

					--Submit bid
					if not bMatch then
						table.insert(playersBid, author)
						SendAddonMessage("ESK_BID", "BID_SUBMIT", "WHISPER", author)
						updateBidders()
					end
					
				--Bid cancelled
				elseif msg == "0" then
					if #playersBid > 0 then
						for i = 1, #playersBid do
							if (playersBid[i] == author) then table.remove(playersBid, i) end
						end
					end
					SendAddonMessage("ESK_BID", "BID_CANCEL", "WHISPER", author)
					updateBidders()
				end
			end
		end

		if event == "LOOT_OPENED" then lootOpened() end
--		if event == "LOOT_CLOSED" then msgLootClosed() end
		if event == "LOOT_SLOT_CLEARED" then lootOpened() end
		if event == "LOOT_SLOT_CHANGED" then lootOpened() end
		--if event == "UPDATE_MASTER_LOOT_LIST" then end

		if event == "PLAYER_ENTERING_WORLD" then ErnSK_MinimapButton_Reposition() end
		if event == "PLAYER_LOGIN" then loadMasterList() end
	end);
end

--Exit/Minimize addon
function ESK_Minimize()
	if (frmMainESK:IsShown()) then
		--Hide it all
		frmMainESK:Hide()
		frmMain_SKTab:Hide()
		frmOptions_SKTab:Hide()
		frmLoot_SKTab:Hide()
	else
		--When being shown, setup to the Main Tab, reset as needed
		frmMainESK:Show()

		if not (frmMain_SKTab:IsShown()) then
			frmMain_SKTab:SetAllPoints(frmMainESK)
			frmMain_SKTab:Show()

			if (selectedList == "") then setListFuncBtns(false) end
			if (selectedPlayer == "") then setPlayerFuncBtns(false) end

			frmOptions_SKTab:SetAllPoints(frmMain_SKTab)
			frmOptions_SKTab_AddPlayer:SetAllPoints(frmMain_SKTab)
			frmOptions_SKTab_AltJoiner:SetPoint("CENTER", frmMain_SKTab)
			frmLoot_SKTab:SetAllPoints(frmMain_SKTab)

			--Setup absent mode
			if not IsInGroup() then
				bAbsentMode = false
				btnMainTab_AbsentMode:Disable()
				btnMainTab_AbsentMode:SetText("Off")
				
				btnLootTab_AbsentToggle:Disable()
				btnLootTab_AbsentToggle:SetText("Absent Mode: Off")
			else
				btnMainTab_AbsentMode:Enable()
				btnLootTab_AbsentToggle:Enable()
			end
		end
	end
end

--Indicate frame moving has occurred
function ESK_FramesMoved()
	bMoved = true
end

-- Load Master List
function loadMasterList()
	local maxPlayerButtonCount = 0
	
	clearTable(listAdded)

	--Go through Master List
	for key, value in pairs(ErnSK_Lists) do
		--Create quick array of Lists
		table.insert(listAdded, key)
		
		--Determine the amount of player buttons to create
		local trackCount = 0
		for val in string.gmatch(ErnSK_Lists[key], ";;") do
			trackCount = trackCount + 1
		end
		if (trackCount > maxPlayerButtonCount) then maxPlayerButtonCount = trackCount end
	end
	
	--Clear out any existing lists
	clearListButtons(btnMainTabList, fntMainTabList)
	clearListButtons(btnOptionsTabList, fntOptionsTabList)

	--Disable buttons
	setListFuncBtns(false)
	setPlayerFuncBtns(false)

	--Populate Lists
	table.sort(listAdded)
	for i = 1, #listAdded do
		createListButton(i, (i - 1) * -12)
		modifyListButton(i)
	end

	--Create blank Player Buttons
	for i = 1, maxPlayerButtonCount do
		createPlayerButton(i, (i - 1) * -12)
	end

	--Clear out any existing players
	clearPlayerButtons(btnMainTabPlayer, fntMainTabPlayer)
	clearPlayerButtons(btnOptionsTabPlayer, fntOptionsTabPlayer)
	
end


-----------------------------
--
-- MINIMAP BUTTON
--
-----------------------------

-- Set button position in saved spot
function ErnSK_MinimapButton_Reposition()
	ErnSK_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(ErnSK_MapPos)),(80*sin(ErnSK_MapPos))-52)
end

-- Move button
function ErnSK_MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70 -- get coordinates as differences from the center of the minimap
	ypos = ypos/UIParent:GetScale()-ymin-70

	ErnSK_MapPos = math.deg(math.atan2(ypos,xpos)) -- save the degrees we are relative to the minimap center
	ErnSK_MinimapButton_Reposition() -- move the button
end

-- Click button
function ErnSK_MinimapButton_OnClick()
	ESK_Minimize();
end

--Tooltip enter
function ErnSK_MinimapButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	GameTooltip:SetText("Ern's Suicide Kings")
	GameTooltip:AddLine("Click to open!", 1, 1, 1)
	GameTooltip:Show()
end

--Tooltip leave
function ErnSK_MinimapButton_OnLeave()
	GameTooltip:Hide()
end



------------------------
--
-- BUTTONS
--
------------------------

--Close Buttons
function btnClose_OnClick()
	ESK_Minimize()
end

--Select Tabs
---> Main Tab
function btnMain_OnClick()
	clearAllSelects()
	if not (frmMain_SKTab:IsShown()) then ESK_MoveFrames() end
	frmMain_SKTab:Show()
	frmOptions_SKTab:Hide()
	frmLoot_SKTab:Hide()
end

---> Options Tab
function btnOptions_OnClick()
	clearAllSelects()
	if not (frmOptions_SKTab:IsShown()) then ESK_MoveFrames() end
	frmMain_SKTab:Hide()
	frmOptions_SKTab:Show()
	frmLoot_SKTab:Hide()
end

---> Loot Tab
function btnLoot_OnClick()
	clearAllSelects()
	if not (frmLoot_SKTab:IsShown()) then ESK_MoveFrames() end
	frmMain_SKTab:Hide()
	frmOptions_SKTab:Hide()
	frmLoot_SKTab:Show()

	clearAllLoot()
end

--If window's been moved, set intended tab to the same position
function ESK_MoveFrames()
	if bMoved then
		if (frmMain_SKTab:IsShown()) then
			frmOptions_SKTab:SetAllPoints(frmMain_SKTab)
			frmLoot_SKTab:SetAllPoints(frmMain_SKTab)
		elseif (frmOptions_SKTab:IsShown()) then
			frmMain_SKTab:SetAllPoints(frmOptions_SKTab)
			frmLoot_SKTab:SetAllPoints(frmOptions_SKTab)
		elseif (frmLoot_SKTab:IsShown()) then
			frmMain_SKTab:SetAllPoints(frmLoot_SKTab)
			frmOptions_SKTab:SetAllPoints(frmLoot_SKTab)
		end

		bMoved = false
	end
end

-----------------------------
--
-- LISTS FUNCTIONALITY
--
-----------------------------

--List Select
function listSelect(self)
	local buttonList
	local fontList
	
	local buttonPlayer
	local fontPlayer

	selectedPlayer = ""

	--Set appropriate button/font lists based on current tab
	if (frmMain_SKTab:IsShown()) then
		buttonList = btnMainTabList
		fontList = fntMainTabList
		
		buttonPlayer = btnMainTabPlayer
		fontPlayer = fntMainTabPlayer

		setPlayerFuncBtns(false)

	elseif (frmOptions_SKTab:IsShown()) then
		buttonList = btnOptionsTabList
		fontList = fntOptionsTabList
		
		buttonPlayer = btnOptionsTabPlayer
		fontPlayer = fntOptionsTabPlayer

		btnOptionsTab_PlayerRemove:Disable()
	end

	--Hide Add Players frame
	if (frmOptions_SKTab_AddPlayer:IsShown()) then frmOptions_SKTab_AddPlayer:Hide() end
	if (frmOptions_SKTab_AltJoiner:IsShown()) then frmOptions_SKTab_AltJoiner:Hide() end

	--Reset textures for all Lists and select correct one
	local index
	for key, _ in pairs(buttonList) do
		if (buttonList[key] ~= self) then
			buttonList[key]:SetNormalTexture("")
		else
			index = key
		end
	end
	selectedList = fontList[index]:GetText()

	--Kill this process if empty button
	if (selectedList == nil or selectedList == "") then return false end

	self:SetNormalTexture(sButtonSelect)
	
	--Populate list of Players
	populatePlayerList()
	
end

--Display selected list's players
function populatePlayerList()
	--Loot Tab, halt process
	--if frmLoot_SKTab:IsShown() then return false end

	local sPlayer
	local sClass
	local playerIndex = 0	

	local buttonPlayer = nil
	local fontPlayer = nil

	local raidInfo = {}

	--Main Tab / Option Tab 
	if (frmMain_SKTab:IsShown() or frmLoot_SKTab:IsShown()) then			
		buttonPlayer = btnMainTabPlayer
		fontPlayer = fntMainTabPlayer

		btnMainTab_ListRandom:Enable()
		btnMainTab_ListAnnounce:Enable()

		--Activate Sync option as appropriate
		local _, partyID = GetLootMethod()
		if (IsInGroup() and partyID == 0) then btnMainTab_ListSync:Enable() end
		
		--Raiders - pull and set info
		local groupCount = GetNumGroupMembers()
		if groupCount > 0 then
			clearTable(raidInfo)
			for i = 1, groupCount do
				local name, _, _, _, class = GetRaidRosterInfo(i)
			
				if (string.find(name, "-") == nil) then name = name .. "-" .. GetRealmName() end

				raidInfo[i] = {
					rName = name,
					rClass = class
				}
			end
		end

	elseif (frmOptions_SKTab:IsShown()) then
		buttonPlayer = btnOptionsTabPlayer
		fontPlayer = fntOptionsTabPlayer

		btnOptionsTab_ListRemove:Enable()
		btnOptionsTab_ListCopy:Enable()
		btnOptionsTab_PlayerAdd:Enable()
	end

	--Clear out player buttons
	local tempSelPlayer = selectedPlayer
	clearPlayerButtons(buttonPlayer, fontPlayer)
		
	selectedPlayer = tempSelPlayer

	--Grab Master List info
	local playersListed = Split(ErnSK_Lists[selectedList], ";;")

	--Sort listing on Options tab
	if (frmOptions_SKTab:IsShown()) then table.sort(playersListed) end	
	clearTable(absentPlayers)

	for key, value in pairs(playersListed) do
		if (value ~= nil and value ~= "") then
			sPlayer = nameOnly(value)
			sClass = classOnly(value)
			
			playerIndex = playerIndex + 1
			buttonPlayer[playerIndex]:Show()
			
			if (bAbsentMode and #raidInfo > 0) then
				--If AbsentMode is on and raidInfo has been filled in (just Main Tab)
				local bInList = false
				for i = 1, #raidInfo do
					--Indicate if player in list is currently in the party
					if (raidInfo[i].rName == sPlayer) then
						bInList = true
						break
					end
				end
				
				--Mark absent if not in list, clear out selectedPlayer if it was the same as now absent player
				if not bInList then 
					buttonPlayer[playerIndex]:SetNormalTexture(sButtonAbsent)
					table.insert(absentPlayers, sPlayer.."("..sClass..")")
					if (sPlayer == selectedPlayer) then selectedPlayer = "" end
				elseif (sPlayer == selectedPlayer and selectedPlayer ~= "") then
					buttonPlayer[playerIndex]:SetNormalTexture(sButtonSelect)
				end

			elseif (sPlayer == selectedPlayer and selectedPlayer ~= "") then
				-- The usual selection
				buttonPlayer[playerIndex]:SetNormalTexture(sButtonSelect)
			else
				buttonPlayer[playerIndex]:SetNormalTexture("")
			end

			fontPlayer[playerIndex]:SetText(sPlayer)
			playerColors(fontPlayer[playerIndex], sClass)
		end
	end
end

--Player Select
function playerSelect(self)
	local buttonPlayer
	local fontPlayer

	--Set appropriate button/font lists based on current tab
	if (frmMain_SKTab:IsShown()) then
		buttonPlayer = btnMainTabPlayer
		fontPlayer = fntMainTabPlayer

	elseif (frmOptions_SKTab:IsShown()) then
		buttonPlayer = btnOptionsTabPlayer
		fontPlayer = fntOptionsTabPlayer
		
		btnOptionsTab_PlayerRemove:Enable()
	end
	
	--Reset textures for all Players and select correct one
	local index = 1
	local bProceed = true

	for key, _ in pairs(buttonPlayer) do
		local bSelf = false

		if (buttonPlayer[key] ~= self) then
			buttonPlayer[key]:SetNormalTexture("")
		else
			index = key
			bSelf = true
		end

		--Set selection on clicked player, unless they're absent
		if bAbsentMode and #absentPlayers > 0 then
			for i = 1, #absentPlayers do
				if (nameOnly(absentPlayers[i]) == fontPlayer[key]:GetText()) then
					buttonPlayer[key]:SetNormalTexture(sButtonAbsent)
					if bSelf then bProceed = false end
					break
				end
			end
		end
	end

	if bProceed then
		if (fontPlayer[index]:GetText() ~= "" and fontPlayer[index]:GetText() ~= nil) then
			self:SetNormalTexture(sButtonSelect)
			selectedPlayer = fontPlayer[index]:GetText()
		end
	end

	--Disable/enable player buttons as needed
	if (selectedPlayer ~= "") then
		setPlayerFuncBtns(true)
	else
		setPlayerFuncBtns(false)
	end
	
end

--Clear selections and displays
function clearAllSelects()
	selectedList = ""
	selectedPlayer = ""

	--Disable Option Buttons
	setListFuncBtns(false)
	setPlayerFuncBtns(false)

	if (frmOptions_SKTab_AddPlayer:IsShown()) then frmOptions_SKTab_AddPlayer:Hide() end	--Hide Add Players frame
	if (frmOptions_SKTab_AltJoiner:IsShown()) then frmOptions_SKTab_AltJoiner:Hide() end

	--Main
	---> Deselect List
	for key, _ in pairs(btnMainTabList) do
		btnMainTabList[key]:SetNormalTexture("")
	end
	---> Deselect and Clear Players
	clearPlayerButtons(btnMainTabPlayer, fntMainTabPlayer)

	--Options
	---> Deselect List
	for key, _ in pairs(btnOptionsTabList) do
		btnOptionsTabList[key]:SetNormalTexture("")
	end
	---> Deselect and Clear Players
	clearPlayerButtons(btnOptionsTabPlayer, fntOptionsTabPlayer)

end

--Clear out buttons
function clearButtons(buttons, fonts)
	for key, _ in pairs(buttons) do
		buttons[key]:Hide()
		buttons[key]:SetNormalTexture("")
		fonts[key]:SetText("")
	end
end

--Reset textures and text for all Lists
function clearListButtons(buttonList, fontList)
	clearButtons(buttonList, fontList)
	selectedList = ""
end

--Reset textures and text for all Players
function clearPlayerButtons(buttonPlayer, fontPlayer)
	clearButtons(buttonPlayer, fontPlayer)
	selectedPlayer = ""
end

--Enable/Disable buttons as needed
function setListFuncBtns(enable)
	if enable then
		if IsInGroup() then btnMainTab_ListSync:Enable() end
		btnMainTab_ListRandom:Enable()
		btnMainTab_ListAnnounce:Enable()
	else
		btnMainTab_ListSync:Disable()
		btnMainTab_ListRandom:Disable()
		btnMainTab_ListAnnounce:Disable()
	end
end

function setPlayerFuncBtns(enable)
	if enable then
		btnMainTab_PlayerMoveUp:Enable()
		btnMainTab_PlayerMoveDown:Enable()
		btnMainTab_PlayerMoveTop:Enable()
		btnMainTab_PlayerMoveBottom:Enable()

		btnOptionsTab_ListRemove:Enable()
		btnOptionsTab_ListCopy:Enable()
		btnOptionsTab_PlayerAdd:Enable()
	else
		btnMainTab_PlayerMoveUp:Disable()
		btnMainTab_PlayerMoveDown:Disable()
		btnMainTab_PlayerMoveTop:Disable()
		btnMainTab_PlayerMoveBottom:Disable()

		btnOptionsTab_ListRemove:Disable()
		btnOptionsTab_ListCopy:Disable()
		btnOptionsTab_PlayerAdd:Disable()
		btnOptionsTab_PlayerRemove:Disable()
	end
end

-- Need Party Tooltips
--->Tooltip enter
function NeedPartyTooltip_OnEnter(self)
	if self:GetButtonState() == "DISABLED" then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetText("Activation Requirements:")
		GameTooltip:AddLine("- You must be in a raid/party.", 1, 1, 1)
		GameTooltip:Show()
	end
end

--->Tooltip leave
function NeedPartyTooltip_OnLeave()
	GameTooltip:Hide()
end

-- Player Tooltips
--->Tooltip enter
function PlayerAltTooltip_OnEnter(self)

	local btnPlayer = nil
	local fntPlayer = nil

	if (frmMain_SKTab:IsShown()) then
		btnPlayer = btnMainTabPlayer
		fntPlayer = fntMainTabPlayer
	elseif (frmOptions_SKTab:IsShown()) then
		btnPlayer = btnOptionsTabPlayer
		fntPlayer = fntOptionsTabPlayer
	end


	local index
	for key, value in pairs(btnPlayer) do
		if (btnPlayer[key] == self) then
			index = key
			break
		end
	end
	
	local sPlayer = fntPlayer[index]:GetText()
	
	if (ErnSK_Alts[sPlayer] ~= nil and ErnSK_Alts[sPlayer] ~= "") then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		
		local playerFirstName = Split(sPlayer, "-")
		GameTooltip:SetText(playerFirstName[1].."'s Alts:")
		
		local playersListed = Split(ErnSK_Alts[sPlayer], ";;")
		table.sort(playersListed)	
		for key, value in pairs(playersListed) do
			if (value ~= nil and value ~= "") then
				local sAlt = nameOnly(value)
				GameTooltip:AddLine("- " .. value, 1, 1, 1)
			end
		end
		
		GameTooltip:Show()
	end
end

--->Tooltip leave
function PlayerAltTooltip_OnLeave()
	GameTooltip:Hide()
end

------------------------
-- MISC
------------------------

--Set fontstring's text color based on class
function playerColors(fontstring, class)
	if (class == "Death Knight") then fontstring:SetTextColor(0.77, 0.12, 0.23)	
	elseif (class == "Druid") then fontstring:SetTextColor(1.00, 0.49, 0.04)
	elseif (class == "Hunter") then fontstring:SetTextColor(0.67, 0.83, 0.45)
	elseif (class == "Mage") then fontstring:SetTextColor(0.41, 0.80, 0.94)
	elseif (class == "Monk") then fontstring:SetTextColor(0.33, 0.54, 0.52)
	elseif (class == "Paladin") then fontstring:SetTextColor(0.96, 0.55, 0.73)
	elseif (class == "Priest") then fontstring:SetTextColor(1.00, 1.00, 1.00)
	elseif (class == "Rogue") then fontstring:SetTextColor(1.00, 0.96, 0.41)
	elseif (class == "Shaman") then fontstring:SetTextColor(0.0, 0.44, 0.87)
	elseif (class == "Warlock") then fontstring:SetTextColor(0.58, 0.51, 0.79)
	elseif (class == "Warrior") then fontstring:SetTextColor(0.78, 0.61, 0.43)
	end
end

--Determine class based off font color (not a surefire method)
function playerColorToClass(fontstring)
	local r, g, b = fontstring:GetTextColor()
	local class = ""

	if (r >= 0.77 and r < 0.78) then class = "Death Knight"
	elseif (r >= 0.67 and r < 0.68) then class = "Hunter"
	elseif (r >= 0.41 and r < 0.42) then class = "Mage"
	elseif (r >= 0.33 and r < 0.34) then class = "Monk"
	elseif (r >= 0.96 and r < 0.97) then class = "Paladin"
	elseif (r >= 0.00 and r < 0.01) then class = "Shaman"
	elseif (r >= 0.58 and r < 0.59) then class = "Warlock"
	elseif (r >= 0.78 and r < 0.79) then class = "Warrior"
	elseif (r >= 0.99 and r < 1.01) then
		if (g >= 0.49 and g < 0.50) then class = "Druid"
		elseif (g >= 1.00 and g < 1.01) then class = "Priest"
		elseif (g >= 0.96 and g < 0.97) then class = "Rogue"
		end
	end
	
	return class
end

--Clear out a table
function clearTable(t)
	for key, _ in pairs(t) do
		t[key] = nil
	end
end

-- Pull Name only from ErnSK_List / ErnSK_Alts
function nameOnly(value)
	return value:sub(1, (value:find("%(") - 1))
end

-- Pull Class only from ErnSK_List / ErnSK_Alts
function classOnly(value)
	return value:sub((value:find("%(") + 1), (value:find("%)") - 1))
end

-- Get UnitID value
function GetUnitID(name, realm)
	local unitID = ""
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local uname, urealm = UnitName("raid"..i)
			if uname == name and (urealm == nil or urealm == realm) then 
				unitID = "raid" .. i
				break
			end
		end
	elseif IsInGroup() then
		local uname, urealm = UnitName("player")
		if uname == name and (urealm == nil or urealm == realm) then 
			unitID = "player"
		else
			if GetNumGroupMembers() > 1 then
				for i = 1, (GetNumGroupMembers() - 1) do
					uname, urealm = UnitName("party"..i)
					if uname == name and (urealm == nil or urealm == realm) then 
						unitID = "party" .. i
						break
					end
				end
			end
		end
	end
	
	return unitID
end




-----  
function Split (s, delim)
	--originally written by Nick Gammon @ (http://www.gammon.com.au/forum/?id=6079)
  assert (type (delim) == "string" and string.len (delim) > 0, "bad delimiter")

  local start = 1
  local t = {}  -- results table

  -- find each instance of a string followed by the delimiter

  while true do
    local pos = string.find (s, delim, start, true) -- plain find

    if not pos then
      break
    end

    table.insert (t, string.sub (s, start, pos - 1))
    start = pos + string.len (delim)
  end -- while

  -- insert final one (after last delimiter)

  table.insert (t, string.sub (s, start))

  return t
 
end -- function split
