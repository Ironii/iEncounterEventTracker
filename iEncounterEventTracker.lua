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
better filtering, STARTED
reset & exit button
target tracking
--]]
local _, iEET = ...
iEET.data = {}
iEET.ignoring = {} -- so ignore list resets on relog, don't want to save it, atleast not yet
iEET.font = select(4, GetBuildInfo()) >= 70000 and 'Fonts\\ARIALN.TTF' or 'Interface\\AddOns\\iEncounterEventTracker\\Accidental Presidency.ttf'
iEET.fontsize = 12
iEET.spacing = 2
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
iEET.version = 1.413
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
};
local addon = CreateFrame("Frame")
addon:SetScript("OnEvent", function(self, event, ...)
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
end
function addon:ENCOUNTER_END(EncounterID, encounterName, difficultyID, raidSize, kill)
	table.insert(iEET.data, {['e'] = 28, ['t'] = GetTime() ,['cN'] = kill == 1 and 'Victory!' or 'Wipe'})
	addon:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	addon:UnregisterEvent('CHAT_MSG_MONSTER_SAY')
	addon:UnregisterEvent('CHAT_MSG_MONSTER_EMOTE')
	addon:UnregisterEvent('CHAT_MSG_MONSTER_YELL')
	addon:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
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
<<<<<<< HEAD
		--3-2084-1520-9097-202968-0028916A53
		if select(4, GetBuildInfo()) >= 70000 then
=======
		if select(4, GetBuildInfo()) >= 70000 then
			--3-2084-1520-9097-202968-0028916A53
>>>>>>> cfb37cb32822c8b74adf380115db56567b65c2c1
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
function addon:UNIT_TARGET(unitID)
	
end
function iEET:getColor(event, sourceGUID, spellID)
	if sourceGUID then
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
	elseif event and event == 'ENCOUNTER_START' then
		return {0,1,0}
	elseif event and event == 'ENCOUNTER_END' then
		return {1,0,0}
	else
		return {0,0,0}
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
	if eventData.sI and iEET.ignoring[eventData.sI] then
		shouldShow = false
	elseif not iEETConfig.tracking[iEET.events.fromID[eventData.e].l] then
		shouldShow = false
	elseif iEET.ignoring[eventData.cN] then
		shouldShow = false
	elseif eventData.e == 26 then -- UNIT_SPELLCAST_SUCCEEDED
		local targetName = eventData.tN
		if string.find(eventData.tN, 'nameplate') then
			targetName = 'nameplate'
		end
		if iEET.ignoring[targetName] then
			shouldShow = false
		end
	end
	local timeOK = true
	if shouldShow then
		if #iEETConfig.filtering.timeBasedFiltering > 0 then
			for i = 1, #iEETConfig.filtering.timeBasedFiltering do -- loop trough every from/to combo
				if iEETConfig.filtering.timeBasedFiltering[i].from then
					iEETConfig.filtering.timeBasedFiltering[i].from.ok = false
					if iEETConfig.filtering.timeBasedFiltering[i].from.timestamp then
						if iEETConfig.filtering.timeBasedFiltering[i].from.timestamp <= eventData.t-e_time then
							iEETConfig.filtering.timeBasedFiltering[i].from.ok = true
						end
					else
						for k,v in pairs(eventData) do
							if iEETConfig.filtering.timeBasedFiltering[i].from[k] and string.find(string.lower(v), iEETConfig.filtering.timeBasedFiltering[i].from[k]) then
								iEETConfig.filtering.timeBasedFiltering[i].from.ok = true
							end
						end
					end
				end
				if iEETConfig.filtering.timeBasedFiltering[i].to then
					iEETConfig.filtering.timeBasedFiltering[i].to.ok = false
					if iEETConfig.filtering.timeBasedFiltering[i].to.timestamp then
						if iEETConfig.filtering.timeBasedFiltering[i].to.timestamp >= eventData.t-e_time then
							iEETConfig.filtering.timeBasedFiltering[i].to.ok = true
						end
					else
						for k,v in pairs(eventData) do
							if iEETConfig.filtering.timeBasedFiltering[i].to[k] and string.find(string.lower(v), iEETConfig.filtering.timeBasedFiltering[i].to[k]) then
								iEETConfig.filtering.timeBasedFiltering[i].to.ok = true
							end
						end
					end
				end
			end
			local found = 0
			for i = 1, #iEETConfig.filtering.timeBasedFiltering do
				local ok = true
				if iEETConfig.filtering.timeBasedFiltering[i].from and not iEETConfig.filtering.timeBasedFiltering[i].from.ok then
					ok = false
				end
				if iEETConfig.filtering.timeBasedFiltering[i].to and not iEETConfig.filtering.timeBasedFiltering[i].to.ok then
					ok = false
				end
				if ok then
					found = found + 1
				end
			end
			if (iEETConfig.filtering.requireAll and found == #iEETConfig.filtering.timeBasedFiltering) or (found > 0 and not iEETConfig.filtering.requireAll) then
				timeOK = true
			else
				timeOK = false
			end
		end
		if timeOK then
			if #iEETConfig.filtering.req > 0 or msg then
				for k,v in pairs(eventData) do -- loop trough current event
					for _,t in ipairs(iEETConfig.filtering.req) do
						for requiredKey, requiredValue in pairs(t) do -- try to find right values
							if (k == requiredKey and v == requiredValue) then
								return true -- found right value
							end
						end
					end
					if msg and string.find(string.lower(v),msg) then
						return true
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
	for _,t in pairs(iEETConfig.filtering.req) do
		for k,v in pairs(t) do
			if k == 'e' then
				v = iEET.events.fromID[v].l
			end
			iEET:AddNewFiltering(k .. '=' .. v)
		end
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
		if string.len(spellName) > 20 then
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
	elseif frameID == 5 or frameID == 6 then
		if value and string.len(value) > 16 then
			value = string.sub(value, 1, 16)
		end
	end
	frame:AddMessage(value and value or ' ', unpack(color))
end
function iEET:loopData(msg)
	if #iEETConfig.filtering.timeBasedFiltering > 0 or #iEETConfig.filtering.req > 0 then
		iEET.top:SetBackdropBorderColor(0.64,0,0,1)
	else
		iEET.top:SetBackdropBorderColor(0,0,0,1)
	end
	iEET.loopDataCall = GetTime()
	iEET.frame:Hide()
	local starttime = 0
	local intervalls = {}
	local counts = {}
	colors = {}
	for i=1, 8 do
		iEET['content' .. i]:Clear()
	end
	iEET.encounterAbilitiesContent:Clear()
	local from, to = false, false
	iEET.collector = {
		['encounterNPCs'] = {},
		['encounterSpells'] = {},
	}
	for k,v in ipairs(iEET.data) do
		if v.e == 27 then -- ENCOUNTER_START
			starttime = v.t 
		elseif v.cN and not iEET.collector.encounterNPCs[v.cN] and v.e ~= 26 and v.e ~= 27 then -- Collect npc names & spells| 26 = USCS, 27 = ENCOUNTER_START
			if v.sI and v.sN and not iEET.collector.encounterSpells[v.sI] then
				iEET.collector.encounterSpells[v.sI] = v.sN
				iEET:addToEncounterAbilities(v.sI, v.sN)
			end
			iEET.collector.encounterNPCs[v.cN] = true
		end
		if v.e == 26 then -- UNIT_SPELLCAST_SUCCEEDED
			if v.sI and v.sN and not iEET.collector.encounterSpells[v.sI] then
				iEET.collector.encounterSpells[v.sI] = v.sN
				iEET:addToEncounterAbilities(v.sI, v.sN)
			end
			if string.find(v.tN, 'nameplate') then -- could be safe to assume that there will be atleast one nameplate unitid
				if not not iEET.collector.encounterNPCs then
					iEET.collector.encounterNPCs.nameplates = true
				end
			elseif v.tN and not iEET.collector.encounterNPCs[v.tN] then
				iEET.collector.encounterNPCs[v.tN] = true
			end
		end
		if iEET:ShouldShow(v,starttime, msg) then -- NEW, TESTING
			local intervall = nil
			local timestamp = v.t-starttime or nil
			local casterName = v.cN or nil
			local targetName = v.tN or nil
			local spellName = v.sN or nil
			local spellID = v.sI or nil
			local event = v.e
			local count = nil
			local sourceGUID = v.sG or nil
			local hp = v.hp or nil
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
			if iEETConfig.tracking[iEET.events.fromID[event].l] or event == 27 or event == 28 then -- ENCOUNTER_START & ENCOUNTER_END
					iEET:addToContent(timestamp,event,casterName,targetName,spellName,spellID, intervall,count, sourceGUID,hp)
			end
		end
	end
	iEET.frame:Show()
end
function iEET:AddNewFiltering(txt)
	--print(text) -- Debug
	local newFilters = {}
	-- split by args by ';'
	--[[ temp fix for spellid only tracking
	local temp = { strsplit(';', txt) }
	for v in pairs(temp) do
		print(v)
		local msg = 'spellID:' .. v
	end
	--]]
	if tonumber(txt) then
		txt = 'sI=' .. txt
	end
	iEET.optionsFrameFilterTexts:AddMessage(txt)
	--iEET:addNewFilterToOptionsWindow(arg)
end
function iEET:ClearFilteringArgs()
	iEETConfig.filtering = {
		timeBasedFiltering = {},
		req = {},
		requireAll = false,
		showTime = false, -- show time from nearest 'from' event instead of ENCOUNTER_START
	}
end
function iEET:GetFiltersFromLine(line)
	local t = {}
	for _,arg in pairs({strsplit(';', line)}) do
		if string.match(arg, '^(%a-)=(%d+)') then --change to elseif when from/to filtering is done?
			k,v = string.match(arg, '^(%a-)=(%d+)')
			table.insert(t, {[k] = tonumber(v)})
		elseif string.match(arg, '^(%a-)=(%a+)') then
			k,v = strsplit('=', arg)
			if k == 'e' then
				if not tonumber(v) then
					v = iEET.events.toID[v]
				end
			end
			table.insert(t, {[k] = v})
		elseif tonumber(arg) then
			table.insert(t, {['sI'] = tonumber(arg)})
		end
	end
	if #t > 0 then
		return t
	else
		return
	end
end
function iEET:ParseFilters()
	local function GetFiltersFromLine(line)
		local t = {}
		for _,arg in pairs({strsplit(';', line)}) do
			if string.match(arg, '^(%a-)=(%d+)') then --change to elseif when from/to filtering is done?
				local k,v = string.match(arg, '^(%a-)=(%d+)')
				table.insert(t, {[k] = tonumber(v)})
			elseif string.match(arg, '^(%a-)=(%a+)') then
				local k,v = strsplit('=', arg)
				if k == 'e' then
					if not tonumber(v) then
						v = iEET.events.toID[v]
					end
				end
				table.insert(t, {[k] = v})
			elseif tonumber(arg) then
				table.insert(t, {['sI'] = tonumber(arg)})
			end
		end
		if #t > 0 then
			return t
		else
			return
		end
	end
	--gather all data etc and hide window
	iEET:ClearFilteringArgs()	--Clear old filters
	for i = 1, iEET.optionsFrameFilterTexts:GetNumMessages() do
		local line = iEET.optionsFrameFilterTexts:GetMessageInfo(i)
		--[[
		if string.find(line, 'FROM') or string.find(line, 'TO') then
			local fromTo = {}
			for _,v pairs({strsplit(' AND ', line)}) do	-- NEEDS TESTING
				if string.find(v,'FROM') then
					fromTo.from = GetFiltersFromLine(v)
				else --TO
					fromTo.to = GetFiltersFromLine(v)
				end
			end
			table.insert(iEETConfig.filtering.timeBasedFiltering)
		else
			local t = GetFiltersFromLine(line)
			if t then
				table.insert(iEETConfig.filtering.req, t)
			end
		end
		--]]
		if string.match(line, '^(%a-)=(%d+)') then --change to elseif when from/to filtering is done?
			local k,v = string.match(line, '^(%a-)=(%d+)')
			table.insert(iEETConfig.filtering.req, {[k] = tonumber(v)})
		elseif string.match(line, '^(%a-)=(%a+)') then
			local k,v = strsplit('=', line)
			if k == 'e' then
				if not tonumber(v) then
					v = iEET.events.toID[v]
				end
			end
			table.insert(iEETConfig.filtering.req, {[k] = v})
		elseif tonumber(line) then
			table.insert(iEETConfig.filtering.req, {['sI'] = tonumber(line)})
		end
	end
	iEET:loopData()
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
			if iEET.editbox:GetText() ~= 'Search' then
				iEET:loopData(iEET.editbox:GetText())
			else
				iEET:loopData() 
			end
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
			if iEET.editbox:GetText() ~= 'Search' then
				iEET:loopData(iEET.editbox:GetText())
			else
				iEET:loopData() 
			end
		end})
		table.insert(iEET.optionMenu, tempIgnoreSpells)
	end
	local tempEvents = {text = "Events", hasArrow = true, notCheckable = true, menuList = {}}
	for k,_ in spairs(iEETConfig.tracking) do
		table.insert(tempEvents.menuList, { 
			text = k, 
			isNotRadio = true,
			checked = iEETConfig.tracking[k],
			--checked = false,
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
		if iEET.editbox:GetText() ~= 'Search' then
			iEET:loopData(iEET.editbox:GetText())
		else
			iEET:loopData() 
		end
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
						text = (v.kill == 1 and '+' or '-') .. v.fT .. ' (' .. v.pT .. ')',
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
			if iEET.editbox:GetText() ~= 'Search' then
				iEET:loopData(iEET.editbox:GetText())
			else
				iEET:loopData() 
			end
		end
	end)
	iEET.frame:Show()
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
	-----EXCEL STYLE test -----
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
		
		iEET['content' .. i]:SetIndentedWordWrap(false)
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
		--smf:SetFrameStrata('HIGH')
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
	--]]
	---- END OF EXCEL STYLE TEST ---
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
	local scale = (0.63999998569489/iEET.frame:GetEffectiveScale())
	iEET.frame:SetScale(scale)
	--iEET.editbox = CreateFrame('EditBox', 'iEETEditBox', iEET.frame,'SearchBoxTemplate')
	iEET.editbox = CreateFrame('EditBox', 'iEETEditBox', iEET.frame)
	--local editbox = CreateFrame('EditBox', 'iEETEditBox', f, 'InputBoxTemplate')
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
			iEETConfig.filtering.timeBasedFiltering = {}
			local from, to
			if string.match(txt, '^from:(%d-) to:(%d+)') then
				from, to = string.match(txt, '^from:(%d-) to:(%d+)')
				table.insert(iEETConfig.filtering.timeBasedFiltering, {['from'] = {['timestamp'] = tonumber(from)}, ['to'] = {['timestamp'] = tonumber(to)}})
			elseif string.match(txt, '^from:(%d+)') then
				from = string.match(txt, '^from:(%d+)')
				table.insert(iEETConfig.filtering.timeBasedFiltering, {['from'] = {['timestamp'] = tonumber(from)}})
			elseif string.match(txt, '^to:(%d+)') then
				to = string.match(txt, '^to:(%d+)')
				table.insert(iEETConfig.filtering.timeBasedFiltering, {['to'] = {['timestamp'] = tonumber(to)}})
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
	--f.eventlist:SetFont(font, fontsize, 'OUTLINE')
	iEET.eventlist:SetSize(20, 20)
	iEET.eventlist.texture:SetVertexColor(0.5,0.5,0.5,1)
	iEET.eventlist:SetPoint("LEFT", iEET.top, 'LEFT', 4,-2)
	--f.eventlist:SetText('Events')
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
	iEET:loopData()
	
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
	local scale = (0.63999998569489/iEET.optionsFrame:GetEffectiveScale())
	iEET.optionsFrame:SetScale(scale)
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
		--TO DO: allow ';' splitting
		local txt = iEET.optionsFrameEditbox:GetText()
		if string.match(txt, 'del:(%d+)') then
			local toDelete = tonumber(string.match(txt, 'del:(%d+)'))
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
			iEET:AddNewFiltering(iEET.optionsFrameEditbox:GetText())
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
	iEET.optionsFrameCancelButton.text:SetText('Close')
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
	local s = 
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