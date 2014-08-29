--[[
	Ern's Suicide Kings
	<Ern_SKTab_Options.lua>
	Original Creation Date:	7/18/2012
	Updated Date:			2/16/2014
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

btnOptionsTabList = {}
fntOptionsTabList = {}

btnOptionsTabPlayer = {}
fntOptionsTabPlayer = {}

function optionsOnShow()
	--Activate Sync option as appropriate
	local _, partyID = GetLootMethod()
	btnOptionsTab_AltSync:Disable()
	if (IsInGroup() and partyID == 0) then btnOptionsTab_AltSync:Enable() end
end

--Create new list entry and button
function createListButton(index, offset)
	---> Main Tab
	if (btnMainTabList[index] == "" or btnMainTabList[index] == nil) then
		btnMainTabList[index] = CreateFrame("Button","btnMainTabList"..index, scrMainTab_ListsChild, "scrMainTab_List_Template")
		btnMainTabList[index]:SetPoint("TOPLEFT", 7, offset)
		btnMainTabList[index]:SetWidth(140)
		btnMainTabList[index]:SetHeight(12)

		fntMainTabList[index] = btnMainTabList[index]:CreateFontString("fntMainTabList"..index)
		fntMainTabList[index]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		fntMainTabList[index]:SetText("")
		fntMainTabList[index]:SetPoint("LEFT", btnMainTabList[index], "LEFT", 5, 0)
	end

	---> Options Tab
	if (btnOptionsTabList[index] == "" or btnOptionsTabList[index] == nil) then
		btnOptionsTabList[index] = CreateFrame("Button","btnOptionsTabList"..index, scrOptionsTab_ListsChild, "scrOptionsTab_List_Template")
		btnOptionsTabList[index]:SetPoint("TOPLEFT", 7, offset)
		btnOptionsTabList[index]:SetWidth(140)
		btnOptionsTabList[index]:SetHeight(12)

		fntOptionsTabList[index] = btnOptionsTabList[index]:CreateFontString("fntOptionsTabList"..index)
		fntOptionsTabList[index]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		fntOptionsTabList[index]:SetText("")
		fntOptionsTabList[index]:SetPoint("LEFT", btnOptionsTabList[index], "LEFT", 5, 0)
	end
end

--Modify existing List Button
function modifyListButton(index)
	---> Main Tab
	btnMainTabList[index]:Show()
	btnMainTabList[index]:SetHighlightTexture(sButtonHighlight)
	fntMainTabList[index]:SetText(listAdded[index])

	---> Options Tab
	btnOptionsTabList[index]:Show()
	btnOptionsTabList[index]:SetHighlightTexture(sButtonHighlight)
	fntOptionsTabList[index]:SetText(listAdded[index])

end

--Create blank Player buttons
function createPlayerButton(index, offset)
	---> Main Tab
	if (btnMainTabPlayer[index] == "" or btnMainTabPlayer[index] == nil) then
		btnMainTabPlayer[index] = CreateFrame("Button","btnMainTabPlayer"..index, scrMainTab_PlayersChild, "scrMainTab_Player_Template")
		btnMainTabPlayer[index]:SetPoint("TOPLEFT", 0, offset)
		btnMainTabPlayer[index]:SetWidth(140)
		btnMainTabPlayer[index]:SetHeight(12)

		fntMainTabPlayer[index] = btnMainTabPlayer[index]:CreateFontString("fntMainTabPlayer"..index)
		fntMainTabPlayer[index]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		fntMainTabPlayer[index]:SetText("")
		fntMainTabPlayer[index]:SetPoint("LEFT", btnMainTabPlayer[index], "LEFT", 5, 0)
	end

	---> Options Tab
	if (btnOptionsTabPlayer[index] == "" or btnOptionsTabPlayer[index] == nil) then
		btnOptionsTabPlayer[index] = CreateFrame("Button","btnOptionsTabPlayer"..index, scrOptionsTab_PlayersChild, "scrOptionsTab_Player_Template")
		btnOptionsTabPlayer[index]:SetPoint("TOPLEFT", 0, offset)
		btnOptionsTabPlayer[index]:SetWidth(140)
		btnOptionsTabPlayer[index]:SetHeight(12)

		fntOptionsTabPlayer[index] = btnOptionsTabPlayer[index]:CreateFontString("fntOptionsTabPlayer"..index)
		fntOptionsTabPlayer[index]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		fntOptionsTabPlayer[index]:SetText("")
		fntOptionsTabPlayer[index]:SetPoint("LEFT", btnOptionsTabPlayer[index], "LEFT", 5, 0)
	end
end

--Collect and send sync data
function performAltSync()
	local playerOrder = {}
	
	SendAddonMessage("ESK_ALTS_START", "", "RAID")

	for key, value in pairs(ErnSK_Alts) do
		SendAddonMessage("ESK_ALTS_KEY", key, "RAID")

		--Get clean table of alt data
		clearTable(playerOrder)
		local playersListed = Split(ErnSK_Alts[key], ";;")
		for _, value2 in pairs(playersListed) do
			if (value2 ~= nil and value2 ~= "") then
				table.insert(playerOrder, value2)
			end
		end

		--Setup alts to send, sending multiple sets if string gets too long
		local sendPlayers = ""
		for i = 1, #playerOrder do
			sendPlayers = sendPlayers .. playerOrder[i] .. ";;"

			--If the string length is starting to get too long and there's more to send
			if (strlen(sendPlayers) > 200 and i < #playerOrder) then
				SendAddonMessage("ESK_ALTS_VALUES", sendPlayers, "RAID")
				sendPlayers = ""
			end
		end
		SendAddonMessage("ESK_ALTS_VALUES", sendPlayers, "RAID")
		SendAddonMessage("ESK_ALTS_DATA", sendPlayers, "RAID")
	end

	SendAddonMessage("ESK_ALTS_FINISH", "", "RAID")
end



-------------------
-- BUTTONS
-------------------
function btnOptionsTab_ListAdd_OnClick()
	StaticPopup_Show("OptionsTab_AddList")
end

function btnOptionsTab_ListCopy_OnClick()
	StaticPopup_Show("OptionsTab_CopyList")
end

function btnOptionsTab_ListRemove_OnClick()
	StaticPopup_Show("OptionsTab_RemoveList")
end

function btnOptionsTab_PlayerAdd_OnClick()
	frmOptions_SKTab_AddPlayer:Show()
	fntOptionsTab_AddPlayer_ListName:SetText(selectedList)
end

function btnOptionsTab_PlayerRemove_OnClick()
	StaticPopup_Show("OptionsTab_RemovePlayer")
end

function btnOptionsTab_AltJoiner_OnClick()
	frmOptions_SKTab_AltJoiner:Show()
end

function btnOptionsTab_AltSync_OnClick()
	StaticPopup_Show("OptionTab_SyncConfirm")
end

-- Player Tooltips
--->Tooltip enter
local function PlayerAltTooltip_OnEnter(self)
	local index
	for key, value in pairs(btnOptionsTabPlayer) do
		if (btnOptionsTabPlayer[key] == self) then
			index = key
			break
		end
	end
	
	local sPlayer = fntOptionsTabPlayer[index]:GetText()
	
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
local function PlayerAltTooltip_OnLeave()
	GameTooltip:Hide()
end

--Sync Tooltip
--->Tooltip enter
function btnOptionsTab_AltSync_OnEnter(self)
	if btnOptionsTab_AltSync:GetButtonState() == "DISABLED" then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetText("Activation Requirements:")
		if not IsInGroup() then GameTooltip:AddLine("- You must be in a raid/party.", 1, 1, 1) end
		GameTooltip:AddLine("- You must be the Loot Master in said raid/party.", 1, 1, 1)
		GameTooltip:Show()
	end
end

--->Tooltip leave
function btnOptionsTab_AltSync_OnLeave()
	GameTooltip:Hide()
end

-------------------
-- POP UPs
-------------------
--Add List
StaticPopupDialogs["OptionsTab_AddList"] = {
	text = "Please enter new list's name:",
	button1 = "Add List",
	button2 = "Cancel",
	hasEditBox = 1,
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnShow = function(self)
		getglobal(self:GetName().."EditBox"):SetText("")
	end,
	OnAccept = function(self)
		variable = getglobal(self:GetName().."EditBox"):GetText()

		--Ensure list doesn't exist already
		for key, value in pairs(listAdded) do
			if (value == variable) then
				StaticPopup_Show("OptionsTab_AddListDUPLICATE")
				return false
			end
		end

		--Add new key to Master List
		if (variable ~= "") then ErnSK_Lists[variable] = "" end

		loadMasterList()

	end
};

--Add List
StaticPopupDialogs["OptionsTab_CopyList"] = {
	text = "Please enter new list's name:",
	button1 = "Copy List",
	button2 = "Cancel",
	hasEditBox = 1,
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnShow = function(self)
		getglobal(self:GetName().."EditBox"):SetText("")
	end,
	OnAccept = function(self)
		variable = getglobal(self:GetName().."EditBox"):GetText()

		--Ensure list doesn't exist already
		for key, value in pairs(listAdded) do
			if (value == variable) then
				StaticPopup_Show("OptionsTab_AddListDUPLICATE")
				return false
			end
		end

		--Add new key to Master List
		ErnSK_Lists[variable] = ErnSK_Lists[selectedList]

		loadMasterList()

	end
};
  
--List duplicate warning
StaticPopupDialogs["OptionsTab_AddListDUPLICATE"] = {
	text = "List already exists!",
	button1 = "OK",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnAccept = function(self)
		--StaticPopup_Show("OptionsTab_AddList")
	end
};
  
--List removal warning
StaticPopupDialogs["OptionsTab_RemoveList"] = {
	text = "Please confirm that you intend to DELETE this List.",
	button1 = "Yes",
	button2 = "No",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnAccept = function(self)
		--Remove entry from Master List and clear selected
		if currentSelectedLootList == selectedList then currentSelectedLootList = "" end
		ErnSK_Lists[selectedList] = nil
		loadMasterList()
		btnOptionsTab_ListRemove:Disable()
		btnOptionsTab_ListCopy:Disable()
	end
};

--Player duplicate warning
StaticPopupDialogs["OptionsTab_AddPlayerDUPLICATE"] = {
	text = "Player already exists on this list!",
	button1 = "OK",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnAccept = function(self)

	end
};

--Player removal warning
StaticPopupDialogs["OptionsTab_RemovePlayer"] = {
	text = "Please confirm that you intend to REMOVE the selected player from the selected list.",
	button1 = "Yes",
	button2 = "No",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnAccept = function(self)
		--Remove player info from Master List for selected list
		local playersListed = Split(ErnSK_Lists[selectedList], ";;")
		for key, value in pairs(playersListed) do
			if (value ~= nil and value ~= "") then
				
				if (selectedPlayer == nameOnly(value)) then
					table.remove(playersListed, key)
				end
			end
		end

		local sPlayers = ""
		for _, value in pairs(playersListed) do
			if (value ~= nil and value ~= "") then
				sPlayers = sPlayers .. value .. ";;"
			end
		end
		ErnSK_Lists[selectedList] = sPlayers

		--Repopulate player listing
		selectedPlayer = ""
		btnOptionsTab_PlayerRemove:Disable()
		populatePlayerList()
	end
};

--Alt Sync confirm
StaticPopupDialogs["OptionTab_SyncConfirm"] = {
	text = "Do you want to sync all of your current set Alts with your raid/party members?",
	button1 = "Yes",
	button2 = "No",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnAccept = function(self)
		performAltSync()
	end
};
