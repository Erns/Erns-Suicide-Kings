--[[
	Ern's Suicide Kings
	<Ern_SKTab_Main.lua>
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


-------------------
-- PAGE VARIABLES
-------------------
btnMainTabList = {}
fntMainTabList = {}

btnMainTabPlayer = {}
fntMainTabPlayer = {}

local iUP = -1
local iDOWN = 1

-------------------
-- FUNCTIONS
-------------------

-- Move selected player UP once
function movePlayerUP()
	movePlayer(iUP)
end

-- Move selected player DOWN once
function movePlayerDOWN()
	movePlayer(iDOWN)
end

-- Move selected player to the TOP of list
function movePlayerTOP()
	while (movePlayer(iUP) ~= "STOP") do
		--Twiddle thumbs
	end
end

-- Move selected player to the BOTTOM of list
function movePlayerBOTTOM()
	while (movePlayer(iDOWN) ~= "STOP") do
		--Twiddle thumbs
	end
end

--Move player in indicated direction
function movePlayer(direction)
	--Generate quick list of players
	if selectedPlayer ~= "" then
		local sReturn = ""

		local playerOrder = {}
		local playersListed = Split(ErnSK_Lists[selectedList], ";;")
	
		--Get ordered list of players in current list
		for _, value in pairs(playersListed) do
			if (value ~= nil and value ~= "") then
				table.insert(playerOrder, value)
			end
		end

		if #playerOrder > 0 then
			--Find selected player's index in created list
			local selectedPlayerIndex = 1
			for i = 1, #playerOrder do
				if (selectedPlayer == nameOnly(playerOrder[i])) then
					selectedPlayerIndex = i
					break
				end
			end
		
			local movetoPlayerIndex = selectedPlayerIndex + direction

			--Skip over absent players
			if bAbsentMode then
				if #absentPlayers > 0 then
					if (direction == iDOWN) then
						for i = 1, #absentPlayers do
							if (absentPlayers[i] == playerOrder[movetoPlayerIndex]) then
								movetoPlayerIndex = movetoPlayerIndex + direction
							end
						end
					elseif (direction == iUP) then
						for i = #absentPlayers, 1, -1 do
							if (absentPlayers[i] == playerOrder[movetoPlayerIndex]) then
								movetoPlayerIndex = movetoPlayerIndex + direction
							end
						end
					end
				end
			end

			--Move around in said list
			if (movetoPlayerIndex > 0 and movetoPlayerIndex <= #playerOrder) then
				local swap = playerOrder[movetoPlayerIndex]
				playerOrder[movetoPlayerIndex] = playerOrder[selectedPlayerIndex]
				playerOrder[selectedPlayerIndex] = swap
				sReturn = "GO"
			else
				--Indicate that it's been moved as far as possible
				sReturn = "STOP"
			end
		
			--Clear out Master List's entry and regenerate
			ErnSK_Lists[selectedList] = ""
			for _, val in pairs(playerOrder) do 
				ErnSK_Lists[selectedList] = ErnSK_Lists[selectedList] .. val .. ";;"
			end
		end

		--Repopulate screen
		populatePlayerList()

		return sReturn
	end
end

--Randomize selected list's players
function randomizePlayers()
	local playersListed = Split(ErnSK_Lists[selectedList], ";;")

	--Remove any blanks from PlayersListed
	for i = #playersListed, 1, -1 do
		if (playersListed[i] == "" or playersListed[i] == nil) then
			table.remove(playersListed, i)
		end
	end

	local playerCount = #playersListed
	local randomTable = {}
	local randomNum = random(playerCount)
	local numInTable = false

	--Populate randomTable with unique randomized numbers
	table.insert(randomTable, randomNum)
	while #randomTable < playerCount do
		randomNum = random(playerCount)
		numInTable = false

		--Determine if random number already in table
		for i = 1, #randomTable do
			if (randomTable[i] == randomNum) then
				numInTable = true
				break
			end
		end

		if not numInTable then table.insert(randomTable, randomNum) end
	end

	--Use table of random numbers as which keys to pull from playersListed
	local sPlayers = ""
	for i = 1, #randomTable do
		sPlayers = sPlayers .. playersListed[randomTable[i]] .. ";;"
	end

	--Set Master List and repopulate
	ErnSK_Lists[selectedList] = sPlayers

	populatePlayerList()

end

--Toggle Absent Mode, reload lists
function toggleAbsentMode()
	if bAbsentMode then bAbsentMode = false
	else bAbsentMode = true
	end

	if bAbsentMode then 
		btnMainTab_AbsentMode:SetText("On")
		btnLootTab_AbsentToggle:SetText("Absent Mode: On")
		print("|cffff0000 <Ern's Suicide Kings ALERT> |cff00FF7F Absent Mode is now |cffffffffON|cff00FF7F!");
	else 
		btnMainTab_AbsentMode:SetText("Off")
		btnLootTab_AbsentToggle:SetText("Absent Mode: Off")
		print("|cffff0000 <Ern's Suicide Kings ALERT> |cff00FF7F Absent Mode is now |cffffffffOFF|cff00FF7F!");
	end

	loadMasterList()
end

--Announce selected list's players
function AnnounceListPlayers()
	SendChatMessage("List Order For: " .. selectedList, sAnnounceType)

	local playersListed = Split(ErnSK_Lists[selectedList], ";;")
	for key, value in pairs(playersListed) do
		if (value ~= nil and value ~= "") then
			SendChatMessage("#" .. key .. ": " .. value, sAnnounceType)
		end
	end
end

-------------------
-- BUTTONS
-------------------
--LIST : SYNC
function btnMainTab_ListSync_OnClick()
	SendAddonMessage("ESK_LISTS_START", selectedList, "RAID")
	StaticPopup_Show("MainTab_SyncConfirm")
end

--Collect and send sync data
function performSync()
	local playerOrder = {}
	local playersListed = Split(ErnSK_Lists[selectedList], ";;")
	
	--Get ordered list of players in current list
	for _, value in pairs(playersListed) do
		if (value ~= nil and value ~= "") then
			table.insert(playerOrder, value)
		end
	end

	local sendPlayers = ""
	for i = 1, #playerOrder do
		sendPlayers = sendPlayers .. playerOrder[i] .. ";;"

		--If the string length is starting to get too long and there's more to send
		if (strlen(sendPlayers) > 200 and i < #playerOrder) then
			SendAddonMessage("ESK_LISTS_DATA", sendPlayers, "RAID")
			sendPlayers = ""
		end
	end

	SendAddonMessage("ESK_LISTS_DATA", sendPlayers, "RAID")

	SendAddonMessage("ESK_LISTS_FINISH", "", "RAID")
end

--->Tooltip enter
function btnMainTab_ListSync_OnEnter(self)
	if self:GetButtonState() == "DISABLED" then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetText("Activation Requirements:")
		if (selectedList == "") then GameTooltip:AddLine("- A list must be selected.", 1, 1, 1) end
		if not IsInGroup() then GameTooltip:AddLine("- You must be in a raid/party.", 1, 1, 1) end
		GameTooltip:AddLine("- You must be the Loot Master in said raid/party.", 1, 1, 1)
		GameTooltip:Show()
	end
end

--->Tooltip leave
function btnMainTab_ListSync_OnLeave()
	GameTooltip:Hide()
end

--LIST : RANDOMIZE
function btnMainTab_ListRandom_OnClick()
	StaticPopup_Show("MainTab_RandomizeConfirm")
end

--LIST : ANNOUNCE
function btnMainTab_ListAnnounce_OnClick()
	AnnounceListPlayers()
end

--PLAYER : MOVE UP
function btnMainTab_PlayerMoveUp_OnClick()
	movePlayerUP()
end

--PLAYER : MOVE DOWN
function btnMainTab_PlayerMoveDown_OnClick()
	movePlayerDOWN()
end

--PLAYER : KING
function btnMainTab_PlayerMoveTop_OnClick()
	movePlayerTOP()
end

--PLAYER : SUICIDE
function btnMainTab_PlayerMoveBottom_OnClick()
	movePlayerBOTTOM()
end

--ABSENT MODE
function btnMainTab_AbsentMode_OnClick()
	toggleAbsentMode()
end

-------------------
-- POP UP CONFIRMS
-------------------

--List Sync confirm
StaticPopupDialogs["MainTab_SyncConfirm"] = {
	text = "Do you want to sync the selected list with your raid/party members?",
	button1 = "Yes",
	button2 = "No",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnAccept = function(self)
		performSync()
	end
};

--Randomization warning
StaticPopupDialogs["MainTab_RandomizeConfirm"] = {
	text = "Do you want to randomize the Players on this List?",
	button1 = "Yes",
	button2 = "No",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnAccept = function(self)
		randomizePlayers()
	end
};
