--[[
	Ern's Suicide Kings
	<Ern_SKTab_Options_AltJoiner.lua>
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

local btnAltJoinPlayer = {}
local fntAltJoinPlayer = {}

local btnAltJoinAlt = {}
local fntAltJoinAlt = {}

local selectedJoinPlayer = ""
local selectedJoinAlt = ""

local allPlayers = {}

function altJoinLoad()
	clearButtons(btnAltJoinPlayer, fntAltJoinPlayer)
	clearButtons(btnAltJoinAlt, fntAltJoinAlt)

	btnOptionsTab_AltJoiner_AddAlt:Disable()
	btnOptionsTab_AltJoiner_RemoveAlt:Disable()

	selectedJoinPlayer = ""
	selectedJoinAlt = ""

	loadAllPlayers()
end

--Create blank Player buttons
function createAltJoinPlayerButtons(index, offset)
	if (btnAltJoinPlayer[index] == "" or btnAltJoinPlayer[index] == nil) then
		btnAltJoinPlayer[index] = CreateFrame("Button","btnAltJoinPlayer"..index, scrOptionsTab_AltJoiner_PlayerChild, "scrOptionsTab_AltJoiner_Player_Template")
		btnAltJoinPlayer[index]:SetPoint("TOPLEFT", 0, offset)
		btnAltJoinPlayer[index]:SetWidth(140)
		btnAltJoinPlayer[index]:SetHeight(12)

		fntAltJoinPlayer[index] = btnAltJoinPlayer[index]:CreateFontString("fntAltJoinPlayer"..index)
		fntAltJoinPlayer[index]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		fntAltJoinPlayer[index]:SetText("")
		fntAltJoinPlayer[index]:SetPoint("LEFT", btnAltJoinPlayer[index], "LEFT", 5, 0)
	end
end

--Create blank Alt buttons
function createAltJoinAltButtons(index, offset)
	if (btnAltJoinAlt[index] == "" or btnAltJoinAlt[index] == nil) then
		btnAltJoinAlt[index] = CreateFrame("Button","btnAltJoinAlt"..index, scrOptionsTab_AltJoiner_AltsChild, "scrOptionsTab_AltJoiner_Alt_Template")
		btnAltJoinAlt[index]:SetPoint("TOPLEFT", 0, offset)
		btnAltJoinAlt[index]:SetWidth(140)
		btnAltJoinAlt[index]:SetHeight(12)

		fntAltJoinAlt[index] = btnAltJoinAlt[index]:CreateFontString("fntAltJoinAlt"..index)
		fntAltJoinAlt[index]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		fntAltJoinAlt[index]:SetText("")
		fntAltJoinAlt[index]:SetPoint("LEFT", btnAltJoinAlt[index], "LEFT", 5, 0)
	end
end

--Add alt to player
function addAltToPlayer(player)
	local playerBtnCount = #btnAltJoinAlt
	local playersListed = {}

	--Ensure no duplicate player
	if (ErnSK_Alts[selectedJoinPlayer] ~= nil and ErnSK_Alts[selectedJoinPlayer] ~= "") then
		playersListed = Split(ErnSK_Alts[selectedJoinPlayer], ";;")
		for _, value in pairs(playersListed) do
			if (value == player) then return false end
		end
		
		--Add player to list
		ErnSK_Alts[selectedJoinPlayer] = ErnSK_Alts[selectedJoinPlayer] .. ";;" .. player
	else
		ErnSK_Alts[selectedJoinPlayer] = player
		table.insert(playersListed, player)
	end
	
	--Add player buttons to accommodate the amount of players in list
	while (playerBtnCount < #playersListed + 1) do
		createAltJoinPlayerButtons((playerBtnCount + 1), (playerBtnCount * -12))
		playerBtnCount = playerBtnCount + 1
	end
end

-------------------
-- BUTTONS
-------------------
function btnOptionsTab_AltJoiner_Close_OnClick()
	frmOptions_SKTab_AltJoiner:Hide()
end

function btnOptionsTab_AltJoiner_Close2_OnClick()
	frmOptions_SKTab_AltJoiner:Hide()
end

function btnOptionsTab_AltJoiner_AddAlt_OnClick()
	frmOptions_SKTab_AddPlayer:Show()
	fntOptionsTab_AddPlayer_ListName:SetText(selectedJoinPlayer)
end

function btnOptionsTab_AltJoiner_RemoveAlt_OnClick()
	StaticPopup_Show("OptionsTab_AltJoiner_RemoveAlt")
end


-----------------------------
--
--  FUNCTIONALITY
--
-----------------------------
--Load up all Players
function loadAllPlayers()
	clearTable(allPlayers)

	for key1, value1 in pairs(ErnSK_Lists) do
		--Grab Master List info
		local playersListed = Split(ErnSK_Lists[key1], ";;")

		--Go through each list and check out each player
		for key2, value2 in pairs(playersListed) do
			if (value2 ~= nil and value2 ~= "") then
				local bAdd = true
				for key3, value3 in pairs(allPlayers) do
					if (value3 == value2) then
						bAdd = false 
						break
					end
				end
				
				--Insert player if not already on the list
				if bAdd then table.insert(allPlayers, value2) end
			end
		end
	end

	if #allPlayers > 0 then
		--Sort all the players, create needed buttons
		table.sort(allPlayers)
		for i = 1, #allPlayers do
			createAltJoinPlayerButtons(i, (i - 1) * -12)
		end

		--Clean up global Alts listing
		for key, value in pairs(ErnSK_Alts) do
			local bKeep = false
			for i = 1, #allPlayers do
				if nameOnly(allPlayers[i]) == key then
					bKeep = true
					break
				end
			end
			if not bKeep then ErnSK_Alts[key] = nil end
		end

		local buttonPlayer = btnAltJoinPlayer
		local fontPlayer = fntAltJoinPlayer

		--Set the correct names
		if #buttonPlayer > 0 then
			local sPlayer
			local sClass
			local playerIndex = 0

			for key, value in pairs(allPlayers) do
				if (value ~= nil and value ~= "") then
					sPlayer = nameOnly(value)
					sClass = classOnly(value)
			
					playerIndex = playerIndex + 1
					buttonPlayer[playerIndex]:Show()
			
					buttonPlayer[playerIndex]:SetNormalTexture("")

					fontPlayer[playerIndex]:SetText(sPlayer)
					playerColors(fontPlayer[playerIndex], sClass)
				end
			end
		end
	end
end


--Player Select
function playerAltJoinSelect(self)
	selectedJoinAlt = ""
	btnOptionsTab_AltJoiner_RemoveAlt:Disable()

	--Reset textures for all Lists and select correct one
	local index
	for key, _ in pairs(btnAltJoinPlayer) do
		if (btnAltJoinPlayer[key] ~= self) then
			btnAltJoinPlayer[key]:SetNormalTexture("")
		else
			index = key
		end
	end
	selectedJoinPlayer = fntAltJoinPlayer[index]:GetText()

	--Kill this process if empty button
	if (selectedJoinPlayer == nil or selectedJoinPlayer == "") then return false end

	self:SetNormalTexture(sButtonSelect)
	
	--Populate list of Players
	populateAltList()
	
end

--Display selected list's players
function populateAltList()
	btnOptionsTab_AltJoiner_AddAlt:Enable()

	local sPlayer
	local sClass
	local playerIndex = 0	

	local buttonPlayer = btnAltJoinAlt
	local fontPlayer = fntAltJoinAlt

	--Clear out player buttons
	local tempSelPlayer = selectedJoinAlt
	clearPlayerButtons(buttonPlayer, fontPlayer)
		
	selectedJoinAlt = tempSelPlayer

	--Grab Master List info
	if (ErnSK_Alts[selectedJoinPlayer] ~= nil and ErnSK_Alts[selectedJoinPlayer] ~= "") then
		local playersListed = Split(ErnSK_Alts[selectedJoinPlayer], ";;")

		--Create needed buttons
		for i = 1, #playersListed do
			createAltJoinAltButtons(i, (i - 1) * -12)
		end

		--Sort listing on Options tab
		table.sort(playersListed)	

		for key, value in pairs(playersListed) do
			if (value ~= nil and value ~= "") then
				sPlayer = nameOnly(value)
				sClass = classOnly(value)
			
				playerIndex = playerIndex + 1
				buttonPlayer[playerIndex]:Show()
			
				if (sPlayer == selectedJoinAlt and selectedJoinAlt ~= "") then
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
end

--Alt Select
function altAltJoinSelect(self)
	selectedJoinAlt = ""

	--Reset textures for all Lists and select correct one
	local index
	for key, _ in pairs(btnAltJoinAlt) do
		if (btnAltJoinAlt[key] ~= self) then
			btnAltJoinAlt[key]:SetNormalTexture("")
		else
			index = key
		end
	end
	selectedJoinAlt = fntAltJoinAlt[index]:GetText()

	--Kill this process if empty button
	if (selectedJoinAlt == nil or selectedJoinAlt == "") then return false end

	self:SetNormalTexture(sButtonSelect)
	
	--Populate list of Players
	btnOptionsTab_AltJoiner_RemoveAlt:Enable()
	
end

------------------------
-- POP UPs
------------------------

--Player removal warning
StaticPopupDialogs["OptionsTab_AltJoiner_RemoveAlt"] = {
	text = "Please confirm that you intend to REMOVE the selected alt from the selected player.",
	button1 = "Yes",
	button2 = "No",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnAccept = function(self)
		--Remove player info from Master List for selected list
		local playersListed = Split(ErnSK_Alts[selectedJoinPlayer], ";;")
		for key, value in pairs(playersListed) do
			if (value ~= nil and value ~= "") then
				
				if (selectedJoinAlt == nameOnly(value)) then
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
		ErnSK_Alts[selectedJoinPlayer] = sPlayers

		--Repopulate player listing
		selectedJoinAlt = ""
		btnOptionsTab_AltJoiner_RemoveAlt:Disable()
		populateAltList()
	end
};
