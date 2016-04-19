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
target tracking NEXT IN LINE
--]]
local _, iEET = ...
iEET.data = {}
local isAlpha = select(4, GetBuildInfo()) >= 70000 and true or false
iEET.ignoring = {} -- so ignore list resets on relog, don't want to save it, atleast not yet
iEET.font = isAlpha and 'Fonts\\ARIALN.TTF' or 'Interface\\AddOns\\iEncounterEventTracker\\Accidental Presidency.ttf'
iEET.fontsize = 12
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
iEET.version = 1.420
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
	--['UNIT_TARGET'] = 'UNIT_TARGET',
};
local addon = CreateFrame('frame')
--[[
local unitEventHandlers = {
	['oneTwo'] = CreateFrame('frame'),
	['threeFour'] = CreateFrame('frame'),
	['five'] = CreateFrame('frame'),
}
	unitEventHandlers.oneTwo:SetScript('OnEvent', iEET:UNIT_TARGET)
	unitEventHandlers.threeFour:SetScript('OnEvent', iEET:UNIT_TARGET)
	unitEventHandlers.five:SetScript('OnEvent', iEET:UNIT_TARGET)
]]
addon:SetScript('OnEvent', function(self, event, ...)
	self[event](self, ...)
end)
addon:RegisterEvent('ENCOUNTER_START')
addon:RegisterEvent('ENCOUNTER_END')
addon:RegisterEvent('ADDON_LOADED')
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
		--['UNIT_TARGET'] = 32,
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
		--[32] = {
		--	l = 'UNIT_TARGET',
		--	s = 'UNIT_TARGET',
		--},
	},
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
	iEETConfig.tracking = {
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
		['MONSTER_EMOTE'] = true,
		['MONSTER_SAY'] = true,
		['MONSTER_YELL'] = true,

		['ENCOUNTER_START'] = true,
		['ENCOUNTER_END'] = true,
	}
	iEETConfig.version = iEET.version
	iEETConfig.autoSave = true
	iEETConfig.autoDiscard = 30
	iEETConfig.filtering = {
		timeBasedFiltering = {},
		req = {},
		requireAll = false,
		showTime = false, -- show time from nearest 'from' event instead of ENCOUNTER_START
	}
	print('iEET: loaded default settings.')
end
function addon:ADDON_LOADED(addonName)
	if addonName == 'iEncounterEventTracker' then
		iEETConfig = iEETConfig or {}
		if not iEETConfig.version or not iEETConfig.tracking or iEETConfig.version < 1.413 then -- Last version with db changes
			iEET:LoadDefaults()
		else
			iEETConfig.version = iEET.version
		end
		addon:UnregisterEvent('ADDON_LOADED')
	end
end
function addon:ENCOUNTER_START(encounterID, encounterName)
	iEET.data = nil
	iEET.data = {}
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
	iEET.encounterInfo = date('%d.%m.%y %H:%M') .. ' ' .. encounterName
	table.insert(iEET.data, {['e'] = 27, ['t'] = GetTime(), ['cN'] = encounterName, ['tN'] = encounterID})
	addon:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	addon:RegisterEvent('CHAT_MSG_MONSTER_SAY')
	addon:RegisterEvent('CHAT_MSG_MONSTER_EMOTE')
	addon:RegisterEvent('CHAT_MSG_MONSTER_YELL')
	addon:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	--unitEventHandlers.oneTwo:RegisterUnitEvent('UNIT_TARGET', 'boss1', 'boss2')
	--unitEventHandlers.threeFour:RegisterUnitEvent('UNIT_TARGET', 'boss3', 'boss4')
	--unitEventHandlers.five:RegisterUnitEvent('UNIT_TARGET', 'boss5')
end
function addon:ENCOUNTER_END(EncounterID, encounterName, difficultyID, raidSize, kill)
	table.insert(iEET.data, {['e'] = 28, ['t'] = GetTime() ,['cN'] = kill == 1 and 'Victory!' or 'Wipe'})
	addon:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	addon:UnregisterEvent('CHAT_MSG_MONSTER_SAY')
	addon:UnregisterEvent('CHAT_MSG_MONSTER_EMOTE')
	addon:UnregisterEvent('CHAT_MSG_MONSTER_YELL')
	addon:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	--unitEventHandlers.oneTwo:UnregisterEvent('UNIT_TARGET')
	--unitEventHandlers.threeFour:UnregisterEvent('UNIT_TARGET)
	--unitEventHandlers.five:UnregisterEvent('UNIT_TARGET')
	iEET.encounterInfoData.fT = iEET.encounterInfoData.s and date('%M:%S', (GetTime() - iEET.encounterInfoData.s)) or '00:00' -- if we are missing start time for some reason
	iEET.encounterInfoData.d = difficultyID
	iEET.encounterInfoData.k = kill
	iEET.encounterInfoData.rS = raidSize
	if iEETConfig.autoSave then
		iEET:ExportData(true)
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
		if isAlpha then
			local id = select(5, strsplit('-', arg4))
			spellID = tonumber(id)
		end
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
function addon:COMBAT_LOG_EVENT_UNFILTERED(timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,spellID, spellName,...)
	if eventsToTrack[event] then
		local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
		if sourceGUID then -- fix for arena id's
			unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
		end
		if event == 'UNIT_DIED' then
			if (unitType == 'Creature') or (unitType == 'Vehicle') or (unitType == 'Player') then
				table.insert(iEET.data, {
					['e'] = 25,
					['t'] = GetTime(),
					['sG'] = destGUID or 'NONE',
					['cN'] = destName or 'NONE',
					['sN'] = 'Death',
					['sI'] = 'NONE',
				});
			end
		elseif (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and iEET.approvedSpells[spellID]) or not sourceGUID or hideCaster or event == 'SPELL_INTERRUPT' or event == 'SPELL_DISPEL' then
			if spellID and not iEET.ignoredSpells[spellID] then
				if not iEET.npcIgnoreList[tonumber(npcID)] then
					table.insert(iEET.data, {
						['e'] = iEET.events.toID[event],
						['t'] = GetTime(),
						['sG'] = sourceGUID or 'NONE',
						['cN'] = sourceName or 'NONE',
						['tN'] = destName or nil,
						['sN'] = spellName or 'NONE',
						['sI'] = spellID or 'NONE',
					});
				end
			end
		end
	end
end
function iEET:UNIT_TARGET(unitID)
	--[[
	if UnitExists(unitID) then --didn't just disappear
		local sourceGUID = UnitGUID(unitID)
		local sourceName = UnitName(unitID)
		local chp = UnitHealth(unitID)
		local maxhp = UnitHealthMax(unitID)
		local php = nil
		local targetName = UnitName(unitID .. 'target') or 'Dropped'
		if chp and maxhp then
			php = math.floor(chp/maxhp*1000+0.5)/10
		end
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
	--]]
end
function iEET:getColor(event, sourceGUID, spellID)
	if event and event == 27 then
		return {0,1,0}
	elseif event and event == 28 then
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
				iEET['content' .. i]:PageDown()
			else
				iEET['content' .. i]:ScrollDown()
			end
		end
	else
		for i = 1, 8 do
			if IsShiftKeyDown() then
				iEET['content' .. i]:PageUp()
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
					iEET['detailContent' .. i]:PageDown()
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
					iEET['detailContent' .. i]:PageUp()
				else
					iEET['detailContent' .. i]:ScrollUp()
				end
			end
		end
	end
end
function iEET:ShouldShow(eventData,e_time, msg) -- NEW, TESTING msg is a temporary fix
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
	elseif eventData.e == 26 then -- UNIT_SPELLCAST_SUCCEEDED
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
	for k,v in ipairs(iEET.data) do
		if v.e == 27 then starttime = v.t end -- ENCOUNTER_START
		if linkType == 'iEETcustomspell' or linkType == 'iEETcustomyell' then
			local found = false
			if v.sI then
				if v.sI == spellIDToFind and v.e == eventToFind then
					found = true
				end
			end
			if found then
				local intervall = false
				local timestamp = v.t-starttime or nil
				local casterName = v.cN or nil
				local targetName = v.tN or nil
				local spellID = v.sI or nil
				local event = v.e or nil
				local count = nil
				local sourceGUID = v.sG or nil
				--local spellID = v.spellID
				if sourceGUID then
					if intervalls[sourceGUID] then
						if intervalls[sourceGUID][event] then
							if intervalls[sourceGUID][event][spellID] then
								intervall = timestamp - intervalls[sourceGUID][event][spellID]
								intervalls[sourceGUID][event][spellID] = timestamp
							else
								intervalls[sourceGUID][event][spellID] = timestamp
							end
						else
							intervalls[sourceGUID][event] = {
									[spellID] = timestamp,
							};
						end
					else
						intervalls[sourceGUID] = {
							[event] = {
								[spellID] = timestamp,
							};
						};
					end
					if counts[sourceGUID] then
						if counts[sourceGUID][event] then
							if counts[sourceGUID][event][spellID] then
								counts[sourceGUID][event][spellID] = counts[sourceGUID][event][spellID] + 1
								count = counts[sourceGUID][event][spellID]
							else
								counts[sourceGUID][event][spellID] = 1
								count = 1
							end
						else
							counts[sourceGUID][event] = {
								[spellID] = 1,
							}
						end
					else
						counts[sourceGUID] = {
							[event] = {
								[spellID] = 1,
							};
						};
						count = 1
					end
				end
				color = iEET:getColor(event, sourceGUID, spellID)
				iEET:addMessages(2, 1, timestamp, color)
				iEET:addMessages(2, 2, intervall, color, intervall and ('\124HiEETtime:' .. intervall ..'\124h%s\124h') or nil)
				iEET:addMessages(2, 3, iEET.events.fromID[event].s, color)
				iEET:addMessages(2, 5, casterName, color)
				iEET:addMessages(2, 6, targetName, color)
				iEET:addMessages(2, 7, count, color)
			end
		end
	end
	iEETDetailInfo:SetText(hyperlink)
end
function iEET:addToContent(timestamp,event,casterName,targetName,spellName,spellID,intervall,count,sourceGUID, hp)
	local color = iEET:getColor(event, sourceGUID, spellID)
	iEET:addMessages(1, 1, timestamp, color)
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
		iEET.content4:AddMessage('\124HiEETcustomyell:' .. event .. ':' .. msg .. '\124hMessage\124h', unpack(iEET:getColor(event, sourceGUID, spellID))) -- NEEDS CHANGING
	elseif spellID then
		local spellnametoShow = ''
		if isAlpha and string.len(spellName) > 16 then
			spellnametoShow = string.sub(spellName, 1, 16)
		elseif string.len(spellName) > 20 then
			spellnametoShow = string.sub(spellName, 1, 20)
		else
			spellnametoShow = spellName
		end
		local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
		if sourceGUID then
			unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
		else
			npcID = 'NONE'
		end
		iEET.content4:AddMessage('\124HiEETcustomspell:' .. event .. ':' .. spellID .. ':' .. spellName .. ':' .. (npcID and npcID or 'NONE').. '!' .. (spawnID and spawnID or '') ..'\124h' .. spellnametoShow .. '\124h', unpack(iEET:getColor(event, sourceGUID, spellID))) -- NEEDS CHANGING
	else
		iEET.content4:AddMessage(' ')
	end
	iEET:addMessages(1, 5, casterName, color)
	iEET:addMessages(1, 6, targetName, color)
	iEET:addMessages(1, 7, count, color)
	iEET:addMessages(1, 8, hp, color)
end
function iEET:addToEncounterAbilities(spellID, spellName)
	if spellID and tonumber(spellID) and spellName then
		iEET.encounterAbilitiesContent:AddMessage('\124Hspell:' .. tonumber(spellID) .. '\124h[' .. spellName .. ']\124h\124r')
	end
end
function iEET:addMessages(placeToAdd, frameID, value, color, hyperlink)
	local frame = ''
	if placeToAdd == 1 then
		frame = iEET['content' .. frameID]
	elseif placeToAdd == 2 then
		frame = iEET['detailContent' .. frameID]
	end
	if frameID == 1 or frameID == 2 then
		if value then
			value = string.format("%.1f",value)
		end
		if hyperlink then
			value = hyperlink:format(value)
		end
	elseif frameID == 5 then
		if isAlpha and value and string.len(value) > 16 then -- can't use custom fonts on alpha and default font(ARIALN) is wider than Accidental Presidency
			value = string.sub(value, 1, 16)
		elseif value and string.len(value) > 18 then
			value = string.sub(value, 1, 18)
		end
	elseif frameID == 6 then
		if isAlpha and value and string.len(value) > 13 then -- can't use custom fonts on alpha and default font(ARIALN) is wider than Accidental Presidency
			value = string.sub(value, 1, 13)
		elseif value and string.len(value) > 16 then
			value = string.sub(value, 1, 16)
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
		iEET.encounterInfo:SetBackdropBorderColor(0,0,0,1)
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
		if v.e == 27 then -- ENCOUNTER_START
			starttime = v.t
		end
		if v.cN and not iEET.collector.encounterNPCs[v.cN] and v.e ~= 27 and v.e ~= 28 then -- Collect npc names, 27 = ENCOUNTER_START, 28 = ENCOUNTER_END
			if v.e == 26 then -- UNIT_SPELLCAST_SUCCEEDED
				if string.find(v.tN, 'nameplate') then -- could be safe to assume that there will be atleast one nameplate unitid
					if not iEET.collector.encounterNPCs.nameplates then
						iEET.collector.encounterNPCs.nameplates = true
					end
				elseif v.tN and not iEET.collector.encounterNPCs[v.tN] then
					iEET.collector.encounterNPCs[v.tN] = true
				end
			else
				if v.sI and iEET.interrupts[v.sI] then
					if not iEET.collector.encounterNPCs.Interrupters then
						iEET.collector.encounterNPCs.Interrupters = true
					end
				elseif v.sI and iEET.dispels[v.sI] then
					iEET.collector.encounterNPCs.Dispellers = true
				else
					iEET.collector.encounterNPCs[v.cN] = true
				end
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
				iEET.collector.encounterSpells[v.sI] = v.sN
				iEET:addToEncounterAbilities(v.sI, v.sN)
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
					iEET:addToContent(timestamp,v.e,v.cN,v.tN,v.sN,v.sI, intervall,count, v.sG,v.hp)
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
	iEET.optionsFrameFilterTexts:AddMessage(msg)
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
	iEET.optionsFrame:Hide()
end
iEET.optionMenu = {}
function iEET:updateOptionMenu()
	iEET.optionMenu = nil
	iEET.optionMenu = {}
	if iEET.collector then
		-- NPCs
		local tempIgnoreNPCs = {text = "Ignore NPCs", hasArrow = true, notCheckable = true, menuList = {}}
		for k in spairs(iEET.collector.encounterNPCs) do
			table.insert(tempIgnoreNPCs.menuList, {
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
		table.insert(tempIgnoreNPCs.menuList, { text = 'Save', notCheckable = true, func = function()
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
		table.insert(iEET.optionMenu, tempIgnoreNPCs)
		-- Spells
		local tempIgnoreSpells = {text = "Ignore Spells", hasArrow = true, notCheckable = true, menuList = {}}
		for k,v in spairs(iEET.collector.encounterSpells) do
			table.insert(tempIgnoreSpells.menuList, {
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
		table.insert(tempIgnoreSpells.menuList, { text = 'Save', notCheckable = true, func = function()
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
		table.insert(iEET.optionMenu, tempIgnoreSpells)
	end
	local tempEvents = {text = "Events", hasArrow = true, notCheckable = true, menuList = {}}
	for k,_ in spairs(iEETConfig.tracking) do
		table.insert(tempEvents.menuList, {
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
	table.insert(tempEvents.menuList, { text = 'Save', notCheckable = true, func = function()
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
	table.insert(iEET.optionMenu, tempEvents)
	table.insert(iEET.optionMenu, { text = 'Close', notCheckable = true, func = function () CloseDropDownMenus(); end})
end
iEET.optionMenuFrame = CreateFrame("Frame", "iEETEventListMenu", UIParent, "UIDropDownMenuTemplate")
iEET.encounterListMenu = {}
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
						text = (v.kill == 1 and '+ ' or '- ') .. v.fT .. ' (' .. v.pT .. ')',
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
iEET.encounterListMenuFrame = CreateFrame("Frame", "iEETEncounterListMenu", UIParent, "UIDropDownMenuTemplate")
function iEET:CreateMainFrame()
	iEET.frame = CreateFrame("Frame", "iEETFrame", UIParent)
	iEET.frame:SetSize(554,800)
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
	iEET.top:SetSize(554, 25)
	iEET.top:SetPoint('BOTTOMRIGHT', iEET.frame, 'TOPRIGHT', 0, -1)
	iEET.top:SetBackdrop(iEET.backdrop);
	iEET.top:SetBackdropColor(0.1,0.1,0.1,0.9)
	iEET.top:SetBackdropBorderColor(0,0,0,1)
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
	iEET.encounterInfo:SetSize(354, 18)
	iEET.encounterInfo:SetPoint('BOTTOM', iEET.top, 'TOP', 0, -1)
	iEET.encounterInfo:SetBackdrop(iEET.backdrop);
	iEET.encounterInfo:SetBackdropColor(0.1,0.1,0.1,0.9)
	iEET.encounterInfo:SetBackdropBorderColor(0,0,0,1)
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
	--Main window exit button
	iEET.exitButton = CreateFrame('Button', nil, iEET.frame)
	iEET.exitButton:SetSize(9, 9)
	iEET.exitButton.tex = iEET.exitButton:CreateTexture()
	iEET.exitButton.tex:SetAllPoints(iEET.exitButton)
	iEET.exitButton.tex:SetTexture(0.64,0,0,1)
	iEET.exitButton:SetPoint('TOPRIGHT', iEET.top, 'TOPRIGHT', -3,-3)
	iEET.exitButton:Show()
	iEET.exitButton:RegisterForClicks('AnyUp')
	iEET.exitButton:SetScript('OnClick',function()
		iEET.frame:Hide()
	end)
	iEET.detailtop = CreateFrame('FRAME', nil, iEET.frame)
	iEET.detailtop:SetSize(405, 25)
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
	iEET.detailtop:SetBackdropColor(0.1,0.1,0.1,0.9)
	iEET.detailtop:SetBackdropBorderColor(0,0,0,1)
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
	iEET.encounterAbilities:SetBackdropColor(0.1,0.1,0.1,0.9)
	iEET.encounterAbilities:SetBackdropBorderColor(0,0,0,1)
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
		[1] = 36,
		[2] = 36,
		[3] = 110,
		[4] = 121,
		[5] = 110,
		[6] = 87,
		[7] = 31,
		[8] = 30,
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
		iEET['contentAnchor' .. i]:SetBackdropColor(0.1,0.1,0.1,0.9)
		iEET['contentAnchor' .. i]:SetBackdropBorderColor(0,0,0,1)
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
		if i == 4 or i == 2 then --allow hyperlinks for intervall time and spellname only
			iEET['content' .. i]:SetHyperlinksEnabled(true)
			iEET['content' .. i]:SetScript("OnHyperlinkEnter", function(self, linkData, link)
				GameTooltip:SetOwner(iEET.frame, "ANCHOR_TOPRIGHT", 0-iEET.frame:GetWidth(), 0-iEET.frame:GetHeight())
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
				else
					GameTooltip:SetHyperlink(link)
				end
				GameTooltip:Show()
			end)
			iEET['content' .. i]:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
				if string.find(linkData, 'iEETtime') then
					return
				end
				if IsShiftKeyDown() and IsInRaid() then
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
		iEET['detailAnchor' .. i]:SetBackdropColor(0.1,0.1,0.1,0.9)
		iEET['detailAnchor' .. i]:SetBackdropBorderColor(0,0,0,1)
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
		if i == 2 then --allow hyperlinks for intervall time only
			iEET['detailContent' .. i]:SetHyperlinksEnabled(true)
			iEET['detailContent' .. i]:SetScript('OnHyperlinkEnter', function(self, linkData, link)
				GameTooltip:SetOwner(iEET.frame, "ANCHOR_TOPRIGHT", 0-iEET.frame:GetWidth(), 0-iEET.frame:GetHeight())
				GameTooltip:ClearLines()
				local _, txt = strsplit(':',linkData)
				GameTooltip:SetText(txt)
				GameTooltip:Show()
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
		iEET.encounterAbilitiesAnchor:SetBackdropColor(0.1,0.1,0.1,0.9)
		iEET.encounterAbilitiesAnchor:SetBackdropBorderColor(0,0,0,1)
		---
		iEET.encounterAbilitiesContent = CreateFrame('ScrollingMessageFrame', nil, iEET.encounterAbilitiesAnchor)
		iEET.encounterAbilitiesContent:SetSize(192,392)
		iEET.encounterAbilitiesContent:SetPoint('CENTER', iEET.encounterAbilitiesAnchor, 'CENTER', 0, 0)
		iEET.encounterAbilitiesContent:SetFont(iEET.font, iEET.fontsize)
		iEET.encounterAbilitiesContent:SetFading(false)
		iEET.encounterAbilitiesContent:SetInsertMode("BOTTOM")
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
	iEET.editbox:SetBackdropColor(0.1,0.1,0.1,0.2)
	iEET.editbox:SetBackdropBorderColor(0,0,0,1)
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
	iEET.editbox:SetWidth(300)
	iEET.editbox:SetHeight(21)
	iEET.editbox:SetTextInsets(2, 2, 1, 0)
	iEET.editbox:SetPoint('RIGHT', iEET.top, 'RIGHT', -25,0)
	iEET.editbox:SetFrameStrata('HIGH')
	iEET.editbox:SetFrameLevel(3)
	iEET.editbox:Show()
	iEET.editbox:SetFont(iEET.font, iEET.fontsize+2, 'OUTLINE')
	----Event list:
	iEET.eventlist = CreateFrame('BUTTON', 'iEETEventListMenuButton', iEET.frame, "UIPanelInfoButton")
	iEET.eventlist:SetSize(20, 20)
	iEET.eventlist.texture:SetVertexColor(0.5,0.5,0.5,1)
	iEET.eventlist:SetPoint("LEFT", iEET.top, 'LEFT', 4,-2)
	iEET.eventlist:Show()
	iEET.eventlist:RegisterForClicks('AnyUp')
	iEET.eventlist:SetScript('OnClick',function()
		iEET:updateOptionMenu()
		EasyMenu(iEET.optionMenu, iEET.optionMenuFrame, "cursor", 0 , 0, "MENU");
	end)
	iEET:updateOptionMenu()
	----end of event list
	----Encounter list button:
	iEET.encounterListButton = CreateFrame('BUTTON', 'iEETEncounterListMenuButton', iEET.frame, "UIPanelInfoButton")
	iEET.encounterListButton:SetSize(20, 20)
	iEET.encounterListButton.texture:SetVertexColor(1,0.25,0.25,1)
	iEET.encounterListButton:SetPoint('LEFT', iEET.eventlist, 'RIGHT', 3,0)
	iEET.encounterListButton:Show()
	iEET.encounterListButton:RegisterForClicks('AnyUp')
	iEET.encounterListButton:SetScript('OnClick',function()
		EasyMenu(iEET.encounterListMenu, iEET.encounterListMenuFrame, "cursor", 0 , 0, "MENU");
	end)
	iEET:updateEncounterListMenu()
	----end of encounter list button
	--iEET:loopData() OnShow already handles this
	iEET.frame:Show()
end
function iEET:CreateOptionsFrame()
	-- Options main frame
	iEET.optionsFrame = CreateFrame('Frame', 'iEETOptionsFrame', UIParent)
	iEET.optionsFrame:SetSize(650,500)
	iEET.optionsFrame:SetPoint('CENTER', UIParent, 'CENTER', 0,0)
	iEET.optionsFrame:SetBackdrop(iEET.backdrop);
	iEET.optionsFrame:SetBackdropColor(0.1,0.1,0.1,0.9)
	iEET.optionsFrame:SetBackdropBorderColor(0.64,0,0,1)
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
	iEET.optionsFrameTop:SetBackdropColor(0.1,0.1,0.1,0.9)
	iEET.optionsFrameTop:SetBackdropBorderColor(0.64,0,0,1)
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
	local function infoFrame(hide)
		if hide and iEET.infoFrame then
			iEET.infoFrame:Hide()
		else
			if iEET.infoFrame then
				iEET.infoFrame:Show()
			else
				iEET.infoFrame = CreateFrame('Frame', 'iEETOptionsFrame', UIParent)
				iEET.infoFrame:SetPoint('TOPLEFT', iEET.optionsFrameTop, 'TOPRIGHT', -1,0)
				iEET.infoFrame:SetBackdrop(iEET.backdrop);
				iEET.infoFrame:SetBackdropColor(0.1,0.1,0.1,0.9)
				iEET.infoFrame:SetBackdropBorderColor(0.64,0,0,1)
				iEET.infoFrame:Show()
				iEET.infoFrame:SetFrameStrata('DIALOG')
				iEET.infoFrame:SetFrameLevel(1)
				if not iEET.frame then
					iEET.scale = (GetScreenHeight()/GetScreenWidth()/iEET.infoFrame:GetEffectiveScale())
				end
				iEET.infoFrame:SetScale(iEET.scale)
				iEET.infoFrame.text = iEET.infoFrame:CreateFontString()
				iEET.infoFrame.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
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
31/MONSTER_YELL]]
				iEET.infoFrame.text:SetText(infoText)
				iEET.infoFrame.text:Show()
				iEET.infoFrame:SetSize(iEET.infoFrame.text:GetStringWidth()+4,iEET.infoFrame.text:GetStringHeight()+4)
			end
		end
	end
	--Info button
	iEET.infoButton = CreateFrame('FRAME', nil, iEET.optionsFrame)
	iEET.infoButton:SetSize(21, 21)
	iEET.infoButton:SetPoint('TOPRIGHT', iEET.optionsFrameTop, 'TOPRIGHT', -2, -2)
	iEET.infoButton:SetBackdrop(iEET.backdrop);
	iEET.infoButton:SetBackdropColor(0.1,0.1,0.1,0.9)
	iEET.infoButton:SetBackdropBorderColor(0.64,0,0,1)
	iEET.infoButton:SetScript('OnEnter', function()
		infoFrame()
	end)
	iEET.infoButton:SetScript('OnLeave', function()
		infoFrame(true)
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
	iEET.optionsFrameFilterTexts:SetScript("OnMouseWheel", function(self, delta)
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
	iEET.optionsFrameEditbox:SetBackdropColor(0.1,0.1,0.1,0.2)
	iEET.optionsFrameEditbox:SetBackdropBorderColor(0,0,0,1)
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
	-- Save button
	iEET.optionsFrameSaveButton = CreateFrame('BUTTON', nil, iEET.optionsFrame)
	iEET.optionsFrameSaveButton:SetSize(100, 20)
	iEET.optionsFrameSaveButton:SetBackdrop(iEET.backdrop);
	iEET.optionsFrameSaveButton:SetBackdropColor(0.1,0.1,0.1,0.9)
	iEET.optionsFrameSaveButton.text = iEET.optionsFrameSaveButton:CreateFontString()
	iEET.optionsFrameSaveButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.optionsFrameSaveButton.text:SetPoint('CENTER', iEET.optionsFrameSaveButton, 'CENTER', 0,0)
	iEET.optionsFrameSaveButton.text:SetText('Save')
	iEET.optionsFrameSaveButton:SetBackdropBorderColor(0.64,0,0,1)
	iEET.optionsFrameSaveButton:SetPoint('BOTTOMRIGHT', iEET.optionsFrame, 'BOTTOM', -2,4)
	iEET.optionsFrameSaveButton:Show()
	iEET.optionsFrameSaveButton:RegisterForClicks('AnyUp')
	iEET.optionsFrameSaveButton:SetScript('OnClick',function()
		--Parse filters from scrolling message frame
		iEET:ParseFilters()
	end)
	-- Cancel button
	iEET.optionsFrameCancelButton = CreateFrame('BUTTON', nil, iEET.optionsFrame)
	iEET.optionsFrameCancelButton:SetSize(100, 20)
	iEET.optionsFrameCancelButton:SetBackdrop(iEET.backdrop);
	iEET.optionsFrameCancelButton:SetBackdropColor(0.1,0.1,0.1,0.9)
	iEET.optionsFrameCancelButton.text = iEET.optionsFrameCancelButton:CreateFontString()
	iEET.optionsFrameCancelButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.optionsFrameCancelButton.text:SetPoint('CENTER', iEET.optionsFrameCancelButton, 'CENTER', 0,0)
	iEET.optionsFrameCancelButton.text:SetText('Cancel')
	iEET.optionsFrameCancelButton:SetBackdropBorderColor(0.64,0,0,1)
	iEET.optionsFrameCancelButton:SetPoint('BOTTOMLEFT', iEET.optionsFrame, 'BOTTOM', 2,4)
	iEET.optionsFrameCancelButton:Show()
	iEET.optionsFrameCancelButton:RegisterForClicks('AnyUp')
	iEET.optionsFrameCancelButton:SetScript('OnClick',function()
		-- clear unsaved args & close
		iEET.optionsFrameEditbox:SetText('')
		iEET.optionsFrame:Hide()
	end)
	iEET:FillFilters()
end
function iEET:Options()
	if iEET.optionsFrame then
		if iEET.optionsFrame:IsShown() then
			iEET.optionsFrame:Hide()
		else
			iEET.optionsFrame:Show()
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
		iEET.copyFrame:SetBackdropColor(0.1,0.1,0.1,0.2)
		iEET.copyFrame:SetBackdropBorderColor(0.5,0,0,1)
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
function iEET:copyCurrent()

	--iEET['content' .. i]GetCurrentLine()
	local totalData = ''
	for line = 1, iEET.content1:GetNumMessages() do
		local lineData = ''
		for i = 1, 8 do
			lineData = lineData .. iEET['content' .. i]:GetMessageInfo(line) .. '\t'
		end
		totalData = totalData .. '\r' .. string.gsub(lineData, '+', '') --+SAURA etc messes excel so remove +, should be enough for excel
	end
	iEET:toggleCopyFrame(true)
	iEET.copyFrame:SetText(totalData)
end
function iEET:ExportData(auto)
	if iEET.encounterInfoData then -- nil check
		if auto then
			local m,s = string.match(iEET.encounterInfoData.fT, '(%d):(%d)')
			--print(iEET.encounterInfoData.fightTime)
			if m*60+s < iEETConfig.autoDiscard then
				iEET:print('discarded', m*60+s)
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
SLASH_IEET1 = "/ieet"
SlashCmdList["IEET"] = function(msg)
	if string.match(msg, 'copy') then
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
	else
		iEET:Toggle()
	end
end
BINDING_HEADER_IEET = 'iEncounterEventTracker'
BINDING_NAME_IEET_TOGGLE = 'Toggle window'
BINDING_NAME_IEET_EXPORT = 'Export Data'
BINDING_NAME_IEET_COPY = 'Copy currently shown fight to spreadsheet'
BINDING_NAME_IEET_OPTIONS = 'Show filtering options window'
function IEET_TOGGLE(window)
	if window == 'frame' then
		iEET:Toggle()
	elseif window == 'copy' and not InCombatLockdown() then
		iEET:copyCurrent()
	elseif window == 'export' and not InCombatLockdown() then
		iEET:ExportData()
	elseif window == 'options' and not InCombatLockdown() then
		iEET:Options()
	end
end
function iEET_Debug(v)
	return iEET[v]
end