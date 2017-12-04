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
better fight selecting
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
iEET.version = 1.641
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
iEET.auraEvents = {
	['SPELL_AURA_APPLIED'] = true,
	['SPELL_AURA_REMOVED'] = true,
	['SPELL_AURA_APPLIED_DOSE'] = true,
	['SPELL_AURA_REMOVED_DOSE'] = true,
	['SPELL_AURA_REFRESH'] = true,
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
iEET.encounterShortList = {}
iEET.maxScrollRange = 0
iEET.fakeSpells = {

}
iEET.savedPowers = {}
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

		['UNIT_SPELLCAST_INTERRUPTIBLE'] = 41,
		['UNIT_SPELLCAST_NOT_INTERRUPTIBLE'] = 42,

		['RAID_BOSS_EMOTE'] = 43,
		['RAID_BOSS_WHISPER'] = 44,

		['CHAT_MSG_RAID_BOSS_WHISPER'] = 45,
		['CHAT_MSG_RAID_BOSS_EMOTE'] = 46,

		['BigWigs_BarCreated'] = 47,
		['BigWigs_Message'] = 48,
		['BigWigs_PauseBar'] = 49,
		['BigWigs_ResumeBar'] = 50,
		['BigWigs_StopBar'] = 51,
		['BigWigs_StopBars'] = 52,
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
		[41] = {
			l = 'UNIT_SPELLCAST_INTERRUPTIBLE',
			s = 'INTERRUPTIBLE',
		},
		[42] = {
			l = 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE',
			s = 'NOT_INTERRUPTIBLE',
		},
		[43]= {
			l = 'RAID_BOSS_EMOTE',
			s = 'RB_EMOTE',
		},
		[44] = {
			l = 'RAID_BOSS_WHISPER',
			s = 'RB_WHISPER',
		},
		[45] = {
			l = 'CHAT_MSG_RAID_BOSS_WHISPER',
			s = 'CMRB_WHISPER',
		},
		[46] = {
			l = 'CHAT_MSG_RAID_BOSS_EMOTE',
			s = 'CMRB_EMOTE',
		},
		[47] = {
			l = 'BigWigs_BarCreated',
			s = 'BW_BarCreated',
		},
		[48] = {
			l = 'BigWigs_Message',
			s = 'BW_Message',
		},
		[49] = {
			l = 'BigWigs_PauseBar',
			s = 'BW_PauseBar',
		},
		[50] = {
			l = 'BigWigs_ResumeBar',
			s = 'BW_ResumeBar',
		},
		[51] = {
			l = 'BigWigs_StopBar',
			s = 'BW_StopBar',
		},
		[52] = {
			l = 'BigWigs_StopBars',
			s = 'BW_StopBars',
		},
	},
}
iEET.ignoreList = {  -- Ignore list for 'Ignore Spell's menu, use event ignore to hide these if you want (they are fake spells)
	[98391] = true, -- Death
	[103528] = true, -- Target Selection
	[133217] = true, -- Spawn NPCs
	[143409] = true, -- Power Update
}
iEET.addonUsers = {}
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
function iEET:shouldTrack(event, unitType, npcID, spellID, sourceGUID, hideCaster)
	if (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and (iEET.approvedSpells[spellID] or iEET.taunts[spellID])) or not sourceGUID or hideCaster or event == 'SPELL_INTERRUPT' or event == 'SPELL_DISPEL' then
		if spellID and not iEET.ignoredSpells[spellID] then
			if not iEET.npcIgnoreList[tonumber(npcID)] then
				return true
			end
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
			['UNIT_SPELLCAST_INTERRUPTIBLE'] = true,
			['UNIT_SPELLCAST_NOT_INTERRUPTIBLE'] = true,

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

			['RAID_BOSS_EMOTE'] = true,
			['RAID_BOSS_WHISPER'] = true,

			['CHAT_MSG_RAID_BOSS_EMOTE'] = true,
			['CHAT_MSG_RAID_BOSS_WHISPER'] = true,

			['BigWigs_BarCreated'] = true,
			['BigWigs_Message'] = true,
			['BigWigs_PauseBar'] = true,
			['BigWigs_ResumeBar'] = true,
			['BigWigs_StopBar'] = true,
			['BigWigs_StopBars'] = true,
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
		['cInfo'] = true,
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
		RegisterAddonMessagePrefix('iEET')
		addon:RegisterEvent('CHAT_MSG_ADDON')
		iEETConfig = iEETConfig or {}
		iEET_Data = iEET_Data or {}
		--if not iEETConfig.version or not iEETConfig.tracking or iEETConfig.version < 1.503 then -- Last version with db changes
		iEET:LoadDefaults()
		--else
		iEETConfig.version = iEET.version
		--end
		addon:UnregisterEvent('ADDON_LOADED')
	end
end
function addon:CHAT_MSG_ADDON(prefix,msg,chatType,sender)
	if prefix == 'iEET' then
		if msg == 'userCheck' then
			SendAddonMessage('iEET', string.format('userCheckReply;;%s;;%s',  iEETConfig.version, (iEETConfig.autoSave and '1' or '0')), chatType)
		elseif msg:find('userCheckReply') then -- unnecessary check for now, but use it so it will also work in future
			local v,s = msg:match('userCheckReply;;(%d%.%d+);;(%d)')
			if v and s then -- nil check to filter out idiots
				iEET.addonUsers[sender] = {
					version = v,
					autoSave = s,
				}
			end
		end
	end
end
function addon:PLAYER_LOGOUT()
	if iEET.forceRecording then
		iEET:Force()
	end
end
function addon:ENCOUNTER_START(encounterID, encounterName, difficultyID, raidSize,...)
	if not iEET.forceRecording then
		local mapID = select(8, GetInstanceInfo())
		iEET:StartRecording()
		iEET.encounterInfoData = { --TODO
			['s'] = GetTime(),
			['eN'] = encounterName,
			['pT'] = date('%y.%m.%d %H:%M'), -- y.m.d instead of d.m.y for easier sorting
			['fT'] = '00:00',
			['d']= 0,
			['rS'] = 0,
			['k'] = 0,
			['zI'] = mapID,
			['v'] = iEET.version,
			['eI'] = encounterID,
			['d'] = difficultyID,
			['rs'] = raidSize,
		}
	end
	table.insert(iEET.data, {['e'] = 27, ['t'] = GetTime(), ['cN'] = encounterName, ['tN'] = encounterID, ['sN'] = 'Logger: '..UnitName('player')})
end
function addon:ENCOUNTER_END(EncounterID, encounterName, difficultyID, raidSize, kill,...)
	table.insert(iEET.data, {['e'] = 28, ['t'] = GetTime() ,['cN'] = kill == 1 and 'Victory!' or 'Wipe', ['tN'] = EncounterID,  ['sN'] = 'Logger: '..UnitName('player')})
	if not iEET.forceRecording then
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
	if (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and (iEET.approvedSpells[spellID] or iEET.taunts[spellID])) or not sourceGUID then
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
function addon:UNIT_SPELLCAST_INTERRUPTIBLE(unitID)
	local sourceGUID = UnitGUID(unitID)
	local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
	if sourceGUID then -- fix for arena id's
		unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
	end
	if (unitType == 'Creature') or (unitType == 'Vehicle') or not sourceGUID then
		local sourceName = UnitName(unitID)
		local chp = UnitHealth(unitID)
		local maxhp = UnitHealthMax(unitID)
		local php = nil
		if chp and maxhp then
			php = math.floor(chp/maxhp*1000+0.5)/10
		end
		if not iEET.npcIgnoreList[tonumber(npcID)] then
			if not iEET.ignoredSpells[spellID] then
				local spellName = GetSpellInfo(140021)
				table.insert(iEET.data, {
					['e'] = 41,
					['t'] = GetTime(),
					['sG'] = sourceGUID or 'NONE',
					['cN'] = sourceName or 'NONE',
					['tN'] = unitID or nil,
					['sN'] = '-'..spellName,
					['sI'] = 140021,
					['hp'] = php or nil,
				});
			end
		end
	end
end
function addon:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(unitID)
	local sourceGUID = UnitGUID(unitID)
	local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
	if sourceGUID then -- fix for arena id's
		unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
	end
	if (unitType == 'Creature') or (unitType == 'Vehicle') or not sourceGUID then
		local sourceName = UnitName(unitID)
		local chp = UnitHealth(unitID)
		local maxhp = UnitHealthMax(unitID)
		local php = nil
		if chp and maxhp then
			php = math.floor(chp/maxhp*1000+0.5)/10
		end
		if not iEET.npcIgnoreList[tonumber(npcID)] then
			local spellName = GetSpellInfo(140021)
			if not iEET.ignoredSpells[spellID] then
				table.insert(iEET.data, {
					['e'] = 42,
					['t'] = GetTime(),
					['sG'] = sourceGUID or 'NONE',
					['cN'] = sourceName or 'NONE',
					['tN'] = unitID or nil,
					['sN'] = '-'..spellName,
					['sI'] = 140021,
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
	if unitID:find('boss') then
		if UnitExists(unitID) then --didn't just disappear
			if not iEET.savedPowers[powerType] then
				local powerNumber = _G['SPELL_POWER_'..powerType]
				if not powerNumber then
					powerNumber = _G['SPELL_POWER_'..powerType..'_POWER']
					if not powerNumber then
						powerNumber = UnitPowerType(unitID)
					end
				end
				iEET.savedPowers[powerType] = {
					i = powerNumber,
					n = _G[powerType] or powerType,
				}
			end
			local sourceGUID = UnitGUID(unitID)
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
			local maxPower = UnitPowerMax(unitID,iEET.savedPowers[powerType].i)
			local pUP = 0
			if currentPower and maxPower then
				pUP = math.floor(currentPower/maxPower*1000+0.5)/10
			end
			local tooltipText = string.format('%s %s%%;%s/%s;%s',iEET.savedPowers[powerType].n, pUP, currentPower, maxPower, change) --PowerName 50%;50/100;+20
			--/dump string.format('%s %s%%;%s/%s;%s','Rage', 50, 50,100, 20)
			table.insert(iEET.data, {
			['e'] = 34,
			['t'] = GetTime(),
			['sG'] = unitID,
			['cN'] = sourceName or unitID,
			['tN'] = pUP .. '%',
			['sN'] = iEET.savedPowers[powerType].n .. ' Update',
			['sI'] = 143409, -- Power Regen
			['hp'] = php,
			['eD'] = tooltipText, --eD = extraData
			});
		end
	end
end
function addon:COMBAT_LOG_EVENT_UNFILTERED(timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,spellID, spellName,spellSchool,auraType,...)
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
		elseif iEET:shouldTrack(event, unitType, npcID, spellID, sourceGUID, hideCaster) then
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
						['dG'] = destGUID or nil,
						['sN'] = spellName or 'NONE',
						['sI'] = spellID or 'NONE',
						['eD']= eD,
						['hp']= iEET.auraEvents[event] and (auraType == 'DEBUFF' and '-' or '+') or nil,
					})
				--end
			--end
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
		else
			break
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
	})
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
function addon:RAID_BOSS_EMOTE(msg, sourceName,_,_,destName)
	table.insert(iEET.data, {
		['e'] = 43,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName or UNKNOWN,
		['sG'] = sourceName or UNKNOWN,
		['tN'] = destName and destName or nil,
	})
end
function addon:RAID_BOSS_WHISPER(msg, sourceName) -- im not sure if there is sourceName, needs testing
	table.insert(iEET.data, {
		['e'] = 44,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName or UNKNOWN,
		['sG'] = sourceName or UNKNOWN,
		['tN'] = 'player', -- meh
	})
end
function addon:CHAT_MSG_RAID_BOSS_EMOTE(msg, sourceName,_,_,destName)
	table.insert(iEET.data, {
		['e'] = 46,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName or UNKNOWN,
		['sG'] = sourceName or UNKNOWN,
		['tN'] = destName and destName or nil,
	})
end
function addon:CHAT_MSG_RAID_BOSS_WHISPER(msg, sourceName)
	table.insert(iEET.data, {
		['e'] = 45,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName or UNKNOWN,
		['sG'] = sourceName or UNKNOWN,
		['tN'] = 'player',
	})
end
function addon:PLAYER_REGEN_DISABLED()
	table.insert(iEET.data, {['e'] = 35, ['t'] = GetTime() ,['cN'] = '+Combat'})
end
function addon:PLAYER_REGEN_ENABLED()
	table.insert(iEET.data, {['e'] = 36, ['t'] = GetTime() ,['cN'] = '-Combat'})
end
function iEET:BigWigsData(event,...)
	if event == 'BigWigs_BarCreated' then
		local key, text, time, cd = ...
		table.insert(iEET.data, {
			['e'] = 47,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['cN'] = time,
			['tN'] = key,
			['sN'] = text,
			['sI'] = key or text, -- nil check for pull timers etc
			['hp'] = cd and 'CD' or nil,
		})
	elseif event == 'BigWigs_Message' then
		local key,text = ...
		table.insert(iEET.data, {
			['e'] = 48,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['tN'] = key,
			['sN'] = text,
			['sI'] = key or text, -- nil check for pull timers etc
		})
	elseif event == 'BigWigs_PauseBar' then
		local text = ...
		table.insert(iEET.data, {
			['e'] = 49,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['sN'] = text,
			['sI'] = text,
		})
	elseif event == 'BigWigs_ResumeBar' then
		local text = ...
		table.insert(iEET.data, {
			['e'] = 50,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['sN'] = text,
			['sI'] = text,
		})
	elseif event == 'BigWigs_StopBar' then
		local text = ...
		table.insert(iEET.data, {
			['e'] = 51,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['sN'] = text,
			['sI'] = text,
		})
	elseif event == 'BigWigs_StopBars' then
		table.insert(iEET.data, {
			['e'] = 52,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['sN'] = 'Stop all bars',
			['sI'] = 'BWStopAllBars',
		})
	end
end
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
function iEET:TrimWS(str)
	return str:gsub('^%s*(.-)%s*$', '%1')
end
function iEET:ShowColorPicker(frame)
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
function iEET:ScrollContent(delta, fixedValue)
	if fixedValue then
		local offSet = iEET.maxScrollRange-fixedValue
		for i = 1, 8 do
			iEET['content' .. i]:SetScrollOffset(offSet)
		end
	else
		if delta == -1 then
			local offSet
			if IsShiftKeyDown() then
				offSet = iEET['content' .. 1]:GetScrollOffset()-75
			else
				offSet = iEET['content' .. 1]:GetScrollOffset()-1
			end

			for i = 1, 8 do
				iEET['content' .. i]:SetScrollOffset(offSet)
			end
			iEET.mainFrameSlider:SetValue(iEET.maxScrollRange-offSet)
		else
			local offSet
			if IsShiftKeyDown() then
				offSet = iEET['content' .. 1]:GetScrollOffset()+75
			else
				offSet = iEET['content' .. 1]:GetScrollOffset()+1
			end

			for i = 1, 8 do
				iEET['content' .. i]:SetScrollOffset(offSet)
			end
			iEET.mainFrameSlider:SetValue(iEET.maxScrollRange-offSet)
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
function iEET:removeExtras(str, hyperlink)
	str = str:gsub('|c........', '') -- Colors
	str = str:gsub('|r', '') -- Colors
	str = str:gsub('|T.+|t', '') -- Textures
	str = str:gsub('^%s*(.-)%s*$', '%1') -- Whitespace
	str = str:gsub(':', ';;')
	str = str:gsub('%%', '%%%%')
	if hyperlink then
		str = str:gsub('|h', '') -- Spells
		str = str:gsub('|H', '') -- Spells
	end
	return str
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
	if eventToFind == 43 or eventToFind == 44 or eventToFind == 45 or eventToFind == 46 then -- RAID_BOSS_EMOTE, RAID_BOSS_WHISPER
		spellIDToFind = spellIDToFind:match('spell;;(%d+)')
		iEETDetailInfo:SetText(iEET.events.fromID[eventToFind].s ..':'..GetSpellInfo(spellIDToFind))
		spellIDToFind = 'spell:'..spellIDToFind
	else
		iEETDetailInfo:SetText(iEET.events.fromID[eventToFind].s ..':'..hyperlink)
	end
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
				if (v.e == eventToFind) and (eventToFind == 43 or eventToFind == 44 or eventToFind == 45 or eventToFind == 46) then -- RAID_BOSS_EMOTE, RAID_BOSS_WHISPER
					if v.sI:find(spellIDToFind) then
						found = true
					end
				elseif v.sI == spellIDToFind and v.e == eventToFind then
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
end
function iEET:addToContent(timestamp,event,casterName,targetName,spellName,spellID,intervall,count,sourceGUID, hp, extraData, destGUID)
	local color = iEET:getColor(event, sourceGUID, spellID)
	iEET:addMessages(1, 1, timestamp, color, '\124HiEETtime:' .. timestamp ..'\124h%s\124h')
	iEET:addMessages(1, 2, intervall, color, intervall and ('\124HiEETtime:' .. intervall ..'\124h%s\124h') or nil)
	iEET:addMessages(1, 3, iEET.events.fromID[event].s, color)
	if event == 29 or event == 30 or event == 31 or event == 43 or event == 44 or event == 45 or event == 46 then -- MONSTER_EMOTE = 29, MOSNTER_SAY = 30, MONSTER_YELL = 31, RAID_BOSS_EMOTE = 43, RAID_BOSS_WHISPER = 44
		local msg = spellID
		if event == 29 or event == 43 or event == 44 or event == 45 or event == 46 then --trying to fix monster emotes, MONSTER_EMOTE
			--"|TInterface\\Icons\\spell_fel_elementaldevastation.blp:20|tVerestriona's |cFFFF0000|Hspell:182008|h[Latent Energy]|h|r reacts violently as they step into the |cFFFF0000|Hspell:179582|h[Rumbling Fissure]|h|r!}|D|"
			--TODO: Better solution
			msg = iEET:removeExtras(spellID, true)
			--msg = string.gsub(spellID, "|T.+|t", "") -- Textures
			--msg = string.gsub(msg, "|h", "") -- Spells
			--msg = string.gsub(msg, "|H", "") -- Spells
			--msg = string.gsub(msg, "|c........", "") -- Colors
			--msg = string.gsub(msg, "|r", "") -- Colors
			--msg = string.gsub(msg, '%%', '%%%%')
			--msg = string.gsub(msg, ':', ';;')
		end
		if event == 43 or event == 44 or event == 45 or event == 46 then
			local sID = msg:match('spell;;(%d+)')
			if sID then
				local s = 'Message'
				local sN = GetSpellInfo(sID) or 'Message'
				iEET:addMessages(1, 4, sN, color, '\124HiEETcustomyell:' .. event .. ':' .. msg .. '\124h%s\124h')
			else
				iEET:addMessages(1, 4, 'Message', color, '\124HiEETcustomyell:' .. event .. ':' .. msg .. '\124h%s\124h') -- NEEDS CHANGING
			end
		else
			iEET:addMessages(1, 4, 'Message', color, '\124HiEETcustomyell:' .. event .. ':' .. msg .. '\124h%s\124h') -- NEEDS CHANGING
		end
	elseif event == 47 or event == 48 or event == 49 or event == 50 or event == 51 or event == 52 then -- BigWigs
		--spellName = spellName:gsub(':', ';;')
		--spellName = spellName:gsub('|c........', '') -- Colors
		--spellName = spellName:gsub('|r', '') -- Colors
		--spellName = spellName:gsub('|T.+|t', '') -- Textures
		--spellName = iEET:TrimWS(spellName)
		--spellName = spellName:gsub('%%', '%%%%')
		spellName = iEET:removeExtras(spellName)
		if event == 52 then -- BigWigs_StopBars
			iEET:addMessages(1, 4, spellName, color)
		elseif event == 47 or event == 48 then -- BigWigs_BarCreated, BigWigs_Message
			local sn
			if tonumber(spellID) then
				spellID = tonumber(spellID)
				if spellID > 0 then -- spellID
					sn = GetSpellInfo(spellID)
					if not sn then -- PTR nil check
						sn = spellID
					end
				else -- Encounter journal section ID
					sn = EJ_GetSectionInfo(-spellID)
					if not sn then -- PTR nil check
						sn = spellID
					end
				end
			else
				sn = spellID
			end
			iEET:addMessages(1, 4, sn, color, '\124HiEETBW:' .. event .. ':' .. spellName .. '\124h%s\124h')
		else -- BigWigs_PauseBar, BigWigs_ResumeBar, BigWigs_StopBar
			iEET:addMessages(1, 4, spellName:gsub(';;', ':'), color, '\124HiEETBW_NOKEY:' .. event .. ':' .. spellName .. '\124h%s\124h')
		end
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
			iEET:addMessages(1, 4, spellName, color, '\124HiEETcustomspell:' .. event ..
				':' .. spellID .. ':' .. string.gsub(spellName, '%%', '%%%%') ..
				':' .. (npcID and (npcID .. '!' .. (spawnID and spawnID or '')) or 'NONE')
				.. ((destGUID and destGUID:len() > 0) and (':'.. destGUID) or '')
				..'\124h%s\124h')
		end
	elseif event == 27 or event == 28 then -- ENCOUNTER_START, ENCOUNTER_END
		if spellName then -- nil check for older logs
			iEET:addMessages(1, 4, spellName, color)
		else
			iEET.content4:AddMessage(' ')
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
		if v.e == 26 or v.e == 39 or v.e == 40 or v.e == 41 or v.e == 42 then -- UNIT_SPELLCAST_SUCCEEDED
			if string.find(v.tN, 'nameplate') then -- could be safe to assume that there will be atleast one nameplate unitid
				if not iEET.collector.encounterNPCs.nameplates then
					iEET.collector.encounterNPCs.nameplates = true
				end
			elseif v.tN and not iEET.collector.encounterNPCs[v.tN] then
				iEET.collector.encounterNPCs[v.tN] = true
			end
		elseif v.cN and v.sI and not iEET.collector.encounterNPCs[v.cN] and not (v.e == 27 or v.e == 28 or v.e == 47 or v.e == 48 or v.e == 49 or v.e == 50 or v.e == 51 or v.e == 52) then -- Collect npc names, 27 = ENCOUNTER_START, 28 = ENCOUNTER_END, 47-52 BigWigs events
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
		if v.sI and v.sN and not iEET.collector.encounterSpells[v.sI] and not (v.e == 27 or v.e == 28 or v.e == 47 or v.e == 48 or v.e == 49 or v.e == 50 or v.e == 51 or v.e == 52) then -- Collect npc names, 27 = ENCOUNTER_START, 28 = ENCOUNTER_END, 47-52 BigWigs events
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
				iEET:addToContent(timestamp,v.e,v.cN,v.tN,v.sN,v.sI,intervall,count,v.sG,v.hp,v.eD, v.dG)
			end
		end
	end
	-- Update Slider values
	iEET.maxScrollRange = iEET['content' .. 1]:GetMaxScrollRange()
	iEET.mainFrameSlider:SetMinMaxValues(0, iEET.maxScrollRange)
	iEET.mainFrameSlider:SetValue(iEET.maxScrollRange)
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
	local lineID = iEET.optionsFrameFilterTexts:GetNumMessages()+1
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
		local sID = spellID:match('spell;;(%d+)')
		local text = spellID:gsub(';;', ':')
		if GetSpellInfo(sID) then -- PTR/LIVE nil check
			local spellInfo = GetSpellDescription(sID)
			text = text..'\n\n'..spellInfo
		end
		GameTooltip:AddLine(text, nil,nil,nil,true) -- Force wrapping
	elseif linkType == 'iEETcustomspell' then
		local _, event, spellID, spellName, npcID, destGUID = strsplit(':',linkData)
		if spellID == 'NONE' then
			return
		end
		local hyperlink = '\124Hspell:' .. tonumber(spellID)
		GameTooltip:SetHyperlink('spell:' .. tonumber(spellID))
		GameTooltip:AddLine('spellID:' .. spellID)
		GameTooltip:AddLine('npc:' .. npcID)
		if destGUID then
			GameTooltip:AddLine('destGUID:' .. destGUID)
		end
	elseif linkType == 'iEETtime' then
		local _, txt = strsplit(':',linkData)
		local ntxt = tonumber(txt)
		local m = math.floor(ntxt/60)
		local s = ntxt%60
		local ms = (s-math.floor(s))*1000
		GameTooltip:SetText(string.format('%s\n%02d:%02d.%03d',txt,m,s,ms))
	elseif linkType == 'iEETNpcList' then
		local _, txt = strsplit(':',linkData)
		GameTooltip:SetText(txt)
	elseif linkType == 'iEETList' then
		linkData = linkData:gsub('iEETList:', '')
		for _,v in pairs({strsplit(';',linkData)}) do
			GameTooltip:AddLine(v)
		end
	elseif linkType == 'iEETBW' then
		local event, text = linkData:match('iEETBW:(%d-):(.+)')
		text = text:gsub(';;', ':')
		GameTooltip:AddLine(text)
	elseif linkType == 'iEETBW_NOKEY' then
		local event,  text = linkData:match('iEETBW_NOKEY:(%d-):(.+)')
		text = text:gsub(';;', ':')
		GameTooltip:AddLine(text)
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
	table.insert(iEET.optionsMenu, {text = 'Mass delete options', notCheckable = true, func = function() iEET:toggleDeleteOptions() end})
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
	table.insert(iEET.optionsMenu, {text = 'Clear all fights', notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = {
		{text = 'Are you sure?', keepShownOnClick = true, notCheckable = true, hasArrow = true, menuList = {
			{text = 'For realsies?', keepShownOnClick = true, notCheckable = true, hasArrow = true, menuList = {
				{text = 'Clear all fights', notCheckable = true, function()
					iEET_Data = nil
					iEET_Data = {}
					iEET:print('iEET_Data wiped.')
					end}
				}
			}
		}}
	}})
	table.insert(iEET.optionsMenu, {text = 'Export sorted fights to WTF file', notCheckable = true, func = function() iEET:ExportFightsToWTF() end})
	table.insert(iEET.optionsMenu, {text = 'Clear exported fights (iEET_ExportFromWTF)', notCheckable = true, func = function()
		iEET_ExportFromWTF = {}
		iEET:print('Export variable cleared.')
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
		local zonesTemp = {}
		for k,_ in pairs(iEET_Data) do -- Get encounters
			--if string.find(k, 'encounterName=') then -- swichted to first :Show()
			--	iEET:print('found old reports, please use "/ieet convert" to continue')
			--	return
			--end
			local temp = {}
			for eK,eV in string.gmatch(k, '{(.-)=(.-)}') do
				if eK == 'd' or eK == 'rS' or eK == 's' or eK == 'k' or eK == 'v' or eK == 'zI' or eK == 'eI' then
					if tonumber(eV) then
						eV = tonumber(eV)
					end
				end
				temp[eK] = eV
			end
			--if not temp.eI then
			--	iEET:print('found old reports, please use "/ieet convert" to continue')
			--	return
			--end
			temp.dataKey = k
			if temp.zI then
				local zone = GetRealZoneText(temp.zI)
				temp.zoneName = zone
				if not zonesTemp[zone] then
					zonesTemp[zone] = {text = zone, hasArrow = true, notCheckable = true, menuList = {}}
				end
			else
				temp.zoneName = UNKNOWN
				if not zonesTemp[UNKNOWN] then
					zonesTemp[UNKNOWN] = {text = UNKNOWN, hasArrow = true, notCheckable = true, menuList = {}}
				end
			end
			if not encountersTempTable[temp.zoneName] then
				encountersTempTable[temp.zoneName] = {}
			end
			if not encountersTempTable[temp.zoneName][temp.eN] then
				encountersTempTable[temp.zoneName][temp.eN] = {}
			end
			if not encountersTempTable[temp.zoneName][temp.eN][temp.d] then
				encountersTempTable[temp.zoneName][temp.eN][temp.d] = {}
			end
			table.insert(encountersTempTable[temp.zoneName][temp.eN][temp.d], temp)
		end -- Sorted by encounter -> Sort by ids inside
		-- temp{} -> encounter{} -> difficulty{} -> fight{}
		for zoneName, encountersTemp in pairs(encountersTempTable) do
			for encounterName in spairs(encountersTemp) do -- Get alphabetically sorted encounters
				--Looping bosses
				local t = {text = encounterName, hasArrow = true, notCheckable = true, menuList = {}}
				local t2 = {}
				local zone
				for difficultyID,_ in spairs(encountersTemp[encounterName]) do
					-- Looping difficulties
					t2 = {text = GetDifficultyInfo(difficultyID), hasArrow = true, notCheckable = true, menuList = {}}
					for k,v in spairs(encountersTemp[encounterName][difficultyID], function(t,a,b) return t[b].pT < t[a].pT end) do
						if not zone or (zone == UNKNOWN and v.zoneName ~= zone) then
							zone = v.zoneName
						end
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
				table.insert(zonesTemp[zone].menuList, t)
				--table.insert(iEET.encounterListMenu, t)
			end
		end
		for zoneName,v in spairs(zonesTemp) do
			table.insert(iEET.encounterListMenu, v)
		end
	end
	table.insert(iEET.encounterListMenu, { text = 'Exit', notCheckable = true, func = function () CloseDropDownMenus() end})
end
function iEET:CreateMainFrame()
	iEET.frame = CreateFrame("Frame", "iEETFrame", UIParent)
	iEET.frame:SetSize(598,834)
	iEET.frame:SetPoint('CENTER', UIParent, 'CENTER', 0,0)
	iEET.frame:SetScript('OnMouseDown', function(self,button)
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
	iEET.top:SetSize(605, 25)
	iEET.top:SetPoint('BOTTOMLEFT', iEET.frame, 'TOPLEFT', 0, -1)
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

	-- Prev button
	iEET.prevEncounter = CreateFrame('FRAME', nil, iEET.frame)
	iEET.prevEncounter:SetSize(18, 18)
	iEET.prevEncounter:SetPoint('BOTTOMRIGHT', iEET.encounterInfo, 'BOTTOMLEFT', 0, 0)
	iEET.prevEncounter:SetBackdrop(iEET.backdrop);
	iEET.prevEncounter:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.prevEncounter:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.prevEncounter:SetScript('OnMouseDown', function(self,button)
		iEET:ImportData(iEET:getNextPrevEncounter(-1))
	end)
	iEET.prevEncounter:SetScript('OnEnter', function()
		GameTooltip:SetOwner(iEET.prevEncounter, 'ANCHOR_BOTTOMLEFT', 0, 20)
		GameTooltip:SetText(iEET:getTooltipForEncounter(iEET:getNextPrevEncounter(-1)))
	end)
	iEET.prevEncounter:SetScript('OnLeave', function()
		GameTooltip:ClearLines()
		GameTooltip:Hide()
	end)
	iEET.prevEncounter:EnableMouse(true)
	iEET.prevEncounter:Show()
	iEET.prevEncounter:SetFrameStrata('HIGH')
	iEET.prevEncounter:SetFrameLevel(2)
	iEET.prevEncounter.text = iEET.prevEncounter:CreateFontString()
	iEET.prevEncounter.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.prevEncounter.text:SetPoint('CENTER', iEET.prevEncounter, 'CENTER', 0,1)
	iEET.prevEncounter.text:SetText('<')
	iEET.prevEncounter.text:Show()

	-- Next button
	iEET.nextEncounter = CreateFrame('FRAME', nil, iEET.frame)
	iEET.nextEncounter:SetSize(18, 18)
	iEET.nextEncounter:SetPoint('BOTTOMLEFT', iEET.encounterInfo, 'BOTTOMRIGHT', 0, 0)
	iEET.nextEncounter:SetBackdrop(iEET.backdrop);
	iEET.nextEncounter:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.nextEncounter:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.nextEncounter:SetScript('OnMouseDown', function(self,button)
		iEET:ImportData(iEET:getNextPrevEncounter(1))
	end)
	iEET.nextEncounter:SetScript('OnEnter', function()
		GameTooltip:SetOwner(iEET.nextEncounter, 'ANCHOR_BOTTOMRIGHT', 0, 20)
		GameTooltip:SetText(iEET:getTooltipForEncounter(iEET:getNextPrevEncounter(1)))
	end)
	iEET.nextEncounter:SetScript('OnLeave', function()
		GameTooltip:ClearLines()
		GameTooltip:Hide()
	end)
	iEET.nextEncounter:EnableMouse(true)
	iEET.nextEncounter:SetFrameStrata('HIGH')
	iEET.nextEncounter:SetFrameLevel(2)
	iEET.nextEncounter:Show()
	iEET.nextEncounter.text = iEET.nextEncounter:CreateFontString()
	iEET.nextEncounter.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.nextEncounter.text:SetPoint('CENTER', iEET.nextEncounter, 'CENTER', 0,1)
	iEET.nextEncounter.text:SetText('>')
	iEET.nextEncounter.text:Show()
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
		--iEET['content' .. i]:SetClipsChildren(true)
		iEET['content' .. i]:SetInsertMode("BOTTOM")
		iEET['content' .. i]:SetJustifyH(iEET.justifyH)
		iEET['content' .. i]:SetMaxLines(10000)
		iEET['content' .. i]:SetSpacing(iEET.spacing)
		iEET['content' .. i]:EnableMouseWheel(true)
		--iEET['content' .. i]:SetFrameLevel(4)
		iEET['content' .. i]:SetScript("OnMouseWheel", function(self, delta)
			iEET:ScrollContent(delta)
		end)
		if i == 1 or i == 2 or i == 4 or i == 5 or i == 6 then --allow hyperlinks for encounter time, intervall time, spellName, sourceName, destName
			iEET['content' .. i]:SetHyperlinksEnabled(true)
			iEET['content' .. i]:SetScript("OnHyperlinkEnter", function(self, linkData, link)
				GameTooltip:SetOwner(iEET.frame, "ANCHOR_TOPRIGHT", 0-iEET.frame:GetWidth(), 0-iEET.frame:GetHeight())
				iEET:Hyperlinks(linkData, link)
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
		iEET['detailContent' .. i]:SetMaxLines(10000)
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
			end)
			iEET['detailContent' .. i]:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
			end)
		end
		iEET['detailContent' .. i]:EnableMouse(true)
		iEET['detailContent' .. i]:SetFrameStrata('HIGH')
		iEET['detailContent' .. i]:SetFrameLevel(2)
	end
	end
	--SPELL LISTING--
	do
		--Slider
		iEET.mainFrameSlider = CreateFrame('Slider', nil, iEET.frame)
		iEET.mainFrameSlider:SetSize(8,834)
		iEET.mainFrameSlider:SetThumbTexture('Interface\\AddOns\\iTargetingFrames\\media\\thumb')
		iEET.mainFrameSlider:SetBackdrop(bd)
		iEET.mainFrameSlider:SetBackdropColor(0.1,0.1,0.1,0.9)
		iEET.mainFrameSlider:SetBackdropBorderColor(0,0,0,1)
		iEET.mainFrameSlider:SetPoint('BOTTOMLEFT', iEET.frame, 'BOTTOMRIGHT', -1,0)
		iEET.mainFrameSlider:SetMinMaxValues(0, 10)
		iEET.mainFrameSlider:SetValue(0)
		iEET.mainFrameSlider:SetValueStep(1)
		iEET.mainFrameSlider:EnableMouseWheel(true)
		local lastValue = 0
		--iEET.maxScrollRange
		iEET.mainFrameSlider:SetScript('OnMouseDown', function(self, button)
			iEET.mainFrameSlider:SetScript('OnUpdate', function()
				local value = math.floor(self:GetValue())
				if value ~= lastValue then
					iEET:ScrollContent(delta, value)
					lastValue = value
				end
			end)
		end)
		iEET.mainFrameSlider:SetScript('OnMouseUp', function(self, button)
			iEET.mainFrameSlider:SetScript('OnUpdate', nil)
		end)
		iEET.mainFrameSlider:SetScript('OnMouseWheel', function(self, delta)
			iEET:ScrollContent(delta)
		end)
		iEET.mainFrameSliderBG = CreateFrame('FRAME', nil , iEET.frame)
		--iEET.contentAnchor8 = CreateFrame('FRAME', nil , iEET.frame)
		iEET.mainFrameSliderBG:SetSize(8, 834)
		iEET.mainFrameSliderBG:SetPoint('BOTTOMLEFT', iEET.frame, 'BOTTOMRIGHT', -1, 0)
		iEET.mainFrameSliderBG:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
			insets = {
				left = -1,
				right = -1,
				top = -1,
				bottom = -1,
			},
		})
		iEET.mainFrameSliderBG:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
		iEET.mainFrameSliderBG:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)

		iEET.encounterAbilitiesAnchor = CreateFrame('FRAME', nil, iEET.frame)
		iEET.encounterAbilitiesAnchor:SetSize(200, 400)
		--iEET.encounterAbilitiesAnchor:SetPoint('TOPLEFT', iEET.frame, 'TOPRIGHT', -1, 0)
		iEET.encounterAbilitiesAnchor:SetPoint('TOPLEFT', iEET.frame, 'TOPRIGHT', 6, 0)
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
			elseif string.len(txt) > 1 then
				msg = string.lower(txt)
			end
		end
		iEET:loopData(msg)
	end)
	iEET.editbox:SetAutoFocus(false)
	iEET.editbox:SetWidth(269)
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
		iEET[name]:SetFrameLevel(4)
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
	-- Check if fight is already saved, if its enable prev/next buttons, else hide
	if iEET.encounterInfoData then
		if iEET:getNextPrevEncounter(1) then
			iEET.prevEncounter:Show()
			iEET.nextEncounter:Show()
		else
			iEET.prevEncounter:Hide()
			iEET.nextEncounter:Hide()
		end
	else
		iEET.prevEncounter:Hide()
		iEET.nextEncounter:Hide()
	end
	--Contact information on first run
	if iEETConfig.cInfo then
		iEETConfig.cInfo = false
		iEET:print("This is one time only message with authors contact information, feel free to use any of them if you run into any problems.\nBnet:\n    Ironi#2880 (EU)\nDiscord:\n    Ironi#2097\n    https://discord.gg/stY2nyj")
	end
end
function iEET:getNextPrevEncounter(prevNext)
	local encounters = {}
	local currentEncounterString = iEET:getEncounterString()
	if currentEncounterString then
		for key,dataString in pairs(iEET_Data) do
			if key:find('{d='..iEET.encounterInfoData.d..'}') and key:find('{eI='..iEET.encounterInfoData.eI..'}') then
				local year,month,day,hour,mins = key:match('{pT=(%d+).(%d+).(%d+) (%d+):(%d+)}')
				encounters[key] = tonumber(year..month..day..hour..mins)
			end
		end
		local sortedEncounters = {}
		local currentPos
		for key,pullTime in spairs(encounters, function(t,a,b) return t[b] > t[a] end) do -- Sorted by date
			table.insert(sortedEncounters, key)
			if key == currentEncounterString then
				currentPos = #sortedEncounters
			end
		end
		if #sortedEncounters > 1 and currentPos then
			if currentPos + prevNext > #sortedEncounters then -- Return first
				return sortedEncounters[1]
			elseif currentPos + prevNext == 0 then -- Return last
				return sortedEncounters[#sortedEncounters]
			else -- continue
				return sortedEncounters[currentPos+prevNext]
			end
		else
			return false
		end
	else
		return false
	end
end
function iEET:getTooltipForEncounter(key)
	local temp = {}
		for k,v in string.gmatch(key, '{(.-)=(.-)}') do
		temp[k] = v
	end
	return string.format('%s(%s)\n%s%s\n%s', temp.eN,string.sub(GetDifficultyInfo(temp.d),1,1),(temp.k == 1 and '+' or '-'),temp.fT, temp.pT)
end
function iEET:getEncounterString()
	local currentEncounterString = ''
	if iEET.encounterInfoData.eI then
		for k,v in spairs(iEET.encounterInfoData) do
			currentEncounterString = currentEncounterString .. '{' .. k .. '=' .. v .. '}'
		end
		return currentEncounterString
	else
		return false
	end
end
function iEET:massDelete(data)
	local specificEncounter = tonumber(data.encounter)
	--First gather eligible encounters, IF its required
	local encounters = {}
	for key,dataString in pairs(iEET_Data) do
		if specificEncounter then
			if (not data.dif or (data.dif and key:find('{d='..data.dif..'}'))) and key:find('{eI='..specificEncounter..'}') then
				encounters[key] = false
			end
		else
			if not data.dif or (data.dif and key:find('{d='..data.dif..'}')) then
				encounters[key] = false
			end
		end
	end
	if data.del == 'deleteAllWipes' then
		for key,_ in pairs(encounters) do
			if key:find('{k=1}') then
				encounters[key] = true
			end
		end
	elseif tonumber(data.del) then
		for key, _ in pairs(encounters) do
			local ftH, ftM = key:match('{fT=(%d+):(%d+)}')
			if tonumber(ftH)*60+tonumber(ftM) > data.del then -- Save longer than
				encounters[key] = true
			end
		end
	elseif data.del == 'saveLastKill' or data.del == 'saveShortestKill' or tonumber(data.del)then -- need to sort by encounterID
		local encountersByID = {}
		for key, _ in pairs(encounters) do
			if key:find('{k=1}') then
				local eID = key:match('{eI=(%d+)}')
				--if not eID then
				--	iEET:print('found old reports, please use "/ieet convert" to continue')
				--	break
				--end
				if not encountersByID[eID] then
					encountersByID[eID] = {}
				end
				local year,month,day,hour,mins = key:match('{pT=(%d+).(%d+).(%d+) (%d+):(%d+)}')
				local ftH, ftM = key:match('{fT=(%d+):(%d+)}')
				encountersByID[eID][key] = {
					['killDate'] = tonumber(year..month..day..hour..mins),
					['fightTime'] = tonumber(ftH)*60+tonumber(ftM),
				}
			end
		end
		local key = ''
		local compare
		for encounterID, encounterData in pairs(encountersByID) do
			for encounterKey, eData in pairs(encounterData) do
				if data.del == 'saveLastKill' then
					if not compare then
						compare = eData.killDate
						key = encounterKey
					elseif eData.killDate > compare then
						compare = eData.killDate
						key = encounterKey
					end
				else -- Save shortest
					if not compare then
						key = encounterKey
						compare = eData.fightTime
					elseif eData.fightTime < compare then
						key = encounterKey
						compare = eData.fightTime
					end
				end
			end
			if compare then -- Shouldn't be needed, but its there for safety
				encounters[key] = true
				compare = nil
			end
		end
	end
	local counter = 0
	for k,v in pairs(encounters) do
		if not v then
			counter = counter + 1
			iEET_Data[k] = nil
		end
	end
	iEET:print(counter .. ' fights deleted.')
	encounters = nil
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
]]

			for i = 1, #iEET.events.fromID do
				infoText = infoText..string.format('\n%d - %s - %s', i, iEET.events.fromID[i].l, iEET.events.fromID[i].s)
			end
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
function iEET:toggleDeleteOptions()
	if not iEET.deleteOptions then
		--Delete options main frame
			local width = 310
		iEET.deleteOptions = {}
		iEET.deleteOptions.mainFrame = CreateFrame('Frame', 'iEETDeleteFrame', UIParent)
		iEET.deleteOptions.mainFrame:SetSize(width,110)
		iEET.deleteOptions.mainFrame:SetPoint('CENTER', UIParent, 'CENTER', 0,0)
		iEET.deleteOptions.mainFrame:SetBackdrop(iEET.backdrop);
		iEET.deleteOptions.mainFrame:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.mainFrame:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.mainFrame:Show()
		iEET.deleteOptions.mainFrame:SetFrameStrata('DIALOG')
		iEET.deleteOptions.mainFrame:SetFrameLevel(1)
		iEET.deleteOptions.mainFrame:EnableMouse(true)
		iEET.deleteOptions.mainFrame:SetMovable(true)
		-- Options title frame
		iEET.deleteOptions.top = CreateFrame('FRAME', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.top:SetSize(width, 15)
		iEET.deleteOptions.top:SetPoint('BOTTOMRIGHT', iEET.deleteOptions.mainFrame, 'TOPRIGHT', 0, -1)
		iEET.deleteOptions.top:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.top:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.top:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.top:SetScript('OnMouseDown', function(self,button)
			iEET.deleteOptions.mainFrame:ClearAllPoints()
			iEET.deleteOptions.mainFrame:StartMoving()
		end)
		iEET.deleteOptions.top:SetScript('OnMouseUp', function(self, button)
			iEET.deleteOptions.mainFrame:StopMovingOrSizing()
		end)
		iEET.deleteOptions.top:EnableMouse(true)
		iEET.deleteOptions.top:Show()
		iEET.deleteOptions.top:SetFrameStrata('DIALOG')
		iEET.deleteOptions.top:SetFrameLevel(1)
		-- Options title text
		iEET.deleteOptions.top.text = iEET.deleteOptions.top:CreateFontString()
		iEET.deleteOptions.top.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.top.text:SetPoint('CENTER', iEET.deleteOptions.top, 'CENTER', 0,0)
		iEET.deleteOptions.top.text:SetText('Delete options')
		iEET.deleteOptions.top.text:Show()

		iEET.deleteOptions.top.exitButton = CreateFrame('FRAME', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.top.exitButton:SetSize(15, 15)
		iEET.deleteOptions.top.exitButton:SetPoint('TOPRIGHT', iEET.deleteOptions.top, 'TOPRIGHT', 0, 0)
		iEET.deleteOptions.top.exitButton:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.top.exitButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.top.exitButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.top.exitButton:SetScript('OnMouseDown', function(self,button)
			iEET.deleteOptions.mainFrame:Hide()
		end)
		iEET.deleteOptions.top.exitButton:EnableMouse(true)
		iEET.deleteOptions.top.exitButton:Show()
		iEET.deleteOptions.top.exitButton:SetFrameStrata('DIALOG')
		iEET.deleteOptions.top.exitButton:SetFrameLevel(2)
		iEET.deleteOptions.top.exitButton.text = iEET.deleteOptions.top.exitButton:CreateFontString()
		iEET.deleteOptions.top.exitButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.top.exitButton.text:SetPoint('CENTER', iEET.deleteOptions.top.exitButton, 'CENTER', 0,0)
		iEET.deleteOptions.top.exitButton.text:SetText('X')
		iEET.deleteOptions.top.exitButton.text:Show()


		local deleteOptionsVars = {
			dif = false,
			encounter = false,
			del = false,
		}
		local function setErrorText(check)
			if check then
				if deleteOptionsVars.encounter and deleteOptionsVars.del then
					return true
				else
					return false
				end
			end
			local errorText
			if not  deleteOptionsVars.encounter then
				errorText = 'Error: EncounterID has to be number, use "" or "*" to select all encounters.'
			end
			if not deleteOptionsVars.del then
				if errorText then
					errorText = errorText .. '\nError: Choose delete mode.'
				else
					errorText = 'Error: Choose delete mode.'
				end
			end
			if errorText then
				iEET.deleteOptions.errorText:SetText(errorText)
				iEET.deleteOptions.errorText:Show()
			else
				iEET.deleteOptions.errorText:SetText('')
				iEET.deleteOptions.errorText:Hide()
			end
		end
		local function getMenuTable(menuOption)
			local t = {}
			if menuOption == 'dif' then
				local tempKeys = {}
				for keyString, dataString in pairs(iEET_Data) do
					local dif = keyString:match('{d=(%d+)}')
					tempKeys[tonumber(dif)] = true
				end
				for difID, _ in spairs(tempKeys) do
					local difName, groupType = GetDifficultyInfo(difID)
					local temp = {}
					temp.text = string.format('%s (%s)', difName, groupType)
					temp.keepShownOnClick = false
					temp.isNotRadio = true
					temp.notCheckable = true
					temp.func = function()
						deleteOptionsVars.dif = difID
						iEET.deleteOptions.chooseDifficulty.text:SetText(string.format('%s (%s)', difName, groupType))
					end
					table.insert(t, temp)
				end
				table.insert(t, {text = 'Any', func = function()
					deleteOptionsVars.dif = false
					iEET.deleteOptions.chooseDifficulty.text:SetText('Any')
				end, notCheckable = true})
			else
				local opt = {
					[1] = {k = 'deleteAll', v = 'Delete all'},
					[2] = {k = 'saveLastKill', v = 'Save last kill'},
					[3] = {k = 'saveShortestKill', v = 'Save shortest kill'},
					[4] = {k = 'deleteAllWipes', v = 'Delete all wipes'},
					[5] = {k = 60, v = 'Delete under 60sec fights'},
					[6] = {k = 120, v = 'Delete under 120sec fights'},
					[7] = {k = 180, v = 'Delete under 180sec fights'},
					[8] = {k = 240, v = 'Delete under 240sec fights'},
					[9] = {k = 300, v = 'Delete under 300sec fights'},
					[10] = {k = 360, v = 'Delete under 360sec fights'},
					[11] = {k = 420, v = 'Delete under 420sec fights'},
				}
				for _, data in ipairs(opt) do
					local temp = {}
					temp.text = data.v
					temp.keepShownOnClick = false
					temp.isNotRadio = true
					temp.notCheckable = true
					temp.func = function()
						deleteOptionsVars.del = data.k
						iEET.deleteOptions.chooseDeleteMode.text:SetText(data.v)
						setErrorText()
					end
					table.insert(t, temp)
				end
			end
			table.insert(t, {text = 'Close', func = function() CloseDropDownMenus() end, notCheckable = true})
			return t
		end

		iEET.deleteOptions.chooseDifficulty = CreateFrame('button', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.chooseDifficulty:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.chooseDifficulty:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.chooseDifficulty:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.chooseDifficulty:SetSize(100,20)
		iEET.deleteOptions.chooseDifficulty:EnableMouse(true)
		iEET.deleteOptions.chooseDifficulty:SetPoint('TOPLEFT', iEET.deleteOptions.mainFrame, 'TOPLEFT', 3,-18)
		iEET.deleteOptions.chooseDifficulty.text = iEET.deleteOptions.chooseDifficulty:CreateFontString()
		iEET.deleteOptions.chooseDifficulty.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseDifficulty.text:SetPoint('CENTER', iEET.deleteOptions.chooseDifficulty, 'CENTER', 0,0)
		iEET.deleteOptions.chooseDifficulty.text:SetWidth(100)
		iEET.deleteOptions.chooseDifficulty.text:SetHeight(20)
		iEET.deleteOptions.chooseDifficulty.text:SetText('Any')
		iEET.deleteOptions.chooseDifficulty.title = iEET.deleteOptions.chooseDifficulty:CreateFontString()
		iEET.deleteOptions.chooseDifficulty.title:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseDifficulty.title:SetPoint('BOTTOM', iEET.deleteOptions.chooseDifficulty, 'TOP', 0,3)
		iEET.deleteOptions.chooseDifficulty.title:SetText('Difficulty')
		iEET.deleteOptions.chooseDifficulty.menu = CreateFrame('Frame', 'iEET_Delete_ChooseDifficulty', iEET.deleteOptions.mainFrame, 'UIDropDownMenuTemplate')
		iEET.deleteOptions.chooseDifficulty:SetScript('OnClick',function()
			if UIDROPDOWNMENU_OPEN_MENU then
				CloseDropDownMenus()
				return
			end
			EasyMenu(getMenuTable('dif'), iEET.deleteOptions.chooseDifficulty.menu, iEET.deleteOptions.chooseDifficulty, 0 , 0)
		end)
		iEET.deleteOptions.chooseEncounter = CreateFrame('editbox', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.chooseEncounter:SetSize(100,20)
		iEET.deleteOptions.chooseEncounter:SetAutoFocus(false)
		iEET.deleteOptions.chooseEncounter:SetTextInsets(2, 2, 1, 0)
		iEET.deleteOptions.chooseEncounter:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseEncounter:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.chooseEncounter:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.chooseEncounter:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.chooseEncounter:SetPoint('TOP', iEET.deleteOptions.mainFrame, 'TOP', 0,-18)
		iEET.deleteOptions.chooseEncounter:SetScript('OnTextChanged', function(self)
			local text = self:GetText()
			if tonumber(text) then
				deleteOptionsVars.encounter = tonumber(text)
				setErrorText()
			elseif text == '*' or text == '' then
				deleteOptionsVars.encounter = true
				setErrorText()
			else
				deleteOptionsVars.encounter = false
				setErrorText()
			end
		end)
		iEET.deleteOptions.chooseEncounter:SetScript('OnEnterPressed', function(self)
			self:ClearFocus()
		end)
		iEET.deleteOptions.chooseEncounter:SetText('*')
		iEET.deleteOptions.chooseEncounter.text = iEET.deleteOptions.chooseEncounter:CreateFontString()
		iEET.deleteOptions.chooseEncounter.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseEncounter.text:SetPoint('BOTTOM', iEET.deleteOptions.chooseEncounter, 'TOP', 0,3)
		iEET.deleteOptions.chooseEncounter.text:SetText('Encounter ID')

		iEET.deleteOptions.chooseDeleteMode = CreateFrame('button', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.chooseDeleteMode:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.chooseDeleteMode:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.chooseDeleteMode:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.chooseDeleteMode:SetSize(100,20)
		iEET.deleteOptions.chooseDeleteMode:EnableMouse(true)
		iEET.deleteOptions.chooseDeleteMode:SetPoint('TOPRIGHT', iEET.deleteOptions.mainFrame, 'TOPRIGHT', -3,-18)
		iEET.deleteOptions.chooseDeleteMode.text = iEET.deleteOptions.chooseDeleteMode:CreateFontString()
		iEET.deleteOptions.chooseDeleteMode.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseDeleteMode.text:SetPoint('CENTER', iEET.deleteOptions.chooseDeleteMode, 'CENTER', 0,0)
		iEET.deleteOptions.chooseDeleteMode.text:SetWidth(100)
		iEET.deleteOptions.chooseDeleteMode.text:SetHeight(20)
		iEET.deleteOptions.chooseDeleteMode.text:SetText('Choose')
		iEET.deleteOptions.chooseDeleteMode.title = iEET.deleteOptions.chooseDeleteMode:CreateFontString()
		iEET.deleteOptions.chooseDeleteMode.title:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseDeleteMode.title:SetPoint('BOTTOM', iEET.deleteOptions.chooseDeleteMode, 'TOP', 0,3)
		iEET.deleteOptions.chooseDeleteMode.title:SetText('Delete option')
		iEET.deleteOptions.chooseDeleteMode.menu = CreateFrame('Frame', 'iEET_Delete_DeleteOption', iEET.deleteOptions.mainFrame, 'UIDropDownMenuTemplate')
		iEET.deleteOptions.chooseDeleteMode:SetScript('OnClick',function()
			if UIDROPDOWNMENU_OPEN_MENU then
				CloseDropDownMenus()
				return
			end
			EasyMenu(getMenuTable(), iEET.deleteOptions.chooseDeleteMode.menu, iEET.deleteOptions.chooseDeleteMode, 0 , 0)
		end)

		iEET.deleteOptions.deleteButton = CreateFrame('FRAME', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.deleteButton:SetSize(width-6, 25)
		iEET.deleteOptions.deleteButton:SetPoint('BOTTOM', iEET.deleteOptions.mainFrame, 'BOTTOM', 0, 3)
		iEET.deleteOptions.deleteButton:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.deleteButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.deleteButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.deleteButton:SetScript('OnMouseDown', function(self,button)
			if setErrorText(true) then
				iEET:massDelete(deleteOptionsVars)
			end
		end)
		iEET.deleteOptions.deleteButton:EnableMouse(true)
		iEET.deleteOptions.deleteButton:Show()
		iEET.deleteOptions.deleteButton:SetFrameStrata('DIALOG')
		iEET.deleteOptions.deleteButton:SetFrameLevel(2)
		iEET.deleteOptions.deleteButton.text = iEET.deleteOptions.deleteButton:CreateFontString()
		iEET.deleteOptions.deleteButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.deleteButton.text:SetPoint('CENTER', iEET.deleteOptions.deleteButton, 'CENTER', 0,0)
		iEET.deleteOptions.deleteButton.text:SetText('Delete')
		iEET.deleteOptions.deleteButton.text:Show()

		iEET.deleteOptions.errorText = iEET.deleteOptions.mainFrame:CreateFontString()
		iEET.deleteOptions.errorText:SetFont(iEET.font, iEET.fontsize+2, 'OUTLINE')
		iEET.deleteOptions.errorText:SetPoint('BOTTOM', iEET.deleteOptions.deleteButton, 'TOP', 0,3)
		iEET.deleteOptions.errorText:SetPoint('TOP', iEET.deleteOptions.chooseEncounter, 'BOTTOM', 0,-3)
		iEET.deleteOptions.errorText:SetWidth(width-20)
		iEET.deleteOptions.errorText:SetJustifyV('MIDDLE')
		iEET.deleteOptions.errorText:SetText('')
		iEET.deleteOptions.errorText:SetTextColor(1,0,0,1)
	elseif iEET.deleteOptions.mainFrame:IsShown() then
		iEET.deleteOptions.mainFrame:Hide()
	else
		iEET.deleteOptions.mainFrame:Show()
	end
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
			for key, _ in pairs(iEET_Data) do
				if not key:find('{eI=(%d+)}') then
					iEET:ConvertOldReports()
					break
				end
			end
			iEET:CreateMainFrame()
		elseif iEET.frame:IsShown() and not show then
			iEET.frame:Hide()
		else
			iEET.frame:Show()
			iEET:updateEncounterListMenu()
			-- Check if fight is already saved, if its enable prev/next buttons, else hide
			if iEET.encounterInfoData then
				if iEET:getNextPrevEncounter(1) then
					iEET.prevEncounter:Show()
					iEET.nextEncounter:Show()
				else
					iEET.prevEncounter:Hide()
					iEET.nextEncounter:Hide()
				end
			else
				iEET.prevEncounter:Hide()
				iEET.nextEncounter:Hide()
			end
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
		for k,v in spairs(iEET.encounterInfoData) do
			encounterString = encounterString .. '{' .. k .. '=' .. v .. '}'
		end
		local dataString = ''
		for k,v in ipairs(iEET.data) do
			local t = ''
			for a,b in pairs(v) do
				if type(b) == 'boolean' then
					print(a)
				end
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
function iEET:ImportData(dataKey, prevNext)
	iEET.data = {}
	iEET.encounterInfoData = {}
	for eK,eV in string.gmatch(dataKey, '{(.-)=(.-)}') do
		if eK == 'd' or eK == 'rS' or eK == 's' or eK == 'k' or eK == 'v' or eK == 'zI' or eK == 'eI' then
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
	local msg
	if iEET.editbox:GetText() ~= 'Search' then
		local txt = iEET.editbox:GetText()
		if string.len(txt) > 1 then
			msg = string.lower(txt)
		end
	end
	iEET:loopData(msg)
	iEET:print(string.format('Imported %s on %s (%s), %sman (%s), Time: %s.',iEET.encounterInfoData.eN,GetDifficultyInfo(iEET.encounterInfoData.d),iEET.encounterInfoData.fT, iEET.encounterInfoData.rS, (iEET.encounterInfoData.k == 1 and 'kill' or 'wipe'), iEET.encounterInfoData.pT))
end
function iEET:ConvertOldReports() -- XXX remove at some point
	-- assuming no one uses these logs anymore
	--[[
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
	]]
	local function getEncounterStartData(data)
		for v in string.gmatch(data, 'D|(.-)|D') do
			local targetData
			local eventData
			for dK,dV in string.gmatch(v, '{(.-)=(.-)}') do
				if dK == 'e' then
					if tonumber(dV) == 27 then
						eventData = tonumber(dV)
					end
				elseif dK == 'tN' then
					targetData = dV
				end
				if targetData and eventData then
					return targetData
				end
			end
		end
		return 0
	end
	local newDataTable = {}
	local count = 0
	for key, dataString in pairs(iEET_Data) do
		if not key:find('eI=') then
			--convert string to table; sort it; convert it back to string
			local temp = {}
			for k,v in string.gmatch(key, '{(.-)=(.-)}') do
				temp[k] = v
			end
			-- add encounterID
			temp.eI = getEncounterStartData(dataString)
			-- convert back to string in right order
			local encounterString = ''
			for k,v in spairs(temp) do
				encounterString = encounterString .. '{' .. k .. '=' .. v .. '}'
			end
			newDataTable[encounterString] = dataString
			count = count + 1
		else
			newDataTable[key] = dataString
		end
	end
	iEET_Data = newDataTable
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
	iEET:BWRecording(true)
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
	addon:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE')
	addon:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE')
	addon:RegisterEvent('RAID_BOSS_EMOTE')
	addon:RegisterEvent('RAID_BOSS_WHISPER')
	addon:RegisterEvent('CHAT_MSG_RAID_BOSS_EMOTE')
	addon:RegisterEvent('CHAT_MSG_RAID_BOSS_WHISPER')
	if force then
		addon:RegisterEvent('PLAYER_REGEN_DISABLED')
		addon:RegisterEvent('PLAYER_REGEN_ENABLED')
	end
end
function iEET:StopRecording(force)
	iEET:BWRecording()
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
	addon:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE')
	addon:UnregisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE')
	addon:UnregisterEvent('RAID_BOSS_EMOTE')
	addon:UnregisterEvent('RAID_BOSS_WHISPER')
	addon:UnregisterEvent('CHAT_MSG_RAID_BOSS_EMOTE')
	addon:UnregisterEvent('CHAT_MSG_RAID_BOSS_WHISPER')
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
			['eI'] = 0,
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
			['eI'] = 0,
			}
		end
		iEET:print(string.format('Stopped recording: %s (%s)', iEET.encounterInfoData.eN, iEET.encounterInfoData.fT))
		iEET:StopRecording(true)
	end
end
function iEET:ExportFightsToWTF()
	iEET_ExportFromWTF = {}
	local fightCount = 0
	for k,v in pairs(iEET_Data) do -- Get encounters
		local temp = {}
		for eK,eV in string.gmatch(k, '{(.-)=(.-)}') do
			if eK == 'd' or eK == 'rS' or eK == 's' or eK == 'k' or eK == 'v' or eK == 'zI' or eK == 'eI' then
				if tonumber(eV) then
					eV = tonumber(eV)
				end
			end
			temp[eK] = eV
		end
		local dif = GetDifficultyInfo(temp.d) or 1
		local zone = ''
		if temp.zI then
			zone = GetRealZoneText(temp.zI)
		else
			zone = UNKNOWN
		end
		local str = string.format('%s (%s)', zone, dif)
		if not iEET_ExportFromWTF[str] then
			iEET_ExportFromWTF[str] = {}
		end
		if not iEET_ExportFromWTF[str][temp.eN] then
			iEET_ExportFromWTF[str][temp.eN] = {}
		end
		iEET_ExportFromWTF[str][temp.eN][k] = v
		fightCount = fightCount + 1
	end
	iEET:print(fightCount .. ' fights sorted into "iEET_ExportFromWTF".\nYou can copy it after reloading UI or logging out.')
end
SLASH_IEET1 = "/ieet"
SLASH_IEET2 = '/iencountereventtracker'
SlashCmdList["IEET"] = function(realMsg)
	local msg = realMsg
	if msg then msg = string.lower(msg) end
	if msg:len() <= 1 then
		iEET:Toggle()
	elseif msg == 'copy' then
		iEET:copyCurrent()
	elseif msg == 'filters' then
		iEET:Options()
	elseif msg == 'export' and not InCombatLockdown() then
		iEET:ExportData()
	elseif msg == 'clearwtf' then
		iEET_ExportFromWTF = {}
		iEET:print('Export variable cleared.')
	elseif msg == 'clear' then
		iEET_Data = nil
		iEET_Data = {}
		iEET:print('iEET_Data wiped.')
	elseif msg == 'autosave' then
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
	elseif msg == 'help' then
		iEET:print('/ieet autosave to toggle autosaving\r/ieet autodiscard X to change auto discard timer\r/ieet clear to delete every fight entry')
	elseif msg == 'convert' then
		iEET:ConvertOldReports()
	elseif msg == 'colorreset' then
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
	elseif msg == 'force' then
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
	elseif msg == 'version' then
		iEET:print(iEETConfig.version)
	elseif msg == 'wtf' then
		iEET:ExportFightsToWTF()
	elseif msg == 'contact' then
		iEET:print("\nBnet:\n    Ironi#2880 (EU)\nDiscord:\n    Ironi#2097\n    https://discord.gg/stY2nyj")
	elseif msg == 'users' then
		iEET.addonUsers = {}
		local chatType
		if IsInRaid() then
			chatType = 'RAID'
		elseif IsInGroup() then
			chatType = 'PARTY'
		else
			chatType = 'GUILD'
			iEET:print('You are not in raid group or in a party, checking users in guild.')
		end
		SendAddonMessage('iEET', 'userCheck', chatType)
		C_Timer.After(1, function()
			local str
			for k,v in pairs(iEET.addonUsers) do
				local char, server = k:match('(%a-)-(%a+)')
				if server ~= GetRealmName() then
					char = k
				end
				if not str then
					str = string.format('%s%s\124r(%s)', (v.autoSave == '1' and '\124cff00ff00' or '\124cffff1a1a'), char, v.version)
				else
					str = str .. string.format(', %s%s\124r(%s)', (v.autoSave == '1' and '\124cff00ff00' or '\124cffff1a1a'), char, v.version)
				end
			end
			iEET:print('\n' .. str)
		end)
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
function iEET_Advanced_Delete(dif, encounter, fightTime) -- Usage: iEET_Advanced_Delete(<difficulty, number, or false for any difficulty>, <encounterID(number) or true, <fight time (delete under), number, seconds>)
	--example: iEET_Advanced_Delete(false, true, 60), would delete any fights under 60 seconds
	if encounter and fightTime then
		iEET:massDelete({['dif'] = dif, ['encounter'] = encounter, ['del'] = fightTime})
	end
end
