--[[
	Ern's Suicide Kings
	<Ern_SKTab_Loot.lua>
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

local btnLootTabDropped = {}
local fntLootTabDropped = {}

local dasLoot = {}

local selectedLootDropped = ""
local selectedLootDroppedIndex = 0
local selectedLootList = ""
local selectedLootPlayer = ""
local currentSelectedLootList = ""
local bMasterLooter = false

--Sounds upon victory/defeat in bidding
local victorySounds = {
	"Sound\\Creature\\OrcMaleGuardNPC\\OrcMaleGuardNPCGreeting02.ogg",
	"Sound\\Character\\BloodElf\\BloodElfFemaleCongratulations02.ogg",
	"Sound\\Creature\\Alexstrasza\\VO_DS_Alexstrasza_DWVictory_01.ogg",
	"Sound\\Creature\\Brann\\HS_Brann_ReactingKill01.ogg",
	"Sound\\Creature\\Malfurion\\VO_Quest_42_Malfurion_Accomplishment_02.ogg"
};

local defeatSounds = {
	"Sound\\Creature\\Nazgrim\\VO_QE_VJ_Nazgrim_Neptulon05a.ogg",
	"Sound\\Creature\\Illidan\\BLACK_Illidan_04.wav",
	"Sound\\Creature\\XT002Deconstructor\\UR_XT002_Special01.wav",
	"Sound\\Creature\\Alizabal\\VO_BH_Alizabal_Spell_01.ogg",
	"Sound\\Creature\\Kologarn\\UR_Kologarn_slay02.wav",
	"Sound\\Creature\\Alexstrasza\\VO_DS_Alexstrasza_DWBattle_03.ogg",
	"Sound\\Creature\\Ashbringer\\Ash_Speak_12.ogg",
	"Sound\\Creature\\BlackKnight\\AC_BlackKnight_Death01.ogg"
};

--Create new dropped entry and button
function createLootDroppedButton(index, offset)
	if (btnLootTabDropped[index] == "" or btnLootTabDropped[index] == nil) then
		btnLootTabDropped[index] = CreateFrame("Button","btnLootTabDropped"..index, scrLootTab_DroppedChild, "scrLootTab_Dropped_Template")
		btnLootTabDropped[index]:SetPoint("TOPLEFT", 2, offset)
		btnLootTabDropped[index]:SetWidth(150)
		btnLootTabDropped[index]:SetHeight(12)

		fntLootTabDropped[index] = btnLootTabDropped[index]:CreateFontString("fntLootTabDropped"..index)
		fntLootTabDropped[index]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		fntLootTabDropped[index]:SetText("")
		fntLootTabDropped[index]:SetPoint("LEFT", btnLootTabDropped[index], "LEFT", 5, 0)
	end
end

--Select dropped loot
function lootSelect(self)
	local index = 1

	--Clear out all buttons, set selected
	for key, _ in pairs(btnLootTabDropped) do
		if (btnLootTabDropped[key] ~= self) then
			btnLootTabDropped[key]:SetNormalTexture("")
		else
			index = key
		end
	end

	selectedLootDropped = fntLootTabDropped[index]:GetText()

	if selectedLootDropped ~= "" then
		btnLootTabDropped[index]:SetNormalTexture(sButtonSelect)
	
		--Set loot art and name
		for key, _ in pairs(dasLoot) do
			if (dasLoot[key].lName == selectedLootDropped) then
				txtLootTab_LootSelectArt:SetTexture(dasLoot[key].lTexture)
				txtLootTab_LootSelectArt:Show()

				fntLootTab_LootSelectName:SetText(selectedLootDropped)
				fntLootTab_LootSelectName:SetTextColor(GetItemQualityColor(dasLoot[key].lQuality))
				fntLootTab_LootSelectName:Show()

				selectedLootDroppedIndex = dasLoot[key].lLootIndex

				break
			end
		end

		btnLootTab_AnnounceSelected:Enable()
		activateBidButton()
		activateManualButton()
	end
end

--Clear out Dropped Loot buttons
function clearAllLoot()
	selectedLootDropped = ""
	selectedLootDroppedIndex = 0
	selectedLootList = ""
	selectedLootPlayer = ""

	txtLootTab_LootSelectArt:Hide()
	fntLootTab_LootSelectName:Hide()

	for key, _ in pairs(btnLootTabDropped) do
		btnLootTabDropped[key]:Hide()
	end

	btnLootTab_AnnounceSelected:Disable()
	btnLootTab_AnnounceAll:Disable()
	btnLootTab_OpenBid:Disable()
	btnLootTab_CancelBid:Disable()
	btnLootTab_FinalCall:Disable()
	btnLootTab_CloseBid:Disable()
	btnLootTab_ManualSend:Disable()

	ListsDropDown_DropDownOnLoad(self)
	PlayersDropDown_DropDownOnLoad(self)
end

--Open the Loot tab
function openLootTab()
	if not frmMainESK:IsShown() then ESK_Minimize() end
	btnLoot_OnClick()
end

--Happenings when loot window opens
function lootOpened()
	bMasterLooter = false

	if IsInGroup() then

		if IsInRaid() then
			sMajorAnnounceType = "RAID_WARNING"
			sAnnounceType = "RAID"
		else
			sMajorAnnounceType = "PARTY"
			sAnnounceType = "PARTY"
		end

		local _, partyID = GetLootMethod()

		if partyID == 0 then
			local lootCount = GetNumLootItems()
			local goodLootCount = 0
			bMasterLooter = true
			openLootTab()

			clearTable(dasLoot)

			--Gather info on current loot items
			if lootCount > 0 then
				for i = 1, lootCount do
					local texture, item, quantity, quality = GetLootSlotInfo(i)
					local link, class, subclass
					local itemId

					if (GetLootSlotType(i) == LOOT_SLOT_ITEM) then
						_, link, _, _, _, class, subclass = GetItemInfo(GetLootSlotLink(i))
						_, itemId, _, _, _, _, _, _, _ = strsplit(":", link)
					else
						link = nil
						class = nil
						subclass = nil
						itemId = nil
					end

					if quality ~= nil and quality >= GetLootThreshold() then
						goodLootCount = goodLootCount + 1
						dasLoot[goodLootCount] = {
							lTexture = texture,
							lName = item,
							lQuality = quality,
							lLink = link,
							lID = itemID,
							lClass = class,
							lSubclass = subclass,
							lLootIndex = i
						}
					end
				end
			end

			--Remove any empty items 
			for i = #dasLoot, 1, -1 do
				if (dasLoot[i].lName == "" or dasLoot[i].lName == nil) then
					table.remove(dasLoot, i)
				end
			end
			
			--Create Buttons as needed
			local lootButtonCount = #btnLootTabDropped
			goodLootCount = #dasLoot
			while (lootButtonCount < goodLootCount) do
				createLootDroppedButton(lootButtonCount + 1, lootButtonCount * -12)
				lootButtonCount = lootButtonCount + 1
			end

			--Populate loot items
			if #dasLoot > 0 then
				for i = 1, #dasLoot do
					btnLootTabDropped[i]:Show()
					btnLootTabDropped[i]:SetNormalTexture("")
					fntLootTabDropped[i]:SetText(dasLoot[i].lName)
					fntLootTabDropped[i]:SetTextColor(GetItemQualityColor(dasLoot[i].lQuality))
				end
				btnLootTab_AnnounceAll:Enable()
			else
				if frmMainESK:IsShown() then ESK_Minimize() end
			end
		end
	end
end

--Enable Open Bid button
function activateBidButton()
	if (selectedLootDropped ~= "" and selectedLootList ~= "") then
		if bMasterLooter then btnLootTab_OpenBid:Enable() end
	else
		btnLootTab_OpenBid:Disable()
	end
end

--Enable Manual send to button
function activateManualButton()
	if (selectedLootDropped ~= "" and selectedLootPlayer ~= "") then
		btnLootTab_ManualSend:Enable()
	else
		btnLootTab_ManualSend:Disable()
	end
end

--Bid victory
function lootSoundClip(victory)
	if (victory == true) then
		PlaySoundFile(victorySounds[random(#victorySounds)]);
	else
		PlaySoundFile(defeatSounds[random(#defeatSounds)]);
	end
end

--Open bidding
function openBidding()

	if selectedLootDroppedIndex > 0 and GetLootSlotLink(selectedLootDroppedIndex) ~= nil then
		--Setup buttons
		btnLootTab_OpenBid:Disable()
		btnLootTab_CancelBid:Enable()
		btnLootTab_FinalCall:Enable()
		btnLootTab_CloseBid:Enable()

		--Setup variables
		clearTable(playersBid)
		bBiddingOpen = true

		local alert = "Bidding Is Open!"
		SendChatMessage(alert, sMajorAnnounceType)

		alert = "To Bid Type '1' Into /" .. sAnnounceType
		SendChatMessage(alert, sAnnounceType)

		alert = "To Cancel Your Bid Type '0' Into /" .. sAnnounceType
		SendChatMessage(alert, sAnnounceType)

		alert = "List: " .. selectedLootList
		SendChatMessage(alert, sAnnounceType)

		alert = "Item: " .. GetLootSlotLink(selectedLootDroppedIndex)
		SendChatMessage(alert, sAnnounceType)
	end
end

--Final call to bid
function finalcallBidding()
	local alert = "Final Call! Bid Now!"
	SendChatMessage(alert, sMajorAnnounceType)
end

--Cancel bidding
function cancelBidding()
	if bBiddingOpen then
		clearTable(playersBid)
		updateBidders()
		bBiddingOpen = false
		
		local alert = "Bidding Has Been Cancelled!"
		SendChatMessage(alert, sMajorAnnounceType)

		if frmLoot_SKTab:IsShown() then
			--Setup buttons
			btnLootTab_OpenBid:Enable()
			btnLootTab_CancelBid:Disable()
			btnLootTab_FinalCall:Disable()
			btnLootTab_CloseBid:Disable()
		end
	end
end

--Close bidding
function closeBidding()
	if bBiddingOpen then
		bBiddingOpen = false

		if #playersBid > 0 then
			local playerOrder = {}
			local playerMains = {}
			local playerAlts = {}
			local playersListed = Split(ErnSK_Lists[selectedLootList], ";;")
			local bLastAnnounce = true
	
			--Get ordered list of players in current list
			for _, value in pairs(playersListed) do
				if (value ~= nil and value ~= "") then
					local sNameOnly = nameOnly(value)
					table.insert(playerOrder, sNameOnly)
					table.insert(playerMains, sNameOnly)

					--Add any applicable alts
					if (ErnSK_Alts[sNameOnly] ~= nil and ErnSK_Alts[sNameOnly] ~= "") then
						local altList = Split(ErnSK_Alts[sNameOnly], ";;")
						for _, value2 in pairs(altList) do
							if (value2 ~= nil and value2 ~= "") then
								table.insert(playerOrder, nameOnly(value2))
								table.insert(playerAlts, nameOnly(value2))
							end
						end
					end
				end
			end

			--Determine winner
			local sWinner = ""
			for _, value1 in pairs(playerOrder) do
				for _, value2 in pairs(playersBid) do
					if (value1 == value2) then 
						sWinner = value1
						break
					end
				end
				if sWinner ~= "" then break end
			end

			local alert = ""
			if sWinner ~= "" then

				--Send winner their reward
				local raidIndex = 0
				local groupCount = GetNumGroupMembers()
				
				for i = 1, groupCount do
					local candidate = GetMasterLootCandidate(selectedLootDroppedIndex, i)
					if (string.find(candidate, "-") == nil) then
						candidate = candidate .. "-" .. GetRealmName() 
					end

					if candidate == sWinner then
						-- Retrieve unitID tag, more consistent in telling if in range or not for both party and raid
						local playerInfo = Split(candidate, "-")
						local unitID = GetUnitID(playerInfo[1], playerInfo[2])
						
						if UnitInRange(unitID) or UnitIsVisible(unitID) then
							GiveMasterLoot(selectedLootDroppedIndex, i)
						
							--Kill player on list

							---Determine if main and/or alt
							local bMain = false
							local bAlt = false

							----See if Main (actually on the List)
							for _, value in pairs(playerMains) do
								if (value == sWinner) then 
									bMain = true 
									break
								end
							end

							----See if Alt (associated with winner)
							for _, value in pairs(playerAlts) do
								if (value == sWinner) then 
									bAlt = true 
									break
								end
							end

							-- If an Alt and not listed on the selected list, find their Main
							if bAlt and not bMain then
								local bSet = false
								for key, value in pairs(ErnSK_Alts) do
									local altList = Split(ErnSK_Alts[key], ";;")
									for _, value2 in pairs(altList) do
										if (value2 ~= nil and value2 ~= "") then
											if (nameOnly(value2) == sWinner) then
												sWinner = key
												bSet = true
												break
											end
										end
									end
									if bSet then break end
								end
							end

							--- Set the List and Player needing to be dropped
							selectedList = selectedLootList
							selectedPlayer = sWinner

							movePlayerBOTTOM()

							--Update other players
							SendAddonMessage("ESK_LISTS_START", selectedList, "RAID")
							performSync()

							--Victory sound
							SendAddonMessage("ESK_BID", "WIN", "WHISPER", candidate)
						
							sWinner = candidate

							break
						else
							--Perform these actions when the winner is out of range
							alert = "The Winner, ".. candidate .. ", is out of range!"
							SendChatMessage(alert, sMajorAnnounceType)
							print("|cffff0000 <ESK ALERT> |cff00FF7F The winner is out of range.  No changes made to lists nor was loot distributed.")
							bLastAnnounce = false

							--Clear out loot buttons
							for key, _ in pairs(btnLootTabDropped) do
								btnLootTabDropped[key]:SetNormalTexture("")
							end
							selectedLootDroppedIndex = 0
							selectedLootDropped = ""
							txtLootTab_LootSelectArt:Hide()
							fntLootTab_LootSelectName:Hide()

							break
						end
					end
				end

				--Lose sound
				for _, val in pairs(playersBid) do
					if val ~= sWinner then SendAddonMessage("ESK_BID", "LOSE", "WHISPER", val) end
				end

				alert = "The Winner Is " .. sWinner .. "!"
			else
				alert = "No Qualified Bidders!"
			end

			if bLastAnnounce then SendChatMessage(alert, sMajorAnnounceType) end

			btnLootTab_OpenBid:Disable()
		else
			local alert = "No Bids Were Received!"
			SendChatMessage(alert, sMajorAnnounceType)

			btnLootTab_OpenBid:Enable()
		end

		btnLootTab_CloseBid:Disable()
		btnLootTab_FinalCall:Disable()
		btnLootTab_CancelBid:Disable()

		clearTable(playersBid)
		updateBidders()
	end
end

--Update bidding
function updateBidders()
	local sCurrentBidders = ""
	for _, value in pairs(playersBid) do
		sCurrentBidders = sCurrentBidders .. value .. "\n"
	end

	fntLootTab_Bidding:SetText(sCurrentBidders)
end

--Create Bidders fontstring
function createBiddersFontstring()
	scrLootTab_BiddersChild:CreateFontString("fntLootTab_Bidding", "OVERLAY", "fntLootTab_Bidders_Template")
	fntLootTab_Bidding:SetPoint("TOPLEFT", scrLootTab_BiddersChild, "TOPLEFT")
end


-------------------
-- BUTTONS
-------------------

function btnLootTab_AnnounceSelected_OnClick()
	if (selectedLootDroppedIndex > 0 and GetLootSlotLink(selectedLootDroppedIndex) ~= nil) then
		local alert = ""..GetLootSlotLink(selectedLootDroppedIndex)
		SendChatMessage(alert, sAnnounceType)
	end
end

function btnLootTab_AnnounceAll_OnClick()
	if #dasLoot > 0 then
		for i = 1, #dasLoot do
			if GetLootSlotLink(dasLoot[i].lLootIndex) ~= nil then
				local alert = "".. GetLootSlotLink(dasLoot[i].lLootIndex)
				SendChatMessage(alert, sAnnounceType)
			end
		end
	end
end

function btnLootTab_AbsentToggle_OnClick()
	toggleAbsentMode()
end

function btnLootTab_OpenBid_OnClick()
	openBidding()
end

function btnLootTab_CloseBid_OnClick()
	closeBidding()
end

function btnLootTab_FinalCall_OnClick()
	finalcallBidding()
end

function btnLootTab_CancelBid_OnClick()
	cancelBidding()
end

function btnLootTab_ManualSend_OnClick()
	local groupCount = GetNumGroupMembers()
	for i = 1, groupCount do
		local candidate = GetMasterLootCandidate(selectedLootDroppedIndex, i)

		if (string.find(candidate, "-") == nil) then
			candidate = candidate .. "-" .. GetRealmName() 
		end

		if candidate == selectedLootPlayer then
			local playerInfo = Split(candidate, "-")
			local unitID = GetUnitID(playerInfo[1], playerInfo[2])
						
			if UnitInRange(unitID) or UnitIsVisible(unitID) then
				GiveMasterLoot(selectedLootDroppedIndex, i)

				--Victory sound
				SendAddonMessage("ESK_BID", "WIN", "WHISPER", selectedLootPlayer)
				break
			else
				print("|cffff0000 <ESK ALERT> |cff00FF7F Selected player is out of range!")
			end
		end
	end
end



-------------------
-- TOOL TIPS
-------------------

--Find and set tooltip's correct loot item
function findLootSlot(itemName)
	local lootCount = GetNumLootItems()
	if lootCount > 0 then
		for i = 1, lootCount do
			local _, item = GetLootSlotInfo(i)
			if (item == itemName) then
				GameTooltip:SetLootItem(i)
				break
			end
		end
	end
end

--Display item information in tooltip (selected item)
function EnterLootSelected(self)
	if (selectedLootDropped ~= "") then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -50)
		findLootSlot(selectedLootDropped)
		GameTooltip:Show()
	end
end

--Display item information in tooltip (listed items)
function EnterLootHighlight(self)
	local sLootHighlighted = ""
	
	GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -50)
	
	--Determine which item is being hovered over
	for key, _ in pairs(btnLootTabDropped) do
		if (btnLootTabDropped[key] == self) then
			sLootHighlighted = fntLootTabDropped[key]:GetText()
			break
		end
	end
	
	findLootSlot(sLootHighlighted)
	
	GameTooltip:Show()
end

--Hide tooltip
function LeaveLootHighlight(self)
	GameTooltip:Hide()
end



-------------------
-- DROP DOWNS
-------------------
---> Lists Drop Down
------> Drop Down Select
function ListsDropDown_Select(self)
	UIDropDownMenu_SetSelectedID(selLootTab_Lists, self:GetID())
	selectedLootList = self:GetText()
	currentSelectedLootList = selectedLootList
	activateBidButton()
end

------> Drop Down Populate
function ListsDropDown_InitializeDropDown(self, level)
	local info = UIDropDownMenu_CreateInfo()

	info.text = "<Lists>"
	info.value = "<Lists>"
	info.isTitle = 1
	UIDropDownMenu_AddButton(info, level)

	for key, val in pairs(listAdded) do
		info = UIDropDownMenu_CreateInfo()
		info.text = val
		info.value = val
		info.func = ListsDropDown_Select
		UIDropDownMenu_AddButton(info, level)
	end
end

------> Drop Down Load
function ListsDropDown_DropDownOnLoad(self)
	UIDropDownMenu_Initialize(selLootTab_Lists, ListsDropDown_InitializeDropDown)
	
	UIDropDownMenu_JustifyText(selLootTab_Lists, "LEFT")

	if currentSelectedLootList == "" then UIDropDownMenu_SetSelectedID(selLootTab_Lists, 1)
	else 
		UIDropDownMenu_SetSelectedValue(selLootTab_Lists, currentSelectedLootList)
		selectedLootList = currentSelectedLootList
	end
end


---> Players Drop Down
------> Drop Down Select
function PlayersDropDown_Select(self)
	UIDropDownMenu_SetSelectedID(selLootTab_Players, self:GetID())
	selectedLootPlayer = self:GetText()
	activateManualButton()
end

------> Drop Down Populate
function PlayersDropDown_InitializeDropDown(self, level)
	local info = UIDropDownMenu_CreateInfo()

	info.text = "<Raid/Party>"
	info.value = "<Raid/Party>"
	info.isTitle = 1
	UIDropDownMenu_AddButton(info, level)

	local groupCount = GetNumGroupMembers()
	if groupCount > 0 then
		for i = 1, groupCount do
			local name, _, _, _, class = GetRaidRosterInfo(i)
			
			if (string.find(name, "-") == nil) then name = name .. "-" .. GetRealmName() end

			info = UIDropDownMenu_CreateInfo()
			info.text = name
			info.value = name
			info.func = PlayersDropDown_Select
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

------> Drop Down Load
function PlayersDropDown_DropDownOnLoad(self)
	UIDropDownMenu_Initialize(selLootTab_Players, PlayersDropDown_InitializeDropDown)
	UIDropDownMenu_SetSelectedID(selLootTab_Players, 1)
	UIDropDownMenu_JustifyText(selLootTab_Players, "LEFT")
end
