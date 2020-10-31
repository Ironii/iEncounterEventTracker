local _, iEET = ...
iEET.version = 2.005

iEET.data = {}
local sformat = string.format
local function tcopy(data)
	local t = {}
	for k,v in pairs(data) do
		if type(v) == "table" then
			t[k] = tcopy(v)
		else
			t[k] = v
		end
	end
	return t
end
--local isAlpha = select(4, GetBuildInfo()) >= 70000 and true or false
iEET.ignoring = { -- so ignore list resets on relog, don't want to save it, atleast not yet
	unitIDs = {},
	spellIDs = {},
	specialCategories = {},
	npcNames = {},
}
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
local colors = {}

iEET.auraEvents = {
	['SPELL_AURA_APPLIED'] = true,
	['SPELL_AURA_REMOVED'] = true,
	['SPELL_AURA_APPLIED_DOSE'] = true,
	['SPELL_AURA_REMOVED_DOSE'] = true,
	['SPELL_AURA_REFRESH'] = true,
}
iEET.collapses = {}
for i = 1, 40 do
	iEET.collapses["nameplate"..i] = "nameplates"
	iEET.collapses["raid"..i] = "raid"
	iEET.collapses["raid"..i.."pet"] = "raidpets"
end
iEET.unitPowerUnits = {}
iEET.encounterShortList = {}
iEET.maxScrollRange = 0
iEET.longStrings = {
	['sI'] = "Spell ID",
	['cN'] = "Source name",
	['tN'] = "Target name",
	['sG'] = "Source GUID",
	['tG'] = "Target GUID",
}
iEET.fakeSpells = {
	InterruptShield = {
		name = Spell:CreateFromSpellID(140021):GetSpellName() or "Interrupt Shield",
		spellID = 140021, -- Interrupt Shield
	},
	UnitTargetChanged = {
		name = Spell:CreateFromSpellID(103528):GetSpellName() or "Target Selection",
		spellID = 103528, -- Target Selection
	},
	PowerUpdate = {
		name = Spell:CreateFromSpellID(143409):GetSpellName() or "Power Regen",
		spellID = 143409, -- Power Regen
	},
	Death = {
		name = Spell:CreateFromSpellID(98391):GetSpellName() or "Death",
		spellID = 98391, -- Death
	},
	SpawnNPCs = {
		name = "Spawn NPCs",
		spellID = 133217, -- Spawn Boss Emote
	},
	VehicleEntering = {
		name = Spell:CreateFromSpellID(83912):GetSpellName() or "Entering Aura",
		spellID = 83912, -- Entering Aura
	},
	VehicleEntered = {
		name = Spell:CreateFromSpellID(106322):GetSpellName() or "Player Enter Vehicle",
		spellID = 106322, -- Player Enter Vehicle
	},
	VehicleExiting = {
		name = Spell:CreateFromSpellID(83913):GetSpellName() or "Leaving Aura",
		spellID = 83913, -- Leaving Aura
	},
	VehicleExited = {
		name = Spell:CreateFromSpellID(110911):GetSpellName() or "Exit Vehicle",
		spellID = 110911, -- Exit Vehicle
	},
	PlayMovie = {
		name = Spell:CreateFromSpellID(231376):GetSpellName() or "Play Movie",
		spellID = 231376, -- Play Movie
	},
	CinematicStart = {
		name = Spell:CreateFromSpellID(291125):GetSpellName() or "Play Cinematic",
		spellID = 291125, -- Play Cinematic
	},
	CinematicStop = {
		name = Spell:CreateFromSpellID(94681):GetSpellName() or "Cancel Cinematic",
		spellID = 94681, -- Play Movie
	},
	StartLogging = {
		name = "Start Logging"
	},
	EndLogging = {
		name = "End Logging",
	},
	AllSpellIDs = {},
}
for k,v in pairs(iEET.fakeSpells) do
	if k ~= "AllSpellIDs" then
		if v.spellID then
			iEET.fakeSpells.AllSpellIDs[v.spellID] = true
		end
	end
end
iEET.ignoreList = {  -- Ignore list for 'Ignore Spell's menu, use event ignore to hide these if you want (they are fake spells)
	[98391] = true, -- Death
	[103528] = true, -- Target Selection
	[133217] = true, -- Spawn NPCs
	[143409] = true, -- Power Update
}
iEET.specialCategories = {
	["Ignore"] = 0,
	["Interrupt"] = 1,
	["PowerUpdate"] = 2,
	["Dispel"] = 3,
	["Death"] = 4,
	["NPCSpawn"] = 5,
	["StartLogging"] = 6,
	["EndLogging"] = 7,
	["Taunt"] = 8,
}
iEET.savedPowers = {}
iEET.events = {
	['toID'] = {
		-- Casts
		['SPELL_CAST_START'] = 1, -- CLEU
		['SPELL_CAST_SUCCESS'] = 2, -- CLEU
		['SPELL_CAST_FAILED'] = 8, -- CLEU
		['UNIT_SPELLCAST_SUCCEEDED'] = 26,
		['UNIT_SPELLCAST_START'] = 39,
		['UNIT_SPELLCAST_STOP'] = 61,
		-- Channels
		['SPELL_PERIODIC_CAST_START'] = 14, -- CLEU
		['SPELL_PERIODIC_CAST_SUCCESS'] = 15, -- CLEU
		['SPELL_PERIODIC_CAST_FAILED'] = 21, -- CLEU
		['UNIT_SPELLCAST_CHANNEL_START'] = 40,
		['UNIT_SPELLCAST_CHANNEL_STOP'] = 60,

		-- Auras
		['SPELL_AURA_APPLIED'] = 3, -- CLEU
		['SPELL_AURA_REMOVED'] = 4, -- CLEU
		['SPELL_AURA_APPLIED_DOSE'] = 5, -- CLEU
		['SPELL_AURA_REMOVED_DOSE'] = 6, -- CLEU
		['SPELL_AURA_REFRESH'] = 7, -- CLEU
		['SPELL_PERIODIC_AURA_APPLIED'] = 16, -- CLEU
		['SPELL_PERIODIC_AURA_REMOVED'] = 17, -- CLEU
		['SPELL_PERIODIC_AURA_APPLIED_DOSE'] = 18, -- CLEU
		['SPELL_PERIODIC_AURA_REMOVED_DOSE'] = 19, -- CLEU
		['SPELL_PERIODIC_AURA_REFRESH'] = 20, -- CLEU
		-- Misc
		['SPELL_HEAL'] = 11, -- CLEU
		['SPELL_DISPEL'] = 12, -- CLEU
		['SPELL_INTERRUPT'] = 13, -- CLEU
		['SPELL_PERIODIC_CREATE'] = 22, -- CLEU
		['SPELL_PERIODIC_SUMMON'] = 23, -- CLEU
		['SPELL_PERIODIC_HEAL'] = 24, -- CLEU
		['SPELL_STOLEN'] = 62, -- CLEU
		['UNIT_DIED'] = 25, -- CLEU
		['ENCOUNTER_START'] = 27,
		['ENCOUNTER_END'] = 28,
		['UNIT_TARGET'] = 32,
		['INSTANCE_ENCOUNTER_ENGAGE_UNIT'] = 33,
		['UNIT_POWER_UPDATE'] = 34,
		['PLAYER_REGEN_DISABLED'] = 35,
		['PLAYER_REGEN_ENABLED'] = 36,
		['UNIT_SPELLCAST_INTERRUPTIBLE'] = 41,
		['UNIT_SPELLCAST_NOT_INTERRUPTIBLE'] = 42,
		['MANUAL_LOGGING_START'] = 37, -- Fake event for manual logging
		['MANUAL_LOGGING_END'] = 38, -- Fake event for manual logging
		['UNIT_ENTERING_VEHICLE'] = 53,
		['UNIT_ENTERED_VEHICLE'] = 54,
		['UNIT_EXITING_VEHICLE'] = 55,
		['UNIT_EXITED_VEHICLE'] = 56,
		['CHAT_MSG_ADDON'] = 63,
		['CUSTOM'] = 64,
		['UPDATE_UI_WIDGET'] = 65,
		-- Cinematic
		['PLAY_MOVIE'] = 57,
		['CINEMATIC_START'] = 58,
		['CINEMATIC_STOP'] = 59,
		-- New mobs
		['SPELL_CREATE'] = 9, -- CLEU
		['SPELL_SUMMON'] = 10, -- CLEU
		-- Chat
		['CHAT_MSG_MONSTER_EMOTE'] = 29,
		['CHAT_MSG_MONSTER_SAY'] = 30,
		['CHAT_MSG_MONSTER_YELL'] = 31,
		['RAID_BOSS_EMOTE'] = 43,
		['RAID_BOSS_WHISPER'] = 44,
		['CHAT_MSG_RAID_BOSS_WHISPER'] = 45,
		['CHAT_MSG_RAID_BOSS_EMOTE'] = 46,
		--Boss mods
		['BigWigs_BarCreated'] = 47,
		['BigWigs_Message'] = 48,
		['BigWigs_PauseBar'] = 49,
		['BigWigs_ResumeBar'] = 50,
		['BigWigs_StopBar'] = 51,
		['BigWigs_StopBars'] = 52,
		['DBM_Announce'] = 66,
		['DBM_Debug'] = 67,
		['DBM_TimerStart'] = 68,
		['DBM_TimerStop'] = 69,
		['DBM_TimerFadeUpdate'] = 70,
		['DBM_TimerUpdate'] = 71,
	},
	['fromID'] = {
		[1] = {
			l = 'SPELL_CAST_START',
			s = 'SC_START',
			c = true,
			t = "cast",
		},
		[2] = {
			l = 'SPELL_CAST_SUCCESS',
			s = 'SC_SUCCESS',
			c = true,
			t = "cast",
		},
		[3] = {
			l = 'SPELL_AURA_APPLIED',
			s = '+SAURA',
			c = true,
			t = "aura",
		},
		[4] = {
			l = 'SPELL_AURA_REMOVED',
			s = '-SAURA',
			c = true,
			t = "aura",
		},
		[5] = {
			l = 'SPELL_AURA_APPLIED_DOSE',
			s = '+SA_DOSE',
			c = true,
			t = "aura",
		},
		[6] = {
			l = 'SPELL_AURA_REMOVED_DOSE',
			s = '-SA_DOSE',
			c = true,
			t = "aura",
		},
		[7] = {
			l = 'SPELL_AURA_REFRESH',
			s = 'SAURA_R',
			c = true,
			t = "aura",
		},
		[8] = {
			l = 'SPELL_CAST_FAILED',
			s = 'SC_FAILED',
			c = true,
			t = "cast"
		},
		[9] = {
			l = 'SPELL_CREATE',
			s = 'SPELL_CREATE',
			c = true,
			t = "cast"
		},
		[10] = {
			l = 'SPELL_SUMMON',
			s = 'SPELL_SUMMON',
			c = true,
			t = "cast"
		},
		[11] = {
			l = 'SPELL_HEAL',
			s = 'SPELL_HEAL',
			c = true,
			t = "heal",
		},
		[12] = {
			l = 'SPELL_DISPEL',
			s = 'SPELL_DISPEL',
			c = true,
			t = "misc"
		},
		[13] = {
			l = 'SPELL_INTERRUPT',
			s = 'S_INTERRUPT',
			c = true,
			t = "misc"
		},
		[14] = {
			l = 'SPELL_PERIODIC_CAST_START',
			s = 'SPC_START',
			c = true,
			t = "channel",
		},
		[15] = {
			l = 'SPELL_PERIODIC_CAST_SUCCESS',
			s = 'SPC_SUCCESS',
			c = true,
			t = "channel",
		},
		[16] = {
			l = 'SPELL_PERIODIC_AURA_APPLIED',
			s = '+SPAURA',
			c = true,
			t = "aura",
		},
		[17] = {
			l = 'SPELL_PERIODIC_AURA_REMOVED',
			s = '-SPAURA',
			c = true,
			t = "aura",
		},
		[18] = {
			l = 'SPELL_PERIODIC_AURA_APPLIED_DOSE',
			s = '+SPA_DOSE',
			c = true,
			t = "aura",
		},
		[19] = {
			l = 'SPELL_PERIODIC_AURA_REMOVED_DOSE',
			s = '-SPA_DOSE',
			c = true,
			t = "aura",
		},
		[20] = {
			l = 'SPELL_PERIODIC_AURA_REFRESH',
			s = 'SPAURA_R',
			c = true,
			t = "aura",
		},
		[21] = {
			l = 'SPELL_PERIODIC_CAST_FAILED',
			s = 'SPC_FAILED',
			c = true,
			t = "channel",
		},
		[22] = {
			l = 'SPELL_PERIODIC_CREATE',
			s = 'SP_CREATE',
			c = true,
			t = "channel",
		},
		[23] = {
			l = 'SPELL_PERIODIC_SUMMON',
			s = 'SP_SUMMON',
			c = true,
			t = "channel",
		},
		[24] = {
			l = 'SPELL_PERIODIC_HEAL',
			s = 'SP_HEAL',
			c = true,
			t = "channel",
		},
		[25] = {
			l = 'UNIT_DIED',
			s = 'UNIT_DIED',
			c = true,
			t = "misc",
		},
		[26] = {
			l = 'UNIT_SPELLCAST_SUCCEEDED',
			s = 'USC_SUCCEEDED',
			t = "cast",
		},
		[27] = {
			l = 'ENCOUNTER_START',
			s = 'ENCOUNTER_START',
			t = "misc",
		},
		[28] = {
			l = 'ENCOUNTER_END',
			s = 'ENCOUNTER_END',
			t = "misc",
		},
		[29] = {
			l = 'CHAT_MSG_MONSTER_EMOTE',
			s = 'MONSTER_EMOTE',
			t = "chat",
		},
		[30] = {
			l = 'CHAT_MSG_MONSTER_SAY',
			s = 'MONSTER_SAY',
			t = "chat",
		},
		[31] = {
			l = 'CHAT_MSG_MONSTER_YELL',
			s = 'MONSTER_YELL',
			t = "chat",
		},
		[32] = {
			l = 'UNIT_TARGET',
			s = 'UNIT_TARGET',
			t = "misc",
		},
		[33] = {
			l = 'INSTANCE_ENCOUNTER_ENGAGE_UNIT',
			s = 'IEEU',
			t = "misc",
		},
		[34] = {
			l = 'UNIT_POWER_UPDATE',
			s = 'UNIT_POWER_U',
			t = "misc",
		},
		[35] = {
			l = 'PLAYER_REGEN_DISABLED',
			s = 'COMBAT_START',
			t = "misc",
		},
		[36] = {
			l = 'PLAYER_REGEN_ENABLED',
			s = 'COMBAT_END',
			t = "misc",
		},
		[37] = {
			l = 'MANUAL_LOGGING_START',
			s = 'MANUAL_START',
			t = "misc",
		},
		[38] = {
			l = 'MANUAL_LOGGING_END',
			s = 'MANUAL_END',
			t = "misc",
		},
		[39] = {
			l = 'UNIT_SPELLCAST_START',
			s = 'USC_START',
			t = "cast",
		},
		[40] = {
			l = 'UNIT_SPELLCAST_CHANNEL_START',
			s = 'USC_C_START',
			t = "channel",
		},
		[41] = {
			l = 'UNIT_SPELLCAST_INTERRUPTIBLE',
			s = 'INTERRUPTIBLE',
			t = "misc",
		},
		[42] = {
			l = 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE',
			s = 'NOT_INTERRUPTIBLE',
			t = "misc",
		},
		[43]= {
			l = 'RAID_BOSS_EMOTE',
			s = 'RB_EMOTE',
			t = "chat",
		},
		[44] = {
			l = 'RAID_BOSS_WHISPER',
			s = 'RB_WHISPER',
			t = "chat",
		},
		[45] = {
			l = 'CHAT_MSG_RAID_BOSS_WHISPER',
			s = 'CMRB_WHISPER',
			t = "chat",
		},
		[46] = {
			l = 'CHAT_MSG_RAID_BOSS_EMOTE',
			s = 'CMRB_EMOTE',
			t = "chat",
		},
		[47] = {
			l = 'BigWigs_BarCreated',
			s = 'BW_BarCreated',
			t = "bigwigs",
		},
		[48] = {
			l = 'BigWigs_Message',
			s = 'BW_Message',
			t = "bigwigs",
		},
		[49] = {
			l = 'BigWigs_PauseBar',
			s = 'BW_PauseBar',
			t = "bigwigs",
		},
		[50] = {
			l = 'BigWigs_ResumeBar',
			s = 'BW_ResumeBar',
			t = "bigwigs",
		},
		[51] = {
			l = 'BigWigs_StopBar',
			s = 'BW_StopBar',
			t = "bigwigs",
		},
		[52] = {
			l = 'BigWigs_StopBars',
			s = 'BW_StopBars',
			t = "bigwigs",
		},
		[53] = {
			l = 'UNIT_ENTERING_VEHICLE',
			s =	'U_ENTERING_V',
			t = "misc",
		},
		[54] = {
			l = 'UNIT_ENTERED_VEHICLE',
			s =	'U_ENTERED_V',
			t = "misc",
		},
		[55] = {
			l = 'UNIT_EXITING_VEHICLE',
			s = 'U_EXITING_V',
			t = "misc",
		},
		[56] = {
			l = 'UNIT_EXITED_VEHICLE',
			s = 'U_EXITED_V',
			t = "misc",
		},
		[57] = {
			l = 'PLAY_MOVIE',
			s = 'PLAY_MOVIE',
			t = "misc",
		},
		[58] = {
			l = 'CINEMATIC_START',
			s = 'CINEMATIC_START',
			t = "misc",
		},
		[59] = {
			l = 'CINEMATIC_STOP',
			s = 'CINEMATIC_STOP',
			t = "misc",
		},
		[60] = {
			l = 'UNIT_SPELLCAST_CHANNEL_STOP',
			s = 'USC_C_STOP',
			t = "channel",
		},
		[61] = {
			l = 'UNIT_SPELLCAST_STOP',
			s = 'USC_STOP',
			t = "cast",
		},
		[62] = {
			l = "SPELL_STOLEN",
			s = "SPELL_STOLEN",
			c = true,
			t = "misc",
		},
		[63] = {
			l = 'CHAT_MSG_ADDON',
			s = 'CM_ADDON',
			t = "chat",
		},
		[64] = {
			l = "CUSTOM",
			s = "CUSTOM",
			t = "misc",
		},
		[65] = {
			l = "UPDATE_UI_WIDGET",
			s = "U_UI_WIDGET",
			t = "misc"
		},
		[66] = {
			l = "DBM_Announce",
			s = "DBM_Announce",
			t = "dbm"
		},
		[67] = {
			l = "DBM_Debug",
			s = "DBM_Debug",
			t = "dbm"
		},
		[68] = {
			l = "DBM_TimerStart",
			s = "DBM_TStart",
			t = "dbm"
		},
		[69] = {
			l = "DBM_TimerStop",
			s = "DBM_TStop",
			t = "dbm"
		},
		[70] = {
			l = "DBM_TimerFadeUpdate",
			s = "DBM_TFUpdate",
			t = "dbm"
		},
		[71] = {
			l = "DBM_TimerUpdate",
			s = "DBM_TUpdate",
			t = "dbm"
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

function iEET:getColor(guid)
	if colors[guid] then
		return {colors[guid].r,colors[guid].g,colors[guid].b}
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
	colors[guid] = t
	return {colors[guid].r,colors[guid].g,colors[guid].b}
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

			[53] = true, -- UNIT_ENTERING_VEHICLE
			[54] = true, -- UNIT_ENTERED_VEHICLE
			[55] = true, -- UNIT_EXITING_VEHICLE
			[56] = true, -- UNIT_EXITED_VEHICLE

			[57] = true, -- PLAY_MOVIE
			[58] = true, -- CINEMATIC_START
			[59] = true, -- CINEMATIC_STOP

			[60] = true, -- UNIT_SPELLCAST_CHANNEL_STOP
			[61] = true, -- UNIT_SPELLCAST_STOP

			[62] = true, -- SPELL_STOLEN
			[63] = true, -- CHAT_MSG_ADDON

			[64] = true, -- CUSTOM
			[65] = true, -- UPDATE_UI_WIDGET

			[66] = true, -- DBM_Announce
			[67] = true, -- DBM_Debug
			[68] = true, -- DBM_TimerStart
			[69] = true, -- DBM_TimerStop
			[70] = true, -- DBM_TimerFadeUpdate
			[71] = true, -- DBM_TimerUpdate
		},
		['version'] = iEET.version,
		['autoSave'] = true,
		['autoDiscard'] = 30,
		['filtering'] = {},
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
		['scales'] = {
			['main'] = false,
			['filters'] = false,
			['onscreen'] = false,
		},
		['spawnOffset'] = 0,
		['expansionIgnore'] = {},
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

function iEET:TrimWS(str)
	return str:gsub('^%s*(.-)%s*$', '%1')
end
function iEET:print(msg)
	print('iEET: ', msg)
end

do
	local _id
	local _eventID
	local maxLengths = {
		[5] = 18,
		[6] = 14,
		[7] = 4,
		[8] = 4,
	}
	local function trim(str, col)
		if not str then return " " end
		if type(str) ~= "string" then return tostring(str) end
		if str == "" then return " " end
		str = str:gsub('|c........', '') -- Colors
		str = str:gsub('|r', '') -- Colors
		str = str:gsub('|T.+|t', '') -- Textures
		str = str:gsub('%%', '%%%%')
		str = str:gsub('|h', '') -- Spells
		str = str:gsub('|H', '') -- Spells
		if maxLengths[col] then
			str = str:sub(1, maxLengths[col])
		end
		return str
	end
	local function getHyperlink(str, col, accurateTime)
		return string.format("\124HiEET%02d%03d%06d%s\124h%s\124h", col, _eventID, _id, accurateTime or " ", trim(str, col))
	end
	function iEET:addSpellDetails(link, linkVal) -- TODO : REWRITE
		local col = tonumber(link:sub(5,6))
		local eventID = tonumber(link:sub(7,9))
		local id = tonumber(link:sub(10,15))
		local accurateTime
		if col == 1 or col == 2 then
			accurateTime = tonumber(link:sub(16, -1))
		end
		local t = iEET.data[id]
		if not t then
			iEET:print(sformat("Error: data for id %s not found.", id or "nil"))
			return 
		end
		local guidToSearch = iEET.eventFunctions[t[1]].gui(t, true)
		iEET.detailInfo:SetText(guidToSearch)
		local starttime = 0
		local intervals = {}
		local counts = {}
		for i = 1, 7 do
			if i ~= 4 then
				iEET['detailContent' .. i]:Clear()
			end
		end
		for k,v in ipairs(iEET.data) do
			local intervallGUID, specialCategory, col4, col5, col6, col8, collectorData = iEET.eventFunctions[v[1]].gui(v)
			local _time = v[2]
			local timeFromStart
			if starttime == 0 then
				timeFromStart = 0
			else
				timeFromStart = _time - starttime
			end
			if specialCategory == iEET.specialCategories.StartLogging then
				starttime = _time
			end
			if intervallGUID == guidToSearch then
				local interval
				local count
				if not intervals[intervallGUID] then
					intervals[intervallGUID] = _time
					counts[intervallGUID] = 1
					count = 1
				else
					interval = _time - intervals[intervallGUID]
					intervals[intervallGUID] = _time
					counts[intervallGUID] = counts[intervallGUID] + 1
					count = counts[intervallGUID]
				end
				_id = k
				_eventID = v[1]
				local color = iEET:getColor(intervallGUID)
				iEET:addMessages(2, 1, getHyperlink(sformat("%.1f",timeFromStart), 1, timeFromStart), color)
				iEET:addMessages(2, 2, getHyperlink(interval and sformat("%.1f",interval) or nil, 2, interval), color)
				iEET:addMessages(2, 3, getHyperlink(iEET.events.fromID[eventID].s, 3), color)
				iEET:addMessages(2, 5, getHyperlink(col5, 5), color)
				iEET:addMessages(2, 6, getHyperlink(col6, 6), color)
				iEET:addMessages(2, 7, getHyperlink(count, 7), color)
				--iEET:addMessages(2, 8, getHyperlink(col8, 8), color)
				--iEET:addToContent(intervallGUID, v[1], k, timeFromStart, interval, col4, col5, col6, count, col8)
			end
		end
	end
end
do
	local _id
	local _eventID
	local maxLengths = {
		[4] = 20,
		[5] = 18,
		[6] = 14,
		[7] = 4,
		[8] = 4,
	}
	local function trim(str, col)
		if not str then return " " end
		if type(str) ~= "string" then return tostring(str) end
		if str == "" then return " " end
		str = str:gsub('|c........', '') -- Colors
		str = str:gsub('|r', '') -- Colors
		str = str:gsub('|T.+|t', '') -- Textures
		str = str:gsub('%%', '%%%%')
		str = str:gsub('|h', '') -- Spells
		str = str:gsub('|H', '') -- Spells
		str = str:gsub('\r', '')
		if maxLengths[col] then
			str = str:sub(1, maxLengths[col])
		end
		return str
	end
	local function getHyperlink(str, col, accurateTime)
		return string.format("\124HiEET%02d%03d%06d%s\124h%s\124h", col, _eventID, _id, accurateTime or " ", trim(str, col))
	end
	function iEET:addToContent(intervallGUID, eventID, id, _time, interval, col4, col5, col6, count, col8)
		local color = iEET:getColor(intervallGUID)
		_id = id
		_eventID = eventID
		iEET:addMessages(1, 1, getHyperlink(sformat("%.1f",_time), 1, _time), color)
		iEET:addMessages(1, 2, getHyperlink(interval and sformat("%.1f",interval) or nil, 2, interval), color)
		iEET:addMessages(1, 3, getHyperlink(iEET.events.fromID[eventID].s, 3), color)
		iEET:addMessages(1, 4, getHyperlink(col4, 4), color)
		iEET:addMessages(1, 5, getHyperlink(col5, 5), color)
		iEET:addMessages(1, 6, getHyperlink(col6, 6), color)
		iEET:addMessages(1, 7, getHyperlink(count, 7), color)
		iEET:addMessages(1, 8, getHyperlink(col8, 8), color)
	end
end
do
	local _catNames = {
		Interrupt = {
			name = Spell:CreateFromSpellID(324694):GetSpellName() or "Interrupt",
			tooltip = "Interrupt abilities",
		},
		Dispel = {
			name = Spell:CreateFromSpellID(135856):GetSpellName() or "Dispel",
			tooltip = "Dispel abilities"
		},
		Death = {

		},
		Taunt = {

		},
	}
	--[[
	iEET.specialCategories = {
		["Ignore"] = 0,
		["Interrupt"] = 1,
		["PowerUpdate"] = 2,
		["Dispel"] = 3,
		["Death"] = 4,
		["NPCSpawn"] = 5,
		["StartLogging"] = 6,
		["EndLogging"] = 7,
		["Taunt"] = 8,
	}
	--]]
	do
		local function getSpecialCatName(id)
			for k,v in pairs(iEET.specialCategories) do
				if v == id then return k end
			end
			return UNKNOWN
		end
	function iEET:addToEncounterAbilities(spellID, col4, specialCat)
		if specialCat then
			iEET.commonAbilitiesContent:AddMessage(string.format('\124HiEETCommon%s\124h%s\124r',specialCat,getSpecialCatName(specialCat)), .6,.6,.6)
		elseif spellID and col4 then
			iEET.encounterAbilitiesContent:AddMessage(string.format('\124HiEETEncounter%s\124h%s\124r',spellID,col4), 1,1,1)
		end
	end
	end
end
function iEET:addMessages(placeToAdd, frameID, str, color)
	local frame = ''
	if placeToAdd == 1 then
		frame = iEET['content' .. frameID]
	elseif placeToAdd == 2 then
		frame = iEET['detailContent' .. frameID]
	elseif placeToAdd == 3 then
		frame = iEET['onscreenContent' .. frameID]
	end
	local r,g,b = unpack(color)
	frame:AddMessage(str,r,g,b)
end
do
	local function count(t)
		local c = 0
		for _ in pairs(t) do
			c = c + 1
		end
		return c
	end
	local collapses = iEET.collapses
	local function shouldShow(data, filters, guid)
		local e = data[1]
		if e == 27 or e == 37 then return true end -- Always show ENCOUNTER_START and MANUAL_START
		if not iEETConfig.tracking[e] then return false end
		if guid then return iEET.eventFunctions[e].gui(data, true) == guid end
		if iEET.currentlyIgnoringFilters then return true end
		if not (iEET.eventFunctions[e] and iEET.eventFunctions[e].filtering) then
			iEET:print(string.format("Error: Filtering function for event id %d not found.", e))
			return false
		end
		return iEET.eventFunctions[e].filtering(data, filters)
	end
	function iEET:loopData(generalSearch, dontReload, spellID, specialCat, eventGUID) -- TODO fix normal editbox
		if #iEETConfig.filtering > 0 then
			if iEET.encounterInfo then
				iEET.encounterInfo:SetBackdropBorderColor(0.64,0,0,1)
			end
		elseif iEET.encounterInfo then
			iEET.encounterInfo:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
		end
		-- CBA to optimize these
		if count(iEET.ignoring.unitIDs) > 0 or count(iEET.ignoring.npcNames) > 0 then
			iEET.npcList:SetBackdropBorderColor(1,0,0,1)
		else
			iEET.npcList:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
		end
		if count(iEET.ignoring.specialCategories) > 0 or count(iEET.ignoring.spellIDs) > 0 then
			iEET.spellList:SetBackdropBorderColor(1,0,0,1)
		else
			iEET.spellList:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
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
		if not dontReload then -- already gathered
			iEET.encounterAbilitiesContent:Clear()
			iEET.commonAbilitiesContent:Clear()
			iEET.collector = {
				['npcNames'] = {},
				['unitIDs'] = {},
				['spellIDs'] = {},
				['specialCategories'] = {},
			}
		end
		local filters = tcopy(iEETConfig.filtering)
		for k,v in ipairs(iEET.data) do
			if shouldShow(v,filters,eventGUID) then
				if not iEET.eventFunctions[v[1]] and iEET.eventFunctions[v[1]].gui then
					iEET:print("Error: handlers for event id %d not found, ignoring it.", v[1])
				else
					local intervallGUID, specialCategory, col4, col5, col6, col8, collectorData = iEET.eventFunctions[v[1]].gui(v)
					local _time = v[2]
					local timeFromStart
					if starttime == 0 then
						timeFromStart = 0
					else
						timeFromStart = _time - starttime
					end
					if specialCategory == iEET.specialCategories.StartLogging then
						starttime = _time
					end
					if specialCategory == iEET.specialCategories.StartLogging or (not spellID and not specialCat) or (collectorData and collectorData.spellID and collectorData.spellID == spellID) or (specialCat and specialCategory == specialCat) then
						if not dontReload then
							if collectorData then
								local collapsed = collectorData.unitID and collapses[collectorData.unitID] or collectorData.unitID
								if collectorData.unitID and not iEET.collector.unitIDs[collapsed] then
									iEET.collector.unitIDs[collapsed] = true
								end
								if collectorData.spellID and not iEET.collector.spellIDs[collectorData.spellID] then
									iEET.collector.spellIDs[collectorData.spellID] = true
									iEET:addToEncounterAbilities(collectorData.spellID, col4)
								end
								if collectorData.casterName and not iEET.collector.npcNames[collectorData.casterName] then
									iEET.collector.npcNames[collectorData.casterName] = true
								end
								if specialCategory and not iEET.collector.specialCategories[specialCategory] then
									iEET.collector.specialCategories[specialCategory] = true
									iEET:addToEncounterAbilities(collectorData.spellID, col4, specialCategory)
								end
							end
						end
						local interval
						local count
						if not intervals[intervallGUID] then
							intervals[intervallGUID] = _time
							counts[intervallGUID] = 1
							count = 1
						else
							interval = _time - intervals[intervallGUID]
							intervals[intervallGUID] = _time
							counts[intervallGUID] = counts[intervallGUID] + 1
							count = counts[intervallGUID]
						end
						iEET:addToContent(intervallGUID, v[1], k, timeFromStart, interval, col4, col5, col6, count, col8)
					end
				end
			end
		end
		-- Update Slider values
		iEET.maxScrollRange = iEET['content' .. 1]:GetMaxScrollRange()
		iEET.mainFrameSlider:SetMinMaxValues(0, iEET.maxScrollRange)
		iEET.mainFrameSlider:SetValue(iEET.maxScrollRange)
		iEET.frame:Show()
	end
end

function iEET:Hyperlinks(link, linkVal)
	local col = tonumber(link:sub(5,6))
	local eventID = tonumber(link:sub(7,9))
	local id = tonumber(link:sub(10,15))
	local accurateTime
	if col == 1 or col == 2 then
		accurateTime = tonumber(link:sub(16, -1))
	end
	local t = iEET.data[id]
	if not t then
		iEET:print(sformat("Error: data for id %s not found.", id or "nil"))
		return 
	end
	GameTooltip:ClearLines()
	if col == 1 or col == 2 or col == 3 then
		if col == 1 then
			GameTooltip:AddLine(accurateTime or "Error")
			GameTooltip:AddLine(t[2] or "Error")
		elseif col == 2 then
			GameTooltip:AddLine(accurateTime or "Error")
		else
			GameTooltip:AddLine(iEET.events.fromID[eventID].l or "Error")
			GameTooltip:AddLine("Event ID: "..eventID)
		end
	elseif not (iEET.eventFunctions[eventID] and iEET.eventFunctions[eventID].hyperlink) then
		iEET:print(sformat("Error: hyperlink function for event id %s not found.", eventID or "nil"))
		return
	elseif not iEET.eventFunctions[eventID].hyperlink(col, iEET.data[id]) then
		return
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
		local _concat = table.concat
		local _format = string.format
		local _insert = table.insert
		local dataString = ''
		local tempDataTable = {}
		for k,v in ipairs(iEET.data) do
			local t = {}
			for a,b in pairs(v) do
				_insert(t,_format('{%s=%s}',a,tostring(b)))
			end
			_insert(tempDataTable, _format('|D|%s|D|', _concat(t)))
		end
		dataString = _concat(tempDataTable)
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
			local i = tonumber(eV)
			if i then
				if eK == "v" and i < 2 then -- REMOVE AT 9.1, "support" old logs during 9.0-9.1
					iEET:oldImport(dataKey)
					return
				end
				eV = i
			end
		end
		iEET.encounterInfoData[eK] = eV
	end
	for v in string.gmatch(iEET_Data[dataKey], 'D|(.-)|D') do
		local tempTable = {}
		local eventID = 0
		for key, d in string.gmatch(v, '{(.-)=(.-)}') do
			key = tonumber(key)
			if key == 1 or key == 2 then -- event, timestamp
				d = tonumber(d)
				if key == 1 then
					eventID = d
				end
			elseif d == 'nil' then
				d = nil
			end
			tempTable[key] = d
		end
		if not (iEET.eventFunctions[eventID] and iEET.eventFunctions[eventID].import) then
			iEET:print(sformat("Error: importing functions for event id %d is missing", eventID))
		end
		if iEET.eventFunctions[eventID].import then
			tempTable = iEET.eventFunctions[eventID].import(tempTable)
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
			zone = temp.zI == -1 and "Custom" or GetRealZoneText(temp.zI)
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
	elseif msg:match("^scale (.*) (.*)") then
		--scales
		local frame, value = msg:match("^scale (.*) (.*)")
		value = tonumber(value)
		if value and value <= 0 then
			value = false
		end
		if frame == "main" then
			iEETConfig.scales.main = value and value or false
			if iEET.frame then
				iEET.frame:SetScale(iEETConfig.scales.main and iEETConfig.scales.main or 1)
			end
		elseif frame == "filters" then
			iEETConfig.scales.filters = value and value or false
			if iEET.optionsFrame then
				iEET.optionsFrame:SetScale(iEETConfig.scales.filters and iEETConfig.scales.filters or 1)
			end
		elseif frame == "onscreen" then
			iEETConfig.scales.onscreen = value and value or false
			if iEET.onscreen then
				iEET.onscreen:SetScale(iEETConfig.scales.onscreen and iEETConfig.scales.onscreen or 1)
			end
		else
			iEET:print('Frame not found, possible values are "main", "filters" or "onscreen".')
		end
	elseif msg:match('^spawnoffset ([-]?%d*)') then
		local offset = tonumber(msg:match('^spawnoffset ([-]?%d*)'))
		if not offset then
			iEET:print("Error setting spawn offset.")
			return
		end
		iEETConfig.spawnOffset = offset
		iEET:print(string.format("Spawn offset changed to: %d, requires reloading your ui to take full effect.", iEETConfig.spawnOffset))
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