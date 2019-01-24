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
iEET.version = 1.800
local colors = {}

iEET.auraEvents = {
	['SPELL_AURA_APPLIED'] = true,
	['SPELL_AURA_REMOVED'] = true,
	['SPELL_AURA_APPLIED_DOSE'] = true,
	['SPELL_AURA_REMOVED_DOSE'] = true,
	['SPELL_AURA_REFRESH'] = true,
}

iEET.IEEUnits = {}
iEET.unitPowerUnits = {}
iEET.encounterShortList = {}
iEET.maxScrollRange = 0
iEET.fakeSpells = {
	InterruptShield = {
		name = Spell:CreateFromSpellID(140021):GetSpellName(),
		spellID = 140021, -- Interrupt Shield
	},
	UnitTargetChanged = {
		name = Spell:CreateFromSpellID(103528):GetSpellName(),
		spellID = 103528, -- Target Selection
	},
	PowerUpdate = {
		name = Spell:CreateFromSpellID(143409):GetSpellName(),
		spellID = 143409, -- Power Regen
	},
	Death = {
		name = Spell:CreateFromSpellID(98391):GetSpellName(),
		spellID = 98391, -- Death
	},
	SpawnNPCs = {
		name = "Spawn NPCs",
		spellID = 133217, -- Spawn Boss Emote
	},
}
iEET.ignoreList = {  -- Ignore list for 'Ignore Spell's menu, use event ignore to hide these if you want (they are fake spells)
	[98391] = true, -- Death
	[103528] = true, -- Target Selection
	[133217] = true, -- Spawn NPCs
	[143409] = true, -- Power Update
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

		['UNIT_POWER_UPDATE'] = 34,

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
			l = 'UNIT_POWER_UPDATE',
			s = 'UNIT_POWER_U',
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
iEET.spairs = spairs
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
function iEET:shouldTrack(event, unitType, npcID, spellID, sourceGUID, hideCaster)
	if iEET.ignoreFilters then return true end
	if (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and (iEET.approvedSpells[spellID] or iEET.taunts[spellID] or iEETConfig.CustomWhitelist[spellID])) or not sourceGUID or hideCaster or event == 'SPELL_INTERRUPT' or event == 'SPELL_DISPEL' then
		if (spellID and not iEET.ignoredSpells[spellID]) then
			if not iEET.npcIgnoreList[tonumber(npcID)] then
				return true
			end
		end
	end
end
function iEET:LoadDefaults()
	local defaults = {
		['tracking'] = {
			--[[
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

			['UNIT_POWER_UPDATE'] = true,

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
			--]]
			[1] = true, -- SPELL_CAST_START
			[2] = true, -- SPELL_CAST_SUCCESS
			[3] = true, -- SPELL_AURA_APPLIED
			[4] = true, -- SPELL_AURA_REMOVED
			[5] = true, -- SPELL_AURA_APPLIED_DOSE
			[6] = true, -- SPELL_AURA_REMOVED_DOSE
			[7] = true, -- SPELL_AURA_REFRESH
			[8] = true, -- SPELL_CAST_FAILED
			[9] = true, -- SPELL_CREATE
			[10] = true, -- SPELL_SUMMON
			[11] = true, -- SPELL_HEAL
			[12] = true, -- SPELL_DISPEL
			[13] = true, -- SPELL_INTERRUPT

			[14] = true, -- SPELL_PERIODIC_CAST_START
			[15] = true, -- SPELL_PERIODIC_CAST_SUCCESS
			[16] = true, -- SPELL_PERIODIC_AURA_APPLIED
			[17] = true, -- SPELL_PERIODIC_AURA_REMOVED
			[18] = true, -- SPELL_PERIODIC_AURA_APPLIED_DOSE
			[19] = true, -- SPELL_PERIODIC_AURA_REMOVED_DOSE
			[20] = true, -- SPELL_PERIODIC_AURA_REFRESH
			[21] = true, -- SPELL_PERIODIC_CAST_FAILED
			[22] = true, -- SPELL_PERIODIC_CREATE
			[23] = true, -- SPELL_PERIODIC_SUMMON
			[24] = true, -- SPELL_PERIODIC_HEAL

			[25] = true, -- UNIT_DIED

			[26] = true, -- UNIT_SPELLCAST_SUCCEEDED
			[39] = true, -- UNIT_SPELLCAST_START
			[40] = true, -- UNIT_SPELLCAST_CHANNEL_START
			[41] = true, -- UNIT_SPELLCAST_INTERRUPTIBLE
			[42] = true, -- UNIT_SPELLCAST_NOT_INTERRUPTIBLE

			[29] = true, -- MONSTER_EMOTE
			[30] = true, -- MONSTER_SAY
			[31] = true, -- MONSTER_YELL

			[27] = true, -- ENCOUNTER_START
			[28] = true, -- ENCOUNTER_END

			[32] = true, -- UNIT_TARGET
			[33] = true, -- INSTANCE_ENCOUNTER_ENGAGE_UNIT

			[34] = true, -- UNIT_POWER_UPDATE

			[35] = true, -- PLAYER_REGEN_DISABLED
			[36] = true, -- PLAYER_REGEN_ENABLED

			[37] = true, -- MANUAL_LOGGING_START
			[38] = true, -- MANUAL_LOGGING_END

			[43] = true, -- RAID_BOSS_EMOTE
			[44] = true, -- RAID_BOSS_WHISPER

			[45] = true, -- CHAT_MSG_RAID_BOSS_EMOTE
			[46] = true, -- CHAT_MSG_RAID_BOSS_WHISPER

			[47] = true, -- BigWigs_BarCreated
			[48] = true, -- BigWigs_Message
			[49] = true, -- BigWigs_PauseBar
			[50] = true, -- BigWigs_ResumeBar
			[51] = true, -- BigWigs_StopBar
			[52] = true, -- BigWigs_StopBars
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
			['onscreen'] = {
				['bg'] = {['r'] = 0.1, ['g'] = 0.1, ['b'] = 0.1, ['a'] = 0.7},
				['border'] = {['r'] = 0.64, ['g'] = 0, ['b'] = 0, ['a'] = 1},
			},
		},
		['onscreen'] = {
			['enabled'] = false,
			['lines'] = 20,
			['historySize'] = 1000,
			['position'] = {
				['from'] = 'TOPRIGHT',
				['to'] = 'TOPRIGHT',
				['x'] = 0,
				['y'] = 0,
			},
			['ignoredEvents'] = {},
		},
		['classColors'] = false,
		['cInfo'] = true,
		['CustomWhitelist'] = {},
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
function iEET:print(msg)
	print('iEET: ', msg)
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
	(not iEETConfig.tracking[eventData.e]) or
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
		iEET.detailInfo:SetText(iEET.events.fromID[eventToFind].s ..':'..Spell:CreateFromSpellID(spellIDToFind):GetSpellName())
		spellIDToFind = 'spell:'..spellIDToFind
	else
		iEET.detailInfo:SetText((eventToFind and iEET.events.fromID[eventToFind].s .. ':' or '') .. hyperlink)
	end
	if linkType == 'iEETcustomspell' then
		spellIDToFind = tonumber(spellIDToFind)
	end
	local starttime = 0
	local intervals = {}
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
				if v.sI and v.sI == iEET.fakeSpells.SpawnNPCs.spellID then -- Spawn NPCs
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
				local interval = false
				local timestamp = v.t-starttime or nil
				local count = nil
				if v.sG then
					if intervals[v.sG] then
						if intervals[v.sG][v.e] then
							if intervals[v.sG][v.e][v.sI] then
								interval = timestamp - intervals[v.sG][v.e][v.sI]
								intervals[v.sG][v.e][v.sI] = timestamp
							else
								intervals[v.sG][v.e][v.sI] = timestamp
							end
						else
							intervals[v.sG][v.e] = {
									[v.sI] = timestamp,
							};
						end
					else
						intervals[v.sG] = {
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
				iEET:addMessages(2, 2, interval, color, interval and ('\124HiEETtime:' .. interval ..'\124h%s\124h') or nil)
				iEET:addMessages(2, 3, iEET.events.fromID[v.e].s, color)
				iEET:addMessages(2, 5, v.cN, color, hyperlinkToShow)
				iEET:addMessages(2, 6, v.tN, color)
				iEET:addMessages(2, 7, count, color)
			end
		end
	end
end
function iEET:addToContent(timestamp,event,casterName,targetName,spellName,spellID,interval,count,sourceGUID, hp, extraData, destGUID, realTimeStamp)
	local color = iEET:getColor(event, sourceGUID, spellID)
	iEET:addMessages(1, 1, timestamp, color, '\124HiEETTotaltime:' .. timestamp..':'..realTimeStamp..'\124h%s\124h')
	iEET:addMessages(1, 2, interval, color, interval and ('\124HiEETtime:' .. interval ..'\124h%s\124h') or nil)
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
				local sN = Spell:CreateFromSpellID(sID):GetSpellName() or 'Message'
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
					sn = Spell:CreateFromSpellID(spellID):GetSpellName()
					if not sn then -- PTR nil check
						sn = spellID
					end
				else -- Encounter journal section ID
					sn = C_EncounterJournal.GetSectionInfo(-spellID)
					if sn then
						sn = sn.title
					else -- PTR nil check
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
		if spellID == iEET.fakeSpells.SpawnNPCs.spellID then -- INSTANCE_ENCOUNTER_ENGAGE_UNIT
			iEET:addMessages(1, 4, spellName, color,'\124HiEETNpcList:' .. sourceGUID .. '\124h%s\124h')
		elseif event and event == 34 then -- UNIT_POWER
			iEET:addMessages(1, 4, spellName, color,'\124HiEETList:' .. (extraData and string.gsub(extraData, '%%', '%%%%') or 'Empty List;Contact Ironi') .. '\124h%s\124h')
		else
			local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
			if sourceGUID then
				if string.find(sourceGUID, 'boss') then
					npcID = sourceGUID
				else
					unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
				end
			else
				npcID = 'NONE'
			end
			--iEET.content4:AddMessage('\124HiEETcustomspell:' .. event .. ':' .. spellID .. ':' .. spellName .. ':' .. (npcID and npcID or 'NONE').. '!' .. (spawnID and spawnID or '') ..'\124h' .. spellnametoShow .. '\124h', unpack(iEET:getColor(event, sourceGUID, spellID))) -- NEEDS CHANGING
			iEET:addMessages(1, 4, spellName, color, '\124HiEETcustomspell:' .. event ..
				':' .. spellID .. ':' .. string.gsub(spellName, '%%', '%%%%') ..
				':' .. (npcID and (npcID .. (spawnID and ('!' .. spawnID) or '')) or 'NONE')
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

		if spellID == iEET.fakeSpells.UnitTargetChanged.spellID or spellID == iEET.fakeSpells.SpawnNPCs.spellID or spellID == iEET.fakeSpells.Death.spellID or spellID == iEET.fakeSpells.PowerUpdate.spellID then -- Target Selection, Spawn Boss Emote(Spawn NPCs), Death, Power Regen
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
	elseif placeToAdd == 3 then
		frame = iEET['onscreenContent' .. frameID]
	end
	if frameID == 1 or frameID == 2 then -- time from encounter_start, interval
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
		if value and string.len(value) > 20 then
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
		iEET.encounterInfo.text:SetText(string.format('%s(%s) %s %s, %s by %s', iEET.encounterInfoData.eN,string.sub(GetDifficultyInfo(iEET.encounterInfoData.d),1,1),(iEET.encounterInfoData.k == 1 and '+' or '-'),iEET.encounterInfoData.fT, iEET.encounterInfoData.pT, iEET.encounterInfoData.lN or UNKNOWN))
	end
	local starttime = 0
	local intervals = {}
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
				if v.sI == iEET.fakeSpells.PowerUpdate.spellID then -- Power Update
					iEET.collector.encounterSpells[v.sI] = 'Power Update'
					iEET:addToEncounterAbilities(v.sI, 'Power Update')
				else -- ignore fake spells
					iEET.collector.encounterSpells[v.sI] = v.sN
					iEET:addToEncounterAbilities(v.sI, v.sN)
				end
			end
		end
		if iEET:ShouldShow(v,starttime, msg) then
			local interval = nil
			local timestamp = v.t-starttime or nil
			local count = nil
			if v.sG then
				if intervals[v.sG] then
					if intervals[v.sG][v.e] then
						if intervals[v.sG][v.e][v.sI] then
							interval = timestamp - intervals[v.sG][v.e][v.sI]
							intervals[v.sG][v.e][v.sI] = timestamp
						else
							intervals[v.sG][v.e][v.sI] = timestamp
						end
					else
						intervals[v.sG][v.e] = {
								[v.sI] = timestamp,
						};
					end
				else
					intervals[v.sG] = {
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
			if iEETConfig.tracking[v.e] or v.e == 27 or v.e == 28 then -- ENCOUNTER_START & ENCOUNTER_END
				iEET:addToContent(timestamp,v.e,v.cN,v.tN,v.sN,v.sI,interval,count,v.sG,v.hp,v.eD, v.dG, v.t)
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
		if tonumber(sid) and C_Spell.DoesSpellExist(siD) then -- PTR/LIVE nil check
			Spell:CreateFromSpellID(siD):ContinueOnSpellLoad(function()
				local spellInfo = GetSpellDescription(sID)
				text = text..'\n\n'..spellInfo
				GameTooltip:AddLine(text, nil,nil,nil,true) -- Force wrapping
			end)
		else
			GameTooltip:AddLine(text, nil,nil,nil,true) -- Force wrapping
		end
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
	elseif linkType == 'iEETTotaltime' then
		local _, txt, realTimeStamp = strsplit(':',linkData)
		local ntxt = tonumber(txt)
		local m = math.floor(ntxt/60)
		local s = ntxt%60
		local ms = (s-math.floor(s))*1000
		GameTooltip:SetText(string.format('%s\n%02d:%02d.%03d\n%s',txt,m,s,ms, realTimeStamp))
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
	return string.format('%s(%s)\n%s%s\n%s\nBy %s', temp.eN,string.sub(GetDifficultyInfo(temp.d),1,1),(temp.k == 1 and '+' or '-'),temp.fT, temp.pT, temp.lN or UNKNOWN)
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
		local fights = {}
		--local encountersByID = {}
		for key, _ in pairs(encounters) do
			if key:find('{k=1}') then
				local eID = key:match('{eI=(%d+)}')
				local dif = key:match('{d=(%d+)}')
				if not fights[dif] then
					fights[dif] = {}
				end
				if not fights[dif][eID] then
					fights[dif][eID] = {}
				end
				local year,month,day,hour,mins = key:match('{pT=(%d+).(%d+).(%d+) (%d+):(%d+)}')
				local ftH, ftM = key:match('{fT=(%d+):(%d+)}')
				fights[dif][eID][key] = {
					['killDate'] = tonumber(year..month..day..hour..mins),
					['fightTime'] = tonumber(ftH)*60+tonumber(ftM),
				}
			end
		end
		for raidDifficulty, encountersByID in pairs(fights) do
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
							s = '=HYPERLINK("http://bfa.wowhead.com/spell=%s", "%s")'
						elseif formatStyle == 2 then -- Openoffice Math
							s = '=HYPERLINK("http://bfa.wowhead.com/spell=%s"; "%s")'
						elseif formatStyle == 3 then -- Excel
							s = '=HYPERLINK("http://bfa.wowhead.com/spell=%s", "%s")'
						end
						--add ExtraData to 9th column
						--lineData = lineData .. string.format('=HYPERLINK("http://bfa.wowhead.com/spell=%s", "%s")', spellID, spellName) .. '\t'
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
		iEET:print((iEET.encounterInfoData.eN and iEET.encounterInfoData.eN or UNKNOWN).." exported."..(auto and ' (autosave)' or ''))
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
	iEET:print(string.format('Imported %s on %s (%s), %sman (%s), Time: %s, Logger: %s.',iEET.encounterInfoData.eN,GetDifficultyInfo(iEET.encounterInfoData.d),iEET.encounterInfoData.fT, iEET.encounterInfoData.rS, (iEET.encounterInfoData.k == 1 and 'kill' or 'wipe'), iEET.encounterInfoData.pT, iEET.encounterInfoData.lN or UNKNOWN))
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
		iEET:print("\nBnet:\n    Ironi#2880 (EU)\nDiscord:\n    Ironi#2880\n    https://discord.gg/stY2nyj")
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
		C_ChatInfo.SendAddonMessage('iEET', 'userCheck', chatType)
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
	elseif msg:match('^whitelist ([-]?%d*)') then
		local spellID = tonumber(msg:match('^whitelist ([-]?%d*)'))
		if spellID < 0 then -- Remove
			spellID = math.abs(spellID)
			if iEETConfig.CustomWhitelist[spellID] then
				iEETConfig.CustomWhitelist[spellID] = nil
				iEET:print('Removed '..spellID..' from whitelist.')
			else
				iEET:print(math.abs(spellID).." Isn't currently whitelisted.")
			end
			return
		end
		iEETConfig.CustomWhitelist[spellID] = Spell:CreateFromSpellID(spellID):GetSpellName() or true -- spellname only works as a comment, doesn't really matter what it is as long as it isn't nil or false
		iEET:print('Added '..spellID..' to the whitelist.')
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
BINDING_NAME_IEET_ONSCREEN = 'Toggle onscreen window'
function IEET_TOGGLE(window)
	if window == 'frame' then
		iEET:Toggle()
	elseif window == 'copy' and not InCombatLockdown() then
		iEET:copyCurrent()
	elseif window == 'export' and not InCombatLockdown() then
		iEET:ExportData()
	elseif window == 'options' and not InCombatLockdown() then
		iEET:Options()
	elseif window == 'onscreen' then
		iEET:ToggleOnscreenDisplay()
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
function iEET_RepositionOnscreenWindow(from, to, x, y)
	iEETConfig.onscreen.position.from = from or iEETConfig.onscreen.position.from
	iEETConfig.onscreen.position.to = to or iEETConfig.onscreen.position.to
	iEETConfig.onscreen.position.x = x or iEETConfig.onscreen.position.x
	iEETConfig.onscreen.position.y = y or iEETConfig.onscreen.position.y
	if iEET.onscreen then
		iEET.onscreen:ClearAllPoints()
		iEET.onscreen:SetPoint(iEETConfig.onscreen.position.from, UIParent, iEETConfig.onscreen.position.to, iEETConfig.onscreen.position.x,iEETConfig.onscreen.position.y)
	end
end
