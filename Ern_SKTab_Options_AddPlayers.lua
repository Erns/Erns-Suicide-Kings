--[[
	Ern's Suicide Kings
	<Ern_SKTab_Options_AddPlayers.lua>
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

local btnAddPlayerGuildRank = {}
local fntAddPlayerGuildRank = {}

local btnAddPlayerGuildMember = {}
local fntAddPlayerGuildMember = {}

local btnAddPlayerRaidMember = {}
local fntAddPlayerRaidMember = {}

--Guild Info
local gRoster = {}
local gRanks = {}

--Raid Info
local rRoster = {}

--Class Types
local playerClasses = {
	"Death Knight",
	"Druid",
	"Hunter",
	"Mage",
	"Monk",
	"Paladin",
	"Priest",
	"Rogue",
	"Shaman",
	"Warlock",
	"Warrior"
}

--Create Checkboxes and FontStrings for Raid Members
function createRaidMemberChk(index, offset)
	btnAddPlayerRaidMember[index] = CreateFrame("CheckButton","btnAddPlayerRaidMember"..index, scrOptionsTab_AddPlayer_RaidMemberChild, "ChatConfigCheckButtonTemplate")
	btnAddPlayerRaidMember[index]:SetPoint("TOPLEFT", 1, offset)
	getglobal(btnAddPlayerRaidMember[index]:GetName() .. 'Text'):SetText("")

	fntAddPlayerRaidMember[index] = btnAddPlayerRaidMember[index]:CreateFontString("fntAddPlayerRaidMember"..index)
	fntAddPlayerRaidMember[index]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
	fntAddPlayerRaidMember[index]:SetText("")
	fntAddPlayerRaidMember[index]:SetPoint("LEFT", btnAddPlayerRaidMember[index], "LEFT", 25, 0)
end

--Create Checkboxes and FontStrings for Guild Ranks
function createGuildRankChk(index, offset)
	btnAddPlayerGuildRank[index] = CreateFrame("CheckButton","btnAddPlayerGuildRank"..index, scrOptionsTab_AddPlayer_GuildRankChild, "ChatConfigCheckButtonTemplate")
	btnAddPlayerGuildRank[index]:SetPoint("TOPLEFT", 1, offset)
	getglobal(btnAddPlayerGuildRank[index]:GetName() .. 'Text'):SetText("")

	fntAddPlayerGuildRank[index] = btnAddPlayerGuildRank[index]:CreateFontString("fntAddPlayerGuildRank"..index)
	fntAddPlayerGuildRank[index]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
	fntAddPlayerGuildRank[index]:SetText("")
	fntAddPlayerGuildRank[index]:SetPoint("LEFT", btnAddPlayerGuildRank[index], "LEFT", 25, 0)
end

--Create Checkboxes and FontStrings for Guild Members
function createGuildMemberChk(index, offset)
	btnAddPlayerGuildMember[index] = CreateFrame("CheckButton","btnAddPlayerGuildMember"..index, scrOptionsTab_AddPlayer_GuildMemberChild, "ChatConfigCheckButtonTemplate")
	btnAddPlayerGuildMember[index]:SetPoint("TOPLEFT", 1, offset)
	getglobal(btnAddPlayerGuildMember[index]:GetName() .. 'Text'):SetText("")

	fntAddPlayerGuildMember[index] = btnAddPlayerGuildMember[index]:CreateFontString("fntAddPlayerGuildMember"..index)
	fntAddPlayerGuildMember[index]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
	fntAddPlayerGuildMember[index]:SetText("")
	fntAddPlayerGuildMember[index]:SetPoint("LEFT", btnAddPlayerGuildMember[index], "LEFT", 25, 0)
end

--Grab info when this window is shown
function addPlayerShow()
	
	clearAddPlayerChecks()
	pullRaidInfo()
	pullGuildInfo()
end

--Uncheck and hide everything
function clearAddPlayerChecks()
	--Manual
	inpOptionsTab_AddPlayer_PlayerName:SetText("<Name>")
	inpOptionsTab_AddPlayer_PlayerServer:SetText("<Server>")
	
	--Raid Members
	if #btnAddPlayerRaidMember > 0 then
		for i = 1, #btnAddPlayerRaidMember do
			btnAddPlayerRaidMember[i]:SetChecked(false)
			btnAddPlayerRaidMember[i]:Hide()
			fntAddPlayerRaidMember[i]:Hide()
		end
	end

	--Guild Ranks
	if #btnAddPlayerGuildRank > 0 then
		for i = 1, #btnAddPlayerGuildRank do
			btnAddPlayerGuildRank[i]:SetChecked(false)
			btnAddPlayerGuildRank[i]:Hide()
			fntAddPlayerGuildRank[i]:Hide()
		end
	end
	
	--Guild Members
	if #btnAddPlayerGuildMember > 0 then
		for i = 1, #btnAddPlayerGuildMember do
			btnAddPlayerGuildMember[i]:SetChecked(false)
			btnAddPlayerGuildMember[i]:Hide()
			fntAddPlayerGuildMember[i]:Hide()
		end
	end
end

--Raiders - pull info and create boxes for current raiders
function pullRaidInfo()
	local groupCount = GetNumGroupMembers()
	if groupCount > 0 then
		clearTable(rRoster)
		for i = 1, groupCount do
			local name, _, _, _, class = GetRaidRosterInfo(i)
			
			if (string.find(name, "-") == nil) then name = name .. "-" .. GetRealmName() end

			rRoster[i] = {
				rName = name,
				rClass = class
			}
		end

		--Get list of player names to sort by
		local sortPlayerList = {}
		for i = 1, #rRoster do
			table.insert(sortPlayerList, rRoster[i].rName)
		end
		table.sort(sortPlayerList)

		for i = 1, #sortPlayerList do
			if (btnAddPlayerRaidMember[i] == "" or btnAddPlayerRaidMember[i] == nil) then
			createRaidMemberChk(i, (i - 1) * -15)
			else
				btnAddPlayerRaidMember[i]:Show()
				fntAddPlayerRaidMember[i]:Show()
			end
			fntAddPlayerRaidMember[i]:SetText(sortPlayerList[i])

			--Get correct class for player
			for j = 1, #rRoster do
				if rRoster[j].rName == sortPlayerList[i] then
					playerColors(fntAddPlayerRaidMember[i], rRoster[j].rClass)
					break
				end
			end
		end
	end
end

--Guild - pull info and create boxes for current guildies
function pullGuildInfo()
	GuildRoster()
	
	--Clear stored guild info
	clearTable(gRoster)
	clearTable(gRanks)
	
	--Pull guild roster info
	local gRosterCount = GetNumGuildMembers()
	for i = 1, gRosterCount do
		local name, rank, rankIndex, level, class = GetGuildRosterInfo(i)
		
		if (level >= 90) then	--Attempt not to swarm the guild members listing with all lowbies
			gRoster[#gRoster + 1] = {
				gName = name,
				gRank = rank,
				gClass = class,
				gRankIndex = rankIndex,
				gLevel = level
			}
		end
	end
	
	--Get current guild ranks
	for i = 1, GuildControlGetNumRanks() do
		gRanks[i] = GuildControlGetRankName(i)
	end
	
	--Ranks - create boxes for guild ranks
	if #gRanks > 0 then
		for i = 1, #gRanks do
			if (btnAddPlayerGuildRank[i] == "" or btnAddPlayerGuildRank[i] == nil) then
				createGuildRankChk(i, (i - 1) * -15)
			else
				btnAddPlayerGuildRank[i]:Show()
				fntAddPlayerGuildRank[i]:Show()
			end
			fntAddPlayerGuildRank[i]:SetText(gRanks[i])
			
		end
	end
	
	--Members - create boxes for all guild members
	if #gRoster > 0 then
		--Get list of player names to sort by
		local sortPlayerList = {}
		for i = 1, #gRoster do
			table.insert(sortPlayerList, gRoster[i].gName)
		end
		table.sort(sortPlayerList)

		for i = 1, #sortPlayerList do
			if (btnAddPlayerGuildMember[i] == "" or btnAddPlayerGuildMember[i] == nil) then
				createGuildMemberChk(i, (i - 1) * -15)
			else
				btnAddPlayerGuildMember[i]:Show()
				fntAddPlayerGuildMember[i]:Show()
			end
			fntAddPlayerGuildMember[i]:SetText(sortPlayerList[i])

			--Get correct class for player
			for j = 1, #gRoster do
				if gRoster[j].gName == sortPlayerList[i] then
					playerColors(fntAddPlayerGuildMember[i], gRoster[j].gClass)
					break
				end
			end
		end
	end
end

--Add player to selected list
function addPlayerToList(player)
	if not frmOptions_SKTab_AltJoiner:IsShown() then
		local playerBtnCount = #btnOptionsTabPlayer
	
		--Ensure no duplicate player
		local playersListed = Split(ErnSK_Lists[selectedList], ";;")
		for _, value in pairs(playersListed) do
			if (value == player) then return false end
		end
		
		--Add player to list
		ErnSK_Lists[selectedList] = ErnSK_Lists[selectedList] .. ";;" .. player
	
		--Add player buttons to accommodate the amount of players in list
		while (playerBtnCount < #playersListed + 1) do
			createPlayerButton((playerBtnCount + 1), (playerBtnCount * -12))
			playerBtnCount = playerBtnCount + 1
		end
	else
		addAltToPlayer(player)	--If the Alt Joiner is up, add player to that instead
	end
end


-------------------
-- BUTTONS
-------------------

function btnOptionsTab_AddPlayer_Close_OnClick()
	frmOptions_SKTab_AddPlayer:Hide()
end

function btnOptionsTab_AddPlayer_Cancel_OnClick()
	frmOptions_SKTab_AddPlayer:Hide()
end

local manualClass = ""
function btnOptionsTab_AddPlayer_OK_OnClick()
	local sPlayer = ""

	--Manual
	local manualName = inpOptionsTab_AddPlayer_PlayerName:GetText()
	local manualServer = inpOptionsTab_AddPlayer_PlayerServer:GetText()
	if ((manualName ~= "" and manualName ~= "<Name>") and (manualServer ~= "" and manualServer ~= "<Server>") and (manualClass ~= "" and manualClass ~= "<Class>")) then
		sPlayer = manualName .. "-".. manualServer .. "(" .. manualClass .. ")"
		addPlayerToList(sPlayer)
	end
	
	--Guild Ranks - if checked, throw in all in the guild roster at that rank
	if #gRanks > 0 then
		for i = 1, #gRanks do
			if (btnAddPlayerGuildRank[i]:GetChecked()) then
				for j = 1, #gRoster do
					if (gRoster[j].gRank == gRanks[i]) then
						sPlayer = gRoster[j].gName .. "(" .. gRoster[j].gClass .. ")"
						addPlayerToList(sPlayer)
					end
				end
			end
		end
	end
	
	--Guild Members - add checked players to list
	if #gRoster > 0 then
		for i = 1, #btnAddPlayerGuildMember do
			if (btnAddPlayerGuildMember[i]:GetChecked()) then
				sPlayer = fntAddPlayerGuildMember[i]:GetText()
				
				for j = 1, #gRoster do
					if gRoster[j].gName == sPlayer then 
						sPlayer = sPlayer .. "(" .. gRoster[j].gClass .. ")"
						break
					end
				end

				addPlayerToList(sPlayer)
			end
		end
	end
	
	--Raid Members - add checked players
	if #rRoster > 0 then
		for i = 1, #btnAddPlayerRaidMember do
			if (btnAddPlayerRaidMember[i]:GetChecked()) then
				sPlayer = fntAddPlayerRaidMember[i]:GetText()

				for j = 1, #rRoster do
					if rRoster[j].rName == sPlayer then 
						sPlayer = sPlayer .. "(" .. rRoster[j].rClass .. ")"
						break
					end
				end

				addPlayerToList(sPlayer)
			end
		end
	end

	frmOptions_SKTab_AddPlayer:Hide()

	if not frmOptions_SKTab_AltJoiner:IsShown() then populatePlayerList()
	else populateAltList()
	end
end

---> Class Drop Down
------> Drop Down Select
function ClassDropDown_Select(self)
	UIDropDownMenu_SetSelectedID(selOptionsTab_AddPlayer_PlayerClass, self:GetID())
	manualClass = self:GetText()
end

------> Drop Down Populate
function ClassDropDown_InitializeDropDown(self, level)
	local info = UIDropDownMenu_CreateInfo()
	info.text = "<Class>"
	info.value = "<Class>"
	info.isTitle = 1
	UIDropDownMenu_AddButton(info, level)

	for k,v in pairs(playerClasses) do
		info = UIDropDownMenu_CreateInfo()
		info.text = v
		info.value = v
		info.func = ClassDropDown_Select
		UIDropDownMenu_AddButton(info, level)
	end
end

------> Drop Down Load
function ClassDropDown_DropDownOnLoad(self)
	UIDropDownMenu_Initialize(selOptionsTab_AddPlayer_PlayerClass, ClassDropDown_InitializeDropDown)
	UIDropDownMenu_SetSelectedID(selOptionsTab_AddPlayer_PlayerClass, 1)
	UIDropDownMenu_JustifyText(selOptionsTab_AddPlayer_PlayerClass, "LEFT")
end
