-- TODO : transcriptor imports
-- TODO : add castIDs

local _, iEET = ...
local cleuEventsToTrack = {
	['SPELL_CAST_START'] = 'SC_START',
	['SPELL_CAST_SUCCESS'] = 'SC_SUCCESS',
	['SPELL_AURA_APPLIED'] = '+SAURA',
	['SPELL_AURA_REMOVED'] = '-SAURA',
	['SPELL_AURA_APPLIED_DOSE'] = '+SA_DOSE',
	['SPELL_AURA_REMOVED_DOSE'] = '-SA_DOSE',
	['SPELL_AURA_REFRESH'] = 'SAURA_R',
	['SPELL_CAST_FAILED'] = 'SC_FAILED',
	['SPELL_CREATE'] = 'SPELL_CREATE',
	['SPELL_SUMMON'] = 'SPELL_SUMMON',
	['SPELL_HEAL'] = 'SPELL_HEAL',
	['SPELL_DISPEL'] = 'SPELL_DISPEL',
	['SPELL_INTERRUPT'] = 'S_INTERRUPT',
	['SPELL_STOLEN'] = 'SPELL_STOLEN',

	['SPELL_PERIODIC_CAST_START'] = 'SPC_START',
	['SPELL_PERIODIC_CAST_SUCCESS'] = 'SPC_SUCCESS',
	['SPELL_PERIODIC_AURA_APPLIED'] = '+SPAURA',
	['SPELL_PERIODIC_AURA_REMOVED'] = '-SPAURA',
	['SPELL_PERIODIC_AURA_APPLIED_DOSE'] = '+SPA_DOSE',
	['SPELL_PERIODIC_AURA_REMOVED_DOSE'] = '-SPA_DOSE',
	['SPELL_PERIODIC_AURA_REFRESH'] = 'SPAURA_R',
	['SPELL_PERIODIC_CAST_FAILED'] = 'SPC_FAILED',
	['SPELL_PERIODIC_CREATE'] = 'SP_CREATE',
	['SPELL_PERIODIC_SUMMON'] = 'SP_SUMMON',
	['SPELL_PERIODIC_HEAL'] = 'SP_HEAL',

	['UNIT_DIED'] = 'UNIT_DIED',
}
local seenWidgets = {}
do
	local validUnits = {
		boss1 = true, boss2 = true, boss3 = true, boss4 = true, boss5 = true,
		target = true, focus = true,
		nameplate1 = true, nameplate2 = true, nameplate3 = true, nameplate4 = true, nameplate5 = true,
		nameplate6 = true, nameplate7 = true, nameplate8 = true, nameplate9 = true, nameplate10 = true,
		nameplate11 = true, nameplate12 = true, nameplate13 = true, nameplate14 = true, nameplate15 = true,
		nameplate16 = true, nameplate17 = true, nameplate18 = true, nameplate19 = true, nameplate20 = true,
		nameplate21 = true, nameplate22 = true, nameplate23 = true, nameplate24 = true, nameplate25 = true,
		nameplate26 = true, nameplate27 = true, nameplate28 = true, nameplate29 = true, nameplate30 = true,
		nameplate31 = true, nameplate32 = true, nameplate33 = true, nameplate34 = true, nameplate35 = true,
		nameplate36 = true, nameplate37 = true, nameplate38 = true, nameplate39 = true, nameplate40 = true,
	}
	for i = 1, 40 do
		validUnits["nameplate"..i] = true
	end
	function iEET.IsValidUnit(unitID)
		if not unitID then return end
		if iEET.ignoreFilters or validUnits[unitID] then
			return true
		end
	end
end
-- upvalues
local tonumber, tinsert, GetTime, UnitGUID, UnitName, sformat, UnitClass, GetRaidRosterInfo, sfind = tonumber, table.insert, GetTime, UnitGUID, UnitName, string.format, UnitClass, GetRaidRosterInfo, string.find

local addon = CreateFrame('frame')
addon:RegisterEvent('ENCOUNTER_START')
addon:RegisterEvent('ENCOUNTER_END')
addon:RegisterEvent('ADDON_LOADED')
addon:RegisterEvent('PLAYER_LOGOUT')
addon:SetScript('OnEvent', function(self, event, ...)
	self[event](self, ...)
end)
local tcopy = function(t)
	local temp = {}
	for k,v in pairs(t) do
		temp[k] = v
	end
	return temp
end
iEET.eventFunctions = {}
local function checkForSpecialCategory(spellID, e)
	if spellID and iEET.dispels[spellID] then
		return iEET.specialCategories.Dispel
	elseif spellID and iEET.interrupts[spellID] then
		return iEET.specialCategories.Interrupt
	elseif spellID and iEET.taunts[spellID] then
		return iEET.specialCategories.Taunt
	elseif e == 25 then
		return iEET.specialCategories.Death
	elseif e == 33 then
		return iEET.specialCategories.NPCSpawn
	elseif e == 34 then
		return iEET.specialCategories.PowerUpdate
	end
end
local function formatKV(k,v)
	return sformat("%s : %s", k or "ERROR report to author", tostring(v))
end
local function addToTooltip(spellID, ...)
	if spellID then
		GameTooltip:SetHyperlink(sformat('spell:%s',spellID))
	end
	local t = {...}
	for k,v in ipairs(t) do
		GameTooltip:AddLine(tostring(v))
	end
end
local currentlyLogging = false
iEET.IEEUnits = {}
-- default handlers
local defaults = {
	unitEvents = {},
	chats = {},
}
defaults.unitEvents.data = {
	["event"] = 1,
	["time"] = 2,
	["sourceGUID"] = 3,
	["sourceName"] = 4,
	["unitID"] = 5,
	["spellName"] = 6,
	["spellID"] = 7,
	["hp"] = 8,
	["castGUID"] = 9,
}
defaults.unitEvents.gui = function(args, getGUID)
	local d = defaults.unitEvents.data
	local guid = sformat("%s-%s-%s-%s", args[d.event], args[d.spellID], (args[d.sourceGUID or args[d.sourceName] or ""]), args[d.unitID]) -- Create unique string from event + spellID + sourceGUID
	if getGUID then
		return guid
	end
	return guid, -- 1
	checkForSpecialCategory(args[d.spellID], args[d.event]), -- 2
	args[d.spellName], -- 3
	args[d.sourceName], -- 4
	args[d.unitID], -- 5
	args[d.hp], -- 6
	{unitID = args[d.unitID], spellID = args[d.spellID], casterName = args[d.sourceName]} -- 7
end
defaults.unitEvents.import = function(args)
	local d = defaults.unitEvents.data
	args[d.spellID] = tonumber(args[d.spellID])
	args[d.hp] = tonumber(args[d.hp])
	return args
end
defaults.unitEvents.hyperlink = function(col, data)
	local d = defaults.unitEvents.data
	if col == 7 or col == 8 then return end
	if col == 4 then
		if C_Spell.DoesSpellExist(data[d.spellID]) then -- TODO : CHECK if it requires caching first, live/ptr check
			addToTooltip(data[d.spellID],
				formatKV("Spell ID", data[d.spellID]),
				formatKV("castGUID", data[d.castGUID])
			)
		else
			addToTooltip(nil,
				formatKV("Spell ID", data[d.spellID]),
				formatKV("Spell name", data[d.spellName]),
				formatKV("castGUID", data[d.castGUID])
			)
		end
	elseif col == 5 or col == 6 then
		addToTooltip(nil,
			formatKV("Source name", data[d.sourceName]),
			formatKV("Source GUID", data[d.sourceGUID]),
			formatKV("Unit ID", data[d.unitID])
		)
	end
	return true
end
defaults.unitEvents.chatLink = function(col, data)
	-- ignore column for now
	local d = defaults.unitEvents.data
	if not data[d.spellID] then return end
	return GetSpellLink(data[d.spellID])
end
defaults.chats = {}
defaults.chats.data = {
	["event"] = 1,
	["time"] = 2,
	["sourceName"] = 3,
	["message"] = 4,
}
defaults.chats.gui = function(args, getGUID)
	local d = defaults.chats.data
	local guid = sformat("%s-%s-%s", args[d.event], args[d.sourceName], args[d.message]) -- Create unique string from message + sourceName
	if getGUID then return guid end
	return guid, -- 1
		nil, -- 2
		args[d.message], -- 3
		args[d.sourceName], -- 4
		nil, -- 5
		nil, -- 6
		{casterName = args[d.sourceName]} -- 7
end
defaults.chats.hyperlink = function(col, data)
	if col == 4 then
		addToTooltip(nil, data[defaults.chats.data.message])
		return true
	elseif col == 5 then
		addToTooltip(nil, data[defaults.chats.data.sourceName])
		return true
	end
end
defaults.chats.chatLink = function(col, data)	return end

local function defaultUnitHandler(event, unitID, castGUID, spellID, spellName, returnOnly)
	if iEET.IsValidUnit(unitID) then
		local sourceGUID = UnitGUID(unitID)
		local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
		if sourceGUID then -- fix for arena id's
			unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
		end
		if iEET.ignoreFilters or (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and (iEET.approvedSpells[spellID] or iEET.taunts[spellID])) or not sourceGUID then
			local sourceName = UnitName(unitID)
			local chp = UnitHealth(unitID)
			local maxhp = UnitHealthMax(unitID)
			local php = nil
			if chp and maxhp then
				php = math.floor(chp/maxhp*1000+0.5)/10
			end
			if not iEET.npcIgnoreList[tonumber(npcID)] then
				if returnOnly then
					return true, sourceGUID, sourceName, php
				end
				if not iEET.ignoredSpells[spellID] then
					local d = defaults.unitEvents.data
					local t = {
						[d.event] = event,
						[d.time] = GetTime(),
						[d.sourceGUID] = sourceGUID,
						[d.sourceName] = sourceName,
						[d.unitID] = unitID,
						[d.spellName] = spellName or Spell:CreateFromSpellID(spellID):GetSpellName(),
						[d.spellID] = spellID,
						[d.hp] = php,
						[d.castGUID] = castGUID,
					}
					table.insert(iEET.data, t);
					iEET:OnscreenAddMessages(t)
				end
			end
		end
	end
end
iEET.ignoreFilters = false
local ignoreFiltersTimer

local function checkValid(arg, searchValue, operator)
	if not arg or not searchValue or not operator then return false end
	if operator == "exactly" or operator == "is" or operator == "class" or operator == "role" then
		return arg == searchValue
	elseif operator == "auraType" then
		if searchValue == "0" then
			searchValue = "DEBUFF"
		else
			searchValue = "BUFF"
		end
		return arg == searchValue
	elseif operator == "higher" then
		return arg >= searchValue
	elseif operator == "lower" then
		return arg <= searchValue
	elseif operator == "between" then
		return arg >= searchValue.from and arg <= searchValue.to
	elseif operator == "contains" then
		return sfind(tostring(arg):lower(), tostring(searchValue):lower())
	end
	-- just for safety, shouldn't get this far
	iEET:print(operator .. "-operator not found for filtering.")
	return false
end
local collapses = iEET.collapses
local function defaultFiltering(args, keyIDList, filters, eventID)
	if not eventID then
		iEET:print("Error - filtering without eventID: " .. args[1])
		return true -- debug
	end
	-- check if we are ignoring current event based on some filtering before checking "real" filters
	if keyIDList.unitID then
		local _unitID = args[keyIDList.unitID]
		if _unitID and iEET.ignoring.unitIDs[collapses[_unitID] or _unitID] then
			return false
		end
	end
	do
		local sc = checkForSpecialCategory(nil, args[1])
		if iEET.ignoring.specialCategories[sc] then return false end
	end
	if keyIDList.spellID then
		local sc = checkForSpecialCategory(args[keyIDList.spellID], args[1])
		local _spellID = args[keyIDList.spellID]
		if (_spellID and iEET.ignoring.spellIDs[_spellID]) or (sc and iEET.ignoring.specialCategories[sc]) then
			return false
		end
	end
	if keyIDList.sourceName then
		local _sourceName = args[keyIDList.sourceName]
		if _sourceName and iEET.ignoring.npcNames[_sourceName] then
			return false
		end
	end
	if iEET.generalSearch then
		for _,v in pairs(args) do
			if checkValid(v, iEET.generalSearch, "contains") then
				return true
			end
		end
	elseif #iEETConfig.filtering == 0 then return true end
	local shouldShow = false
	for _,singleFilter in pairs(filters) do
			shouldShow = false
			if singleFilter.events and not singleFilter.events[eventID] then
			elseif not singleFilter.filters then 
				return true
			else
				for _, f in pairs(singleFilter.filters) do
					if f.key == "any" then
						for _,v in pairs(args) do
							if checkValid(v, f.val, f.operator) then
								shouldShow = true
								break -- Go to next
							end
						end
					elseif not keyIDList[f.key] then break -- should not happen, args were changed during update or smh
					elseif checkValid(args[keyIDList[f.key]], f.val, f.operator) then
						shouldShow = true
					else
						shouldShow = false
						break -- Go to next
					end
				end
				if shouldShow then return true end
			end
	end
	return false -- No valid filter found, don't show
end
function addon:ADDON_LOADED(addonName)
	if addonName == 'iEncounterEventTracker' then
		C_ChatInfo.RegisterAddonMessagePrefix('iEET')
		C_ChatInfo.RegisterAddonMessagePrefix('iEETSync')
		addon:RegisterEvent('CHAT_MSG_ADDON')
		iEETConfig = iEETConfig or {}
		iEET_Data = iEET_Data or {}
		if iEETConfig.version and iEETConfig.version < 1.8 then
			iEETConfig.tracking = nil
		end
		if iEETConfig.version and iEETConfig.version < 2.0 then
			iEETConfig.filtering = nil
			iEET:print("This is one time only message with authors contact information, feel free to use any of them if you run into any problems.\nBnet:\n    Ironi#2880 (EU)\nDiscord:\n    Ironi#2880\n    https://discord.gg/stY2nyj")
		end
		iEET:LoadDefaults()
		--Remove extra spells from CustomWhiteList (spells that have been added to iEET.approvedSpells)
		local WLDelete = {}
		for spellID,_ in pairs(iEETConfig.CustomWhitelist) do
			if iEET.approvedSpells[spellID] then
				WLDelete[spellID] = true
			end
		end
		for spellID,_ in pairs(WLDelete) do
			iEETConfig.CustomWhitelist = nil
		end
		WLDelete = nil
		iEETConfig.version = iEET.version
		addon:UnregisterEvent('ADDON_LOADED')
	end
end
do
	local eventID = 63
	iEET.eventFunctions[eventID] = {
		data = defaults.chats.data, 
		gui = defaults.chats.gui,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, defaults.chats.data, filters, eventID, ...)
		end,
		hyperlink = defaults.chats.hyperlink,
		import = function(args)
			return args
		end,
		chatLink = function(col, data) return end,
	}
	local d = iEET.eventFunctions[eventID].data
	function addon:CHAT_MSG_ADDON(prefix,msg,chatType,sender)
		if prefix == 'iEET' then
			if msg == 'userCheck' then
				C_ChatInfo.SendAddonMessage('iEET', string.format('userCheckReply;;%s;;%s',  iEETConfig.version, (iEETConfig.autoSave and '1' or '0')), chatType)
			elseif msg:find('userCheckReply') then -- unnecessary check for now, but use it so it will also work in future
				local v,s = msg:match('userCheckReply;;(%d%.%d+);;(%d)')
				if v and s then -- nil check to filter out idiots
					iEET.addonUsers[sender] = {
						version = v,
						autoSave = s,
					}
				end
			end
		elseif prefix == "iEETSync" then -- TO DO: add syncs to events
			if not currentlyLogging or sender == UnitName('player') then return end
			local t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.sourceName] = sender,
				[d.message] = msg,
			}
			tinsert(iEET.data, t)
			iEET:OnscreenAddMessages(t)
		end
	end
end
function addon:PLAYER_LOGOUT()
	if iEET.forceRecording then
		iEET:Force()
	end
end
do -- ENCOUNTER_START
	local eventID = 27
	local d = {
		["event"] = 1,
		["time"] = 2,
		["encounterID"] = 3,
		["encounterName"] = 4,
		["logger"] = 5,
		["mapID"] = 6,
	}
	iEET.eventFunctions[eventID] = {
		data = d,
		filtering = function() -- Always show ENCOUNTER_START
			return true
		end,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s-%s", eventID, args[d.event], args[d.encounterID]) -- Create unique string from event + encounterID
			if getGUID then return guid end
			return guid, iEET.specialCategories.StartLogging, sformat("Logger: %s", args[d.logger]), args[d.encounterName], args[d.encounterID]
		end,
		import = function(args)
			args[d.encounterID] = tonumber(args[d.encounterID])
			return args
		end,
		hyperlink = function(col, data)
			if col == 7 or col == 8 then
				return
			end
			addToTooltip(nil, 
				formatKV("Logger", data[d.logger]),
				formatKV("Encounter ID", data[d.encounterID]),
				formatKV("Encounter name", data[d.encounterName]),
				formatKV("mapID", data[d.mapID])
			)
			return true
		end,
		chatLink = function(col, data)
			-- TODO: maybe add link to encounter journal?
			return
		end
	}
	function addon:ENCOUNTER_START(encounterID, encounterName, difficultyID, raidSize,...)
		local mapID = select(8, GetInstanceInfo())
		if not iEET.forceRecording then
			iEET:StartRecording()
			iEET.encounterInfoData = { --TODO
				['s'] = GetTime(),
				['eN'] = encounterName,
				['pT'] = date('%y.%m.%d %H:%M'), -- y.m.d instead of d.m.y for easier sorting
				['fT'] = '00:00',
				['rS'] = raidSize,
				['k'] = 0,
				['zI'] = mapID,
				['v'] = iEET.version,
				['eI'] = encounterID,
				['d'] = difficultyID,
				['lN'] = UnitName('player')
			}
		end
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.encounterID] = encounterID,
			[d.encounterName] = encounterName,
			[d.logger] = UnitName('player'),
			[d.mapID] = mapID,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- ENCOUNTER_END
	local eventID = 28
	local d = {
		["event"] = 1,
		["time"] = 2,
		["encounterID"] = 3,
		["encounterName"] = 4,
		["logger"] = 5,
		["kill"] = 6,
	}
	iEET.eventFunctions[eventID] = {
		data = d,
		filtering = function() -- Always show ENCOUNTER_END
			return true
		end,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", eventID, args[d.event], args[d.encounterID]) -- Create unique string from event + encounterID
			if getGUID then return guid end
			return guid, nil, sformat("Logger: %s", args[d.logger]), (args[d.kill] == 1 and "Victory!" or "Wipe"), args[d.encounterID]
		end,
		import = function(args)
			args[d.encounterID] = tonumber(args[d.encounterID]) -- encounterID
			args[d.kill] = tonumber(args[d.kill]) -- kill
			return args
		end,
		hyperlink = function(col, data)
			if col == 7 or col == 8 then
				return
			end
			addToTooltip(nil, 
				formatKV("Logger", data[d.logger]),
				formatKV("Encounter ID", data[d.encounterID]),
				formatKV("Encounter name", data[d.encounterName]),
				formatKV("Kill", data[d.kill])
			)
			return true
		end,
		chatLink = function(col, data) return end
	}
	function addon:ENCOUNTER_END(EncounterID, encounterName, difficultyID, raidSize, kill,...)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.encounterID] = EncounterID,
			[d.encounterName] = encounterName,
			[d.logger] = UnitName('player'), -- logger
			[d.kill] = kill,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
		if not iEET.forceRecording then
			if iEET:ShouldIgnoreEncounter(EncounterID) then return end
			if iEET.encounterInfoData then
				iEET.encounterInfoData.fT = iEET.encounterInfoData.s and date('%M:%S', (GetTime() - iEET.encounterInfoData.s)) or '00:00' -- if we are missing start time for some reason
				iEET.encounterInfoData.d = difficultyID
				iEET.encounterInfoData.k = kill
				iEET.encounterInfoData.rS = raidSize
			else
				local mapID = select(8, GetInstanceInfo())
				iEET.encounterInfoData = {
					['s'] = GetTime(),
					['eN'] = encounterName,
					['pT'] = date('%y.%m.%d %H:%M'), -- y.m.d instead of d.m.y for easier sorting
					['fT'] = '00:00',
					['d']= difficultyID,
					['rS'] = raidSize,
					['k'] = kill,
					['zI'] = mapID,
					['v'] = iEET.version,
					['eI'] = EncounterID,
					['lN'] = UnitName('player')
				}
			end
			iEET:StopRecording(nil, EncounterID)
		end
	end
end
do -- UNIT_SPELLCAST_SUCCEEDED
	local eventID = 26
	iEET.eventFunctions[eventID] = defaults.unitEvents
	iEET.eventFunctions[eventID].filtering = function(args, filters, ...)
		return defaultFiltering(args, defaults.unitEvents.data, filters, eventID, ...)
	end
	function addon:UNIT_SPELLCAST_SUCCEEDED(unitID, castGUID, spellID)
		defaultUnitHandler(eventID, unitID, castGUID, spellID)
	end
end
do -- UNIT_SPELLCAST_START
	local eventID = 39
	iEET.eventFunctions[eventID] = defaults.unitEvents
	iEET.eventFunctions[eventID].filtering = function(args, filters, ...)
		return defaultFiltering(args, defaults.unitEvents.data, filters, eventID, ...)
	end
	function addon:UNIT_SPELLCAST_START(unitID, castGUID, spellID)
		defaultUnitHandler(eventID, unitID, castGUID, spellID)
	end
end
do -- UNIT_SPELLCAST_STOP
	local eventID = 61
	iEET.eventFunctions[eventID] = defaults.unitEvents
	iEET.eventFunctions[eventID].filtering = function(args, filters, ...)
		return defaultFiltering(args, defaults.unitEvents.data, filters, eventID, ...)
	end
	function addon:UNIT_SPELLCAST_STOP(unitID, castGUID, spellID)
		defaultUnitHandler(eventID, unitID, castGUID, spellID)
	end
end
do -- UNIT_SPELLCAST_CHANNEL_START
	local eventID = 40
	iEET.eventFunctions[eventID] = defaults.unitEvents
	iEET.eventFunctions[eventID].filtering = function(args, filters, ...)
		return defaultFiltering(args, defaults.unitEvents.data, filters, eventID, ...)
	end
	function addon:UNIT_SPELLCAST_CHANNEL_START(unitID, castGUID, spellID)
		defaultUnitHandler(eventID, unitID, castGUID, spellID)
	end
end
do -- UNIT_SPELLCAST_CHANNEL_STOP
	local eventID = 60
	iEET.eventFunctions[eventID] = defaults.unitEvents
	iEET.eventFunctions[eventID].filtering = function(args, filters, ...)
		return defaultFiltering(args, defaults.unitEvents.data, filters, eventID, ...)
	end
	function addon:UNIT_SPELLCAST_CHANNEL_STOP(unitID, castGUID, spellID)
		defaultUnitHandler(eventID, unitID, castGUID, spellID)
	end
end
do -- UNIT_SPELLCAST_INTERRUPTIBLE
	local eventID = 41
	local d = {
		["event"] = 1,
		["time"] = 2,
		["sourceGUID"] = 3,
		["sourceName"] = 4,
		["unitID"] = 5,
		["hp"] = 6,
	}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", eventID, (args[d.sourceGUID] or args[d.sourceName] or "")) -- Create unique string from event + sourceGUID
			if getGUID then return guid end
			return guid, -- 1
				nil, -- 2
				"-"..iEET.fakeSpells.InterruptShield.name, -- 3
				args[d.sourceName], -- 4
				args[d.unitID], -- 5
				args[d.hp], -- 6
				{unitID = args[d.unitID], casterName = args[d.sourceName]} -- 7
		end,
		import = function(args)
			args[d.hp] = tonumber(args[d.hp])
			return args
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data)
			if col == 7 or col == 8 or col == 4 then return end
			addToTooltip(nil,
				formatKV("Source name", data[d.sourceName]),
				formatKV("Source GUID", data[d.sourceGUID]),
				formatKV("Unit ID", data[d.unitID])
			)
			return true
		end,
		chatLink = function(col, data) return end,
	}
	function addon:UNIT_SPELLCAST_INTERRUPTIBLE(unitID)
		local isValid, sourceGUID, sourceName, php = defaultUnitHandler(eventID, unitID, nil, nil, nil, true)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceGUID] = sourceGUID,
			[d.sourceName] = sourceName,
			[d.unitID] = unitID,
			[d.hp] = php
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- UNIT_SPELLCAST_NOT_INTERRUPTIBLE
	local eventID = 42
	local d = {
		["event"] = 1,
		["time"] = 2,
		["sourceGUID"] = 3,
		["sourceName"] = 4,
		["unitID"] = 5,
		["hp"] = 6,
	}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", eventID, (args[d.sourceGUID] or args[d.sourceName] or "")) -- Create unique string from event + sourceGUID
			if getGUID then return guid end
			return guid, -- 1
				nil, -- 2
				"+"..iEET.fakeSpells.InterruptShield.name, -- 3
				args[d.sourceName], -- 4
				args[d.unitID], -- 5
				args[d.hp], -- 6
				{unitID = args[d.unitID], casterName = args[d.sourceName]} -- 7
		end,
		import = function(args)
			args[d.hp] = tonumber(args[d.hp])
			return args
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data)
			if col == 7 or col == 8 or col == 4 then return end
			addToTooltip(nil,
				formatKV("Source name", data[d.sourceName]),
				formatKV("Source GUID", data[d.sourceGUID]),
				formatKV("Unit ID", data[d.unitID])
			)
			return true
		end,
		chatLink = function(col, data) return end,
	}
	function addon:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(unitID)
		local isValid, sourceGUID, sourceName, php = defaultUnitHandler(eventID, unitID, nil, nil, nil, true)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceGUID] = sourceGUID,
			[d.sourceName] = sourceName,
			[d.unitID] = unitID,
			[d.hp] = php
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- UNIT_TARGET
	local eventID = 32
	local d = {
		["event"] = 1,
		["time"] = 2,
		["sourceGUID"] = 3,
		["sourceName"] = 4,
		["unitID"] = 5,
		["hp"] = 6,
		["dest"] = 7,
		["destGUID"] = 8,
		["destClass"] = 9,
		["destRole"] = 10,
	}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s-%s", eventID, args[d.unitID], (args[d.sourceGUID] or args[d.sourceName] or "")) -- Create unique string from event + sourceGUID
			if getGUID then return guid end
			return guid, -- 1
				nil, -- 2
				iEET.fakeSpells.UnitTargetChanged.name, -- 3
				sformat("%s (%s)",args[d.unitID], args[d.sourceName]), -- 4
				args[d.dest] or "NONE", -- 5,
				args[d.hp], -- 6
				{unitID = args[d.unitID], spellID = args[d.spellID], casterName = args[d.sourceName]} -- 7
		end,
		import = function(args)
			args[d.hp] = tonumber(args[d.hp])
			args[d.destClass] = tonumber(d.destClass)
			return args
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data)
			if col == 4 or col == 7 or col == 8 then return end
			if col == 5 then 
				addToTooltip(nil,
					formatKV("Source name", data[d.sourceName]),
					formatKV("Source GUID", data[d.sourceGUID]),
					formatKV("Unit ID", data[d.unitID])
				)
			else -- 6
				local class
				if data[d.destClass] then
					class = GetClassInfo(data[d.destClass])
				end
				addToTooltip(nil,
					formatKV("Target name", data[d.dest] or "NONE"),
					formatKV("Target GUID", data[d.destGUID] or ""),
					formatKV("Target class", class or ""),
					formatKV("Target role", data[d.destRole] or "")
				)
			end
			return true
		end,
		chatLink = function(col, data) return end
	}
	function addon:UNIT_TARGET(unitID)
		local isValid, sourceGUID, sourceName, php = defaultUnitHandler(eventID, unitID, nil, nil, nil, true)
		if not isValid then return end
		local targetGUID = UnitGUID(unitID..'target')
		local targetName = UnitName(unitID..'target')
		local targetClass
		local targetRole
		if targetGUID then
			targetClass = iEET.raidComp[targetGUID] and iEET.raidComp[targetGUID].class
			targetRole = iEET.raidComp[targetGUID] and iEET.raidComp[targetGUID].role
		end
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceGUID] = sourceGUID,
			[d.sourceName] = sourceName,
			[d.unitID] = unitID,
			[d.hp] = php,
			[d.dest] = targetName,
			[d.destGUID] = targetGUID,
			[d.destClass] = targetClass,
			[d.destRole] = targetRole,
		}
		table.insert(iEET.data, t);
		iEET:OnscreenAddMessages(t)
	end
end
do -- UNIT_POWER_UPDATE
	local eventID = 34
	local d = {
		["event"] = 1,
		["time"] = 2,
		["sourceGUID"] = 3,
		["sourceName"] = 4,
		["unitID"] = 5,
		["powerName"] = 6,
		["hp"] = 7,
		["tooltip"] = 8,
		["powerPercent"] = 9,
		["powerType"] = 10,
	}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", eventID, (args[d.sourceGUID] or args[d.sourceName] or "")) -- Create unique string from event + sourceGUID
			if getGUID then return guid end
			return guid, -- 1
			iEET.specialCategories.PowerUpdate, -- 2
			iEET.fakeSpells.PowerUpdate.name, -- 3
			args[d.sourceName], -- 4
			args[d.unitID], -- 5
			args[d.hp], -- 6
			{unitID = args[d.unitID], casterName = args[d.sourceName]} -- 7
		end,
		import = function(args)
			args[d.hp] = tonumber(args[d.hp])
			args[d.powerPercent] = tonumber(args[d.powerPercent])
			return args
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data)
			if col == 7 or col == 8 then return end
			if col == 4 then
				addToTooltip(nil, formatKV("Power type", data[d.powerType]), data[d.tooltip])
			elseif col == 5 or col == 6 then 
				addToTooltip(nil,
					formatKV("Source name", data[d.sourceName]),
					formatKV("Source GUID", data[d.sourceGUID]),
					formatKV("Unit ID", data[d.unitID])
			)
			end
			return true
		end,
		chatLink = function(col, data) return end,
	}
	function addon:UNIT_POWER_UPDATE(unitID, powerType)
		local isValid, sourceGUID, sourceName, php = defaultUnitHandler(eventID, unitID, nil, nil, nil, true)
		if not isValid then return end
		if not iEET.savedPowers[powerType] then
			-- Get power type ID
			local powerString = ""
			for _,v in pairs({strsplit("_", powerType)}) do
				powerString = powerString .. string.lower(v):gsub("^%l", string.upper)
			end
			local powerNumber = Enum.PowerType[powerString]
			if not powerNumber then
					powerNumber = UnitPowerType(unitID)
			end
			iEET.savedPowers[powerType] = {
				i = powerNumber,
				n = _G[powerType] or powerType,
			}
		end
		local currentPower = UnitPower(unitID, 	iEET.savedPowers[powerType].i)
		local change = 0
		if iEET.unitPowerUnits[sourceGUID] then -- unit exists, update or add new powerType
			local prev = iEET.unitPowerUnits[sourceGUID][powerType] or 0
			change =  currentPower - prev
			iEET.unitPowerUnits[sourceGUID][powerType] = currentPower --update prev
		end
		if not iEET.unitPowerUnits[sourceGUID] then -- add new sourceguid & powerType
			iEET.unitPowerUnits[sourceGUID] = {
				[powerType] = currentPower
			}
		end
		if change > 0 then
			change = '+' .. change
		end
		local maxPower = UnitPowerMax(unitID,iEET.savedPowers[powerType].i)
		local pUP = 0
		if currentPower and maxPower then
			pUP = math.floor(currentPower/maxPower*1000+0.5)/10
		end
		local tooltipText = string.format('%s %s%%\n%s/%s\n%s',iEET.savedPowers[powerType].n, pUP, currentPower, maxPower, change) --PowerName 50%;50/100;+20
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceGUID] = sourceGUID,
			[d.sourceName] = sourceName,
			[d.unitID] = unitID,
			[d.powerName] = iEET.savedPowers[powerType].n .. ' Update',
			[d.hp] = php,
			[d.tooltip] = tooltipText,
			[d.powerPercent] = pUP,
			[d.powerType] = powerType}
		table.insert(iEET.data, t);
		iEET:OnscreenAddMessages(t)
	end
end
do -- UNIT_ENTERING_VEHICLE
	local eventID = 53
	local d = {
		["event"] = 1,
		["time"] = 2,
		["sourceGUID"] = 3,
		["sourceName"] = 4,
		["unitID"] = 5,
		["vehicleGUID"] = 6,
		["hasVehicleUI"] = 7,
		["isControlSeat"] = 8,
		["mayChooseExit"] = 9,
		["hasPitch"] = 10,
		["vehicleID"] = 11,
		["slots"] = 12,
	}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", eventID, (args[d.sourceGUID] or args[d.sourceName] or "")) -- Create unique string from event + sourceGUID
			if getGUID then return guid end
			return guid, -- 1
				nil, -- 2
				iEET.fakeSpells.VehicleEntering.name, -- 3
				args[d.sourceName], -- 4
				nil, -- 5
				args[d.unitID], -- 6
				{unitID = args[d.unitID], casterName = args[d.sourceName]} -- 7
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data)
			if col == 6 or col == 7 or col == 8 then return end
			if col == 4 then
				addToTooltip(nil,
					formatKV("unitID", data[d.unitID]),
					formatKV("hasVehicleUI", data[d.hasVehicleUI]),
					formatKV("isControlSeat", data[d.isControlSeat]),
					formatKV("vehicleID", data[d.vehicleID]),
					formatKV("vehicleGUID", data[d.vehicleGUID]),
					formatKV("mayChooseExit", data[d.mayChooseExit]),
					formatKV("hasPitch", data[d.hasPitch]),
					formatKV("slots", data[d.slots])
				)
			else -- 5
				addToTooltip(nil,
					formatKV("Source name", data[d.sourceName]),
					formatKV("Source GUID", data[d.sourceGUID]),
					formatKV("Unit ID", data[d.unitID])
				)
			return true
			end
		end,
		import = function(args)
			return args
		end,
		chatLink = function(col, data) return end,
	}
	function addon:UNIT_ENTERING_VEHICLE(unitID, hasVehicleUI,isControlSeat,vehicleID, vehicleGUID, mayChooseExit, hasPitch)
		local sourceGUID = UnitGUID(unitID)
		local sourceName = UnitName(unitID)
		local slots = 0
		if vehicleID and vehicleID ~= 0 then
			local t,i = GetVehicleUIIndicator(vehicleID)
			slots = i
		end
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceGUID] = sourceGUID,
			[d.sourceName] = sourceName,
			[d.unitID] = unitID,
			[d.vehicleGUID] = vehicleGUID,
			[d.hasVehicleUI] = hasVehicleUI,
			[d.isControlSeat] = isControlSeat,
			[d.mayChooseExit] = mayChooseExit,
			[d.hasPitch] = hasPitch,
			[d.vehicleID] = vehicleID,
			[d.slots] = slots,
		}
		table.insert(iEET.data, t);
		iEET:OnscreenAddMessages(t)
	end
end
do -- UNIT_ENTERED_VEHICLE
	local eventID = 54
	local d = {
		["event"] = 1,
		["time"] = 2,
		["sourceGUID"] = 3,
		["sourceName"] = 4,
		["unitID"] = 5,
		["vehicleGUID"] = 6,
		["hasVehicleUI"] = 7,
		["isControlSeat"] = 8,
		["mayChooseExit"] = 9,
		["hasPitch"] = 10,
		["vehicleID"] = 11,
		["slots"] = 12,
	}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", eventID, (args[d.sourceGUID] or args[d.sourceName] or "")) -- Create unique string from event + sourceGUID
			if getGUID then return guid end
			return guid, -- 1
				nil, -- 2
				iEET.fakeSpells.VehicleEntered.name, -- 3
				args[d.sourceName], -- 4
				args[d.unitID], -- 5,
				nil, -- 6
				{unitID = args[d.unitID], casterName = args[d.sourceName]} -- 7
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data)
			if col == 6 or col == 7 or col == 8 then return end
			if col == 4 then
				addToTooltip(nil,
					formatKV("unitID", data[d.unitID]),
					formatKV("hasVehicleUI", data[d.hasVehicleUI]),
					formatKV("isControlSeat", data[d.isControlSeat]),
					formatKV("vehicleID", data[d.vehicleID]),
					formatKV("vehicleGUID", data[d.vehicleGUID]),
					formatKV("mayChooseExit", data[d.mayChooseExit]),
					formatKV("hasPitch", data[d.hasPitch]),
					formatKV("slots", data[d.slots])
				)
			else -- 5
				addToTooltip(nil,
					formatKV("Source name", data[d.sourceName]),
					formatKV("Source GUID", data[d.sourceGUID]),
					formatKV("Unit ID", data[d.unitID])
				)
			return true
			end
		end,
		import = function(args)
			return args
		end,
		chatLink = function(col, data) return end,
	}
	function addon:UNIT_ENTERED_VEHICLE(unitID, hasVehicleUI,isControlSeat,vehicleID, vehicleGUID, mayChooseExit, hasPitch)
		local sourceGUID = UnitGUID(unitID)
		local sourceName = UnitName(unitID)
		local slots = 0
		if vehicleID and vehicleID ~= 0 then
			local t,i = GetVehicleUIIndicator(vehicleID)
			slots = i
		end
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceGUID] = sourceGUID,
			[d.sourceName] = sourceName,
			[d.unitID] = unitID,
			[d.vehicleGUID] = vehicleGUID,
			[d.hasVehicleUI] = hasVehicleUI,
			[d.isControlSeat] = isControlSeat,
			[d.mayChooseExit] = mayChooseExit,
			[d.hasPitch] = hasPitch,
			[d.vehicleID] = vehicleID,
			[d.slots] = slots,
		}
		table.insert(iEET.data, t);
		iEET:OnscreenAddMessages(t)
	end
end
do -- UNIT_EXITING_VEHICLE
	local eventID = 55
	local d = {
		["event"] = 1,
		["time"] = 2,
		["sourceGUID"] = 3,
		["sourceName"] = 4,
		["unitID"] = 5,
	}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", eventID, (args[d.sourceGUID] or args[d.sourceName] or "")) -- Create unique string from event + sourceGUID
			if getGUID then return guid end
			return guid, -- 1
				nil, -- 2
				iEET.fakeSpells.VehicleExiting.name, -- 3
				args[d.sourceName], -- 4
				args[d.unitID], -- 5
				nil, -- 6
				{unitID = args[d.unitID], casterName = args[d.sourceName]} -- 7
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data)
			if col == 5 or col == 6 then
				addToTooltip(nil,
					formatKV("Source name", data[d.sourceName]),
					formatKV("Source GUID", data[d.sourceGUID]),
					formatKV("Unit ID", data[d.unitID])
				)
				return true
			end
		end,
		import = function(args)
			return args
		end,
		chatLink = function(col, data) return end,
	}
	function addon:UNIT_EXITING_VEHICLE(unitID)
		local sourceGUID = UnitGUID(unitID)
		local sourceName = UnitName(unitID)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceGUID] = sourceGUID,
			[d.sourceName] = sourceName,
			[d.unitID] = unitID,
		}
		table.insert(iEET.data, t);
		iEET:OnscreenAddMessages(t)
	end
end
do -- UNIT_EXITED_VEHICLE
	local eventID = 56
	local d = {
		["event"] = 1,
		["time"] = 2,
		["sourceGUID"] = 3,
		["sourceName"] = 4,
		["unitID"] = 5,
	}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", eventID, (args[d.sourceGUID] or args[d.sourceName] or "")) -- Create unique string from event + sourceGUID
			if getGUID then return guid end
			return guid, -- 1
				nil, -- 2
				iEET.fakeSpells.VehicleExited.name, -- 3
				args[d.sourceName], -- 4
				args[d.unitID], -- 5
				nil, -- 6
				{unitID = args[d.unitID], casterName = args[d.sourceName]} -- 7
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data)
			if col == 5 or col == 6 then
				addToTooltip(nil,
					formatKV("Source name", data[d.sourceName]),
					formatKV("Source GUID", data[d.sourceGUID]),
					formatKV("Unit ID", data[d.unitID])
				)
				return true
			end
		end,
		import = function(args)
			return args
		end,
		chatLink = function(col, data) return end,
	}	
	function addon:UNIT_EXITED_VEHICLE(unitID)
		local sourceGUID = UnitGUID(unitID)
		local sourceName = UnitName(unitID)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceGUID] = sourceGUID,
			[d.sourceName] = sourceName,
			[d.unitID] = unitID,
		}
		table.insert(iEET.data, t);
		iEET:OnscreenAddMessages(t)
	end
end
do -- COMBAT_LOG_EVENT_UNFILTERED
	local defaultCLEUData = {
		["event"] = 1,
		["time"] = 2,
		["sourceGUID"] = 3,
		["sourceName"] = 4,
		["sourceClass"] = 5,
		["sourceRole"] = 6,
		["spellName"] = 7,
		["spellID"] = 8,
		["destGUID"] = 9,
		["destName"] = 10,
		["destClass"] = 11,
		["destRole"] = 12,
	}
	local defaultCLEUGUI = function(args)
		local guid = sformat("%s-%s-%s", args[defaultCLEUData.event], (args[defaultCLEUData.sourceGUID] or args[defaultCLEUData.sourceName] or ""), args[defaultCLEUData.spellID]) -- Create unique string from event + sourceGUID
		return guid, -- 1
			checkForSpecialCategory(args[defaultCLEUData.spellID]), -- 2
			args[defaultCLEUData.spellName], -- 3
			args[defaultCLEUData.sourceName], -- 4
			args[defaultCLEUData.destName], -- 5
			nil, -- 6
			{spellID = args[defaultCLEUData.spellID], casterName = args[defaultCLEUData.sourceName]} -- 7
	end
	for _,v in pairs({1,2,8,9,10,11,14,15,16,17,20,21,22,23,24}) do
		iEET.eventFunctions[v] = {
			data = defaultCLEUData,
			gui = defaultCLEUGUI,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, defaultCLEUData, filters, v, ...)
			end,
			import = function(args)
				args[defaultCLEUData.sourceClass] = tonumber(args[defaultCLEUData.sourceClass])
				args[defaultCLEUData.destClass] = tonumber(args[defaultCLEUData.destClass])
				args[defaultCLEUData.spellID] = tonumber(args[defaultCLEUData.spellID])
				return args
			end,
			hyperlink = function(col, data)
				if col == 4 then
					if C_Spell.DoesSpellExist(data[defaultCLEUData.spellID]) then -- TODO : CHECK if it requires caching first, live/ptr check
						addToTooltip(data[defaultCLEUData.spellID], sformat("Spell ID: %s", data[defaultCLEUData.spellID]))
					else
						addToTooltip(nil,
							formatKV("Spell ID", data[defaultCLEUData.spellID]),
							formatKV("Spell name", data[defaultCLEUData.spellName])
						)
					end
				elseif col == 5 then
					addToTooltip(nil,
							formatKV("Source name", data[defaultCLEUData.sourceName]),
							formatKV("Source GUID", data[defaultCLEUData.sourceGUID])
						)
				else -- 6
					local class
					if data[defaultCLEUData.destClass] then
						class = GetClassInfo(data[defaultCLEUData.destClass])
					end
					addToTooltip(nil,
						formatKV("Target name", data[defaultCLEUData.destName]),
						formatKV("Target GUID", data[defaultCLEUData.destGUID]),
						formatKV("Target class", class),
						formatKV("Target role", data[defaultCLEUData.destRole])
					)
				end
				return true
			end,
			chatLink = function(col, data)
				-- ignore column for now
				if not data[defaultCLEUData.spellID] then return end
				return GetSpellLink(data[defaultCLEUData.spellID])
			end,
		}
	end
	do -- SPELL_DISPEL, SPELL_INTERRUPT, SPELL_STOLEN
		for _, v in pairs({12,13,62}) do
			local eventID = v
			local d = tcopy(defaultCLEUData)
			d["extraSpellID"] = 13
			d["extraSpellName"] = 14
			iEET.eventFunctions[eventID] = {
				data = d,
				gui = function(args, getGUID)
					local guid = sformat("%s-%s-%s", eventID, (args[d.sourceGUID] or args[d.sourceName] or ""), args[d.spellID]) -- Create unique string from event + sourceGUID
					if getGUID then return guid end
					return guid, -- 1
						checkForSpecialCategory(args[d.spellID]), -- 2
						args[d.spellName], -- 3
						args[d.sourceName], -- 4
						args[d.destName], -- 5
						nil, -- 6
						{spellID = args[d.spellID], casterName = args[d.sourceName]} -- 7
				end,
				import = function(args)
					args[d.sourceClass] = tonumber(args[d.sourceClass])
					args[d.destClass] = tonumber(args[d.destClass])
					args[d.spellID] = tonumber(args[d.spellID])
					args[d.extraSpellID] = tonumber(args[d.extraSpellID])
					return args
				end,
				filtering = function(args, filters, ...)
					return defaultFiltering(args, d, filters, eventID, ...)
				end,
				hyperlink = function(col, data)
					if col == 7 or col == 8 then return end
					if col == 4 then
						if C_Spell.DoesSpellExist(data[d.spellID]) then -- TODO : CHECK if it requires caching first, live/ptr check
							addToTooltip(data[d.spellID],
								formatKV("Spell ID", data[d.spellID]),
								formatKV("Extra spell ID", data[d.extraSpellID]),
								formatKV("Extra spell name", data[d.extraSpellName])
							)
						else
							addToTooltip(nil,
								formatKV("Spell ID", data[d.spellID]),
								formatKV("Spell name", data[d.spellName]),
								formatKV("Extra spell ID", data[d.extraSpellID]),
								formatKV("Extra spell name", data[d.extraSpellName])
							)
						end
					elseif col == 5 then
						local class
						if data[d.sourceClass] then
							class = GetClassInfo(data[d.sourceClass])
						end
						addToTooltip(nil,
								formatKV("Source name", data[d.sourceName]),
								formatKV("Source GUID", data[d.sourceGUID]),
								formatKV("Source class", class),
								formatKV("Source role", data[d.sourceRole])
							)
					else -- 6
						local class
						if data[d.destClass] then
							class = GetClassInfo(data[d.destClass])
						end
						addToTooltip(nil,
							formatKV("Target name", data[d.destName]),
							formatKV("Target GUID", data[d.destGUID]),
							formatKV("Target class", class),
							formatKV("Target role", data[d.destRole])
						)
					end
					return true
				end,
				chatLink = function(col, data)
					-- ignore column for now
					if not data[d.spellID] then return end
					return GetSpellLink(data[d.spellID])
				end,
			}
		end
	end
	--SPELL_AURA_APPLIED, SPELL_AURA_REMOVED, SPELL_AURA_REFRESH
	local auraEvents = {[3] = true, [4] = true,[7] = true}
	do -- AURA
		local d = tcopy(defaultCLEUData)
		d["auraType"] = 13
		for k in pairs(auraEvents) do
			iEET.eventFunctions[k] = {
				data = d,
				gui = function(args, getGUID)
					local guid = sformat("%s-%s-%s", args[d.event], (args[d.sourceGUID] or args[d.sourceName] or ""), args[d.spellID]) -- Create unique string from event + sourceGUID
					if getGUID then return guid end
					return guid, -- 1
					nil, -- 2 TODO ADD SPECIAL
					args[d.spellName], -- 3
					args[d.sourceName], -- 4,
					args[d.destName], -- 5
					(args[d.auraType] == "1" and "+" or "-"), -- 6
					{spellID = args[d.spellID], casterName = args[d.sourceName]} -- 7
				end,
				import = function(args)
					args[d.sourceClass] = tonumber(args[d.sourceClass])
					args[d.destClass] = tonumber(args[d.destClass])
					args[d.spellID] = tonumber(args[d.spellID])
					return args
				end,
				filtering = function(args, filters, ...)
					return defaultFiltering(args, d, filters, k, ...)
				end,
				hyperlink = function(col, data)
					if col == 7 then return end
					if col == 4 then
						if C_Spell.DoesSpellExist(data[d.spellID]) then -- TODO : CHECK if it requires caching first, live/ptr check
							addToTooltip(data[d.spellID], formatKV("Spell ID", data[d.spellID]))
						else
							addToTooltip(nil,
								formatKV("Spell ID", data[d.spellID]),
								formatKV("Spell name", data[d.spellName])
							)
						end
					elseif col == 5 then
						local class
						if data[d.sourceClass] then
							class = GetClassInfo(data[d.sourceClass])
						end
						addToTooltip(nil,
							formatKV("Source name", data[d.sourceName]),
							formatKV("Source GUID", data[d.sourceGUID]),
							formatKV("Source class", class),
							formatKV("Source role", data[d.sourceRole])
							)
					elseif col == 6 then
						local class
						if data[d.destClass] then
							class = GetClassInfo(data[d.destClass])
						end
						addToTooltip(nil,
							formatKV("Target name", data[d.destName]),
							formatKV("Target GUID", data[d.destGUID]),
							formatKV("Target class", class),
							formatKV("Target role", data[d.destRole])
						)
					else -- 8
						addToTooltip(nil, formatKV("Aura type", data[d.auraType] == "1" and "BUFF" or "DEBUFF"))
					end
					return true
				end,
				chatLink = function(col, data)
					-- ignore column for now
					if not data[d.spellID] then return end
					return GetSpellLink(data[d.spellID])
				end,
			}
		end
	end
	local doseEvents = {
		[18] = true, -- SPELL_PERIODIC_AURA_APPLIED_DOSE
		[19] = true, -- SPELL_PERIODIC_AURA_REMOVED_DOSE
		[5] = true, -- SPELL_AURA_APPLIED_DOSE
		[6] = true, -- SPELL_AURA_REMOVED_DOSE
	}
	do -- DOSE
		local d = tcopy(defaultCLEUData)
		d["auraType"] = 13
		d["stacks"] = 14
		for k in pairs(doseEvents) do
			iEET.eventFunctions[k] = {
				data = d,
				gui = function(args, getGUID)
					local guid = sformat("%s-%s-%s", args[d.event], (args[d.sourceGUID] or args[d.sourceName] or ""), args[d.spellID]) -- Create unique string from event + sourceGUID
					if getGUID then return guid end
					return guid, -- 1
					nil, -- 2 TODO ADD SPECIAL
					args[d.spellName], -- 3
					args[d.sourceName], -- 4
					args[d.destName], -- 5
					(args[d.auraType] == "1" and "+" or "-"), -- 6
					{spellID = args[d.spellID], casterName = args[d.sourceName]} -- 7
				end,
				import = function(args)
					args[d.sourceClass] = tonumber(args[d.sourceClass])
					args[d.destClass] = tonumber(args[d.destClass])
					args[d.spellID] = tonumber(args[d.spellID])
					args[d.stacks] = tonumber(args[d.stacks])
					return args
				end,
				filtering = function(args, filters, ...)
					return defaultFiltering(args, d, filters, k, ...)
				end,
				hyperlink = function(col, data)
					if col == 7 then return end
					if col == 4 then
						if C_Spell.DoesSpellExist(data[d.spellID]) then -- TODO : CHECK if it requires caching first, live/ptr check
							addToTooltip(data[d.spellID],
								formatKV("Spell ID", data[d.spellID])
							)
						else
							addToTooltip(nil,
								formatKV("Spell ID", data[d.spellID]),
								formatKV("Spell name", data[d.spellName])
							)
						end
					elseif col == 5 then
						local class
						if data[d.sourceClass] then
							class = GetClassInfo(data[d.sourceClass])
						end
						addToTooltip(nil,
							formatKV("Source name", data[d.sourceName]),
							formatKV("Source GUID", data[d.sourceGUID]),
							formatKV("Source class", class),
							formatKV("Source role", data[d.sourceRole])
							)
					elseif col == 6 then
						local class
						if data[d.destClass] then
							class = GetClassInfo(data[d.destClass])
						end
						addToTooltip(nil,
							formatKV("Target name", data[d.destName]),
							formatKV("Target GUID", data[d.destGUID]),
							formatKV("Target class", class),
							formatKV("Target role", data[d.destRole])
						)
					else -- 8
						addToTooltip(nil,
							formatKV("Aura type", data[d.auraType] == "1" and "BUFF" or "DEBUFF"),
							formatKV("Stacks", data[d.stacks])
						)
					end
					return true
				end,
				chatLink = function(col, data)
					-- ignore column for now
					if not data[d.spellID] then return end
					return GetSpellLink(data[d.spellID])
				end,
			}
		end
	end
	do -- UNIT_DIED
		local d = {
			["event"] = 1,
			["time"] = 2,
			["destGUID"] = 3,
			["destName"] = 4,
		}
		iEET.eventFunctions[25] = {
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("25-%s-%s", (args[d.destGUID] or args[d.destName] or ""), "Death") -- Create unique string from event + sourceGUID
				if getGUID then return guid end
				return guid, -- 1
					iEET.specialCategories.Death, -- 2
					iEET.fakeSpells.Death.name, -- 3
					args[d.destName], -- 4
					nil, -- 5
					nil, -- 6
					{casterName = args[d.destName]} -- 7
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, 25, ...)
			end,
			import = function(args) return args end,
			hyperlink = function(col, data)
				if col ~= 5 then return end
					addToTooltip(nil,
							formatKV("Target name", data[d.destName]),
							formatKV("Target GUID", data[d.destGUID])
						)
				return true
			end,
			chatLink = function(col, data) return end
		}
	end
	function addon:COMBAT_LOG_EVENT_UNFILTERED()
		local args = {CombatLogGetCurrentEventInfo()}
		-- args[2] = sub event
		if cleuEventsToTrack[args[2]] then
			local eventID = iEET.events.toID[args[2]]
			local d = iEET.eventFunctions[eventID].data
			local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
			if args[4] then -- sourceGUID, fix for arena id's
				unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", args[4]) -- sourceGUID
			end
			if eventID == 25 then -- UNIT_DIED
				unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", args[8]) -- destGUID
				if iEET.ignoreFilters or (unitType == 'Creature') or (unitType == 'Vehicle') or (unitType == 'Player') then
					if iEET.ignoreFilters or not iEET.npcIgnoreList[tonumber(npcID)] then
						local t = {
							[d.event] = eventID,
							[d.time] = GetTime(),
							[d.destGUID] = args[8],
							[d.destName] = args[9]}
						tinsert(iEET.data, t)
						iEET:OnscreenAddMessages(t)
					end
				end
			elseif iEET:shouldTrack(args[2], unitType, npcID, args[12], args[4], args[3]) then
				-- args[4] = sourceGUID, arg[8] = destGUID
				local sourceClass
				local sourceRole
				local destClass
				local destRole
				if iEET.raidComp then
					if iEET.raidComp[args[4]] then -- sourceGUID
						sourceClass = iEET.raidComp[args[4]].class
						sourceRole = iEET.raidComp[args[4]].role
					end
					if iEET.raidComp[args[8]] then -- destGUID
						destClass = iEET.raidComp[args[8]].class
						destRole = iEET.raidComp[args[8]].role
					end
				end
				local t = {
					[d.event] = eventID, -- event
					[d.time] = GetTime(), -- time
					[d.sourceGUID] = args[4], -- sourceGUID
					[d.sourceName] = args[5], -- sourceName
					[d.sourceClass] = sourceClass,
					[d.sourceRole] = sourceRole,
					[d.spellName] = args[13], -- spellName
					[d.spellID] = args[12], -- spellID
					[d.destGUID] = args[8], -- destGUID
					[d.destName] = args[9], -- destName
					[d.destClass] = destClass,
					[d.destRole] = destRole,
				}
				if eventID == 12 or eventID == 13 or eventID == 62 then -- SPELL_DISPEL, SPELL_INTERRUPT, SPELL_STOLEN
					t[d.extraSpellID] = args[15]
					t[d.extraSpellName] = args[16]
				end
				if auraEvents[eventID] or doseEvents[eventID] then
					t[d.auraType] = args[15] == 'DEBUFF' and '0' or '1'
				end
				if doseEvents[eventID] then
					t[d.stacks] = args[16]
				end
				tinsert(iEET.data, t)
				iEET:OnscreenAddMessages(t)
			end
		end
	end
end
do -- INSTANCE_ENCOUNTER_ENGAGE_UNIT
	local eventID = 33
	local d = {
		["event"] = 1,
		["time"] = 2,
		["npcs"] = 3,
	} 
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", eventID, (args[d.npcs] or ""), args[d.spellID]) -- Create unique string from event + npc list
			if getGUID then return guid end
			return guid,iEET.specialCategories.NPCSpawn,iEET.fakeSpells.SpawnNPCs.name
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		import = function(args)
			return args
		end,
		hyperlink = function(col, data)
			if col ~= 4 then return end
			addToTooltip(nil,data[d.npcs])
			return true
		end,
		chatLink = function(col, data) return end,
	}
	function addon:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
		local newUnits = {}
		local unitNames = {}
		for i = 1, 5 do
			local unitID = 'boss' .. i
			local sourceGUID = UnitGUID(unitID)
			if UnitExists(unitID) or sourceGUID then
				local sourceName = UnitName(unitID)
				if not sourceName then
					sourceName = UNKNOWN
				end
				if not iEET.IEEUnits[sourceGUID] then
					newUnits[i] = sourceGUID
				end
				local unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
				unitNames[i] = {name = sourceName, guid = sourceGUID, npcID = npcID}
			end
		end
		iEET.IEEUnits = nil
		iEET.IEEUnits = {}
		for k,v in pairs(unitNames) do
			if v.guid then
				iEET.IEEUnits[v.guid] = true
			end
		end
		local npcNames
		for bossID,v in ipairs(unitNames) do
			if npcNames then
				npcNames = npcNames .. sformat('\n%s (%d)%s - %s',v.name, bossID, newUnits[bossID] and "*" or "", v.npcID)
			else
				npcNames = sformat('%s (%d)%s - %s',v.name, bossID, newUnits[bossID] and "*" or "", v.npcID)
			end
		end
		if #unitNames == 0 then
			npcNames = "NONE"
		end
		local t = {
			eventID, -- event
			GetTime(), -- time
			npcNames, -- npcs
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- CHAT_MSG_MONSTER_EMOTE
	local eventID = 29
	iEET.eventFunctions[eventID] = {
		data = defaults.chats.data, 
		gui = defaults.chats.gui,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, defaults.chats.data, filters, eventID, ...)
		end,
		hyperlink = defaults.chats.hyperlink,
		import = function(args)
			return args
		end,
		chatLink = defaults.chats.chatLink,
	}
	local d = iEET.eventFunctions[eventID].data
	function addon:CHAT_MSG_MONSTER_EMOTE(msg, sourceName)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceName] = sourceName,
			[d.message] = msg,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- CHAT_MSG_MONSTER_SAY
	local eventID = 30
	iEET.eventFunctions[eventID] = {
		data = defaults.chats.data,
		gui = defaults.chats.gui,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, defaults.chats.data, filters, eventID, ...)
		end,
		hyperlink = defaults.chats.hyperlink,
		import = function(args) return args end,
		chatLink = defaults.chats.chatLink,
	}
	local d = iEET.eventFunctions[eventID].data
	function addon:CHAT_MSG_MONSTER_SAY(msg, sourceName)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceName] = sourceName,
			[d.message] = msg,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- CHAT_MSG_MONSTER_YELL
	local eventID = 31
	iEET.eventFunctions[eventID] = {
		data = defaults.chats.data,
		gui = defaults.chats.gui,
		import = function(args)
			return args
		end,
		hyperlink = defaults.chats.hyperlink,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, defaults.chats.data, filters, eventID, ...)
		end,
		chatLink = defaults.chats.chatLink,
	}
	local d = iEET.eventFunctions[eventID].data
	function addon:CHAT_MSG_MONSTER_YELL(msg, sourceName)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceName] = sourceName,
			[d.message] = msg,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- RAID_BOSS_EMOTE
	local eventID = 43
	local d = tcopy(defaults.chats.data)
	d["destName"] = 5
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s-%s", eventID, args[d.sourceName], args[d.message]) -- Create unique string from message + sourceName
			if getGUID then return guid end
			return guid, -- 1
				nil, -- 2
				args[d.message], --3
				args[d.sourceName], -- 4
				args[d.destName], -- 5
				nil, -- 6
				{casterName = args[d.sourceName]} -- 7
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		import = function(args) return args end,
		hyperlink = function(col, data)
			if col == 7 or col == 8 then return end
			if col == 4 then
				addToTooltip(nil,data[d.message])
			elseif col == 5 then
				addToTooltip(nil,data[d.sourceName])
			else -- 6
				addToTooltip(nil,data[d.destName])
			end
			return true
		end,
		chatLink = defaults.chats.chatLink,
	}
	function addon:RAID_BOSS_EMOTE(msg, sourceName,_,_,destName)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceName] = sourceName,
			[d.message] = msg,
			[d.destName] = destName,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- RAID_BOSS_WHISPER
	local eventID = 44
	iEET.eventFunctions[eventID] = {
		data = defaults.chats.data,
		gui = defaults.chats.gui,
		import = function(args) return args end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, defaults.chats.data, filters, eventID, ...)
		end,
		hyperlink = defaults.chats.hyperlink,
		chatLink = defaults.chats.chatLink,
	}
	local d = iEET.eventFunctions[eventID].data
	function addon:RAID_BOSS_WHISPER(msg, sourceName) -- im not sure if there is sourceName, needs testing -- TODO : proc CHAT_MSG_ADDON
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceName] = sourceName,
			[d.message] = msg,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- CHAT_MSG_RAID_BOSS_EMOTE
	local eventID = 46
	local d = tcopy(defaults.chats.data)
	d["destName"] = 5
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s-%s", eventID, args[d.sourceName], args[d.message]) -- Create unique string from message + sourceName
			if getGUID then return guid end
			return guid, -- 1
				nil, -- 2
				args[d.message], -- 3
				args[d.sourceName], -- 4
				args[d.destName], -- 5
				nil, -- 6
				{casterName = args[d.sourceName]} -- 7
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		import = function(args) return args end,
		hyperlink = function(col, data)
			if col == 7 or col == 8 then return end
			if col == 4 then
				addToTooltip(nil,data[d.message])
			elseif col == 5 then
				addToTooltip(nil,data[d.sourceName])
			else -- 6
				addToTooltip(nil,data[d.destName])
			end
			return true
		end,
		chatLink = defaults.chats.chatLink,
	}
	function addon:CHAT_MSG_RAID_BOSS_EMOTE(msg, sourceName,_,_,destName,...)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceName] = sourceName,
			[d.message] = msg,
			[d.destName] = destName,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- CHAT_MSG_RAID_BOSS_WHISPER
	local eventID = 45
	iEET.eventFunctions[eventID] = {
		data = defaults.chats.data,
		gui = defaults.chats.gui,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, defaults.chats.data, filters, eventID, ...)
		end,
		import = function(args) return args end,
		hyperlink = defaults.chats.hyperlink,
		chatLink = defaults.chats.chatLink,
	}
	local d = iEET.eventFunctions[eventID].data
	function addon:CHAT_MSG_RAID_BOSS_WHISPER(msg, sourceName)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceName] = sourceName,
			[d.message] = msg,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- PLAYER_REGEN_DISABLED
	local eventID = 35
	local d = {["event"] = 1, ["time"] = 2, }
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			if getGUID then return args[d.event] end
			return args[d.event], nil, "+Combat"
		end,
		filtering = function(args, filters)
			return true -- Always show
		end,
		hyperlink = function(col, data) return end, -- Nothing to show
		import = function(args) return args end,
		chatLink = function(col, data) return end,
	}
	function addon:PLAYER_REGEN_DISABLED()
		local t = {
			[d.event] = eventID, -- event
			[d.time] = GetTime(), -- time
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- PLAYER_REGEN_ENABLED
	local eventID = 36
	local d = {["event"] = 1, ["time"] = 2, }
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			if getGUID then return args[d.event] end
			return args[d.event], nil, "-Combat"
		end,
		filtering = function(args, filters)
			return true -- Always show
		end,
		hyperlink = function (col, data) return end, -- Nothing to show
		import = function(args) return args end,
		chatLink = function(col, data) return end,
	}
	function addon:PLAYER_REGEN_ENABLED()
		local t = {
			[d.event] = eventID, -- event
			[d.time] = GetTime(), -- time
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- PLAY_MOVIE
	local eventID = 57
	local d = {["event"] = 1, ["time"] = 2, ["movieID"] = 3}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			if getGUID then return args[d.event] end
			return args[d.event], nil, iEET.fakeSpells.PlayMovie, args[d.movieID]
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data)
			if col == 4 then
				addToTooltip(nil, data[d.movieID])
				return true
			end
		end,
		import = function(args) return args end,
		chatLink = function(col, data) return end,
	}
	function addon:PLAY_MOVIE(movieID)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.movieID] = movieID,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- CINEMATIC_START
	local eventID = 58
	local d = {["event"] = 1, ["time"] = 2, ["canBeCancelled"] = 3}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			if getGUID then return args[d.event] end
			return args[d.event], nil, iEET.fakeSpells.CinematicStart, tostring(args[d.canBeCancelled])
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data) 
			if col == 5 then
				addToTooltip(nil, formatKV("canBeCancelled", data[d.canBeCancelled]))
				return true
			end
		end,
		import = function(args) return args end,
		chatLink = function(col, data) return end,
	}
	function addon:CINEMATIC_START(canBeCancelled)
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.canBeCancelled] = canBeCancelled,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- CINEMATIC_STOP
	local eventID = 59
	local d = {["event"] = 1, ["time"] = 2}
	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			if getGUID then return args[d.event] end
			return args[d.event], nil, iEET.fakeSpells.CinematicStop
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data) return end, -- Nothing to show
		import = function(args) return args end,
		chatLink = function(col, data) return end,
	}
	function addon:CINEMATIC_STOP()
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- BigWigs
	function iEET:BWRecording(start)
		if not BigWigsLoader then
			return
		end
		if start then
				BigWigsLoader.RegisterMessage('iEncounterEventTracker', 'BigWigs_BarCreated', function(event,_,_,_, key, text, time,_, cd)
						iEET:BigWigsData(event, key, text, time, cd)
				end)
			BigWigsLoader.RegisterMessage('iEncounterEventTracker', 'BigWigs_Message', function(event, _, key, text)
						iEET:BigWigsData(event, key, text)
				end)
			BigWigsLoader.RegisterMessage('iEncounterEventTracker', 'BigWigs_PauseBar', function(_, _, text)
				iEET:BigWigsData('BigWigs_PauseBar', text)
			end)
			BigWigsLoader.RegisterMessage('iEncounterEventTracker', 'BigWigs_ResumeBar', function(_, _, text)
				iEET:BigWigsData('BigWigs_ResumeBar', text)
			end)
			BigWigsLoader.RegisterMessage('iEncounterEventTracker', 'BigWigs_StopBar', function(_, _, text)
				iEET:BigWigsData('BigWigs_StopBar', text)
			end)
			BigWigsLoader.RegisterMessage('iEncounterEventTracker', 'BigWigs_StopBars', function()
				iEET:BigWigsData('BigWigs_StopBars')
			end)
		else
			BigWigsLoader.UnregisterMessage('iEncounterEventTracker', 'BigWigs_BarCreated')
			BigWigsLoader.UnregisterMessage('iEncounterEventTracker', 'BigWigs_Message')
			BigWigsLoader.UnregisterMessage('iEncounterEventTracker', 'BigWigs_PauseBar')
			BigWigsLoader.UnregisterMessage('iEncounterEventTracker', 'BigWigs_ResumeBar')
			BigWigsLoader.UnregisterMessage('iEncounterEventTracker', 'BigWigs_StopBar')
			BigWigsLoader.UnregisterMessage('iEncounterEventTracker', 'BigWigs_StopBars')
		end
	end
	do -- BigWigs_BarCreated
		local eventID = 47
		local d = {
			["event"] = 1,
			["time"] = 2,
			["duration"] = 3,
			["key"] = 4,
			["text"] = 5,
			["cd"] = 6,
		}
		iEET.eventFunctions[eventID] = {
			data = d, 
			gui = function(args, getGUID)
				local guid = sformat("%s-%s", eventID, args[d.key] or "")
				if getGUID then return guid end
				return guid, iEET.specialCategories.Ignore, args[d.text], sformat("%s", args[d.cd] and "~" or "", args[d.duration]), args[d.key]
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				addToTooltip(nil,
					formatKV("Duration", data[d.duration]),
					formatKV("Key", data[d.key]),
					formatKV("Text", data[d.text]),
					formatKV("CD", data[d.cd])
				)
				return true
			end,
			import = function(args) return args end,
			chatLink = function(col, data) return end,
		}
	end
	do -- BigWigs_Message
		local eventID = 48
		local d = {
			["event"] = 1,
			["time"] = 2,
			["text"] = 3,
			["key"] = 4,
		}
		iEET.eventFunctions[eventID] = { 
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("%s-%s", eventID, args[d.key] or "")
				if getGUID then return guid end
				return guid, iEET.specialCategories.Ignore, args[d.text], nil, args[d.key]
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				addToTooltip(nil,
					formatKV("Key", data[d.key]),
					formatKV("Text", data[d.text])
				)
				return true
			end,
			import = function(args) return args end,
			chatLink = function(col, data) return end,
		}
	end
	do -- BigWigs_PauseBar
		local eventID = 49
		local d = {
			["event"] = 1,
			["time"] = 2,
			["text"] = 3,
		}
		iEET.eventFunctions[eventID] = { 
			data = d, 
			gui = function(args, getGUID)
				local guid = sformat("%s-%s", eventID, args[d.text] or "")
				if getGUID then return guid end
				return guid, iEET.specialCategories.Ignore, args[d.text]
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				addToTooltip(nil,
					formatKV("Text", data[d.text])
				)
				return true
			end,
			import = function(args) return args end,
			chatLink = function(col, data) return end,
		}
	end
	do -- BigWigs_ResumeBar
		local eventID = 50
		local d = {
			["event"] = 1,
			["time"] = 2,
			["text"] = 3,
		}
		iEET.eventFunctions[eventID] = { 
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("%s-%s", eventID, args[d.text] or "")
				if getGUID then return guid end
				return guid, iEET.specialCategories.Ignore, args[d.text]
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				addToTooltip(nil,
					formatKV("Text", data[d.text])
				)
				return true
			end,
			import = function(args) return args end,
			chatLink = function(col, data) return end,
		}
	end
	do -- BigWigs_StopBar
		local eventID = 51
		local d = {
			["event"] = 1,
			["time"] = 2,
			["text"] = 3,
		}
		iEET.eventFunctions[eventID] = { 
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("%s-%s", eventID, args[d.text] or "")
				if getGUID then return guid end
				return guid, iEET.specialCategories.Ignore, args[d.text]
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				addToTooltip(nil,
					formatKV("Text", data[d.text])
				)
				return true
			end,
			import = function(args) return args end,
			chatLink = function(col, data) return end,
		}
	end
	do -- BigWigs_StopBars
		local eventID = 52
		local d =  {
			["event"] = 1,
			["time"] = 2,
		}
		iEET.eventFunctions[eventID] = { 
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("%s-%s", eventID, args[d.key] or "")
				if getGUID then return guid end
				return guid, iEET.specialCategories.Ignore, "BigWigs_StopBars"
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data) return end, -- Nothing to show
			import = function(args) return args end,
			chatLink = function(col, data) return end,
		}
	end
	function iEET:BigWigsData(event,...)
		local t
		local eventID = iEET.events.toID[event]
		if not eventID then 
			print("iEET: BigWigs event not found :",event)
			return 
		end
		local d = iEET.eventFunctions[eventID].data
		if event == 'BigWigs_BarCreated' then
			local key, text, time, cd = ...
			t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.duration] = time,
				[d.key] = key,
				[d.text] = text,
				[d.cd] = cd,
			}
		elseif event == 'BigWigs_Message' then
			local key,text = ...
			t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.key] = key,
				[d.text] = text,
			}
		elseif event == 'BigWigs_PauseBar' then
			local text = ...
			t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.text] = text,
			}
		elseif event == 'BigWigs_ResumeBar' then
			local text = ...
			t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.text] = text,
			}
		elseif event == 'BigWigs_StopBar' then
			local text = ...
			t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.text] = text,
			}
		elseif event == 'BigWigs_StopBars' then
			t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
			}
		end
		if not t then return end
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do --Start/End recording
	local eventsToToggle = {
		'COMBAT_LOG_EVENT_UNFILTERED',
		'CHAT_MSG_MONSTER_SAY',
		'CHAT_MSG_MONSTER_EMOTE',
		'CHAT_MSG_MONSTER_YELL',
		'UNIT_SPELLCAST_SUCCEEDED',
		'UNIT_TARGET',
		'INSTANCE_ENCOUNTER_ENGAGE_UNIT',
		'UNIT_POWER_UPDATE',
		'UNIT_SPELLCAST_START',
		'UNIT_SPELLCAST_CHANNEL_START',
		'UNIT_SPELLCAST_INTERRUPTIBLE',
		'UNIT_SPELLCAST_NOT_INTERRUPTIBLE',
		'RAID_BOSS_EMOTE',
		'RAID_BOSS_WHISPER',
		'CHAT_MSG_RAID_BOSS_EMOTE',
		'CHAT_MSG_RAID_BOSS_WHISPER',
		'UNIT_ENTERING_VEHICLE',
		'UNIT_ENTERED_VEHICLE',
		'UNIT_EXITING_VEHICLE',
		'UNIT_EXITED_VEHICLE',
		'PLAY_MOVIE',
		'CINEMATIC_START',
		'CINEMATIC_STOP',
		'UNIT_SPELLCAST_CHANNEL_STOP',
		'UNIT_SPELLCAST_STOP',
		'UPDATE_UI_WIDGET',
	}
	function iEET:StartRecording(force, encounterID)
		currentlyLogging = true
		iEET.IEEUnits = nil
		iEET.IEEUnits = {}
		iEET.unitPowerUnits = nil
		iEET.unitPowerUnits = {}
		iEET.data = nil
		iEET.data = {}
		iEET.raidComp = nil
		iEET.raidComp = {}
		seenWidgets = nil
		seenWidgets = {}
		--Collecting raid comp info for destName class coloring + class info
		if IsInRaid() then -- ignore solo play etc, don't care about old raids
			for i = 1, GetNumGroupMembers() do
				local unitID = 'raid' .. i
				if UnitExists(unitID) then
					iEET.raidComp[UnitGUID(unitID)] = {
						['class'] = select(3,UnitClass(unitID)), -- Class number
						['role'] = select(12,GetRaidRosterInfo(i)), -- Combat Role, DAMAGER/HEALER/TANK
					}
				end
			end
		elseif IsInGroup() then
			for i = 1, GetNumGroupMembers()-1 do
				local unitID = 'party' .. i
				if UnitExists(unitID) then
					iEET.raidComp[UnitGUID(unitID)] = {
						['class'] = select(3,UnitClass(unitID)), -- Class number
						['role'] = select(12,GetRaidRosterInfo(i)), -- Combat Role, DAMAGER/HEALER/TANK
					}
				end
			end
			iEET.raidComp[UnitGUID('player')] = {
				['class'] = select(3,UnitClass('player')), -- Class number
				['role'] = 'Unknown', -- Combat Role, DAMAGER/HEALER/TANK
			}
		end
		iEET:BWRecording(true)
		iEET:DBMRecording(true)
		for _,v in pairs(eventsToToggle) do
			addon:RegisterEvent(v)
		end
		if force then
			addon:RegisterEvent('PLAYER_REGEN_DISABLED')
			addon:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end

	function iEET:StopRecording(force, encounterID)
		currentlyLogging = false
		iEET:BWRecording(false)
		iEET:DBMRecording(false)
		for _,v in pairs(eventsToToggle) do
			addon:UnregisterEvent(v)
		end
		if force then
			addon:UnregisterEvent('PLAYER_REGEN_DISABLED')
			addon:UnregisterEvent('PLAYER_REGEN_ENABLED')
		end
		if iEETConfig.autoSave then
			if iEET:ShouldIgnoreEncounter(encounterID) then return end
			if iEETConfig.onlyRaids then
				local _, instanceType = IsInInstance()
				if instanceType and instanceType == 'raid' then
					iEET:ExportData(true)
				end
			else
				iEET:ExportData(true)
			end
		end
	end
end
do -- CUSTOM 
	local function tableToString(t)
		local str = ""
		for k,v in pairs(t) do
			if type(v) == "table" then
				str = sformat("%s\r[%s] = %s\r,", str, k, tableToString(v))
			else
				str = sformat("%s\r[%s] = %s,", str, k, tostring(v))
			end
		end
		return str
	end
	local eventID = 64
	iEET.eventFunctions[eventID] = {
		data = defaults.chats.data,
		gui = defaults.chats.gui,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, defaults.chats.data, filters, eventID, ...)
		end,
		hyperlink = defaults.chats.hyperlink,
		import = function(args) return args end,
		chatLink = function(col, data) return end,
	}
	local d = iEET.eventFunctions[eventID].data
	function iEET_AddCustom(msg)
		if not currentlyLogging then
			iEET:print("Error (iEET_AddCustom): iEET isn't currently logging anything.")
			return
		elseif msg == nil then
			iEET:print("Error: Cannot use nil as argument for iEET_AddCustom.")
			return
		end
		if type(msg) == "table" then
			msg = tableToString(msg)
		else
			msg = tostring(msg)
		end
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.sourceName] = "Logger",
			[d.message] = msg,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- Manual logging (start/end)
	iEET.eventFunctions[37] = {  -- START LOGGING
		data = {
			["event"] = 1,
			["time"] = 2,
		},
		gui = function(args)
			local guid = sformat("%s-%s", 37, "START_LOGGING")
			return guid, iEET.specialCategories.StartLogging, iEET.fakeSpells.StartLogging.name
		end,
		filtering = function(args, filters) return true end, -- Always show
		hyperlink = function(args, filters) return end, -- Nothing to show
		import = function(args) return args end,
		chatLink = function(col, data) return end,
	}
	iEET.eventFunctions[38] = {  -- END LOGGING
		data = {
			["event"] = 1,
			["time"] = 2,
		},
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", 38, "END_LOGGING")
			if getGUID then return guid end
			return guid, iEET.specialCategories.EndLogging, iEET.fakeSpells.EndLogging.name
		end,
		filtering = function(args, filters) return true end, -- Always show
		hyperlink = function(args, filters) return end, -- Nothing to show
		import = function(args) return args end,
		chatLink = function(col, data) return end,
	}
	function iEET:Force(start, name)
		local t
		if start then
			iEET:StartRecording(true)
			t = {[1] = 37, [2] = GetTime()}
			table.insert(iEET.data, t)
			iEET.forceRecording = true
			local nameToSave = GetRealZoneText() -- use zone as encounter name by default
			if name then
				nameToSave = name
			end
			iEET:print('Manual recording started: ' .. nameToSave)
			local dID = 1
			if IsInRaid() then
				dID = GetRaidDifficultyID()
			else
				dID = GetDungeonDifficultyID()
			end
			iEET.encounterInfoData = {
				['s'] = GetTime(),
				['eN'] = nameToSave,
				['pT'] = date('%y.%m.%d %H:%M'), -- y.m.d instead of d.m.y for easier sorting
				['fT'] = '00:00',
				['d']= dID,
				['rS'] = GetNumGroupMembers(),
				['k'] = 1,
				['zI'] = -1,
				['v'] = iEET.version,
				['eI'] = 0,
				['lN'] = UnitName('player')
			}
			--register events and start recording
		else
			--unregister events and stop recording
			if iEET.ignoreFilters then
				iEET.ignoreFilters = false
				iEET:print("Filters are no longer ignored.")
			end
			iEET.forceRecording = false
			t = {[1] = 38, [2] = GetTime()}
			table.insert(iEET.data, t)
			if iEET.encounterInfoData then
				iEET.encounterInfoData.fT = iEET.encounterInfoData.s and date('%M:%S', (GetTime() - iEET.encounterInfoData.s)) or '00:00' -- if we are missing start time for some reason
			else
				local dID = 1
				if IsInRaid() then
					dID = GetRaidDifficultyID()
				else
					dID = GetDungeonDifficultyID()
				end
				iEET.encounterInfoData = {
				['s'] = GetTime(),
				['eN'] = GetRealZoneText(),
				['pT'] = date('%y.%m.%d %H:%M'), -- y.m.d instead of d.m.y for easier sorting
				['fT'] = '00:00',
				['d']= dID,
				['rS'] = GetNumGroupMembers(),
				['k'] = 1,
				['zI'] = -1,
				['v'] = iEET.version,
				['eI'] = 0,
				['lN'] = UnitName('player')
				}
			end
			iEET:print(string.format('Stopped recording: %s (%s)', iEET.encounterInfoData.eN, iEET.encounterInfoData.fT))
			iEET:StopRecording(true)
		end
		if t then iEET:OnscreenAddMessages(t) end
	end
end
function iEET:ForceStartWithoutFilters(time, name)
	iEET.ignoreFilters = true
	if ignoreFiltersTimer then
		ignoreFiltersTimer:Cancel()
	end
	ignoreFiltersTimer = C_Timer.NewTimer(time, function()
		if iEET.forceRecording then
			iEET:Force() -- Stop manual recording
		end
	end)
	iEET:Force(true, name .. " (Full logging)")
end
do -- UPDATE_UI_WIDGET
	local eventID = 65
	local d = {
		["event"] = 1,
		["time"] = 2,
		["widgetID"] = 3,
		["widgetData"] = 4,
		["widgetType"] = 5,
		["widgetSetID"] = 6,
		["unitID"] = 7,
		["sourceName"] = 8,
		["sourceGUID"] = 9,
	}
	local _e = Enum.UIWidgetVisualizationType
	local _w = C_UIWidgetManager
	local _widgetHandlers = {
		[_e.IconAndText] = _w.GetIconAndTextWidgetVisualizationInfo,
		[_e.CaptureBar] = _w.GetCaptureBarWidgetVisualizationInfo,
		[_e.StatusBar] = _w.GetStatusBarWidgetVisualizationInfo,
		[_e.DoubleStatusBar] = _w.GetDoubleStatusBarWidgetVisualizationInfo,
		[_e.IconTextAndBackground] = _w.GetIconTextAndBackgroundWidgetVisualizationInfo,
		[_e.DoubleIconAndText] = _w.GetDoubleIconAndTextWidgetVisualizationInfo,
		[_e.StackedResourceTracker] = _w.GetStackedResourceTrackerWidgetVisualizationInfo,
		[_e.IconTextAndCurrencies] = _w.GetIconTextAndCurrenciesWidgetVisualizationInfo,
		[_e.TextWithState] = _w.GetTextWithStateWidgetVisualizationInfo,
		[_e.HorizontalCurrencies] = _w.GetHorizontalCurrenciesWidgetVisualizationInfo,
		[_e.BulletTextList] = _w.GetBulletTextListWidgetVisualizationInfo,
		[_e.ScenarioHeaderCurrenciesAndBackground] = _w.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo,
		[_e.TextureAndText] = _w.GetTextureAndTextVisualizationInfo,
		[_e.SpellDisplay] = _w.GetSpellDisplayVisualizationInfo,
		[_e.DoubleStateIconRow] = _w.GetDoubleStateIconRowVisualizationInfo,
		[_e.TextureAndTextRow] = _w.GetTextureAndTextRowVisualizationInfo,
		[_e.ZoneControl] = _w.GetZoneControlVisualizationInfo,
		[_e.CaptureZone] = _w.GetCaptureZoneVisualizationInfo,
		[_e.TextureWithAnimation] = _w.GetTextureWithAnimationVisualizationInfo,
		[_e.DiscreteProgressSteps] = _w.GetDiscreteProgressStepsVisualizationInfo,
		[_e.ScenarioHeaderTimer] = _w.GetScenarioHeaderTimerWidgetVisualizationInfo,
	}
	local function tableToString(key, t)
		local str = sformat("%s", key)
		for k,v in pairs(t) do
			if type(v) == table then
				str = sformat("%s\r%s", str, tableToString(k,v))
			else
				str = sformat("%s\r%s : %s", str, k, tostring(v))
			end
		end
		return str
	end
	local function _count(t)
		if not t then return 0 end
		local i = 0
		for _ in pairs(t) do
			i = i + 1
		end
		return i
	end
	local _concat = table.concat
	local function _checkChangedValues(key, oldData, newData)
		local t1 = type(oldData) == "table"
		local t2 = type(newData) == "table"
		if t1 or t2 then
			if t1 and t2 then
				local _oi = _count(oldData)
				local _ni = _count(newData)
				local changedValues = {}
				if _oi == _ni or _oi > _ni then -- Old table has more keys (or they have same amount of keys, cba to loop trough to check if all keys are the same)
					for k,v in pairs(oldData) do
						local str = _checkChangedValues(k, v, newData[k])
						if str then
							tinsert(changedValues, str)
						end
					end
				else -- New data has more keys
					for k,v in pairs(newData) do
						str = _checkChangedValues(k, oldData[k], v)
						if str then
							tinsert(changedValues, str)
						end
					end
				end
				if #changedValues == 0 then return end
				return _concat(changedValues, "\r")
			elseif t1 then -- Was table, isn't anymore
				return sformat("%s : %s (table)", key, tostring(newData))
			else -- Is table now, wasn't before
				return sformat("%s : %s (%s)", key, tableToString(t), oldData)
			end
		elseif oldData ~= newData then
			return sformat("%s : %s (%s)", key, tostring(newData), tostring(oldData))
		end
		return
	end
	local function _updateWidgetData(widgetInfo)
		local widgetData = _widgetHandlers[widgetInfo.widgetType](widgetInfo.widgetID)
		local sourceName, sourceGUID
		local shown = widgetData.shownState
		if shown == 0 and not seenWidgets[widgetInfo.widgetID] then return 0 end
		local widgetDataToShow = {prev = {"Changed values from previous:"}, first = {"Changed values from first:"}}
		if widgetInfo.unitToken then
			sourceGUID = UnitGUID(unitID) or UNKNOWN -- cba to do more checks
			sourceName = UnitName(unitID) or UNKNOWN
		end
		if seenWidgets[widgetInfo.widgetID] then
			local prevData = seenWidgets[widgetInfo.widgetID].prev or nil
			local firstData = seenWidgets[widgetInfo.widgetID].first
			if seenWidgets[widgetInfo.widgetID].shownState and shown == 0 then -- state changed to hidden
				shown = 2
			end
			for k,v in pairs(widgetData) do
				local newFromFirst = _checkChangedValues(k, firstData[k], v)
				if newFromFirst then
					tinsert(widgetDataToShow.first, newFromFirst)
				end
				if prevData then
					local newFromPrev = _checkChangedValues(k, prevData[k], v)
					if newFromPrev then
						tinsert(widgetDataToShow.prev, newFromPrev)
					end
				end
			end
			seenWidgets[widgetInfo.widgetID].prev = widgetData
			return shown, sformat("%s\r\r%s", 
			(#widgetDataToShow.prev > 1 and _concat(widgetDataToShow.prev, "\r") or "Changed values from previous: NONE"), 
			(#widgetDataToShow.first > 1 and _concat(widgetDataToShow.first, "\r") or "Changed values from first: NONE")),
			sourceName, sourceGUID
		end
		seenWidgets[widgetInfo.widgetID] = {first = widgetData}
		return shown, tableToString("*New*", widgetData), sourceName, sourceGUID
	end

	iEET.eventFunctions[eventID] = {
		data = d,
		gui = function(args, getGUID)
			local guid = sformat("%s-%s", eventID, args[d.widgetID]) -- Create unique string from event + widgetID
			local dataToShow = args[d.widgetData]:gsub("Changed values from previous:", "") -- remove stuff so you have a chance to see something of value in ieet main window
			dataToShow = dataToShow:gsub("Changed values from first:", "")
			if getGUID then return guid end
			return guid, -- 1
				nil, -- 2
				sformat("%s (%s)", args[d.widgetID], args[d.widgetSetID]), -- 3
				dataToShow, -- 4
				args[d.unitID] and ({unitID = args[d.unitID], casterName = args[d.sourceName]}) or nil -- 5
		end,
		import = function(args)
			args[d.widgetID] = tonumber(args[d.widgetID])
			args[d.widgetSetID] = tonumber(args[d.widgetSetID])
			args[d.widgetType] = tonumber(args[d.widgetType])
			return args
		end,
		filtering = function(args, filters, ...)
			return defaultFiltering(args, d, filters, eventID, ...)
		end,
		hyperlink = function(col, data)
			if col == 7 or col == 8 then return end
			addToTooltip(nil,
				formatKV("Widget id", data[d.widgetID]),
				formatKV("Widget type", data[d.widgetType]),
				formatKV("widget set id", data[d.widgetSetID]),
				formatKV("Unit token", data[d.unitID]),
				formatKV("Source name", data[d.sourceName]),
				formatKV("Source GUID", data[d.sourceGUID]),
				formatKV("Widget data", data[d.widgetData])
			)
			return true
		end,
		chatLink = function(col, data) return end,
	}
	function addon:UPDATE_UI_WIDGET(widgetInfo)
		-- shown: 0 = hidden, 1 = shown, 2 = was shown, now hidden, let trough
		local shown, widgetData, sourceName, sourceGUID = _updateWidgetData(widgetInfo)
		if shown == 0 then return end
		local t = {
			[d.event] = eventID,
			[d.time] = GetTime(),
			[d.widgetID] = widgetInfo.widgetID,
			[d.widgetData] = widgetData,
			[d.widgetType] = widgetInfo.widgetType,
			[d.widgetSetID] = widgetInfo.widgetSetID,
			[d.unitID] = widgetInfo.unitToken,
			[d.sourceName] = sourceName,
			[d.sourceGUID] = sourceGUID,
		}
		tinsert(iEET.data, t)
		iEET:OnscreenAddMessages(t)
	end
end
do -- DeadlyBossMods
	local dbmHandlers = {}
	do -- DBM_Announce
		local eventID = 66
		local d = {
			["event"] = 1,
			["time"] = 2,
			["message"] = 3,
			["icon"] = 4,
			["messageType"] = 5,
			["spellID"] = 6,
			["modID"] = 7,
			["special"] = 8,
		}
		iEET.eventFunctions[eventID] = {
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("%s-%s-%s", eventID, (args[d.spellID] or ""), (args[d.modID] or "")) -- Create unique string from event + spellID + modID
				if getGUID then return guid end
				return guid, -- 1
					iEET.specialCategories.Ignore, -- 2
					args[d.message], -- 3
					args[d.messageType], -- 4
					args[d.spellID], -- 5
					args[d.modID] -- 6
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				addToTooltip(nil,
					formatKV("Message", data[d.message]),
					formatKV("Icon", data[d.icon]),
					formatKV("Type", data[d.messageType]),
					formatKV("Spell ID", data[d.spellID]),
					formatKV("Mod ID", data[d.modID]),
					formatKV("Special", data[d.special])
				)
				return true
			end,
			import = function(args)
				args[d.spellID] = tonumber(args[d.spellID])
				return args
			end,
			chatLink = function(col, data) return end,
		}	
		function dbmHandlers:DBM_Announce(msg, icon, msgType, spellID, modID, specialWarning)
			local t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.message] = msg,
				[d.icon] = icon,
				[d.messageType] = msgType,
				[d.spellID] = spellID,
				[d.modID] = modID,
				[d.special] = specialWarning,
			}
			table.insert(iEET.data, t);
			iEET:OnscreenAddMessages(t)
		end
	end
	do -- DBM_Debug
		local eventID = 67
		local d = {
			["event"] = 1,
			["time"] = 2,
			["message"] = 3,
			["level"] = 4,
		}
		iEET.eventFunctions[eventID] = {
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("%s-%s", eventID, (args[d.level] or "")) -- Create unique string from event + debug level
				if getGUID then return guid end
				return guid, -- 1
					iEET.specialCategories.Ignore, -- 2
					args[d.message], -- 3
					args[d.level] -- 4
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				if col == 4 or col == 5 then
					addToTooltip(nil,
						formatKV("Message", data[d.message]),
						formatKV("Level", data[d.level])
					)
					return true
				end
			end,
			import = function(args)
				return args
			end,
			chatLink = function(col, data) return end,
		}	
		function dbmHandlers:DBM_Debug(msg, level)
			local t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.message] = msg,
				[d.level] = level,
			}
			table.insert(iEET.data, t);
			iEET:OnscreenAddMessages(t)
		end
	end
	do -- DBM_TimerStart
		local eventID = 68
		local d = {
			["event"] = 1,
			["time"] = 2,
			["id"] = 3,
			["message"] = 4,
			["timer"] = 5,
			["icon"] = 6,
			["messageType"] = 7,
			["spellID"] = 8,
			["colorID"] = 9,
			["modID"] = 10,
			["keep"] = 11,
			["fade"] = 12,
			["spellName"] = 13,
			["mobGUID"] = 14,
		}
		iEET.eventFunctions[eventID] = {
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("%s-%s-%s", eventID, (args[d.spellID] or ""), (args[d.modID] or "")) -- Create unique string from event + spellID + modID
				if getGUID then return guid end
				return guid, -- 1
					iEET.specialCategories.Ignore, -- 2
					args[d.message], -- 3
					args[d.messageType], -- 4
					args[d.spellID], -- 5
					args[d.timer] -- 6
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				addToTooltip(nil,
					formatKV("ID", data[d.id]),
					formatKV("Message", data[d.message]),
					formatKV("Timer", data[d.timer]),
					formatKV("Icon", data[d.icon]),
					formatKV("Type", data[d.messageType]),
					formatKV("Spell ID", data[d.spellID]),
					formatKV("Mod ID", data[d.modID]),
					formatKV("Color ID", data[d.colorID]),
					formatKV("Keep", data[d.keep]),
					formatKV("Fade", data[d.fade]),
					formatKV("Spell name", data[d.spellName]),
					formatKV("Mob GUID", data[d.mobGUID])
				)
				return true
			end,
			import = function(args)
				args[d.spellID] = tonumber(args[d.spellID])
				args[d.timer] = tonumber(args[d.timer])
				return args
			end,
			chatLink = function(col, data) return end,
		}	
		function dbmHandlers:DBM_TimerStart(id, msg, timer, icon, msgType, spellID, colorID, modID, keep, fade, spellName, mobGUID)
			local t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.message] = msg,
				[d.icon] = icon,
				[d.messageType] = msgType,
				[d.spellID] = spellID,
				[d.colorID] = colorID,
				[d.modID] = modID,
				[d.keep] = keep,
				[d.fade] = fade,
				[d.spellName] = spellName,
				[d.mobGUID] = mobGUID,
			}
			table.insert(iEET.data, t);
			iEET:OnscreenAddMessages(t)
		end
	end
	do -- DBM_TimerStop
		local eventID = 69
		local d = {
			["event"] = 1,
			["time"] = 2,
			["id"] = 3,
		}
		iEET.eventFunctions[eventID] = {
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("%s-%s", eventID, (args[d.id] or "")) -- Create unique string from event + id
				if getGUID then return guid end
				return guid, -- 1
					iEET.specialCategories.Ignore, -- 2
					args[d.id] -- 3
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				if col == 4 then
					addToTooltip(nil,
						formatKV("ID", data[d.id])
					)
					return true
				end
			end,
			import = function(args)
				return args
			end,
			chatLink = function(col, data) return end,
		}	
		function dbmHandlers:DBM_TimerStop(id)
			local t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.id] = id,
			}
			table.insert(iEET.data, t);
			iEET:OnscreenAddMessages(t)
		end
	end
	do -- DBM_TimerFadeUpdate
		local eventID = 70
		local d = {
			["event"] = 1,
			["time"] = 2,
			["id"] = 3,
			["spellID"] = 4,
			["modID"] = 5,
			["fade"] = 6,
		}
		iEET.eventFunctions[eventID] = {
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("%s-%s-%s", eventID, (args[d.id] or "")) -- Create unique string from event + id
				if getGUID then return guid end
				return guid, -- 1
					iEET.specialCategories.Ignore, -- 2
					args[d.id], -- 3
					args[d.spellID], -- 4
					args[d.modID], -- 5
					args[d.fade] -- 6
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				if col == 4 then
					addToTooltip(nil,
						formatKV("ID", data[d.id]),
						formatKV("Spell ID", data[d.spellID]),
						formatKV("Mod ID", data[d.modID]),
						formatKV("Fade", data[d.fade])
					)
					return true
				end
			end,
			import = function(args)
				args[d.spellID] = tonumber(args.spellID)
				return args
			end,
			chatLink = function(col, data) return end,
		}	
		function dbmHandlers:DBM_TimerFadeUpdate(id, spellID, modID, fade)
			local t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.id] = id,
				[d.spellID] = spellID,
				[d.modID] = modID,
				[d.fade] = fade,
			}
			table.insert(iEET.data, t);
			iEET:OnscreenAddMessages(t)
		end
	end
	do -- DBM_TimerUpdate
		local eventID = 71
		local d = {
			["event"] = 1,
			["time"] = 2,
			["id"] = 3,
			["elapsed"] = 4,
			["total"] = 5,
		}
		iEET.eventFunctions[eventID] = {
			data = d,
			gui = function(args, getGUID)
				local guid = sformat("%s-%s-%s", eventID, (args[d.id] or "")) -- Create unique string from event + id
				if getGUID then return guid end
				return guid, -- 1
					iEET.specialCategories.Ignore, -- 2
					args[d.id], -- 3
					args[d.elapsed], -- 4
					args[d.total] -- 5
			end,
			filtering = function(args, filters, ...)
				return defaultFiltering(args, d, filters, eventID, ...)
			end,
			hyperlink = function(col, data)
				if col == 4 then
					addToTooltip(nil,
						formatKV("ID", data[d.id]),
						formatKV("Elapsed", data[d.elapsed]),
						formatKV("Total", data[d.total])
					)
					return true
				end
			end,
			import = function(args)
				args[d.elapsed] = tonumber(args[d.elapsed])
				args[d.total] = tonumber(args[d.total])
				return args
			end,
			chatLink = function(col, data) return end,
		}	
		function dbmHandlers:DBM_TimerUpdate(id, elapsed, total)
			local t = {
				[d.event] = eventID,
				[d.time] = GetTime(),
				[d.id] = id,
				[d.elapsed] = elapsed,
				[d.total] = total,
			}
			table.insert(iEET.data, t);
			iEET:OnscreenAddMessages(t)
		end
	end
	local callbacks = {
		DBM_Announce = dbmHandlers.DBM_Announce,
		DBM_Debug = dbmHandlers.DBM_Debug,
		DBM_TimerStart = dbmHandlers.DBM_TimerStart,
		DBM_TimerStop = dbmHandlers.DBM_TimerStop,
		DBM_TimerFadeUpdate = dbmHandlers.DBM_TimerFadeUpdate,
		DBM_TimerUpdate = dbmHandlers.DBM_TimerUpdate,
	}
	function iEET:DBMRecording(start)
		if not DBM then
			return
		end		
		for event,func in pairs(callbacks) do
			if start then
				DBM:RegisterCallback(event, func)
			else
				DBM:UnregisterCallback(event, func)
			end
		end
	end
end


--Gather all keys for filtering
iEET.allPossibleKeys = {}
for k,v in pairs(iEET.eventFunctions) do
	for key,_ in pairs(v.data) do
		if key ~= "event" then
			iEET.allPossibleKeys[key] = true
		end
	end
end
--[[
function iEET_CHECK_EVENTS()
	for k,v in pairs(iEET.eventFunctions) do
		for _,tName in pairs({"data", "gui", "filtering", "hyperlink", "import", "chatLink"}) do
			if not v[tName] then print(k,"Missing", tName) end
		end
	end
end
--]]