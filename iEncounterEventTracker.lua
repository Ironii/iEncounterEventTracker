--[[--------------------------FILTERING-OPTIONS-USAGE-------------
split different args with ';' NOT DONE
x=x
possible key values:
t	time 		number
e	event 		number or string	(long(SPELL_CAST_START instead of SC_START) event name or number, numbers under iEET.events)
sG	sourceGUID	string	UNIT_DIED:destGUID
cN	sourceName	string	UNIT_DIED:destName
tN	destName		string	USCS: source unitID
sN	spellName	string
sI	spellID		number
hp	Health		number	USCS only

--]]--------------------------------------------------------------
--[[TO DO:--
compare
--]]
local _, iEET = ...
iEET.data = {}
--local isAlpha = select(4, GetBuildInfo()) >= 70000 and true or false
iEET.ignoring = {} -- so ignore list resets on relog, don't want to save it, atleast not yet
--iEET.font = isAlpha and 'Fonts\\ARIALN.TTF' or 'Interface\\AddOns\\iEncounterEventTracker\\FiraMono-Regular.otf'
iEET.font = 'Interface\\AddOns\\iEncounterEventTracker\\FiraMono-Regular.otf'
--iEET.fontsize = isAlpha and 11 or 9
iEET.fontsize = 9
iEET.spacing = 1
iEET.scale = 1
iEET.justifyH = 'LEFT'
iEET.backdrop = {
	bgFile = 'Interface\\Buttons\\WHITE8x8',
	edgeFile = 'Interface\\Buttons\\WHITE8x8',
	edgeSize = 1,
	insets = {
		left = -1,
		right = -1,
		top = -1,
		bottom = -1,
	}
}
iEET.version = 1.540
local colors = {}
local eventsToTrack = {
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
local addon = CreateFrame('frame')
addon:RegisterEvent('ENCOUNTER_START')
addon:RegisterEvent('ENCOUNTER_END')
addon:RegisterEvent('ADDON_LOADED')
addon:RegisterEvent('PLAYER_LOGOUT')
addon:SetScript('OnEvent', function(self, event, ...)
	self[event](self, ...)
end)
iEET.IEEUnits = {}
iEET.unitPowerUnits = {}
iEET.events = {
	['toID'] = {
		['SPELL_CAST_START'] = 1,
		['SPELL_CAST_SUCCESS'] = 2,
		['SPELL_AURA_APPLIED'] = 3,
		['SPELL_AURA_REMOVED'] = 4,
		['SPELL_AURA_APPLIED_DOSE'] = 5,
		['SPELL_AURA_REMOVED_DOSE'] = 6,
		['SPELL_AURA_REFRESH'] = 7,
		['SPELL_CAST_FAILED'] = 8,
		['SPELL_CREATE'] = 9,
		['SPELL_SUMMON'] = 10,
		['SPELL_HEAL'] = 11,
		['SPELL_DISPEL'] = 12,
		['SPELL_INTERRUPT'] = 13,

		['SPELL_PERIODIC_CAST_START'] = 14,
		['SPELL_PERIODIC_CAST_SUCCESS'] = 15,
		['SPELL_PERIODIC_AURA_APPLIED'] = 16,
		['SPELL_PERIODIC_AURA_REMOVED'] = 17,
		['SPELL_PERIODIC_AURA_APPLIED_DOSE'] = 18,
		['SPELL_PERIODIC_AURA_REMOVED_DOSE'] = 19,
		['SPELL_PERIODIC_AURA_REFRESH'] = 20,
		['SPELL_PERIODIC_CAST_FAILED'] = 21,
		['SPELL_PERIODIC_CREATE'] = 22,
		['SPELL_PERIODIC_SUMMON'] = 23,
		['SPELL_PERIODIC_HEAL'] = 24,

		['UNIT_DIED'] = 25,
		
		['UNIT_SPELLCAST_SUCCEEDED'] = 26,

		['ENCOUNTER_START'] = 27,
		['ENCOUNTER_END'] = 28,

		['MONSTER_EMOTE'] = 29,
		['MONSTER_SAY'] = 30,
		['MONSTER_YELL'] = 31,
		
		['UNIT_TARGET'] = 32,
		
		['INSTANCE_ENCOUNTER_ENGAGE_UNIT'] = 33,
		
		['UNIT_POWER'] = 34,
					
		['PLAYER_REGEN_DISABLED'] = 35,
		['PLAYER_REGEN_ENABLED'] = 36,
		
		['MANUAL_LOGGING_START'] = 37, -- Fake event for manual logging
		['MANUAL_LOGGING_END'] = 38, -- Fake event for manual logging
		
		['UNIT_SPELLCAST_START'] = 39,
		['UNIT_SPELLCAST_CHANNEL_START'] = 40,
	},
	['fromID'] = {
		[1] = {
			l = 'SPELL_CAST_START',
			s = 'SC_START',
		},
		[2] = {
			l = 'SPELL_CAST_SUCCESS',
			s = 'SC_SUCCESS',
		},
		[3] = {
			l = 'SPELL_AURA_APPLIED',
			s = '+SAURA',
		},
		[4] = {
			l = 'SPELL_AURA_REMOVED',
			s = '-SAURA',
		},
		[5] = {
			l = 'SPELL_AURA_APPLIED_DOSE',
			s = '+SA_DOSE',
		},
		[6] = {
			l = 'SPELL_AURA_REMOVED_DOSE',
			s = '-SA_DOSE',
		},
		[7] = {
			l = 'SPELL_AURA_REFRESH',
			s = 'SAURA_R',
		},
		[8] = {
			l = 'SPELL_CAST_FAILED',
			s = 'SC_FAILED',
		},
		[9] = {
			l = 'SPELL_CREATE',
			s = 'SPELL_CREATE',
		},
		[10] = {
			l = 'SPELL_SUMMON',
			s = 'SPELL_SUMMON',
		},
		[11] = {
			l = 'SPELL_HEAL',
			s = 'SPELL_HEAL',
		},
		[12] = {
			l = 'SPELL_DISPEL',
			s = 'SPELL_DISPEL',
		},
		[13] = {
			l = 'SPELL_INTERRUPT',
			s = 'S_INTERRUPT',
		},
		[14] = {
			l = 'SPELL_PERIODIC_CAST_START',
			s = 'SPC_START',
		},
		[15] = {
			l = 'SPELL_PERIODIC_CAST_SUCCESS',
			s = 'SPC_SUCCESS',
		},
		[16] = {
			l = 'SPELL_PERIODIC_AURA_APPLIED',
			s = '+SPAURA',
		},
		[17] = {
			l = 'SPELL_PERIODIC_AURA_REMOVED',
			s = '-SPAURA',
		},
		[18] = {
			l = 'SPELL_PERIODIC_AURA_APPLIED_DOSE',
			s = '+SPA_DOSE',
		},
		[19] = {
			l = 'SPELL_PERIODIC_AURA_REMOVED_DOSE',
			s = '-SPA_DOSE',
		},
		[20] = {
			l = 'SPELL_PERIODIC_AURA_REFRESH',
			s = 'SPAURA_R',
		},
		[21] = {
			l = 'SPELL_PERIODIC_CAST_FAILED',
			s = 'SPC_FAILED',
		},
		[22] = {
			l = 'SPELL_PERIODIC_CREATE',
			s = 'SP_CREATE',
		},
		[23] = {
			l = 'SPELL_PERIODIC_SUMMON',
			s = 'SP_SUMMON',
		},
		[24] = {
			l = 'SPELL_PERIODIC_HEAL',
			s = 'SP_HEAL',
		},
		[25] = {
			l = 'UNIT_DIED',
			s = 'UNIT_DIED',
		},
		[26] = {
			l = 'UNIT_SPELLCAST_SUCCEEDED',
			s = 'USC_SUCCEEDED',
		},
		[27] = {
			l = 'ENCOUNTER_START',
			s = 'ENCOUNTER_START',
		},
		[28] = {
			l = 'ENCOUNTER_END',
			s = 'ENCOUNTER_END',
		},
		[29] = {
			l = 'MONSTER_EMOTE',
			s = 'MONSTER_EMOTE',
		},
		[30] = {
			l = 'MONSTER_SAY',
			s = 'MONSTER_SAY',
		},
		[31] = {
			l = 'MONSTER_YELL',
			s = 'MONSTER_YELL',
		},
		[32] = {
			l = 'UNIT_TARGET',
			s = 'UNIT_TARGET',
		},
		[33] = {
			l = 'INSTANCE_ENCOUNTER_ENGAGE_UNIT',
			s = 'IEEU',
		},
		[34] = {
			l = 'UNIT_POWER',
			s = 'UNIT_POWER',
		},
		[35] = {
			l = 'PLAYER_REGEN_DISABLED',
			s = 'COMBAT_START',
		},
		[36] = {
			l = 'PLAYER_REGEN_ENABLED',
			s = 'COMBAT_END',
		},
		[37] = {
			l = 'MANUAL_LOGGING_START',
			s = 'MANUAL_START',
		},
		[38] = {
			l = 'MANUAL_LOGGING_END',
			s = 'MANUAL_END',
		},
		[39] = {
			l = 'UNIT_SPELLCAST_START',
			s = 'USC_START',
		},
		[40] = {
			l = 'UNIT_SPELLCAST_CHANNEL_START',
			s = 'USC_C_START',
		},
	},
}
iEET.ignoreList = {  -- Ignore list for 'Ignore Spell's menu, use event ignore to hide these if you want (they are fake spells)
	[98391] = true, -- Death
	[103528] = true, -- Target Selection
	[133217] = true, -- Spawn NPCs
	[143409] = true, -- Power Update
}
local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
function iEET:LoadDefaults()
	local defaults = {
		['tracking'] = {
			['SPELL_CAST_START'] = true,
			['SPELL_CAST_SUCCESS'] = true,
			['SPELL_AURA_APPLIED'] = true,
			['SPELL_AURA_REMOVED'] = true,
			['SPELL_AURA_APPLIED_DOSE'] = true,
			['SPELL_AURA_REMOVED_DOSE'] = true,
			['SPELL_AURA_REFRESH'] = true,
			['SPELL_CAST_FAILED'] = true,
			['SPELL_CREATE'] = true,
			['SPELL_SUMMON'] = true,
			['SPELL_HEAL'] = true,
			['SPELL_DISPEL'] = true,
			['SPELL_INTERRUPT'] = true,

			['SPELL_PERIODIC_CAST_START'] = true,
			['SPELL_PERIODIC_CAST_SUCCESS'] = true,
			['SPELL_PERIODIC_AURA_APPLIED'] = true,
			['SPELL_PERIODIC_AURA_REMOVED'] = true,
			['SPELL_PERIODIC_AURA_APPLIED_DOSE'] = true,
			['SPELL_PERIODIC_AURA_REMOVED_DOSE'] = true,
			['SPELL_PERIODIC_AURA_REFRESH'] = true,
			['SPELL_PERIODIC_CAST_FAILED'] = true,
			['SPELL_PERIODIC_CREATE'] = true,
			['SPELL_PERIODIC_SUMMON'] = true,
			['SPELL_PERIODIC_HEAL'] = true,

			['UNIT_DIED'] = true,

			['UNIT_SPELLCAST_SUCCEEDED'] = true,
			['UNIT_SPELLCAST_START'] = true,
			['UNIT_SPELLCAST_CHANNEL_START'] = true,
			
			['MONSTER_EMOTE'] = true,
			['MONSTER_SAY'] = true,
			['MONSTER_YELL'] = true,

			['ENCOUNTER_START'] = true,
			['ENCOUNTER_END'] = true,
			
			['UNIT_TARGET'] = true,
			['INSTANCE_ENCOUNTER_ENGAGE_UNIT'] = true,
			
			['UNIT_POWER'] = true,
			
			['PLAYER_REGEN_DISABLED'] = true,
			['PLAYER_REGEN_ENABLED'] = true,
			
			['MANUAL_LOGGING_START'] = true,
			['MANUAL_LOGGING_END'] = true,
		},
		['version'] = iEET.version,
		['autoSave'] = true,
		['autoDiscard'] = 30,
		['filtering'] = {
			['timeBasedFiltering'] = {},
			['req'] = {},
			['requireAll'] = false,
			['showTime'] = false, -- show time from nearest 'from' event instead of ENCOUNTER_START
		},
		['colors'] = {
			['main'] = {
				['bg'] = {['r'] = 0.1, ['g'] = 0.1, ['b'] = 0.1, ['a'] = 0.9},
				['border'] = {['r'] = 0, ['g'] = 0, ['b'] = 0, ['a'] = 1},
			},
			['options'] = {
				['bg'] = {['r'] = 0.1, ['g'] = 0.1, ['b'] = 0.1, ['a'] = 0.9},
				['border'] = {['r'] = 0.64, ['g'] = 0, ['b'] = 0, ['a'] = 1},
			},
		},
		['classColors'] = false,
	}
	for k,v in pairs(defaults) do
		if iEETConfig[k] == nil then
			iEETConfig[k] = v
		elseif type(v) == 'table' then -- mainly for new events and filtering stuff, no need to go deeper
			for deeperKey, deeperValue in pairs(v) do
				if iEETConfig[k][deeperKey] == nil then
					iEETConfig[k][deeperKey] = deeperValue
				end
			end
		end
	end
end
function addon:ADDON_LOADED(addonName)
	if addonName == 'iEncounterEventTracker' then
		iEETConfig = iEETConfig or {}
		--if not iEETConfig.version or not iEETConfig.tracking or iEETConfig.version < 1.503 then -- Last version with db changes
		iEET:LoadDefaults()
		--else
		iEETConfig.version = iEET.version
		--end
		addon:UnregisterEvent('ADDON_LOADED')
	end
end
function addon:PLAYER_LOGOUT()
	if iEET.forceRecording then
		iEET:Force()
	end
end
function addon:ENCOUNTER_START(encounterID, encounterName)
	if not iEET.forceRecording then
		iEET:StartRecording()
		iEET.encounterInfoData = { --TODO
			['s'] = GetTime(),
			['eN'] = encounterName,
			['pT'] = date('%y.%m.%d %H:%M'), -- y.m.d instead of d.m.y for easier sorting
			['fT'] = '00:00',
			['d']= 0,
			['rS'] = 0,
			['k'] = 0,
			['v'] = iEET.version,
		}
	end
	table.insert(iEET.data, {['e'] = 27, ['t'] = GetTime(), ['cN'] = encounterName, ['tN'] = encounterID})
end
function addon:ENCOUNTER_END(EncounterID, encounterName, difficultyID, raidSize, kill)
	table.insert(iEET.data, {['e'] = 28, ['t'] = GetTime() ,['cN'] = kill == 1 and 'Victory!' or 'Wipe'})
	if not iEET.forceRecording then
		if iEET.encounterInfoData then
			iEET.encounterInfoData.fT = iEET.encounterInfoData.s and date('%M:%S', (GetTime() - iEET.encounterInfoData.s)) or '00:00' -- if we are missing start time for some reason
			iEET.encounterInfoData.d = difficultyID
			iEET.encounterInfoData.k = kill
			iEET.encounterInfoData.rS = raidSize
		else
				iEET.encounterInfoData = {
				['s'] = GetTime(),
				['eN'] = encounterName,
				['pT'] = date('%y.%m.%d %H:%M'), -- y.m.d instead of d.m.y for easier sorting
				['fT'] = '00:00',
				['d']= difficultyID,
				['rS'] = raidSize,
				['k'] = kill,
				['v'] = iEET.version,
			}
		end
		iEET:StopRecording()
	end
end
function addon:UNIT_SPELLCAST_SUCCEEDED(unitID, spellName,_,arg4,spellID)
	local sourceGUID = UnitGUID(unitID)
	local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
	if sourceGUID then -- fix for arena id's
		unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
	end
	if (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and iEET.approvedSpells[spellID]) or not sourceGUID then
		local sourceName = UnitName(unitID)
		local chp = UnitHealth(unitID)
		local maxhp = UnitHealthMax(unitID)
		local php = nil
		if chp and maxhp then
			php = math.floor(chp/maxhp*1000+0.5)/10
		end
		--3-2084-1520-9097-202968-0028916A53
		--[[
		if isAlpha then
			local id = select(5, strsplit('-', arg4))
			spellID = tonumber(id)
		end
		--]]
		if not iEET.npcIgnoreList[tonumber(npcID)] then
			if not iEET.ignoredSpells[spellID] then
				table.insert(iEET.data, {
					['e'] = 26,
					['t'] = GetTime(),
					['sG'] = sourceGUID or 'NONE',
					['cN'] = sourceName or 'NONE',
					['tN'] = unitID or nil,
					['sN'] = spellName or nil,
					['sI'] = spellID or nil,
					['hp'] = php or nil,
				});
			end
		end
	end
end
function addon:UNIT_SPELLCAST_START(unitID, spellName,_,arg4,spellID)
	local sourceGUID = UnitGUID(unitID)
	local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
	if sourceGUID then -- fix for arena id's
		unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
	end
	if (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and iEET.approvedSpells[spellID]) or not sourceGUID then
		local sourceName = UnitName(unitID)
		local chp = UnitHealth(unitID)
		local maxhp = UnitHealthMax(unitID)
		local php = nil
		if chp and maxhp then
			php = math.floor(chp/maxhp*1000+0.5)/10
		end
		--3-2084-1520-9097-202968-0028916A53
		--[[
		if isAlpha then
			local id = select(5, strsplit('-', arg4))
			spellID = tonumber(id)
		end
		--]]
		if not iEET.npcIgnoreList[tonumber(npcID)] then
			if not iEET.ignoredSpells[spellID] then
				table.insert(iEET.data, {
					['e'] = 39,
					['t'] = GetTime(),
					['sG'] = sourceGUID or 'NONE',
					['cN'] = sourceName or 'NONE',
					['tN'] = unitID or nil,
					['sN'] = spellName or nil,
					['sI'] = spellID or nil,
					['hp'] = php or nil,
				});
			end
		end
	end
end
function addon:UNIT_SPELLCAST_CHANNEL_START(unitID, spellName,_,arg4,spellID)
	local sourceGUID = UnitGUID(unitID)
	local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
	if sourceGUID then -- fix for arena id's
		unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
	end
	if (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and iEET.approvedSpells[spellID]) or not sourceGUID then
		local sourceName = UnitName(unitID)
		local chp = UnitHealth(unitID)
		local maxhp = UnitHealthMax(unitID)
		local php = nil
		if chp and maxhp then
			php = math.floor(chp/maxhp*1000+0.5)/10
		end
		--3-2084-1520-9097-202968-0028916A53
		--[[
		if isAlpha then
			local id = select(5, strsplit('-', arg4))
			spellID = tonumber(id)
		end
		--]]
		if not iEET.npcIgnoreList[tonumber(npcID)] then
			if not iEET.ignoredSpells[spellID] then
				table.insert(iEET.data, {
					['e'] = 40,
					['t'] = GetTime(),
					['sG'] = sourceGUID or 'NONE',
					['cN'] = sourceName or 'NONE',
					['tN'] = unitID or nil,
					['sN'] = spellName or nil,
					['sI'] = spellID or nil,
					['hp'] = php or nil,
				});
			end
		end
	end
end
function addon:UNIT_TARGET(unitID)
	if string.find(unitID, 'boss') then
		if UnitExists(unitID) then --didn't just disappear
			local sourceGUID = UnitGUID(unitID)
			local sourceName = UnitName(unitID)
			local chp = UnitHealth(unitID)
			local maxhp = UnitHealthMax(unitID)
			local php = nil
			local targetName = UnitName(unitID .. 'target') or 'No target'
			--local destGUID = UnitGUID(unitID .. 'target')
			if chp and maxhp then
				php = math.floor(chp/maxhp*1000+0.5)/10
			end
			--[[ -- NOT TESTED
			if iEET.raidComp then 
				if destGUID and iEET.raidComp[destGUID]then --player and is in raid
					eD = '1'..'\n'..iEET.raidComp[destGUID].class..'\n'..iEET.raidComp[destGUID].role
				end
			end
			--]]
			table.insert(iEET.data, {
			['e'] = 32,
			['t'] = GetTime(),
			['sG'] = unitID,
			['cN'] = sourceName or unitID,
			['tN'] = targetName,
			['sN'] = 'Target Selection',
			['sI'] = 103528,
			['hp'] = php,
			});
		end
	end
end
function addon:UNIT_POWER(unitID, powerType)
	if string.find(unitID, 'boss') then
		if UnitExists(unitID) then --didn't just disappear
			local sourceGUID = UnitGUID(unitID)
			local currentPower = UnitPower(unitID, powerType)
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
			local sourceName = UnitName(unitID)
			local chp = UnitHealth(unitID)
			local maxhp = UnitHealthMax(unitID)
			local php = nil
			if chp and maxhp then
				php = math.floor(chp/maxhp*1000+0.5)/10
			end
			if change > 0 then
				change = '+' .. change
			end
			local maxPower = UnitPowerMax(unitID)
			local pUP = 0
			if currentPower and maxPower then
				pUP = math.floor(currentPower/maxPower*1000+0.5)/10
			end
			local powerName = getglobal(powerType) or powerType
			local tooltipText = string.format('%s %s%%;%s/%s;%s',powerName, pUP, currentPower, maxPower, change) --PowerName 50%;50/100;+20
			--/dump string.format('%s %s%%;%s/%s;%s','Rage', 50, 50,100, 20)
			table.insert(iEET.data, {
			['e'] = 34,
			['t'] = GetTime(),
			['sG'] = unitID,
			['cN'] = sourceName or unitID,
			['tN'] = pUP .. '%',
			['sN'] = powerName .. ' Update',
			['sI'] = 143409, -- Power Regen
			['hp'] = php,
			['eD'] = tooltipText, --eD = extraData
			});
		end
	end
end
function addon:COMBAT_LOG_EVENT_UNFILTERED(timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,spellID, spellName,...)
	if eventsToTrack[event] then
		local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
		if sourceGUID then -- fix for arena id's
			unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
		end
		if event == 'UNIT_DIED' then
			unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", destGUID)
			if (unitType == 'Creature') or (unitType == 'Vehicle') or (unitType == 'Player') then
				if not iEET.npcIgnoreList[tonumber(npcID)] then
					table.insert(iEET.data, {
						['e'] = 25,
						['t'] = GetTime(),
						['sG'] = destGUID or 'NONE',
						['cN'] = destName or 'NONE',
						['sN'] = 'Death',
						['sI'] = 98391,
					})
				end
			end
		elseif (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and iEET.approvedSpells[spellID]) or not sourceGUID or hideCaster or event == 'SPELL_INTERRUPT' or event == 'SPELL_DISPEL' then
			if spellID and not iEET.ignoredSpells[spellID] then
				if not iEET.npcIgnoreList[tonumber(npcID)] then
					local eD
					if iEET.raidComp then 
						if iEET.raidComp[destGUID] or iEET.raidComp[sourceGUID] then --player and is in raid
							local toColor = 1
							local guidToColor = destGUID
							if iEET.raidComp[destGUID] and iEET.raidComp[sourceGUID] then
								toColor = 3 -- both
								guidToColor = {sourceGUID,destGUID}
							elseif iEET.raidComp[destGUID] then
								toColor = 2 -- target
								guidToColor = destGUID
							else
								toColor = 1 -- source
								guidToColor = sourceGUID
							end
							--eD = toColor..'\n'..iEET.raidComp[destGUID].class..'\n'..iEET.raidComp[destGUID].role 
							if toColor < 3 then -- source or target
								eD = toColor..'\n'..iEET.raidComp[guidToColor].class..'\n'..iEET.raidComp[guidToColor].role
							else -- both
								eD = toColor..'\n'..iEET.raidComp[guidToColor[1]].class..'\n'..iEET.raidComp[guidToColor[1]].role .. ';' .. '\n'..iEET.raidComp[guidToColor[2]].class..'\n'..iEET.raidComp[guidToColor[2]].role
							end
						end
					end
					table.insert(iEET.data, {
						['e'] = iEET.events.toID[event],
						['t'] = GetTime(),
						['sG'] = sourceGUID or 'NONE',
						['cN'] = sourceName or 'NONE',
						['tN'] = destName or nil,
						['sN'] = spellName or 'NONE',
						['sI'] = spellID or 'NONE',
						['eD']= eD,
					})
				end
			end
		end
	end
end
function addon:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	local newUnits = {}
	local unitNames = {}
	for i = 1, 5 do
		if UnitExists('boss' .. i) then
			local sourceGUID = UnitGUID('boss' .. i)
			local sourceName = UnitName('boss' .. i)
			if not iEET.IEEUnits[sourceGUID] then
				iEET.IEEUnits[sourceGUID] = sourceName
				table.insert(newUnits, {sourceName, 'boss' .. i})
			end
			unitNames[i] = sourceName
		end
	end
	local sourceName,npcNames,unitID
	if #newUnits == 1 then
		sourceName = newUnits[1][1]
		unitID = newUnits[1][2]
	end
	for bossID,encounterName in pairs(unitNames) do
		if npcNames then
			npcNames = npcNames .. string.format('\n%s (%d)',encounterName, bossID)
		else
			npcNames = string.format('%s (%d)',encounterName, bossID)
		end
	end
	table.insert(iEET.data, {
		['e'] = 33,
		['t'] = GetTime(),
		['sG'] = npcNames or 'NONE',
		['cN'] = sourceName or 'NONE',
		['tN'] = unitID,
		['sN'] = 'Spawn NPCs',
		['sI'] = 133217 or nil,
	})
end
function addon:CHAT_MSG_MONSTER_EMOTE(msg, sourceName)
	table.insert(iEET.data, {
		['e'] = 29,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName,
		['sG'] = sourceName,
	});
end
function addon:CHAT_MSG_MONSTER_SAY(msg, sourceName)
	table.insert(iEET.data, {
		['e'] = 30,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName,
		['sG'] = sourceName,
	});
end
function addon:CHAT_MSG_MONSTER_YELL(msg, sourceName)
	table.insert(iEET.data, {
		['e'] = 31,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName,
		['sG'] = sourceName,
	});
end
function addon:PLAYER_REGEN_DISABLED()
	table.insert(iEET.data, {['e'] = 35, ['t'] = GetTime() ,['cN'] = '+Combat'})
end
function addon:PLAYER_REGEN_ENABLED()
	table.insert(iEET.data, {['e'] = 36, ['t'] = GetTime() ,['cN'] = '-Combat'})
end
function iEET:TrimWS(str)
	return str:gsub('^%s*(.-)%s*$', '%1')
end
function iEET:ShowColorPicker(frame)
--function iEET:ShowColorPicker(r,g,b,a,callback)
	iEET.colorToChange = frame
	local r,g,b,a
	if frame == 'mainBG' then
		r,g,b,a = iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a
	elseif frame == 'mainBorder' then
		r,g,b,a = iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a
	elseif frame == 'optionsBG' then
		r,g,b,a = iEETConfig.colors.options.border.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a
	else
		r,g,b,a = iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a
	end
	ColorPickerFrame:SetColorRGB(r,g,b)
	ColorPickerFrame.hasOpacity = true 
	ColorPickerFrame.opacity = a
	ColorPickerFrame.previousValues = {r,g,b,a}
	ColorPickerFrame.func = function() iEET:UpdateColors(frame) end
	ColorPickerFrame.opacityFunc = function() iEET:UpdateColors(frame) end
	ColorPickerFrame.cancelFunc = function() iEET:UpdateColors(frame, {['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a}) end
	ColorPickerFrame:Hide() -- Need to run the OnShow handler.
	ColorPickerFrame:Show()
end
function iEET:UpdateColors(frame, prevColors, force)
	local a,r,g,b
	if not force then
		if not prevColors then
			a = OpacitySliderFrame:GetValue()
			r,g,b = ColorPickerFrame:GetColorRGB()
		else
			r,g,b,a = prevColors.r, prevColors.g, prevColors.b, prevColors.a
		end
		if iEET.colorToChange == 'mainBG' then
			frame = 'main'
			iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a = r,g,b,a
		elseif iEET.colorToChange == 'mainBorder' then
			iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a = r,g,b,a
			frame = 'main'
		elseif iEET.colorToChange == 'optionsBG' then
			iEETConfig.colors.options.border.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a = r,g,b,a
			frame = 'options'
		else
			iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a = r,g,b,a
			frame = 'options'
		end
	end
	local frames = {
		['main'] = {'top','encounterInfo','detailtop','encounterAbilities','contentAnchor1','contentAnchor2','contentAnchor3','contentAnchor4','contentAnchor5','contentAnchor6','contentAnchor7','contentAnchor8','detailAnchor1','detailAnchor2','detailAnchor3','detailAnchor5','detailAnchor6','detailAnchor7','encounterAbilitiesAnchor', 'editbox', 'eventlist', 'npcList', 'spellList','encounterListButton', 'filteringButton', 'optionsList', 'spreadsheetCopyButton', 'exitButton'},
		['options'] = {'optionsFrame','optionsFrameTop','infoFrame','optionsFrameSaveButton','optionsFrameSaveAndCloseButton','optionsFrameCancelButton', 'infoButton', 'optionsFrameEditbox'},
	}
	for _,frameName in pairs(frames[frame]) do
		if iEET[frameName] then
			iEET[frameName]:SetBackdropColor(iEETConfig.colors[frame].bg.r,iEETConfig.colors[frame].bg.g,iEETConfig.colors[frame].bg.b,iEETConfig.colors[frame].bg.a)
			iEET[frameName]:SetBackdropBorderColor(iEETConfig.colors[frame].border.r,iEETConfig.colors[frame].border.g,iEETConfig.colors[frame].border.b,iEETConfig.colors[frame].border.a)
		end
	end
end
function iEET:getColor(event, sourceGUID, spellID)
	if (event and event == 27) or (event and event == 37) then
		return {0,1,0}
	elseif (event and event == 28) or (event and event == 38) then
		return {1,0,0}
	elseif sourceGUID then
		if colors[sourceGUID] and colors[sourceGUID][event] and colors[sourceGUID][event][spellID] then
			return {colors[sourceGUID][event][spellID].r,colors[sourceGUID][event][spellID].g,colors[sourceGUID][event][spellID].b}
		end
		-- https://www.w3.org/WAI/ER/WD-AERT/#color-contrast
		local t, i = {}, 0
		repeat
			t = {
				['r'] = math.random(),
				['g'] = math.random(),
				['b'] = math.random(),
				};
				i = i + 1
		until (((t.r * 255 * 299) + (t.g * 255 * 587) + (t.b * 255 * 114)) / 1000 > 125 or i >= 10)
		if colors[sourceGUID] then
			if colors[sourceGUID][event] then
				if not colors[sourceGUID][event][spellID] then
					colors[sourceGUID][event][spellID] = t
				end
			else
				colors[sourceGUID][event] = {[spellID] = t}
			end
		else
			colors[sourceGUID] = {[event] = {[spellID] = t}}
		end
		return {colors[sourceGUID][event][spellID].r,colors[sourceGUID][event][spellID].g,colors[sourceGUID][event][spellID].b}
	else
		return {1,1,1}
	end
end
function iEET:print(msg)
	print('iEET: ', msg)
end
function iEET:ScrollContent(delta)
	if delta == -1 then
		for i = 1, 8 do
			--local f = _G['iEET_content' .. i]
			if IsShiftKeyDown() then
				--iEET['content' .. i]:PageDown()
				for scrollFix=1, 45 do
					iEET['content' .. i]:ScrollDown()
				end
			else
				iEET['content' .. i]:ScrollDown()
			end
		end
	else
		for i = 1, 8 do
			if IsShiftKeyDown() then
				--iEET['content' .. i]:PageUp()
				for scrollFix=1, 45 do
					iEET['content' .. i]:ScrollUp()
				end
			else
				iEET['content' .. i]:ScrollUp()
			end
		end
	end
end
function iEET:ScrollDetails(delta)
	if delta == -1 then
		for i = 1, 7 do
			if i == 4 then
			else
				if IsShiftKeyDown() then
					for scrollFix=1, 15 do
						iEET['detailContent' .. i]:ScrollDown()
					end
				else
					iEET['detailContent' .. i]:ScrollDown()
				end
			end
		end
	else
		for i = 1, 7 do
			if i == 4 then
			else
				if IsShiftKeyDown() then
					for scrollFix=1, 15 do
						iEET['detailContent' .. i]:ScrollUp()
					end
				else
					iEET['detailContent' .. i]:ScrollUp()
				end
			end
		end
	end
end
function iEET:ShouldShow(eventData,e_time, msg) -- TESTING, msg is a temporary fix
	--[[
	iEETConfig.filtering = {
		timeBasedFiltering = {
			[1] = {
				from = { (or nil)
					timestamp/event/spellid/etc = X
				} ,
				to = { (or nil)
					timestamp/event/spellid/etc = X
				},
				ok = true/false
			}
			...
		},
		req = {
			[1] = {
				event/spellid/etc = X,
				event/spellid/etc = X,
				...
			} ,
		},
		requireAll = true/false, --require all from/to combos
		anyData = X,
		showTime = true -- show time from nearest 'from' event instead of ENCOUNTER_START

	}
	]]
	local shouldShow = true
	if (eventData.sI and iEET.ignoring[eventData.sI]) or
	(iEET.interrupts[eventData.sI] and iEET.ignoring[0.1]) or --0.1 = interrupts
	(iEET.dispels[eventData.sI] and iEET.ignoring[0.2]) or --0.2 = dispels
	(not iEETConfig.tracking[iEET.events.fromID[eventData.e].l]) or
	(iEET.interrupts[eventData.sI] and iEET.ignoring.Interrupters) or --spellid = interrupt and interrupters are ignored
	(iEET.dispels[eventData.sI] and iEET.ignoring.Dispellers) or --spellid = dispel and dispellers are ignored
	(iEET.ignoring[eventData.cN]) then
		shouldShow = false
	elseif eventData.e == 26 or eventData.e == 39 or eventData.e == 40 then -- UNIT_SPELLCAST_SUCCEEDED
		local targetName = eventData.tN
		if string.find(eventData.tN, 'nameplate') then
			targetName = 'nameplates'
		end
		if iEET.ignoring[targetName] then
			shouldShow = false
		end
	end
	local timeOK = true
	local function checkFrom(i)
		if iEETConfig.filtering.timeBasedFiltering[i].from then
			if iEETConfig.filtering.timeBasedFiltering[i].from.t then
				if eventData.t-e_time < iEETConfig.filtering.timeBasedFiltering[i].from.t then
					iEETConfig.filtering.timeBasedFiltering[i].from.ok = false
					return false
				end
			end
			local found = 0
			local c = 0
			for requiredKey, requiredValue in pairs(iEETConfig.filtering.timeBasedFiltering[i].from) do -- try to find right values
				if requiredKey == 't' then	--no need to check time again
					found = found + 1
				elseif eventData[requiredKey] and eventData[requiredKey] == requiredValue then
					found = found + 1
				end
				if eventData[requiredKey] then
					c = c + 1
				end
			end
			if found > 0 and found == c then
				if (c > 1 and iEETConfig.filtering.timeBasedFiltering[i].from.t) or (c > 0 and not iEETConfig.filtering.timeBasedFiltering[i].from.t) then
					iEETConfig.filtering.timeBasedFiltering[i].to.alreadyFound = false
				end
				iEETConfig.filtering.timeBasedFiltering[i].from.ok = true
				return true
			end
		else
			return true
		end
	end
	local function checkTo(i)
		if iEETConfig.filtering.timeBasedFiltering[i].to then
			if iEETConfig.filtering.timeBasedFiltering[i].to.t then
				if eventData.t-e_time > iEETConfig.filtering.timeBasedFiltering[i].to.t then
					iEETConfig.filtering.timeBasedFiltering[i].to.ok = false
					return false
				end
			end
			if iEETConfig.filtering.timeBasedFiltering[i].to then
				local found = 0
				local c = 0
				for requiredKey, requiredValue in pairs(iEETConfig.filtering.timeBasedFiltering[i].to) do -- try to find right values
					if requiredKey == 't' then	--no need to check time again
						found = found + 1
					elseif eventData[requiredKey] and eventData[requiredKey] == requiredValue then
						found = found + 1
					end
					if eventData[requiredKey] then
						c = c + 1
					end
				end
				if found > 0 and found == c then
					iEETConfig.filtering.timeBasedFiltering[i].to.ok = false
					iEETConfig.filtering.timeBasedFiltering[i].to.alreadyFound = true
					iEETConfig.filtering.timeBasedFiltering[i].lastToShow = true
					return false
				else
					if not iEETConfig.filtering.timeBasedFiltering[i].to.alreadyFound then
						iEETConfig.filtering.timeBasedFiltering[i].to.ok = true
						return true
					end
				end
			end
		else
			return true
		end
	end
	if shouldShow then
		local function IsTimeOK()
			if #iEETConfig.filtering.timeBasedFiltering > 0 then
				for i = 1, #iEETConfig.filtering.timeBasedFiltering do -- loop trough every from/to combo
					if iEETConfig.filtering.timeBasedFiltering[i].from and iEETConfig.filtering.timeBasedFiltering[i].to then
						if not iEETConfig.filtering.timeBasedFiltering[i].from.ok then	--from still missing
							if checkFrom(i) then
								iEETConfig.filtering.timeBasedFiltering[i].to.ok = false
								checkTo(i)
							end
						else --from found without to
							if not checkTo(i) then
								iEETConfig.filtering.timeBasedFiltering[i].from.ok = false
								checkFrom(i)
							end
						end
					elseif iEETConfig.filtering.timeBasedFiltering[i].from then
						checkFrom(i)
					else
						checkTo(i)
					end
				end
				local found = 0
				for i = 1, #iEETConfig.filtering.timeBasedFiltering do
					local ok = false
					if iEETConfig.filtering.timeBasedFiltering[i].lastToShow then
						ok = true
						iEETConfig.filtering.timeBasedFiltering[i].lastToShow = nil
					elseif iEETConfig.filtering.timeBasedFiltering[i].from and iEETConfig.filtering.timeBasedFiltering[i].to then
						if iEETConfig.filtering.timeBasedFiltering[i].from.ok and iEETConfig.filtering.timeBasedFiltering[i].to.ok then
							ok = true
						end
					elseif iEETConfig.filtering.timeBasedFiltering[i].to and iEETConfig.filtering.timeBasedFiltering[i].to.ok then
						ok = true
					elseif iEETConfig.filtering.timeBasedFiltering[i].from and iEETConfig.filtering.timeBasedFiltering[i].from.ok then
						ok = true
					end
					if ok then
						found = found + 1
					end
				end
				if (iEETConfig.filtering.requireAll and found == #iEETConfig.filtering.timeBasedFiltering) or (found > 0 and not iEETConfig.filtering.requireAll) then
					return true
				else
					return false
				end
			else
				return true
			end
		end
		if IsTimeOK() then
			if #iEETConfig.filtering.req > 0 or msg then
				for _,t in ipairs(iEETConfig.filtering.req) do
					local found = 0
					local c = 0
					for requiredKey, requiredValue in pairs(t) do -- try to find right values
						if eventData[requiredKey] and eventData[requiredKey] == requiredValue then
							found = found + 1
						end
						c = c + 1
					end
					if found > 0 and found == c then
						return true -- found right values
					end
				end
				if msg then
					for k,v in pairs(eventData) do -- loop trough current event
						if msg and string.find(string.lower(v),msg) then
							return true
						end
					end
				end
				return false -- found nothing
			else
				return true -- nothing to find
			end
		else
			return false
		end
	else
		return false
	end
end
function iEET:FillFilters()
	iEET.optionsFrameFilterTexts:Clear()
	--from/to filters:
	for _,t in pairs(iEETConfig.filtering.timeBasedFiltering) do
		local s = ''
		if t.from then
			s = 'FROM:'
			for k,v in pairs(t.from) do
				if k ~= 'ok' and k ~= 'alreadyFound' then
					s = s .. string.format('%s=%s;',k,v)
				end
			end
		end
		if t.to then
			s = s .. (string.len(s) > 0 and ' ' or '') .. 'TO:'
			for k,v in pairs(t.to) do
				if k ~= 'ok' and k ~= 'alreadyFound' then
					s = s.. string.format('%s=%s;',k,v)
				end
			end
		end
		iEET:AddNewFiltering(s)
	end
	if iEETConfig.filtering.requireAll then
		iEET:AddNewFiltering('requireAll')
	end
	for _,t in pairs(iEETConfig.filtering.req) do
		iEET:AddNewFiltering(t)
	end
end
function iEET:addSpellDetails(hyperlink, linkData)
	--local linkType, spellID = strsplit(':', linkData)
	--spellID = tonumber(spellID)
	--1-7, 4 tyhja
	--local linkType, eventToFind, spellIDToFind, spellNametoFind = strsplit(':',linkData)
	local linkType, eventToFind, spellIDToFind, spellNametoFind = strsplit(':',linkData)
	eventToFind = tonumber(eventToFind)
	if linkType == 'iEETcustomspell' then
		spellIDToFind = tonumber(spellIDToFind)
	end
	local starttime = 0
	local intervalls = {}
	local counts = {}
	for i = 1, 7 do
		if i == 4 then
		else
			iEET['detailContent' .. i]:Clear()
		end
	end
	if linkType == 'iEETList' then 
		spellNametoFind = hyperlink:match('\124h(.-)\124h$')
	end
	for k,v in ipairs(iEET.data) do
		if v.e == 27 then starttime = v.t end -- ENCOUNTER_START
		if linkType == 'iEETcustomspell' or linkType == 'iEETcustomyell' or linkType == 'iEETList' or linkType == 'iEETNpcList' then
			local found = false
			local hyperlinkToShow
			if linkType == 'iEETList' then
				if v.sN == spellNametoFind then
					hyperlinkToShow = '\124HiEETList:' .. (v.eD and string.gsub(v.eD, '%%', '%%%%') or 'Empty List;Contact Ironi') .. '\124h%s\124h'
					found = true
				end
			elseif linkType == 'iEETNpcList' then
				if v.sI and v.sI == 133217 then -- Spawn NPCs
					hyperlinkToShow = '\124HiEETNpcList:' .. v.sG .. '\124h%s\124h'
					found = true
				end
			elseif v.sI then
				if v.sI == spellIDToFind and v.e == eventToFind then
					found = true
				end
			end
			if found then
				local intervall = false
				local timestamp = v.t-starttime or nil
				local count = nil
				if v.sG then
					if intervalls[v.sG] then
						if intervalls[v.sG][v.e] then
							if intervalls[v.sG][v.e][v.sI] then
								intervall = timestamp - intervalls[v.sG][v.e][v.sI]
								intervalls[v.sG][v.e][v.sI] = timestamp
							else
								intervalls[v.sG][v.e][v.sI] = timestamp
							end
						else
							intervalls[v.sG][v.e] = {
									[v.sI] = timestamp,
							};
						end
					else
						intervalls[v.sG] = {
							[v.e] = {
								[v.sI] = timestamp,
							};
						};
					end
					if counts[v.sG] then
						if counts[v.sG][v.e] then
							if counts[v.sG][v.e][v.sI] then
								counts[v.sG][v.e][v.sI] = counts[v.sG][v.e][v.sI] + 1
								count = counts[v.sG][v.e][v.sI]
							else
								counts[v.sG][v.e][v.sI] = 1
								count = 1
							end
						else
							counts[v.sG][v.e] = {
								[v.sI] = 1,
							}
						end
					else
						counts[v.sG] = {
							[v.e] = {
								[v.sI] = 1,
							};
						};
						count = 1
					end
				end
				local color = iEET:getColor(v.e, v.sG, v.sI)
				iEET:addMessages(2, 1, timestamp, color, ('\124HiEETtime:' .. timestamp ..'\124h%s\124h'))
				iEET:addMessages(2, 2, intervall, color, intervall and ('\124HiEETtime:' .. intervall ..'\124h%s\124h') or nil)
				iEET:addMessages(2, 3, iEET.events.fromID[v.e].s, color)
				iEET:addMessages(2, 5, v.cN, color, hyperlinkToShow)
				iEET:addMessages(2, 6, v.tN, color)
				iEET:addMessages(2, 7, count, color)
			end
		end
	end
	iEETDetailInfo:SetText(hyperlink)
end
function iEET:addToContent(timestamp,event,casterName,targetName,spellName,spellID,intervall,count,sourceGUID, hp, extraData)
	local color = iEET:getColor(event, sourceGUID, spellID)
	iEET:addMessages(1, 1, timestamp, color, '\124HiEETtime:' .. timestamp ..'\124h%s\124h')
	iEET:addMessages(1, 2, intervall, color, intervall and ('\124HiEETtime:' .. intervall ..'\124h%s\124h') or nil)
	iEET:addMessages(1, 3, iEET.events.fromID[event].s, color)
	if event == 29 or event == 30 or event == 31 then -- MONSTER_EMOTE = 29, MOSNTER_SAY = 30, MONSTER_YELL = 31
		local msg = spellID
		if event == 29 then --trying to fix monster emotes, MONSTER_EMOTE
			--"|TInterface\\Icons\\spell_fel_elementaldevastation.blp:20|tVerestriona's |cFFFF0000|Hspell:182008|h[Latent Energy]|h|r reacts violently as they step into the |cFFFF0000|Hspell:179582|h[Rumbling Fissure]|h|r!}|D|"
			--TODO: Better solution
			msg = string.gsub(spellID, "|T.+|t", "") -- Textures
			msg = string.gsub(msg, "spell:%d-", "") -- Spells
			msg = string.gsub(msg, "|h", "") -- Spells
			msg = string.gsub(msg, "|H", "") -- Spells
			msg = string.gsub(msg, "|c........", "") -- Colors
			msg = string.gsub(msg, "|r", "") -- Colors
		end
		iEET:addMessages(1, 4, 'Message', color, '\124HiEETcustomyell:' .. event .. ':' .. msg .. '\124h%s\124h') -- NEEDS CHANGING
	elseif spellID then
		if spellID == 133217 then -- INSTANCE_ENCOUNTER_ENGAGE_UNIT
			iEET:addMessages(1, 4, spellName, color,'\124HiEETNpcList:' .. sourceGUID .. '\124h%s\124h')
		elseif event and event == 34 then -- UNIT_POWER
			iEET:addMessages(1, 4, spellName, color,'\124HiEETList:' .. (extraData and string.gsub(extraData, '%%', '%%%%') or 'Empty List;Contact Ironi') .. '\124h%s\124h')
		else
			local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
			if sourceGUID then
				unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
			else
				npcID = 'NONE'
			end
			--iEET.content4:AddMessage('\124HiEETcustomspell:' .. event .. ':' .. spellID .. ':' .. spellName .. ':' .. (npcID and npcID or 'NONE').. '!' .. (spawnID and spawnID or '') ..'\124h' .. spellnametoShow .. '\124h', unpack(iEET:getColor(event, sourceGUID, spellID))) -- NEEDS CHANGING
			iEET:addMessages(1, 4, spellName, color, '\124HiEETcustomspell:' .. event .. ':' .. spellID .. ':' .. spellName .. ':' .. (npcID and npcID or 'NONE') .. '!' .. (spawnID and spawnID or '') .. '\124h%s\124h')
		end
	else
		iEET.content4:AddMessage(' ')
	end
	local targetColor,sourceColor, classColor, sourceHyperlink, targetHyperlink
	if iEETConfig.classColors then
		if extraData and  extraData:match('^%d-\n%d-\n%-*') then
			local toColor = string.match(extraData,'^(%d-)\n')
			if toColor == '3' then
				local stringToSplit = string.gsub(extraData,'^(%d-)\n', '')
				local sourceString, targetString = strsplit(';',stringToSplit)
				local sourceClassIndex, sourceRole = strsplit('\n',sourceString)
				local localizedClass, class = GetClassInfo(tonumber(sourceClassIndex))
				sourceColor = RAID_CLASS_COLORS[class]
				sourceHyperlink = '\124HiEETList:' .. localizedClass .. '\n' .. sourceRole .. '\124h%s\124h'
				local _,targetClassIndex, targetRole = strsplit('\n',targetString)
				localizedClass, class = select(2, GetClassInfo(tonumber(targetClassIndex)))
				targetColor = RAID_CLASS_COLORS[class]
				targetHyperlink = '\124HiEETList:' .. localizedClass .. '\n' .. targetRole .. '\124h%s\124h'
			else
				local _,classIndex, role = strsplit('\n',extraData)
				local localizedClass, class = GetClassInfo(tonumber(classIndex))
				if toColor == '1' then
					sourceColor = {RAID_CLASS_COLORS[class].r,RAID_CLASS_COLORS[class].g,RAID_CLASS_COLORS[class].b}
					--sourceColor = RAID_CLASS_COLORS[class]
					sourceHyperlink = '\124HiEETList:' .. localizedClass .. '\n' .. role .. '\124h%s\124h'
				elseif toColor == '2' then					
					targetColor = {RAID_CLASS_COLORS[class].r,RAID_CLASS_COLORS[class].g,RAID_CLASS_COLORS[class].b}
					--targetColor = RAID_CLASS_COLORS[class]
					targetHyperlink = '\124HiEETList:' .. localizedClass .. '\n' .. role .. '\124h%s\124h'
				end
			end
		end
		--[[
		if extraData and  extraData:match('^%d-\n%d-\n%-*') then -- 1-3\n1-12\nrole -- Class Coloring [1] = sourceName, [2] = targetName
			local target, classIndex, role = strsplit('\n',extraData)
			local localizedClass, class = select(2, GetClassInfo(tonumber(classIndex)))
			classColor = RAID_CLASS_COLORS[class]
			hyperlink = '\124HiEETList:' .. localizedClass .. '\n' .. role .. '\124h%s\124h'
		end
		--]]
	end
	iEET:addMessages(1, 5, casterName, (sourceColor or color),sourceHyperlink)
	iEET:addMessages(1, 6, targetName, (targetColor or color),targetHyperlink)
	iEET:addMessages(1, 7, count, color)
	iEET:addMessages(1, 8, hp, color)
end
function iEET:addToEncounterAbilities(spellID, spellName)
	
	if spellID and tonumber(spellID) and spellName then
		spellID = tonumber(spellID)
		local color = {1,1,1}
		
		if spellID == 103528 or spellID == 133217 or spellID == 98391 or spellID == 143409 then -- Target Selection, Spawn Boss Emote(Spawn NPCs), Death, Power Regen
			color = {0.5,0.5,0.5}
		end
		iEET.encounterAbilitiesContent:AddMessage('\124Hspell:' .. spellID .. '\124h[' .. spellName .. ']\124h\124r', unpack(color))
	end
end
function iEET:addMessages(placeToAdd, frameID, value, color, hyperlink)
	local frame = ''
	if placeToAdd == 1 then
		frame = iEET['content' .. frameID]
	elseif placeToAdd == 2 then
		frame = iEET['detailContent' .. frameID]
	end
	if frameID == 1 or frameID == 2 then -- time from encounter_start, intervall
		if value then
			value = string.format("%.1f",value)
		end
		if hyperlink then
			value = hyperlink:format(value)
		end
	--elseif isAlpha and frameID == 3 then -- event, ps. im getting tired of alpha using different font...
	--	if value and value == 'ENCOUNTER_START' then
	--		value = 'ENCOUNTER_STA'
	--	end
	elseif frameID == 4 then -- spellName
		--if isAlpha and string.len(value) > 18 then
		--	value =  string.sub(value, 1, 18)
		--elseif string.len(value) > 20 then
		--	value = string.sub(value, 1, 20)
		--end
		if string.len(value) > 20 then
			value = string.sub(value, 1, 20)
		end
		if hyperlink then
			value = hyperlink:format(value)
		end
	elseif frameID == 5 then -- sourceName
		--if isAlpha and value and string.len(value) > 17 then -- can't use custom fonts on alpha and default font(ARIALN) is wider than Accidental Presidency
		--	value = string.sub(value, 1, 17)
		--elseif value and string.len(value) > 18 then
		--	value = string.sub(value, 1, 18)
		--end
		if value and string.len(value) > 18 then
			value = string.sub(value, 1, 18)
		end
		if hyperlink then -- Spell details, for IEEU and UNIT_POWER
			value = hyperlink:format(value)
		end
	elseif frameID == 6 then -- targetName
		--if isAlpha and value and string.len(value) > 13 then -- can't use custom fonts on alpha and default font(ARIALN) is wider than Accidental Presidency
		--	value = string.sub(value, 1, 13)
		--elseif value and string.len(value) > 14 then
		--	value = string.sub(value, 1, 14)
		--end
		if value and string.len(value) > 14 then
			value = string.sub(value, 1, 14)
		end
		if hyperlink then -- Spell details, for IEEU and UNIT_POWER
			value = hyperlink:format(value)
		end
	end
	frame:AddMessage(value and value or ' ', unpack(color))
end
function iEET:loopData(msg)
	if #iEETConfig.filtering.timeBasedFiltering > 0 or #iEETConfig.filtering.req > 0 then
		if iEET.encounterInfo then
			iEET.encounterInfo:SetBackdropBorderColor(0.64,0,0,1)
		end
		--reset
		for i = 1, #iEETConfig.filtering.timeBasedFiltering do
			if iEETConfig.filtering.timeBasedFiltering[i].to then
				iEETConfig.filtering.timeBasedFiltering[i].to.ok = false
				iEETConfig.filtering.timeBasedFiltering[i].to.alreadyFound = false
			end
			if iEETConfig.filtering.timeBasedFiltering[i].from then
				iEETConfig.filtering.timeBasedFiltering[i].from.ok = false
			end
		end
	elseif iEET.encounterInfo then
		iEET.encounterInfo:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	end
	iEET.loopDataCall = GetTime() 
	iEET.frame:Hide() -- avoid fps spiking from ScrollingMessageFrame adding too many messages
	if iEET.encounterInfoData and iEET.encounterInfoData.eN then
		iEET.encounterInfo.text:SetText(string.format('%s(%s) %s %s, %s', iEET.encounterInfoData.eN,string.sub(GetDifficultyInfo(iEET.encounterInfoData.d),1,1),(iEET.encounterInfoData.k == 1 and '+' or '-'),iEET.encounterInfoData.fT, iEET.encounterInfoData.pT))
	end
	local starttime = 0
	local intervalls = {}
	local counts = {}
	colors = {}
	for i=1, 8 do
		iEET['content' .. i]:Clear()
	end
	iEET.encounterAbilitiesContent:Clear()
	iEET.collector = {
		['encounterNPCs'] = {},
		['encounterSpells'] = {},
	}
	for k,v in ipairs(iEET.data) do
		if v.e == 27 or v.e == 37 then -- ENCOUNTER_START
			starttime = v.t
		end
		if v.e == 26 or v.e == 39 or v.e == 40 then -- UNIT_SPELLCAST_SUCCEEDED
			if string.find(v.tN, 'nameplate') then -- could be safe to assume that there will be atleast one nameplate unitid
				if not iEET.collector.encounterNPCs.nameplates then
					iEET.collector.encounterNPCs.nameplates = true
				end
			elseif v.tN and not iEET.collector.encounterNPCs[v.tN] then
				iEET.collector.encounterNPCs[v.tN] = true
			end
		elseif v.cN and v.sI and not iEET.collector.encounterNPCs[v.cN] and v.e ~= 27 and v.e ~= 28 then -- Collect npc names, 27 = ENCOUNTER_START, 28 = ENCOUNTER_END
			if iEET.interrupts[v.sI] then
				if not iEET.collector.encounterNPCs.Interrupters then
					iEET.collector.encounterNPCs.Interrupters = true
				end
			elseif iEET.dispels[v.sI] then
				iEET.collector.encounterNPCs.Dispellers = true
			elseif not iEET.ignoreList[v.sI] then --ignore fake spells
				iEET.collector.encounterNPCs[v.cN] = true
			end
		end
		if v.sI and v.sN and not iEET.collector.encounterSpells[v.sI] and v.e ~= 27 and v.e ~= 28 then -- Collect spells, 27 = ENCOUNTER_START, 28 = ENCOUNTER_END
			if iEET.interrupts[v.sI] then
				if not iEET.collector.encounterSpells[0.1] then
					iEET.collector.encounterSpells[0.1] = 'Interrupts'
				end
			elseif iEET.dispels[v.sI] then
				if not iEET.collector.encounterSpells[0.2] then
					iEET.collector.encounterSpells[0.2] = 'Dispels'
				end
			else
				if v.sI == 143409 then -- Power Update
					iEET.collector.encounterSpells[v.sI] = 'Power Update'
					iEET:addToEncounterAbilities(v.sI, 'Power Update')
				else -- ignore fake spells
					iEET.collector.encounterSpells[v.sI] = v.sN
					iEET:addToEncounterAbilities(v.sI, v.sN)
				end
			end
		end
		if iEET:ShouldShow(v,starttime, msg) then
			local intervall = nil
			local timestamp = v.t-starttime or nil
			local count = nil
			if v.sG then
				if intervalls[v.sG] then
					if intervalls[v.sG][v.e] then
						if intervalls[v.sG][v.e][v.sI] then
							intervall = timestamp - intervalls[v.sG][v.e][v.sI]
							intervalls[v.sG][v.e][v.sI] = timestamp
						else
							intervalls[v.sG][v.e][v.sI] = timestamp
						end
					else
						intervalls[v.sG][v.e] = {
								[v.sI] = timestamp,
						};
					end
				else
					intervalls[v.sG] = {
						[v.e] = {
							[v.sI] = timestamp,
						};
					};
				end
				if counts[v.sG] then
					if counts[v.sG][v.e] then
						if counts[v.sG][v.e][v.sI] then
							counts[v.sG][v.e][v.sI] = counts[v.sG][v.e][v.sI] + 1
							count = counts[v.sG][v.e][v.sI]
						else
							counts[v.sG][v.e][v.sI] = 1
							count = 1
						end
					else
						counts[v.sG][v.e] = {
							[v.sI] = 1,
						}
					end
				else
					counts[v.sG] = {
						[v.e] = {
							[v.sI] = 1,
						};
					};
					count = 1
				end
			end
			if iEETConfig.tracking[iEET.events.fromID[v.e].l] or v.e == 27 or v.e == 28 then -- ENCOUNTER_START & ENCOUNTER_END
				iEET:addToContent(timestamp,v.e,v.cN,v.tN,v.sN,v.sI,intervall,count,v.sG,v.hp,v.eD)
			end
		end
	end
	iEET.frame:Show()
end
function iEET:AddNewFiltering(msg)
	if type(msg) == 'table' then
		local s = false
		for k,v in pairs(msg) do
			if k == 'e' then
				v = iEET.events.fromID[v].l
			end
			if not s then
				s = k .. '=' .. v
			else
				s = s .. ';' .. k .. '=' .. v
			end
		end
		msg = s
	elseif tonumber(msg) then
		msg = 'sI=' .. msg 
	end
	if msg:match('^%d-%) ') then
		msg = msg:gsub('^%d-%) ', '')
	end
	local lineID = iEET.optionsFrameFilterTexts:GetCurrentLine()+2
	iEET.optionsFrameFilterTexts:AddMessage(lineID .. ') ' .. msg)
end
function iEET:ClearFilteringArgs()
	iEETConfig.filtering = {
		timeBasedFiltering = {},
		req = {},
		requireAll = false,
		showTime = false, -- show time from nearest 'from' event instead of ENCOUNTER_START
	}
end
function iEET:ParseFilters()
	local possibleNames = {
		['event'] = 'e',
		['spellid'] = 'sI',
		['spellname'] = 'sN',
		['time'] = 't',
		['sourceguid'] = 'sG',
		['sourcename'] = 'cN',
		['destname'] = 'tN',
		['unitid'] = 'tN',
		['health'] = 'hp',
		['e'] = 'e',
		['si'] = 'sI',
		['sn'] = 'sN',
		['t'] = 't',
		['sg'] = 'sG',
		['cn'] = 'cN',
		['tn'] = 'tN',
		['hp'] = 'hp',
	}
	local function GetFiltersFromLine(line)
		local t = {}
		for _,arg in pairs({strsplit(';', line)}) do
			arg = arg:gsub('^%s*(.-)%s*$', '%1')
			if string.match(arg, '^(%a-)=(%d+)') then --change to elseif when from/to filtering is done?
				local k,v = string.match(arg, '^(%a-)=(%d+)')
				if possibleNames[string.lower(k)] then
					k = possibleNames[string.lower(k)]
				end
				t[k] = tonumber(v)
			elseif string.match(arg, '^(%a-)=(%a+)') then
				local k,v = strsplit('=', arg)
				if possibleNames[string.lower(k)] then
					k = possibleNames[string.lower(k)]
				end
				if k == 'e' then
					if not tonumber(v) then
						v = string.upper(v)
						if iEET.events.toID[v] then
							v = iEET.events.toID[v]
						else
							for id,names in pairs(iEET.events.fromID) do
								if names.s == v then
									v = id
									break
								end
							end
						end
					end
				end
				if k == 'e' and not tonumber(v) then
						iEET:print('Invalid event: ' .. v)
				else
					t[k] = v
				end
			elseif tonumber(arg) then
				t['sI'] = tonumber(arg)
			end
		end
		local c = 0
		for _ in pairs(t) do -- count entries
			c = c + 1
		end
		if c > 0 then
			return t
		else
			return
		end
	end
	--gather all data etc and hide window
	iEET:ClearFilteringArgs()	--Clear old filters
	for i = 1, iEET.optionsFrameFilterTexts:GetNumMessages() do
		local line = iEET.optionsFrameFilterTexts:GetMessageInfo(i)
		line = line:gsub('^%d-%) ', '') -- strip lineID
		if line:gsub('^%s*(.-)%s*$', '%1') == 'requireAll' then
			iEETConfig.filtering.requireAll = true
		elseif string.find(line, 'FROM:') or string.find(line, 'TO:') then
			local fromTo = {}
			if string.find(line, 'FROM:') and string.find(line, 'TO:') then -- BOTH
				--line = line:gsub('^%s*(.-)%s*$', '%1')
				local fromStart = string.find(line, 'FROM:')
				local toStart = string.find(line, 'TO:')
				local from = ''
				local to = ''
				if fromStart < toStart then --FROM first
					from = line:sub(fromStart+5, toStart-1)
					to = line:sub(toStart+3)
				else -- TO first
					to = line:sub(toStart+3, fromStart-1)
					from = line:sub(fromStart+5)
				end
				fromTo.from = GetFiltersFromLine(from)
				fromTo.to = GetFiltersFromLine(to)
			elseif string.find(line,'FROM:') then
				fromTo.from = GetFiltersFromLine(line:gsub('FROM:', ''))
			else --TO
				fromTo.to = GetFiltersFromLine(line:gsub('TO:', ''))
			end	
			table.insert(iEETConfig.filtering.timeBasedFiltering, fromTo)
		else
			local t = GetFiltersFromLine(line)
			if t then
				table.insert(iEETConfig.filtering.req, t)
			end
		end
	end
	if iEET.frame then
		iEET:loopData()
	end
end
function iEET:Hyperlinks(linkData, link)
	GameTooltip:ClearLines()
	local linkType = strsplit(':', linkData)
	if linkType == 'iEETcustomyell' then
		local _, event, spellID, spellName = strsplit(':',linkData)
		GameTooltip:SetText(spellID)
		--iEET_content4:AddMessage('\124HiEETcustomspell:' .. event .. ':' .. spellID .. ':' .. spellname ..'\124h' .. spellName .. '\124h', unpack(getColor(event, sourceGUID, spellID)))
	elseif linkType == 'iEETcustomspell' then
		local _, event, spellID, spellName, npcID = strsplit(':',linkData)
		if spellID == 'NONE' then
			return
		end
		local hyperlink = '\124Hspell:' .. tonumber(spellID)
		GameTooltip:SetHyperlink('spell:' .. tonumber(spellID))
		GameTooltip:AddLine('spellID:' .. spellID)
		GameTooltip:AddLine('npcID:' .. npcID)
	elseif linkType == 'iEETtime' then
		local _, txt = strsplit(':',linkData)
		GameTooltip:SetText(txt)
	elseif linkType == 'iEETNpcList' then
		local _, txt = strsplit(':',linkData)
		GameTooltip:SetText(txt)
	elseif linkType == 'iEETList' then
		linkData = linkData:gsub('iEETList:', '')
		for _,v in pairs({strsplit(';',linkData)}) do
			GameTooltip:AddLine(v)
		end
	else
		GameTooltip:SetHyperlink(link)
	end
	GameTooltip:Show()
end
iEET.optionsMenu = {}
iEET.optionsMenuFrame = CreateFrame('Frame', 'iEETOptionsListMenu', UIParent, 'UIDropDownMenuTemplate')
function iEET:updateOptionsMenu()
	iEET.optionsMenu = nil
	iEET.optionsMenu = {}
	table.insert(iEET.optionsMenu, {text = 'Options', isTitle = true, notCheckable = true})
	table.insert(iEET.optionsMenu, {text = 'Color', notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = {
			{text = 'Main Frame',
			notCheckable = true,
			hasArrow = true,
			keepShownOnClick = true,
			menuList = {
				{text = 'Background',
				notCheckable = true,
				hasArrow = false,
				keepShownOnClick = false,
				func = function()
					iEET:ShowColorPicker('mainBG')
				end},
				{text = 'Border',
				notCheckable = true,
				hasArrow = false,
				keepShownOnClick = false,
				func = function()
					iEET:ShowColorPicker('mainBorder')
				end},
				{text = 'Reset',
				notCheckable = true,
				hasArrow = false,
				keepShownOnClick = false,
				func = function()
					iEETConfig.colors.main = {
						['bg'] = {['r'] = 0.1, ['g'] = 0.1, ['b'] = 0.1, ['a'] = 0.9},
						['border'] = {['r'] = 0, ['g'] = 0, ['b'] = 0, ['a'] = 1},
					}
					iEET:UpdateColors('main',nil,true) --force update after reset
				end},
			},},
			{text = 'Filtering Frame',
			notCheckable = true,
			hasArrow = true,
			keepShownOnClick = true,
			menuList = {
				{text = 'Background',
				notCheckable = true,
				hasArrow = false,
				keepShownOnClick = false,
				func = function()
					iEET:ShowColorPicker('optionsBG')
				end},
				{text = 'Border',
				notCheckable = true,
				hasArrow = false,
				keepShownOnClick = false,
				func = function()
				iEET:ShowColorPicker('optionsBorder')
				end},
				{text = 'Reset',
				notCheckable = true,
				hasArrow = false,
				keepShownOnClick = false,
				func = function()
					iEETConfig.colors.options = {
						['bg'] = {['r'] = 0.1, ['g'] = 0.1, ['b'] = 0.1, ['a'] = 0.9},
						['border'] = {['r'] = 0.64, ['g'] = 0, ['b'] = 0, ['a'] = 1},
					}
					iEET:UpdateColors('options',nil,true) --force update after reset
				end},
			},},
		},})
	table.insert(iEET.optionsMenu, {text = 'Automatic saving', isNotRadio = true, checked = iEETConfig.autoSave, keepShownOnClick = false, func = function()
			if iEETConfig.autoSave then
				iEETConfig.autoSave = false
				iEET:print('Automatic saving is now off.')
			else
				iEETConfig.autoSave = true
				iEET:print('Automatic saving is now on.')
			end
			iEET:updateOptionsMenu()
			EasyMenu(iEET.optionsMenu, iEET.optionsMenuFrame, iEET.optionsList, 0 , 0, 'MENU');
		end})
		
	table.insert(iEET.optionsMenu, {text = 'Use automatic saving only inside raid instances', isNotRadio = true, checked = iEETConfig.onlyRaids, keepShownOnClick = false, func = function()
			if iEETConfig.onlyRaids then
				iEETConfig.onlyRaids = false
				iEET:print('Always using automatic saving.')
			else
				iEETConfig.onlyRaids = true
				iEET:print('Use automatic saving only inside raid instances.')
			end
			iEET:updateOptionsMenu()
			EasyMenu(iEET.optionsMenu, iEET.optionsMenuFrame, iEET.optionsList, 0 , 0, 'MENU');
		end})
	table.insert(iEET.optionsMenu, {text = 'Class coloring', isNotRadio = true,	checked = iEETConfig.classColors, keepShownOnClick = true, func = function()
			if iEETConfig.classColors then
				iEETConfig.classColors = false
				iEET:print('Class coloring is now off.')
			else
				iEETConfig.classColors = true
				iEET:print('Class coloring is now on.')
			end
			iEET:updateOptionsMenu()
			EasyMenu(iEET.optionsMenu, iEET.optionsMenuFrame, iEET.optionsList, 0 , 0, 'MENU');
			iEET:loopData()
		end})
	table.insert(iEET.optionsMenu, { text = 'Close', notCheckable = true, func = function () CloseDropDownMenus(); end})
end
iEET.eventListMenu = {}
iEET.eventListMenuFrame = CreateFrame('Frame', 'iEETEventListMenu', UIParent, 'UIDropDownMenuTemplate')
function iEET:updateEventMenu()
	iEET.eventListMenu = nil
	iEET.eventListMenu = {}
	table.insert(iEET.eventListMenu, {text = 'Show Events', isTitle = true, notCheckable = true})
	for k,_ in spairs(iEETConfig.tracking) do
		table.insert(iEET.eventListMenu, {
			text = k,
			isNotRadio = true,
			checked = iEETConfig.tracking[k],
			keepShownOnClick = true,
			func = function()
				if iEETConfig.tracking[k] then
					iEETConfig.tracking[k] = false
				else
					iEETConfig.tracking[k] = true
				end
			end,
		})
	end
	table.insert(iEET.eventListMenu, {text = 'Deselect all', notCheckable = true, func = function()
		for k,_ in spairs(iEETConfig.tracking) do
			iEETConfig.tracking[k] = false
		end
		iEET:updateEventMenu()
		EasyMenu(iEET.eventListMenu, iEET.eventListMenuFrame, iEET.eventlist, 0 , 0, 'MENU');
		end})
	table.insert(iEET.eventListMenu, {text = 'Select all', notCheckable = true, func = function()
		for k,_ in spairs(iEETConfig.tracking) do
			iEETConfig.tracking[k] = true
		end
		iEET:updateEventMenu()
		EasyMenu(iEET.eventListMenu, iEET.eventListMenuFrame,iEET.eventlist, 0 , 0, 'MENU');
		end})
	table.insert(iEET.eventListMenu, { text = 'Apply changes', notCheckable = true, func = function()
		CloseDropDownMenus()
		local msg
		if iEET.editbox:GetText() ~= 'Search' then
			local txt = iEET.editbox:GetText()
			if string.len(txt) > 1 then
				msg = string.lower(txt)
			end
		end
		iEET:loopData(msg)
	end})
end
iEET.npcListMenu = {}
iEET.npcListMenuFrame = CreateFrame('Frame', 'iEETNPCListMenu', UIParent, 'UIDropDownMenuTemplate')
function iEET:updateNPCListMenu()
	iEET.npcListMenu = nil
	iEET.npcListMenu = {}
	table.insert(iEET.npcListMenu, {text = 'Ignored NPCs', isTitle = true, notCheckable = true})
	if iEET.collector then
		-- NPCs
		for k in spairs(iEET.collector.encounterNPCs) do
			table.insert(iEET.npcListMenu, {
			text = k,
			isNotRadio = true,
			checked = iEET.ignoring[k],
			keepShownOnClick = true,
			func = function()
				if iEET.ignoring[k] then
					iEET.ignoring[k] = nil
				else
					iEET.ignoring[k] = true
				end
			end,
			})
		end
	end
	table.insert(iEET.npcListMenu, {text = 'Deselect all', notCheckable = true, func = function()
		for k in spairs(iEET.collector.encounterNPCs) do
			iEET.ignoring[k] = nil
		end
		iEET:updateNPCListMenu()
		EasyMenu(iEET.npcListMenu, iEET.npcListMenuFrame, iEET.npcList, 0 , 0, 'MENU');
		end})
	table.insert(iEET.npcListMenu, {text = 'Select all', notCheckable = true, func = function()
		for k in spairs(iEET.collector.encounterNPCs) do
			iEET.ignoring[k] = true
		end
		iEET:updateNPCListMenu()
		EasyMenu(iEET.npcListMenu, iEET.npcListMenuFrame, iEET.npcList, 0 , 0, 'MENU');
		end})
	table.insert(iEET.npcListMenu, { text = 'Apply changes', notCheckable = true, func = function()
		CloseDropDownMenus()
		local msg
		if iEET.editbox:GetText() ~= 'Search' then
			local txt = iEET.editbox:GetText()
			if string.len(txt) > 1 then
				msg = string.lower(txt)
			end
		end
		iEET:loopData(msg)
	end})
end
iEET.spellListMenu = {}
iEET.spellListMenuFrame = CreateFrame('Frame', 'iEETSpellListMenu', UIParent, 'UIDropDownMenuTemplate')
function iEET:updateSpellListMenu()
	iEET.spellListMenu = nil
	iEET.spellListMenu = {}
	table.insert(iEET.spellListMenu, {text = 'Ignored Spells', isTitle = true, notCheckable = true})
	if iEET.collector then
		-- Spells
		for k,v in spairs(iEET.collector.encounterSpells) do
			if not iEET.ignoreList[k] then -- Filter fake spells out
				table.insert(iEET.spellListMenu, {
				text = k .. ' - ' .. v,
				isNotRadio = true,
				checked = iEET.ignoring[k],
				keepShownOnClick = true,
				func = function()
					if iEET.ignoring[k] then
						iEET.ignoring[k] = nil
					else
						iEET.ignoring[k] = true
					end
				end,
				})
			end
		end
		--table.insert(iEET.optionMenu, tempIgnoreSpells)
	end
	table.insert(iEET.spellListMenu, {text = 'Deselect all', notCheckable = true, func = function()
			for k in spairs(iEET.collector.encounterSpells) do
				iEET.ignoring[k] = nil
			end
			iEET:updateSpellListMenu()
			EasyMenu(iEET.spellListMenu, iEET.spellListMenuFrame, iEET.spellList , 0 , 0, 'MENU');
			end})
	table.insert(iEET.spellListMenu, {text = 'Select all', notCheckable = true, func = function()
			for k in spairs(iEET.collector.encounterSpells) do
				iEET.ignoring[k] = true
			end
			iEET:updateSpellListMenu()
			EasyMenu(iEET.spellListMenu, iEET.spellListMenuFrame, iEET.spellList , 0 , 0, 'MENU');
			end})
	table.insert(iEET.spellListMenu, { text = 'Apply changes', notCheckable = true, func = function()
		CloseDropDownMenus()
		local msg
		if iEET.editbox:GetText() ~= 'Search' then
			local txt = iEET.editbox:GetText()
			if string.len(txt) > 1 then
				msg = string.lower(txt)
			end
		end
		iEET:loopData(msg)
	end})
end
iEET.encounterListMenu = {}
iEET.encounterListMenuFrame = CreateFrame('Frame', 'iEETEncounterListMenu', UIParent, 'UIDropDownMenuTemplate')
function iEET:updateEncounterListMenu()
		iEET.encounterListMenu = nil
		iEET.encounterListMenu = {}
	if iEET_Data then
		local encountersTempTable = {}
		for k,_ in pairs(iEET_Data) do -- Get encounters
			if string.find(k, 'encounterName=') then
				iEET:print('found old reports, please use "/ieet convert" to continue')
				return
			end
			local temp = {}
			for eK,eV in string.gmatch(k, '{(.-)=(.-)}') do
				if eK == 'd' or eK == 'rS' or eK == 's' or eK == 'k' or eK == 'v' then
					if tonumber(eV) then
						eV = tonumber(eV)
					end
				end
				temp[eK] = eV
			end
			temp.dataKey = k
			if not encountersTempTable[temp.eN] then
				encountersTempTable[temp.eN] = {}
			end
			if not encountersTempTable[temp.eN][temp.d] then
				encountersTempTable[temp.eN][temp.d] = {}
			end
			table.insert(encountersTempTable[temp.eN][temp.d], temp)
		end -- Sorted by encounter -> Sort by ids inside
		-- temp{} -> encounter{} -> difficulty{} -> fight{}


		for encounterName,_ in spairs(encountersTempTable) do -- Get alphabetically sorted encounters
			--Looping bosses
			--print(encounterName) -- Debug
			local t = {text = encounterName, hasArrow = true, notCheckable = true, menuList = {}}
			local t2 = {}
			for difficultyID,_ in spairs(encountersTempTable[encounterName]) do
				-- Looping difficulties
				--print('difficultyID', difficultyID) -- Debug
				t2 = {text = GetDifficultyInfo(difficultyID), hasArrow = true, notCheckable = true, menuList = {}}
				--for k,v in pairs(encountersTempTable[encounterName][difficultyID]) do
				for k,v in spairs(encountersTempTable[encounterName][difficultyID], function(t,a,b) return t[b].pT < t[a].pT end) do
					local fightEntry = {
						text = (v.k == 1 and '+ ' or '- ') .. v.fT .. ' (' .. v.pT .. ')',
						notCheckable = true,
						hasArrow = true,
						checked = false,
						keepShownOnClick = false,
						func = function()
							iEET:ImportData(v.dataKey)
							iEET:Toggle(true) -- not really needed
							CloseDropDownMenus()
						end,
						menuList = {{ -- delete menu
							text = 'Delete',
							notCheckable = true,
							func = function()
								iEET_Data[v.dataKey] = nil
								iEET:updateEncounterListMenu()
							end,
						},},
					}
					table.insert(t2.menuList, fightEntry)
				end
				table.insert(t.menuList, t2)
			end
			table.insert(iEET.encounterListMenu, t)
		end
	end
	table.insert(iEET.encounterListMenu, { text = 'Exit', notCheckable = true, func = function () CloseDropDownMenus() end})
end
function iEET:CreateMainFrame()
	iEET.frame = CreateFrame("Frame", "iEETFrame", UIParent)
	iEET.frame:SetSize(598,800)
	iEET.frame:SetPoint('CENTER', UIParent, 'CENTER', 0,0)
	iEET.scale = (GetScreenHeight()/GetScreenWidth()/iEET.frame:GetEffectiveScale())
	iEET.frame:SetScript("OnMouseDown", function(self,button)
		iEET.frame:ClearAllPoints()
		iEET.frame:StartMoving()
	end)
	iEET.frame:SetScript('OnMouseUp', function(self, button)
		iEET.frame:StopMovingOrSizing()
	end)
	iEET.frame:SetScript('OnShow', function()
		if not iEET.loopDataCall or (iEET.loopDataCall and (GetTime() - iEET.loopDataCall > 0.5)) then -- avoid infinite loops
			iEET.loopDataCall = GetTime()
			local txt = iEET.editbox:GetText()
			if txt ~= 'Search' and string.len(txt) > 0 then
				iEET:loopData(txt)
			else
				iEET:loopData()
			end
		end
	end)
	iEET.frame:SetFrameStrata('HIGH')
	iEET.frame:SetFrameLevel(1)
	iEET.top = CreateFrame('FRAME', nil, iEET.frame)
	iEET.top:SetSize(598, 25)
	iEET.top:SetPoint('BOTTOMRIGHT', iEET.frame, 'TOPRIGHT', 0, -1)
	iEET.top:SetBackdrop(iEET.backdrop);
	iEET.top:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.top:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.top:SetScript('OnMouseDown', function(self,button)
		iEET.frame:ClearAllPoints()
		iEET.frame:StartMoving()
	end)
	iEET.top:SetScript('OnMouseUp', function(self, button)
		iEET.frame:StopMovingOrSizing()
	end)
	iEET.top:EnableMouse(true)
	iEET.top:Show()
	iEET.top:SetFrameStrata('HIGH')
	iEET.top:SetFrameLevel(1)
	--Encounter Info background & fontstring
	iEET.encounterInfo = CreateFrame('FRAME', nil, iEET.frame)
	iEET.encounterInfo:SetSize(370, 18)
	iEET.encounterInfo:SetPoint('BOTTOM', iEET.top, 'TOP', 0, -1)
	iEET.encounterInfo:SetBackdrop(iEET.backdrop);
	iEET.encounterInfo:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.encounterInfo:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.encounterInfo:SetScript('OnMouseDown', function(self,button)
		iEET.frame:ClearAllPoints()
		iEET.frame:StartMoving()
	end)
	iEET.encounterInfo:SetScript('OnMouseUp', function(self, button)
		iEET.frame:StopMovingOrSizing()
	end)
	iEET.encounterInfo:EnableMouse(true)
	iEET.encounterInfo:Show()
	iEET.encounterInfo:SetFrameStrata('HIGH')
	iEET.encounterInfo:SetFrameLevel(1)
	iEET.encounterInfo.text = iEET.frame:CreateFontString()
	iEET.encounterInfo.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.encounterInfo.text:SetPoint('CENTER', iEET.encounterInfo, 'CENTER', 0,1)
	iEET.encounterInfo.text:SetText("Ironi's Encounter Event Tracker")
	iEET.encounterInfo.text:Show()
	iEET.detailtop = CreateFrame('FRAME', nil, iEET.frame)
	iEET.detailtop:SetSize(433, 25)
	iEET.detailtop:SetPoint('RIGHT', iEET.top, 'LEFT', 1, 0)
	iEET.detailtop:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
		insets = {
			left = -1,
			right = -1,
			top = -1,
			bottom = -1,
		},
	});
	iEET.detailtop:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.detailtop:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.detailtop:Show()
	iEET.detailtop:SetScript("OnMouseDown", function(self,button)
		iEET.frame:ClearAllPoints()
		iEET.frame:StartMoving()
	end)
	iEET.detailtop:SetScript('OnMouseUp', function(self, button)
		iEET.frame:StopMovingOrSizing()
	end)
	iEET.detailtop:SetFrameStrata('HIGH')
	iEET.detailtop:SetFrameLevel(1)
	iEET.detailtop:EnableMouse(true)

	iEET.encounterAbilities = CreateFrame('FRAME', nil, iEET.frame)
	iEET.encounterAbilities:SetSize(200, 25)
	iEET.encounterAbilities:SetPoint('LEFT', iEET.top, 'RIGHT', -1, 0)
	iEET.encounterAbilities:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
		insets = {
			left = -1,
			right = -1,
			top = -1,
			bottom = -1,
		},
	});
	iEET.encounterAbilities:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.encounterAbilities:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.encounterAbilities:Show()
	iEET.encounterAbilities:SetScript("OnMouseDown", function(self,button)
		iEET.frame:ClearAllPoints()
		iEET.frame:StartMoving()
	end)
	iEET.encounterAbilities:SetScript('OnMouseUp', function(self, button)
		iEET.frame:StopMovingOrSizing()
	end)
	iEET.encounterAbilities:SetFrameStrata('HIGH')
	iEET.encounterAbilities:SetFrameLevel(1)
	iEET.encounterAbilities:EnableMouse(true)
	local lastframe = false
	local slices = {
		[1] = 40,
		[2] = 40,
		[3] = 105,
		[4] = 131,
		[5] = 120,
		[6] = 97,
		[7] = 36,
		[8] = 36,
	};
	for i=1, 8 do ---bigcontent
		---anhorframe
		iEET['contentAnchor' .. i] = CreateFrame('FRAME', nil , iEET.frame)
		iEET['contentAnchor' .. i]:SetSize(slices[i], 834)
		if not lastframe then
			iEET['contentAnchor' .. i]:SetPoint('TOPLEFT', iEET.frame, 'TOPLEFT', 0, 0)
			lastframe = 'contentAnchor' .. i
		else
			iEET['contentAnchor' .. i]:SetPoint('LEFT', iEET[lastframe], 'RIGHT', -1,0)
			lastframe = 'contentAnchor' .. i
		end
		iEET['contentAnchor' .. i]:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
			insets = {
				left = -1,
				right = -1,
				top = -1,
				bottom = -1,
			},
		});
		iEET['contentAnchor' .. i]:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
		iEET['contentAnchor' .. i]:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
		---
		iEET['content' .. i] = CreateFrame('ScrollingMessageFrame', nil, iEET['contentAnchor' .. i])
		iEET['content' .. i]:SetSize(slices[i]-8,828)
		iEET['content' .. i]:SetPoint('CENTER', iEET['contentAnchor' .. i], 'CENTER', 0, 0)
		iEET['content' .. i]:SetFont(iEET.font, iEET.fontsize)
		iEET['content' .. i]:SetFading(false)
		iEET['content' .. i]:SetInsertMode("BOTTOM")
		iEET['content' .. i]:SetJustifyH(iEET.justifyH)
		iEET['content' .. i]:SetMaxLines(5000)
		iEET['content' .. i]:SetSpacing(iEET.spacing)
		iEET['content' .. i]:EnableMouseWheel(true)
		iEET['content' .. i]:SetScript("OnMouseWheel", function(self, delta)
			iEET:ScrollContent(delta)
		end)
		if i == 1 or i == 2 or i == 4 or i == 5 or i == 6 then --allow hyperlinks for encounter time, intervall time, spellName, sourceName, destName
			iEET['content' .. i]:SetHyperlinksEnabled(true)
			iEET['content' .. i]:SetScript("OnHyperlinkEnter", function(self, linkData, link)
				GameTooltip:SetOwner(iEET.frame, "ANCHOR_TOPRIGHT", 0-iEET.frame:GetWidth(), 0-iEET.frame:GetHeight())
				iEET:Hyperlinks(linkData, link)
				--[[
				GameTooltip:ClearLines()
				local linkType = strsplit(':', linkData)
				if linkType == 'iEETcustomyell' then
					local _, event, spellID, spellName = strsplit(':',linkData)
					GameTooltip:SetText(spellID)
					--iEET_content4:AddMessage('\124HiEETcustomspell:' .. event .. ':' .. spellID .. ':' .. spellname ..'\124h' .. spellName .. '\124h', unpack(getColor(event, sourceGUID, spellID)))
				elseif linkType == 'iEETcustomspell' then
					local _, event, spellID, spellName, npcID = strsplit(':',linkData)
					if spellID == 'NONE' then
						return
					end
					local hyperlink = '\124Hspell:' .. tonumber(spellID)
					GameTooltip:SetHyperlink('spell:' .. tonumber(spellID))
					GameTooltip:AddLine('spellID:' .. spellID)
					GameTooltip:AddLine('npcID:' .. npcID)
				elseif linkType == 'iEETtime' then
					local _, txt = strsplit(':',linkData)
					GameTooltip:SetText(txt)
				elseif linkType == 'iEETNpcList' then
					local _, txt = strsplit(':',linkData)
					GameTooltip:SetText(txt)
				else
					GameTooltip:SetHyperlink(link)
				end
				GameTooltip:Show()
				--]]
			end)
			iEET['content' .. i]:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
			end)
			iEET['content' .. i]:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
				if string.find(linkData, 'iEETtime') then
					return
				elseif IsShiftKeyDown() and IsInRaid() then
					local linkType = strsplit(':', linkData)
					if linkType == 'iEETcustomyell' then
						local _, event, spellID, spellName = strsplit(':',linkData)
						SendChatMessage(spellID, 'RAID')
					elseif linkType == 'iEETcustomspell' then
						local _, event, spellID, spellName, npcID = strsplit(':',linkData)
						SendChatMessage(GetSpellLink(tonumber(spellID)), 'RAID')
					end
				else
					iEET:addSpellDetails(link, linkData)
				end
			end)
		end
		iEET['content' .. i]:SetFrameStrata('HIGH')
		iEET['content' .. i]:SetFrameLevel(2)
		iEET['content' .. i]:EnableMouse(true)
	end
	lastframe = false
	for i=7, 1, -1 do ---detail content
		---anhorframe
		if i == 4 then
		else
		iEET['detailAnchor' .. i] = CreateFrame('FRAME', nil, iEET.frame)
		iEET['detailAnchor' .. i]:SetSize(slices[i], 400)
		if not lastframe then
			iEET['detailAnchor' .. i]:SetPoint('TOPRIGHT', iEET.frame, 'TOPLEFT', 1, 0)
			lastframe = 'detailAnchor' .. i
		else
			iEET['detailAnchor' .. i]:SetPoint('RIGHT', iEET[lastframe], 'LEFT', 1,0)
			lastframe = 'detailAnchor' .. i
		end
		iEET['detailAnchor' .. i]:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
			insets = {
				left = -1,
				right = -1,
				top = -1,
				bottom = -1,
			},
		});
		iEET['detailAnchor' .. i]:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
		iEET['detailAnchor' .. i]:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
		---
		iEET['detailContent' .. i] = CreateFrame('ScrollingMessageFrame', nil, iEET['detailAnchor' .. i])
		iEET['detailContent' .. i]:SetSize(slices[i]-8,392)
		iEET['detailContent' .. i]:SetPoint('CENTER', iEET['detailAnchor' .. i], 'CENTER', 0, 0)
		iEET['detailContent' .. i]:SetFont(iEET.font, iEET.fontsize)
		iEET['detailContent' .. i]:SetFading(false)
		iEET['detailContent' .. i]:SetInsertMode('BOTTOM')
		iEET['detailContent' .. i]:SetJustifyH(iEET.justifyH)
		iEET['detailContent' .. i]:SetMaxLines(5000)
		iEET['detailContent' .. i]:SetSpacing(iEET.spacing)
		iEET['detailContent' .. i]:EnableMouseWheel(true)
		iEET['detailContent' .. i]:SetScript("OnMouseWheel", function(self, delta)
			iEET:ScrollDetails(delta)
		end)
		if i == 1 or i == 2 or i == 5 or i == 6 then --allow hyperlinks for time,intervall,sourceName, targetName (IEEU, UNIT_POWER)
			iEET['detailContent' .. i]:SetHyperlinksEnabled(true)
			iEET['detailContent' .. i]:SetScript('OnHyperlinkEnter', function(self, linkData, link)
				GameTooltip:SetOwner(iEET.frame, "ANCHOR_TOPRIGHT", 0-iEET.frame:GetWidth(), 0-iEET.frame:GetHeight())
				iEET:Hyperlinks(linkData)
				--[[
				GameTooltip:ClearLines()
				local _, txt = strsplit(':',linkData)
				GameTooltip:SetText(txt)
				GameTooltip:Show()
				--]]
			end)
			iEET['detailContent' .. i]:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
			end)
		end
		iEET['detailContent' .. i]:EnableMouse(true)
		iEET['detailContent' .. i]:SetFrameStrata('HIGH')
		iEET['detailContent' .. i]:SetFrameLevel(2)
		--smf:SetFrameStrata('HIGH')
	end
	end
	--SPELL LISTING--
	do
		iEET.encounterAbilitiesAnchor = CreateFrame('FRAME', nil, iEET.frame)
		iEET.encounterAbilitiesAnchor:SetSize(200, 400)
		iEET.encounterAbilitiesAnchor:SetPoint('TOPLEFT', iEET.frame, 'TOPRIGHT', -1, 0)
		iEET.encounterAbilitiesAnchor:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
			insets = {
				left = -1,
				right = -1,
				top = -1,
				bottom = -1,
			},
		});
		iEET.encounterAbilitiesAnchor:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
		iEET.encounterAbilitiesAnchor:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
		---
		iEET.encounterAbilitiesContent = CreateFrame('ScrollingMessageFrame', nil, iEET.encounterAbilitiesAnchor)
		iEET.encounterAbilitiesContent:SetSize(192,392)
		iEET.encounterAbilitiesContent:SetPoint('CENTER', iEET.encounterAbilitiesAnchor, 'CENTER', 0, 0)
		iEET.encounterAbilitiesContent:SetFont(iEET.font, iEET.fontsize)
		iEET.encounterAbilitiesContent:SetFading(false)
		iEET.encounterAbilitiesContent:SetInsertMode('BOTTOM')
		iEET.encounterAbilitiesContent:SetJustifyH(iEET.justifyH)
		iEET.encounterAbilitiesContent:SetMaxLines(200)
		iEET.encounterAbilitiesContent:SetSpacing(iEET.spacing)
		iEET.encounterAbilitiesContent:EnableMouseWheel(true)
		iEET.encounterAbilitiesContent:SetHyperlinksEnabled(true)
		iEET.encounterAbilitiesContent:SetScript("OnMouseWheel", function(self, delta)
			if delta == -1 then
				if IsShiftKeyDown() then
					iEET.encounterAbilitiesContent:PageDown()
				else
					iEET.encounterAbilitiesContent:ScrollDown()
				end
			else
				if IsShiftKeyDown() then
					iEET.encounterAbilitiesContent:PageUp()
				else
					iEET.encounterAbilitiesContent:ScrollUp()
				end
			end
		end)
		iEET.encounterAbilitiesContent:SetScript("OnHyperlinkEnter", function(self, linkData, link)
			GameTooltip:SetOwner(iEET.frame, "ANCHOR_TOPRIGHT", 0-iEET.frame:GetWidth(), 0-iEET.frame:GetHeight())
			GameTooltip:ClearLines()
			GameTooltip:SetHyperlink(link)
			GameTooltip:Show()
		end)
		iEET.encounterAbilitiesContent:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
		end)
		iEET.encounterAbilitiesContent:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
			local spellID = tonumber(string.match(linkData, 'spell:(%d+)'))
			if spellID then
				iEET:loopData(spellID)
			end
		end)
		iEET.encounterAbilitiesContent:EnableMouse(true)
		iEET.encounterAbilitiesContent:SetFrameStrata('HIGH')
		iEET.encounterAbilitiesContent:SetFrameLevel(2)
	end
	iEET.detailInfo = iEET.frame:CreateFontString('iEETDetailInfo')
	iEET.detailInfo:SetFont(iEET.font, iEET.fontsize, "OUTLINE")
	iEET.detailInfo:SetPoint("CENTER", iEET.detailtop, 'CENTER', 0,0)
	iEET.detailInfo:SetText("Details")
	iEET.detailInfo:Show()
	iEET.encounterAbilitiesText = iEET.frame:CreateFontString('iEETEncounterAbilitiesInfo')
	iEET.encounterAbilitiesText:SetFont(iEET.font, iEET.fontsize, "OUTLINE")
	iEET.encounterAbilitiesText:SetPoint("CENTER", iEET.encounterAbilities, 'CENTER', 0,0)
	iEET.encounterAbilitiesText:SetText("Encounter spells")
	iEET.encounterAbilitiesText:Show()
	iEET.frame:EnableMouse(true)
	iEET.frame:SetMovable(true)
	--local scale = (0.63999998569489/iEET.frame:GetEffectiveScale())
	iEET.frame:SetScale(iEET.scale)
	iEET.editbox = CreateFrame('EditBox', 'iEETEditBox', iEET.frame)
	iEET.editbox:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
			insets = {
				left = -1,
				right = -1,
				top = -1,
				bottom = -1,
			},
		});
	iEET.editbox:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,0.2)
	iEET.editbox:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.editbox:SetScript('OnEnterPressed', function()
		iEET.editbox:ClearFocus()
		local msg
		if iEET.editbox:GetText() ~= 'Search' then
			local txt = iEET.editbox:GetText()
			local from, to
			if string.lower(txt) == 'clear' then
				iEET:ClearFilteringArgs()
				iEET.editbox:SetText('')
			--[[
			elseif string.match(txt, '^from:(%d-) to:(%d+)') then
				from, to = string.match(txt, '^from:(%d-) to:(%d+)')
				table.insert(iEETConfig.filtering.timeBasedFiltering, {['from'] = {['t'] = tonumber(from)}, ['to'] = {['t'] = tonumber(to)}})
			elseif string.match(txt, '^from:(%d+)') then
				from = string.match(txt, '^from:(%d+)')
				table.insert(iEETConfig.filtering.timeBasedFiltering, {['from'] = {['t'] = tonumber(from)}})
			elseif string.match(txt, '^to:(%d+)') then
				to = string.match(txt, '^to:(%d+)')
				table.insert(iEETConfig.filtering.timeBasedFiltering, {['to'] = {['t'] = tonumber(to)}})
			--]]
			elseif string.len(txt) > 1 then
				msg = string.lower(txt)
			end
		end
		iEET:loopData(msg)
	end)
	iEET.editbox:SetAutoFocus(false)
	iEET.editbox:SetWidth(262)
	iEET.editbox:SetHeight(21)
	iEET.editbox:SetTextInsets(2, 2, 1, 0)
	iEET.editbox:SetPoint('RIGHT', iEET.top, 'RIGHT', -24,0)
	iEET.editbox:SetFrameStrata('HIGH')
	iEET.editbox:SetFrameLevel(3)
	iEET.editbox:Show()
	iEET.editbox:SetFont(iEET.font, iEET.fontsize+2, 'OUTLINE')
	local function createButton(name, buttonName, width, height, buttonText,point,anchorFrame,relativePoint,xOffset,yOffset)
		iEET[name] = CreateFrame('BUTTON', buttonName, iEET.frame)
		iEET[name]:SetSize(width, height)
		iEET[name]:SetBackdrop(iEET.backdrop);
		iEET[name]:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
		iEET[name]:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
		iEET[name].text = iEET[name]:CreateFontString()
		iEET[name].text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET[name].text:SetPoint('CENTER', iEET[name], 'CENTER', 0,0)
		iEET[name].text:SetText(buttonText)
		iEET[name]:SetPoint(point, iEET[anchorFrame], relativePoint, xOffset,yOffset)
		iEET[name]:SetFrameStrata('HIGH')
		iEET[name]:SetFrameLevel(3)
		iEET[name]:RegisterForClicks('AnyUp')
	end
	--[Events][NPCs][Spells][E(encounters)][F(filtering)][O(options)][S(spreadsheet)]
	----Event list:
	createButton('eventlist',nil,60,21,'Events','LEFT','top','LEFT',2,0)
	iEET.eventlist:SetScript('OnClick',function()
		iEET:updateEventMenu()
		EasyMenu(iEET.eventListMenu, iEET.eventListMenuFrame, iEET.eventlist, 0 , 0, 'MENU')
	end)
	--iEET:updateOptionMenu()
	--NPC list
	createButton('npcList', nil,60,21,'NPCs','LEFT','eventlist','RIGHT',1,0)
	iEET.npcList:SetScript('OnClick',function()
		iEET:updateNPCListMenu()
		EasyMenu(iEET.npcListMenu, iEET.npcListMenuFrame, iEET.npcList, 0 , 0, 'MENU')
	end)
	--Spells list
	createButton('spellList', nil,60,21,'Spells','LEFT','npcList','RIGHT',1,0)
	iEET.spellList:SetScript('OnClick',function()
		iEET:updateSpellListMenu()
		EasyMenu(iEET.spellListMenu, iEET.spellListMenuFrame, iEET.spellList, 0 , 0, 'MENU')
	end)
	----Encounter list button:
	createButton('encounterListButton',nil,60,21,'Fights','LEFT','spellList','RIGHT',1,0)
	iEET.encounterListButton:SetScript('OnClick',function()
		iEET:updateEncounterListMenu()
		EasyMenu(iEET.encounterListMenu, iEET.encounterListMenuFrame, iEET.encounterListButton, 0 , 0, 'MENU')
	end)
	----Filtering window button:
	createButton('filteringButton', nil,21,21,'F','LEFT','encounterListButton','RIGHT',1,0)
	iEET.filteringButton:SetScript('OnClick',function()
		iEET:Options()
	end)
	--Settings
	createButton('optionsList', nil,21,21,'O','LEFT','filteringButton','RIGHT',1,0)
	iEET.optionsList:SetScript('OnClick',function()
		iEET:updateOptionsMenu()
		EasyMenu(iEET.optionsMenu, iEET.optionsMenuFrame, iEET.optionsList, 0 , 0, 'MENU')
	end)
	----Spreadsheet export button:
	iEET.spreadsheetCopyMenu = {
		{ text = 'Excel', notCheckable = true, func = function() iEET:copyCurrent(3) end},
		{ text = 'Google', notCheckable = true, func = function() iEET:copyCurrent(1) end},
		{ text = 'OpenOffice', notCheckable = true, func = function() iEET:copyCurrent(2) end},
		{ text = 'Cancel', notCheckable = true, func = function() CloseDropDownMenus() end},
	}
	iEET.spreadsheetListMenuFrame = CreateFrame('Frame', 'iEETspreadsheetListMenu', UIParent, 'UIDropDownMenuTemplate')
	createButton('spreadsheetCopyButton',nil,21,21,'S','LEFT','optionsList','RIGHT',1,0)
	iEET.spreadsheetCopyButton:SetScript('OnClick',function()
		EasyMenu(iEET.spreadsheetCopyMenu, iEET.spreadsheetListMenuFrame, iEET.spreadsheetCopyButton, 0 , 0, 'MENU');
	end)
	--Main window exit button
	createButton('exitButton', nil,21,21,'X','LEFT','editbox','RIGHT',1,0)
	iEET.exitButton:SetScript('OnClick',function()
		iEET.frame:Hide()
	end)
	--fill window
	iEET:loopData()
	iEET.frame:Show()
end
function iEET:CreateOptionsFrame()
	-- Options main frame
	iEET.optionsFrame = CreateFrame('Frame', 'iEETOptionsFrame', UIParent)
	iEET.optionsFrame:SetSize(650,500)
	iEET.optionsFrame:SetPoint('CENTER', UIParent, 'CENTER', 0,0)
	iEET.optionsFrame:SetBackdrop(iEET.backdrop);
	iEET.optionsFrame:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.optionsFrame:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.optionsFrame:Show()
	iEET.optionsFrame:SetFrameStrata('DIALOG')
	iEET.optionsFrame:SetFrameLevel(1)
	iEET.optionsFrame:EnableMouse(true)
	iEET.optionsFrame:SetMovable(true)
	--local scale = (0.63999998569489/iEET.optionsFrame:GetEffectiveScale())
	iEET.optionsFrame:SetScale(iEET.scale)
	-- Options title frame
	iEET.optionsFrameTop = CreateFrame('FRAME', nil, iEET.optionsFrame)
	iEET.optionsFrameTop:SetSize(650, 25)
	iEET.optionsFrameTop:SetPoint('BOTTOMRIGHT', iEET.optionsFrame, 'TOPRIGHT', 0, -1)
	iEET.optionsFrameTop:SetBackdrop(iEET.backdrop);
	iEET.optionsFrameTop:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.optionsFrameTop:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.optionsFrameTop:SetScript('OnMouseDown', function(self,button)
		iEET.optionsFrame:ClearAllPoints()
		iEET.optionsFrame:StartMoving()
	end)
	iEET.optionsFrameTop:SetScript('OnMouseUp', function(self, button)
		iEET.optionsFrame:StopMovingOrSizing()
	end)
	iEET.optionsFrameTop:EnableMouse(true)
	iEET.optionsFrameTop:Show()
	iEET.optionsFrameTop:SetFrameStrata('DIALOG')
	iEET.optionsFrameTop:SetFrameLevel(1)
	-- Options title text
	iEET.optionsFrameTopInfo = iEET.optionsFrame:CreateFontString('iEETOptionsInfo')
	iEET.optionsFrameTopInfo:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.optionsFrameTopInfo:SetPoint('CENTER', iEET.optionsFrameTop, 'CENTER', 0,0)
	iEET.optionsFrameTopInfo:SetText('Filtering options')
	iEET.optionsFrameTopInfo:Show()
	--Info frame
	iEET.lastShownOnClick = false
	local function infoFrame(forceHide,clicked)
		if iEET.infoFrame then
			if forceHide and clicked then -- OnClick with shown OnClick -> Hide
				iEET.infoFrame:Hide()
				iEET.lastShownOnClick = false
				return
			elseif not forceHide and clicked then -- OnClick -> force Show
				iEET.infoFrame:Show()
				iEET.lastShownOnClick = true
				return
			elseif not iEET.lastShownOnClick then -- Ignore OnEvent & OnLeave events
				if iEET.infoFrame:IsShown() or forceHide then
					iEET.infoFrame:Hide()
				else
					iEET.infoFrame:Show()
				end
			end
		else
			iEET.infoFrame = CreateFrame('Frame', 'iEETOptionsFrame', UIParent)
			iEET.infoFrame:SetPoint('TOPLEFT', iEET.optionsFrameTop, 'TOPRIGHT', -1,0)
			iEET.infoFrame:SetBackdrop(iEET.backdrop);
			iEET.infoFrame:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
			iEET.infoFrame:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
			iEET.infoFrame:Show()
			iEET.infoFrame:SetFrameStrata('DIALOG')
			iEET.infoFrame:SetFrameLevel(1)
			if not iEET.frame then
				iEET.scale = (GetScreenHeight()/GetScreenWidth()/iEET.infoFrame:GetEffectiveScale())
			end
			iEET.infoFrame:SetScale(iEET.scale)
			iEET.infoFrame.text = iEET.infoFrame:CreateFontString()
			iEET.infoFrame.text:SetFont(iEET.font, 11)
			iEET.infoFrame.text:SetPoint('TOPLEFT', iEET.infoFrame, 'TOPLEFT', 2,-2)
			iEET.infoFrame.text:SetJustifyH('LEFT')
			local infoText = [[
Usage:
Key=Value

Split different argument with ';', eg.
k=v;k=v;k=v
e=2; si=205231; tn=Tichondrius; cn=Beholder
shows every event where event is SPELL_CAST_SUCCESS, spellID = 205231, 
caster name (sourceName) = Beholder and the target is Tichondrius

205231, using only numbers, ieet will assume you want search with spellID and shows every event where spellID = 205231

possible key values (not case sensitive):
t/time, number (doesn't support >/<, atleast not yet)
e/event, number or string(long or short event names), numbers & names at the bottom
sG/sourceGUID, string, UNIT_DIED:destGUID
cN/sourceName, string, UNIT_DIED:destName
tN/destName/unitID, string, USCS: source unitID
sN/spellName, string
sI/spellID, number
hp, number, USCS only (doesn't support >/<, atleast not yet)

using FROM/TO filters: (FROM/TO are case sensitive)
FROM:k=v;k=v TO:k=v;k=v;k=v;
FROM:k=v
TO:k=v
eg. FROM:182263;t=330 TO:185690;t=550

to clear all filters use: clear
to delete just one use: del:x, eg del:1 will delete the first filter (from bottom)
to require every from/to combo use: requireAll (not case sensitive)

REMEMBER TO CLICK 'Save' IF YOU WANT TO SAVE YOUR FILTERS, CLICKING 'Cancel' WILL ERASE YOUR EDITS

Event names/values:
1/SPELL_CAST_START/SC_START
2/SPELL_CAST_SUCCESS/SC_SUCCESS
3/SPELL_AURA_APPLIED/+SAURA
4/SPELL_AURA_REMOVED/-SAURA
5/SPELL_AURA_APPLIED_DOSE/+SA_DOSE
6/SPELL_AURA_REMOVED_DOSE/-SA_DOSE
7/SPELL_AURA_REFRESH/SAURA_R
8/SPELL_CAST_FAILED/SC_FAILED
9/SPELL_CREATE
10/SPELL_SUMMON
11/SPELL_HEAL
12/SPELL_DISPEL
13/SPELL_INTERRUPT/S_INTERRUPT
14/SPELL_PERIODIC_CAST_START/SPC_START
15/SPELL_PERIODIC_CAST_SUCCESS/SPC_SUCCESS
16/SPELL_PERIODIC_AURA_APPLIED/+SPAURA
17/SPELL_PERIODIC_AURA_REMOVED/-SPAURA
18/SPELL_PERIODIC_AURA_APPLIED_DOSE/+SPA_DOSE
19/SPELL_PERIODIC_AURA_REMOVED_DOSE/-SPA_DOSE
20/SPELL_PERIODIC_AURA_REFRESH/SPAURA_R
21/SPELL_PERIODIC_CAST_FAILED/SPC_FAILED
22/SPELL_PERIODIC_CREATE/SP_CREATE
23/SPELL_PERIODIC_SUMMON/SP_SUMMON
24/SPELL_PERIODIC_HEAL/SP_HEAL
25/UNIT_DIED
26/UNIT_SPELLCAST_SUCCEEDED/USC_SUCCEEDED
27/ENCOUNTER_START
28/ENCOUNTER_END
29/MONSTER_EMOTE
30/MONSTER_SAY
31/MONSTER_YELL
32/UNIT_TARGET
33/INSTANCE_ENCOUNTER_ENGAGE_UNIT/IEEU
34/UNIT_POWER
35/PLAYER_REGEN_DISABLED/COMBAT_START
36/PLAYER_REGEN_ENABLED/COMBAT_END
37/MANUAL_LOGGING_START/MANUAL_START
38/MANUAL_LOGGING_END/MANUAL_END
39/UNIT_SPELLCAST_START/USC_START
40/UNIT_SPELLCAST_CHANNEL_START/USC_C_START]]

			iEET.infoFrame.text:SetText(infoText)
			iEET.infoFrame.text:Show()
			iEET.infoFrame:SetSize(iEET.infoFrame.text:GetStringWidth()+4,iEET.infoFrame.text:GetStringHeight()+4)
		end
	end
	--Info button
	iEET.infoButton = CreateFrame('FRAME', nil, iEET.optionsFrame)
	iEET.infoButton:SetSize(21, 21)
	iEET.infoButton:SetPoint('TOPRIGHT', iEET.optionsFrameTop, 'TOPRIGHT', -2, -2)
	iEET.infoButton:SetBackdrop(iEET.backdrop);
	iEET.infoButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.infoButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.infoButton:SetScript('OnEnter', function()
		infoFrame()
	end)
	iEET.infoButton:SetScript('OnLeave', function()
		infoFrame(true)
	end)
	iEET.infoButton:SetScript('OnMouseDown', function()
		if iEET.lastShownOnClick then
			infoFrame(true,true)
		else
			infoFrame(false,true)
		end
	end)
	iEET.infoButton.text = iEET.infoButton:CreateFontString()
	iEET.infoButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.infoButton.text:SetPoint('CENTER', iEET.infoButton, 'CENTER', 0,0)
	iEET.infoButton.text:SetText('I')
	iEET.infoButton.text:Show()
	-- Scrolling Message frame for filters
	iEET.optionsFrameFilterTexts = CreateFrame('ScrollingMessageFrame', nil, iEET.optionsFrame)
	iEET.optionsFrameFilterTexts:SetSize(620,380)
	iEET.optionsFrameFilterTexts:SetPoint('TOP', iEET.optionsFrame, 'TOP', 0, -6)
	iEET.optionsFrameFilterTexts:SetFont(iEET.font, iEET.fontsize)
	iEET.optionsFrameFilterTexts:SetFading(false)
	iEET.optionsFrameFilterTexts:SetInsertMode('TOP')
	iEET.optionsFrameFilterTexts:SetJustifyH(iEET.justifyH)
	iEET.optionsFrameFilterTexts:SetMaxLines(50)
	iEET.optionsFrameFilterTexts:SetSpacing(iEET.spacing)
	iEET.optionsFrameFilterTexts:EnableMouseWheel(true)
	iEET.optionsFrameFilterTexts:SetHyperlinksEnabled(true)
	iEET.optionsFrameFilterTexts:SetScript('OnMouseWheel', function(self, delta)
		if delta == -1 then
			if IsShiftKeyDown() then
				iEET.optionsFrameFilterTexts:PageDown()
			else
				iEET.optionsFrameFilterTexts:ScrollDown()
			end
		else
			if IsShiftKeyDown() then
				iEET.optionsFrameFilterTexts:PageUp()
			else
				iEET.optionsFrameFilterTexts:ScrollUp()
			end
		end
	end)
	iEET.optionsFrameFilterTexts:EnableMouse(true)
	iEET.optionsFrameFilterTexts:SetFrameStrata('DIALOG')
	iEET.optionsFrameFilterTexts:SetFrameLevel(4)
	-- Options Editbox
	iEET.optionsFrameEditbox = CreateFrame('EditBox', 'iEETOptionsEditBox', iEET.optionsFrame)
	iEET.optionsFrameEditbox:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
			insets = {
				left = -1,
				right = -1,
				top = -1,
				bottom = -1,
			},
		});
	iEET.optionsFrameEditbox:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,0.2)
	iEET.optionsFrameEditbox:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.optionsFrameEditbox:SetScript('OnEnterPressed', function()
		local txt = (iEET.optionsFrameEditbox:GetText()):gsub('^%s*(.-)%s*$', '%1')
		if txt == '' then
			iEET.optionsFrameEditbox:ClearFocus()
		elseif string.find(txt, 'FROM:') or string.find(txt, 'TO:') then
			iEET.optionsFrameEditbox:SetText('')
			iEET:AddNewFiltering(txt)
		elseif string.match(string.lower(txt), 'requireall') then
			iEET.optionsFrameEditbox:SetText('')
			iEET:AddNewFiltering('requireAll')
		elseif string.match(string.lower(txt), 'del:(%d+)') then
			--local toDelete = tonumber(string.match(string.lower(txt), 'del:(%d+)'))
			local toDelete = tonumber(string.match(txt, ':(%d+)'))
			local t = {}
			for i = 1, iEET.optionsFrameFilterTexts:GetNumMessages() do
				if not (i == toDelete) then
					local line = iEET.optionsFrameFilterTexts:GetMessageInfo(i)
					table.insert(t,line)
				end
			end
			iEET.optionsFrameFilterTexts:Clear()
			iEET.optionsFrameEditbox:SetText('')
			for _,v in ipairs(t) do
				iEET:AddNewFiltering(v)
			end
		elseif string.lower(txt) == 'clear' then
			iEET.optionsFrameFilterTexts:Clear()
			iEET.optionsFrameEditbox:SetText('')
		elseif string.match(txt, '^(%a-)=(%d+)') or string.match(txt, '^(%a-)=(%a+)') or tonumber(txt) then
			iEET:AddNewFiltering(txt)
			iEET.optionsFrameEditbox:SetText('')
		else
			iEET:print('error, invalid filter')
		end
	end)
	iEET.optionsFrameEditbox:SetAutoFocus(false)
	iEET.optionsFrameEditbox:SetWidth(620)
	iEET.optionsFrameEditbox:SetHeight(200)
	iEET.optionsFrameEditbox:SetMaxLetters(500)
	iEET.optionsFrameEditbox:SetTextInsets(2, 2, 1, 0)
	iEET.optionsFrameEditbox:SetPoint('BOTTOM', iEET.optionsFrame, 'BOTTOM', 0,30)
	iEET.optionsFrameEditbox:SetFrameStrata('DIALOG')
	iEET.optionsFrameEditbox:SetFrameLevel(3)
	iEET.optionsFrameEditbox:SetMultiLine(true)
	iEET.optionsFrameEditbox:Show()
	iEET.optionsFrameEditbox:SetFont(iEET.font, iEET.fontsize+2, 'OUTLINE')
	iEET:FillFilters()
	-- Save button
	iEET.optionsFrameSaveButton = CreateFrame('BUTTON', nil, iEET.optionsFrame)
	iEET.optionsFrameSaveButton:SetSize(100, 20)
	iEET.optionsFrameSaveButton:SetBackdrop(iEET.backdrop);
	iEET.optionsFrameSaveButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.optionsFrameSaveButton.text = iEET.optionsFrameSaveButton:CreateFontString()
	iEET.optionsFrameSaveButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.optionsFrameSaveButton.text:SetPoint('CENTER', iEET.optionsFrameSaveButton, 'CENTER', 0,0)
	iEET.optionsFrameSaveButton.text:SetText('Save')
	iEET.optionsFrameSaveButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.optionsFrameSaveButton:SetPoint('BOTTOMRIGHT', iEET.optionsFrame, 'BOTTOM', -54,4)
	iEET.optionsFrameSaveButton:Show()
	iEET.optionsFrameSaveButton:RegisterForClicks('AnyUp')
	iEET.optionsFrameSaveButton:SetScript('OnClick',function()
		--Parse filters from scrolling message frame
		iEET:ParseFilters()
		iEET:FillFilters()
	end)
	-- Save & Close
	iEET.optionsFrameSaveAndCloseButton = CreateFrame('BUTTON', nil, iEET.optionsFrame)
	iEET.optionsFrameSaveAndCloseButton:SetSize(100, 20)
	iEET.optionsFrameSaveAndCloseButton:SetBackdrop(iEET.backdrop);
	iEET.optionsFrameSaveAndCloseButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.optionsFrameSaveAndCloseButton.text = iEET.optionsFrameSaveAndCloseButton:CreateFontString()
	iEET.optionsFrameSaveAndCloseButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.optionsFrameSaveAndCloseButton.text:SetPoint('CENTER', iEET.optionsFrameSaveAndCloseButton, 'CENTER', 0,0)
	iEET.optionsFrameSaveAndCloseButton.text:SetText('Save & Close')
	iEET.optionsFrameSaveAndCloseButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.optionsFrameSaveAndCloseButton:SetPoint('BOTTOM', iEET.optionsFrame, 'BOTTOM', 0,4)
	iEET.optionsFrameSaveAndCloseButton:Show()
	iEET.optionsFrameSaveAndCloseButton:RegisterForClicks('AnyUp')
	iEET.optionsFrameSaveAndCloseButton:SetScript('OnClick',function()
		--Parse filters from scrolling message frame
		iEET:ParseFilters()
		if iEET.infoFrame then
			iEET.infoFrame:Hide()
		end
		iEET.optionsFrame:Hide()
	end)
	-- Cancel button
	iEET.optionsFrameCancelButton = CreateFrame('BUTTON', nil, iEET.optionsFrame)
	iEET.optionsFrameCancelButton:SetSize(100, 20)
	iEET.optionsFrameCancelButton:SetBackdrop(iEET.backdrop);
	iEET.optionsFrameCancelButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.optionsFrameCancelButton.text = iEET.optionsFrameCancelButton:CreateFontString()
	iEET.optionsFrameCancelButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.optionsFrameCancelButton.text:SetPoint('CENTER', iEET.optionsFrameCancelButton, 'CENTER', 0,0)
	iEET.optionsFrameCancelButton.text:SetText('Cancel')
	iEET.optionsFrameCancelButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.optionsFrameCancelButton:SetPoint('BOTTOMLEFT', iEET.optionsFrame, 'BOTTOM', 54,4)
	iEET.optionsFrameCancelButton:Show()
	iEET.optionsFrameCancelButton:RegisterForClicks('AnyUp')
	iEET.optionsFrameCancelButton:SetScript('OnClick',function()
		-- clear unsaved args & close
		iEET.optionsFrameEditbox:SetText('')
		iEET.optionsFrame:Hide()
		if iEET.infoFrame then
			iEET.infoFrame:Hide()
		end
	end)
	iEET:FillFilters()
end
function iEET:Options()
	if iEET.optionsFrame then
		if iEET.optionsFrame:IsShown() then
			iEET.optionsFrame:Hide()
			if iEET.infoFrame then
				iEET.infoFrame:Hide()
			end
		else
			iEET.optionsFrame:Show()
			if iEET.infoFrame and iEET.lastShownOnClick then
				iEET.infoFrame:Show()
			end
			iEET:FillFilters()
		end
	else
		iEET:CreateOptionsFrame()
	end
end
function iEET:Toggle(show)
	if not InCombatLockdown() then
		if not iEET.frame then
			iEET:CreateMainFrame()
		elseif iEET.frame:IsShown() and not show then
			iEET.frame:Hide()
		else
			iEET.frame:Show()
			iEET:updateEncounterListMenu()
		end
	elseif iEET.frame and not show then
		iEET.frame:Hide()
	end
end
function iEET:toggleCopyFrame(forceShow)
	if not iEET.frame then iEET:CreateMainFrame() end
	if not iEET.copyFrame and not InCombatLockdown() then
		iEET.copyFrame = CreateFrame('EditBox', 'iEETCopyFrame', UIParent)
		iEET.copyFrame:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
				edgeFile = "Interface\\Buttons\\WHITE8x8",
				edgeSize = 1,
				insets = {
					left = -1,
					right = -1,
					top = -1,
					bottom = -1,
				},
			});
		iEET.copyFrame:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,0.2)
		iEET.copyFrame:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.copyFrame:SetScript('OnEnterPressed', function()
			iEET.copyFrame:ClearFocus()
			iEET.copyFrame:SetText('')
			iEET.copyFrame:Hide()
		end)
		iEET.copyFrame:SetAutoFocus(true)
		iEET.copyFrame:SetWidth(400)
		iEET.copyFrame:SetHeight(21)
		iEET.copyFrame:SetTextInsets(2, 2, 1, 0)
		--iEET.copyFrame:SetMultiLine(true)
		iEET.copyFrame:SetPoint('CENTER', UIParent, 'CENTER', 0,0)
		iEET.copyFrame:SetFrameStrata('DIALOG')
		iEET.copyFrame:Show()
		iEET.copyFrame:SetFont(iEET.font, iEET.fontsize+2, 'OUTLINE')
	else
		if iEET.copyFrame:IsShown() and not forceShow then
			iEET.copyFrame:Hide()
		elseif not InCombatLockdown() then
			iEET.copyFrame:Show()
		end
	end
end
function iEET:copyCurrent(formatStyle)
	local totalData = ''
	for line = 1, iEET.content1:GetNumMessages() do
		local lineData = ''
		for i = 1, 8 do
			if i == 4 then
				local lineInfo = iEET['content' .. i]:GetMessageInfo(line)
				local spellID = lineInfo:match('^.*:%d-:(%d-):.-:')
				if tonumber(spellID) then
					local spellName = lineInfo:match('\124h(.*)\124h$')
					if spellName then
						local s = ''
						if formatStyle == 1 then -- Google Spreadsheet
							s = '=HYPERLINK("http://legion.wowhead.com/spell=%s", "%s")'
						elseif formatStyle == 2 then -- Openoffice Math
							s = '=HYPERLINK("http://legion.wowhead.com/spell=%s"; "%s")'
						elseif formatStyle == 3 then -- Excel
							s = '=HYPERLINK("http://legion.wowhead.com/spell=%s", "%s")'
						end
						--add ExtraData to 9th column
						--lineData = lineData .. string.format('=HYPERLINK("http://legion.wowhead.com/spell=%s", "%s")', spellID, spellName) .. '\t'
						lineData = lineData .. string.format(s, spellID, spellName) .. '\t'
					else
						lineData = lineData .. lineInfo .. '\t'
					end
				else
					lineData = lineData .. lineInfo .. '\t'
				end
			else
				lineData = lineData .. iEET['content' .. i]:GetMessageInfo(line) .. '\t'
			end
		end
		totalData = totalData .. '\r' .. string.gsub(lineData, '+', '') --+SAURA etc messes excel so remove +, should be enough for excel
	end
	iEET:toggleCopyFrame(true)
	iEET.copyFrame:SetText(totalData)
end
function iEET:ExportData(auto)
	if iEET.encounterInfoData then -- nil check
		if auto then
			local m,s = string.match(iEET.encounterInfoData.fT, '(%d):(%d*)')
			if m*60+s < iEETConfig.autoDiscard then
				iEET:print(string.format('discarded (%ss)', m*60+s))
				return
			end
			if InCombatLockdown() then
				C_Timer.After(3, function()
					iEET:ExportData(true)
				end)
				return
			end
		end
		local encounterString = ''
		for k,v in pairs(iEET.encounterInfoData) do
			encounterString = encounterString .. '{' .. k .. '=' .. v .. '}'
		end
		local dataString = ''
		for k,v in ipairs(iEET.data) do
			local t = ''
			for a,b in pairs(v) do
				t = t .. '{' .. a .. '=' .. b .. '}'
			end
			dataString = dataString .. '|D|' .. t .. '|D|'

		end
		if not iEET_Data then
			iEET_Data = {}
		end
		iEET_Data[encounterString] = dataString
		iEET:print((iEET.encounterInfoData.eN and iEET.encounterInfoData.eN or 'Unknown').." exported."..(auto and ' (autosave)' or ''))
	end
end
function iEET:ImportData(dataKey)
	iEET.data = {}
	iEET.encounterInfoData = {}
	for eK,eV in string.gmatch(dataKey, '{(.-)=(.-)}') do
		if eK == 'd' or eK == 'rS' or eK == 's' or eK == 'k' or eK == 'v'  then
			if tonumber(eV) then
				eV = tonumber(eV)
			end
		end
		iEET.encounterInfoData[eK] = eV
	end
	for v in string.gmatch(iEET_Data[dataKey], 'D|(.-)|D') do
		local tempTable = {}
		for dK,dV in string.gmatch(v, '{(.-)=(.-)}') do
			if dK == 'sI' or dK == 't' or dK == 'e' then
				if tonumber(dV) then
					dV = tonumber(dV)
				end
			end
			tempTable[dK] = dV
		end
		table.insert(iEET.data, tempTable)
	end
	iEET:loopData()
	iEET:print(string.format('Imported %s on %s (%s), %sman (%s), Time: %s.',iEET.encounterInfoData.eN,GetDifficultyInfo(iEET.encounterInfoData.d),iEET.encounterInfoData.fT, iEET.encounterInfoData.rS, (iEET.encounterInfoData.k == 1 and 'kill' or 'wipe'), iEET.encounterInfoData.pT))
end
function iEET:ConvertOldReports()
	local oldEventVars = {
		timestamp = 't',
		casterName = 'cN',
		targetName = 'tN',
		spellName = 'sN',
		spellID = 'sI',
		event = 'e',
		sourceGUID = 'sG',
	}
	local oldKeyVars = {
		encounterName = 'eN',
		kill = 'k',
		difficulty = 'd',
		start = 's',
		raidSize = 'rS',
		pullTime = 'pT',
		fightTime = 'fT',
	}
	for k,v in pairs(iEET.events.fromID) do --short event names to ids
		oldEventVars[v.s] = k
	end
	local count = 0
	for oldDataKey,oldDataValue in pairs(iEET_Data) do
		if string.find(oldDataKey, 'encounterName=') then
			local newKey = oldDataKey
			local newValue = oldDataValue
			for oV,nV in pairs(oldEventVars) do
				newValue = string.gsub(newValue, oV, nV)
			end
			for oV, nV in pairs(oldKeyVars) do
				newKey = string.gsub(newKey, oV, nV)
			end
			iEET_Data[newKey] = newValue
			iEET_Data[oldDataKey] = nil
			count = count + 1
		end
	end
	iEET:print('Converted ' .. count .. ' old reports to new format.')
end
function iEET:StartRecording(force)
	iEET.IEEUnits = nil
	iEET.IEEUnits = {}
	iEET.unitPowerUnits = nil
	iEET.unitPowerUnits = {}
	iEET.data = nil
	iEET.data = {}
	iEET.raidComp = nil
	iEET.raidComp = {}
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
	addon:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	addon:RegisterEvent('CHAT_MSG_MONSTER_SAY')
	addon:RegisterEvent('CHAT_MSG_MONSTER_EMOTE')
	addon:RegisterEvent('CHAT_MSG_MONSTER_YELL')
	addon:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	addon:RegisterEvent('UNIT_TARGET')
	addon:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT')
	addon:RegisterEvent('UNIT_POWER')
	addon:RegisterEvent('UNIT_SPELLCAST_START')
	addon:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START')
	if force then
		addon:RegisterEvent('PLAYER_REGEN_DISABLED')
		addon:RegisterEvent('PLAYER_REGEN_ENABLED')
	end
end
function iEET:StopRecording(force)
	addon:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	addon:UnregisterEvent('CHAT_MSG_MONSTER_SAY')
	addon:UnregisterEvent('CHAT_MSG_MONSTER_EMOTE')
	addon:UnregisterEvent('CHAT_MSG_MONSTER_YELL')
	addon:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	addon:UnregisterEvent('UNIT_TARGET')
	addon:UnregisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT')
	addon:UnregisterEvent('UNIT_POWER')
	addon:UnregisterEvent('UNIT_SPELLCAST_START')
	addon:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START')
	if force then
		addon:UnregisterEvent('PLAYER_REGEN_DISABLED')
		addon:UnregisterEvent('PLAYER_REGEN_ENABLED')
	end
	if iEETConfig.autoSave then
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
function iEET:Force(start, name)
	if start then
		iEET:StartRecording(true)
		table.insert(iEET.data, {['e'] = 37, ['t'] = GetTime() ,['cN'] = 'Start Logging'})
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
			['v'] = iEET.version,
		}
		--register events and start recording
	else
		--unregister events and stop recording
		iEET.forceRecording = false
		table.insert(iEET.data, {['e'] = 38, ['t'] = GetTime() ,['cN'] = 'End Logging'})
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
			['v'] = iEET.version,
			}
		end
		iEET:print(string.format('Stopped recording: %s (%s)', iEET.encounterInfoData.eN, iEET.encounterInfoData.fT))
		iEET:StopRecording(true)
	end
end
SLASH_IEET1 = "/ieet"
SLASH_IEET2 = '/iencountereventtracker'
SlashCmdList["IEET"] = function(realMsg)
	local msg = realMsg
	if msg then msg = string.lower(msg) end
	if msg:len() <= 1 then
		iEET:Toggle()
	elseif string.match(msg, 'copy') then
		iEET:copyCurrent()
	elseif string.match(msg, 'filters') then
		iEET:Options()
	elseif string.match(msg, 'import') then
		if iEET_Data then
			iEET:Toggle(true)
			local id = string.gsub(msg, 'import ', '')
			if iEET_Data[id] then
				iEET:ImportData(id)
			else
				iEET:print('key [' .. id .. '] not found')
			end
		else
			iEET:print('No data to import.')
		end
	elseif string.match(msg, 'clear') then
		iEET_Data = nil
		iEET_Data = {}
		iEET:print('iEET_Data wiped.')
	elseif string.match(msg, 'autosave') then
		if iEETConfig.autoSave then
			iEETConfig.autoSave = false
			iEET:print('Automatic saving after ENCOUNTER_END off.')
		else
			iEETConfig.autoSave = true
			iEET:print('Automatic saving after ENCOUNTER_END on.')
		end
	elseif string.match(msg, 'autodiscard') then
		local timer = string.match(msg, 'autodiscard (%d+)')
		if timer then
			iEET:print('Auto discard timer changed from ' .. iEETConfig.autoDiscard .. ' to ' .. timer .. '.')
			iEETConfig.autoDiscard = tonumber(timer)
		else
			iEET:print('Invalid number')
		end
	elseif string.match(msg, 'help') then
		iEET:print('/ieet autosave to toggle autosaving\r/ieet autodiscard X to change auto discard timer\r/ieet clear to delete every fight entry')
	elseif string.match(msg, 'convert') then
		iEET:ConvertOldReports()
	elseif string.match(msg, 'colorreset') then
		iEETConfig.colors = {
			['main'] = {
				['bg'] = {['r'] = 0.1, ['g'] = 0.1, ['b'] = 0.1, ['a'] = 0.9},
				['border'] = {['r'] = 0, ['g'] = 0, ['b'] = 0, ['a'] = 1},
			},
			['options'] = {
				['bg'] = {['r'] = 0.1, ['g'] = 0.1, ['b'] = 0.1, ['a'] = 0.9},
				['border'] = {['r'] = 0.64, ['g'] = 0, ['b'] = 0, ['a'] = 1},
			},
		}
		iEET:UpdateColors('main',nil,true) --force update after reset
		iEET:UpdateColors('options',nil,true) --force update after reset
	elseif string.match(msg, 'force') then
		local arg = string.sub(realMsg, 6)
		arg = iEET:TrimWS(arg)
		local name
		if arg:len() > 0 then
			name = arg
		end
		if iEET.forceRecording then
			iEET:Force()
		else
			iEET:Force(true, name)
		end
	elseif string.match(msg, 'version') then
		iEET:print(iEETConfig.version)
	else
		iEET:print(string.format('Command "%s" not found, read the readme.txt.', msg))
	end
end
BINDING_HEADER_IEET = 'iEncounterEventTracker'
BINDING_NAME_IEET_TOGGLE = 'Toggle window'
BINDING_NAME_IEET_EXPORT = 'Export Data'
BINDING_NAME_IEET_COPY = 'Copy currently shown fight to spreadsheet'
BINDING_NAME_IEET_OPTIONS = 'Show filtering options window'
BINDING_NAME_IEET_FORCE = 'Start/Stop manual logging'
function IEET_TOGGLE(window)
	if window == 'frame' then
		iEET:Toggle()
	elseif window == 'copy' and not InCombatLockdown() then
		iEET:copyCurrent()
	elseif window == 'export' and not InCombatLockdown() then
		iEET:ExportData()
	elseif window == 'options' and not InCombatLockdown() then
		iEET:Options()
	elseif window == 'force' then
		if iEET.forceRecording then
			iEET:Force()
		else
			iEET:Force(true)
		end
	end
end
function iEET_Debug(v)
	return iEET[v]
end