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
iEET.ignoreFilters = false
local ignoreFiltersTimer

function addon:ADDON_LOADED(addonName)
	if addonName == 'iEncounterEventTracker' then
		C_ChatInfo.RegisterAddonMessagePrefix('iEET')
		addon:RegisterEvent('CHAT_MSG_ADDON')
		iEETConfig = iEETConfig or {}
		iEET_Data = iEET_Data or {}
		if iEETConfig.version and iEETConfig.version < 1.8 then
			iEETConfig.tracking = nil
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
			['rS'] = raidSize,
			['k'] = 0,
			['zI'] = mapID,
			['v'] = iEET.version,
			['eI'] = encounterID,
			['d'] = difficultyID,
			['lN'] = UnitName('player')
		}
	end
	local t = {['e'] = 27, ['t'] = GetTime(), ['cN'] = encounterName, ['tN'] = encounterID, ['sN'] = 'Logger: '..UnitName('player')}
	table.insert(iEET.data, t)
	iEET:OnscreenAddMessages(t)
end
function addon:ENCOUNTER_END(EncounterID, encounterName, difficultyID, raidSize, kill,...)
	local t = {['e'] = 28, ['t'] = GetTime() ,['cN'] = kill == 1 and 'Victory!' or 'Wipe', ['tN'] = EncounterID,  ['sN'] = 'Logger: '..UnitName('player')}
	table.insert(iEET.data, t)
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
				['lN'] = UnitName('player')
			}
		end
		iEET:StopRecording()
	end
	iEET:OnscreenAddMessages(t)
end
function addon:UNIT_SPELLCAST_SUCCEEDED(unitID, arg2,spellID)
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
		--3-2084-1520-9097-202968-0028916A53
		--[[
		if isAlpha then
			local id = select(5, strsplit('-', arg4))
			spellID = tonumber(id)
		end
		--]]
		if not iEET.npcIgnoreList[tonumber(npcID)] then
			if not iEET.ignoredSpells[spellID] then
				local t = {
					['e'] = 26,
					['t'] = GetTime(),
					['sG'] = sourceGUID or 'NONE',
					['cN'] = sourceName or 'NONE',
					['tN'] = unitID or nil,
					['sN'] = Spell:CreateFromSpellID(spellID):GetSpellName() or nil,
					['sI'] = spellID or nil,
					['hp'] = php or nil,
				}
				table.insert(iEET.data, t);
				iEET:OnscreenAddMessages(t)
			end
		end
	end
end
function addon:UNIT_SPELLCAST_START(unitID, arg2,spellID)
	local sourceGUID = UnitGUID(unitID)
	local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
	if sourceGUID then -- fix for arena id's
		unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
	end
	if iEET.ignoreFilters or (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and iEET.approvedSpells[spellID]) or not sourceGUID then
		local sourceName = UnitName(unitID)
		local chp = UnitHealth(unitID)
		local maxhp = UnitHealthMax(unitID)
		local php = nil
		if chp and maxhp then
			php = math.floor(chp/maxhp*1000+0.5)/10
		end
		if not iEET.npcIgnoreList[tonumber(npcID)] then
			if not iEET.ignoredSpells[spellID] then
				local t = {
					['e'] = 39,
					['t'] = GetTime(),
					['sG'] = sourceGUID or 'NONE',
					['cN'] = sourceName or 'NONE',
					['tN'] = unitID or nil,
					['sN'] = Spell:CreateFromSpellID(spellID):GetSpellName() or nil,
					['sI'] = spellID or nil,
					['hp'] = php or nil,
				}
				table.insert(iEET.data, t);
				iEET:OnscreenAddMessages(t)
			end
		end
	end
end
function addon:UNIT_SPELLCAST_CHANNEL_START(unitID, arg2,spellID)
	local sourceGUID = UnitGUID(unitID)
	local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
	if sourceGUID then -- fix for arena id's
		unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", sourceGUID)
	end
	if iEET.ignoreFilters or (unitType == 'Creature') or (unitType == 'Vehicle') or (spellID and iEET.approvedSpells[spellID]) or not sourceGUID then
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
				local t = {
					['e'] = 40,
					['t'] = GetTime(),
					['sG'] = sourceGUID or 'NONE',
					['cN'] = sourceName or 'NONE',
					['tN'] = unitID or nil,
					['sN'] = Spell:CreateFromSpellID(spellID):GetSpellName() or nil,
					['sI'] = spellID or nil,
					['hp'] = php or nil,
				}
				table.insert(iEET.data, t);
				iEET:OnscreenAddMessages(t)
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
	if iEET.ignoreFilters or (unitType == 'Creature') or (unitType == 'Vehicle') or not sourceGUID then
		local sourceName = UnitName(unitID)
		local chp = UnitHealth(unitID)
		local maxhp = UnitHealthMax(unitID)
		local php = nil
		if chp and maxhp then
			php = math.floor(chp/maxhp*1000+0.5)/10
		end
		if not iEET.npcIgnoreList[tonumber(npcID)] then
			if not iEET.ignoredSpells[spellID] then
				local t = {
					['e'] = 41,
					['t'] = GetTime(),
					['sG'] = sourceGUID or 'NONE',
					['cN'] = sourceName or 'NONE',
					['tN'] = unitID or nil,
					['sN'] = '-'..iEET.fakeSpells.InterruptShield.name,
					['sI'] = iEET.fakeSpells.InterruptShield.spellID,
					['hp'] = php or nil,
				}
				table.insert(iEET.data, t);
				iEET:OnscreenAddMessages(t)
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
	if iEET.ignoreFilters or (unitType == 'Creature') or (unitType == 'Vehicle') or not sourceGUID then
		local sourceName = UnitName(unitID)
		local chp = UnitHealth(unitID)
		local maxhp = UnitHealthMax(unitID)
		local php = nil
		if chp and maxhp then
			php = math.floor(chp/maxhp*1000+0.5)/10
		end
		if not iEET.npcIgnoreList[tonumber(npcID)] then
			if not iEET.ignoredSpells[spellID] then
				local t = {
					['e'] = 42,
					['t'] = GetTime(),
					['sG'] = sourceGUID or 'NONE',
					['cN'] = sourceName or 'NONE',
					['tN'] = unitID or nil,
					['sN'] = '+'..iEET.fakeSpells.InterruptShield.name,
					['sI'] = iEET.fakeSpells.InterruptShield.spellID,
					['hp'] = php or nil,
				}
				table.insert(iEET.data, t);
				iEET:OnscreenAddMessages(t)
			end
		end
	end
end
function addon:UNIT_TARGET(unitID)
	if iEET.ignoreFilters or string.find(unitID, 'boss') then
		if UnitExists(unitID) then --didn't just disappear
			local sourceGUID = UnitGUID(unitID)
			local sourceName = UnitName(unitID)
			local chp = UnitHealth(unitID)
			local maxhp = UnitHealthMax(unitID)
			local php = nil
			local targetName = UnitName(unitID .. 'target') or 'No target'
			if chp and maxhp then
				php = math.floor(chp/maxhp*1000+0.5)/10
			end
			local t = {
				['e'] = 32,
				['t'] = GetTime(),
				['sG'] = unitID,
				['cN'] = sourceName or unitID,
				['tN'] = targetName,
				['sN'] = iEET.fakeSpells.UnitTargetChanged.name,
				['sI'] = iEET.fakeSpells.UnitTargetChanged.spellID,
				['hp'] = php,
				}
			table.insert(iEET.data, t);
			iEET:OnscreenAddMessages(t)
		end
	end
end
function addon:UNIT_POWER_UPDATE(unitID, powerType)
	if iEET.ignoreFilters or unitID:find('boss') then
		if UnitExists(unitID) then --didn't just disappear
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
			local t = {
				['e'] = 34,
				['t'] = GetTime(),
				['sG'] = unitID,
				['cN'] = sourceName or unitID,
				['tN'] = pUP .. '%',
				['sN'] = iEET.savedPowers[powerType].n .. ' Update',
				['sI'] = iEET.fakeSpells.PowerUpdate.spellID, -- Power Regen
				['hp'] = php,
				['eD'] = tooltipText, --eD = extraData
				}
			table.insert(iEET.data, t);
			iEET:OnscreenAddMessages(t)
		end
	end
end
function addon:UNIT_ENTERING_VEHICLE(unitID, hasVehicleUI,arg3,vehicleID, destGUID, isPlayerControlled, canAim)
	local sourceGUID = UnitGUID(unitID)
	local sourceName = UnitName(unitID)
	local slots = 0
	if vehicleID and vehicleID ~= 0 then
		local t,i = GetVehicleUIIndicator(vehicleID)
		slots = i
	end
	local eD = string.format("%s:%s:%s:%s", (hasVehicleUI and 1 or 0), slots, (isPlayerControlled and 1 or 0), (canAim and 1 or 0))
	local t = {
		['e'] = 53,
		['t'] = GetTime(),
		['sG'] = sourceGUID or 'NONE',
		['cN'] = sourceName or 'NONE',
		['tN'] = unitID or nil,
		['dG'] = destGUID,
		['sN'] = iEET.fakeSpells.VehicleEntering.name,
		['sI'] = iEET.fakeSpells.VehicleEntering.spellID,
		['eD'] = eD,
	}
	table.insert(iEET.data, t);
	iEET:OnscreenAddMessages(t)
end
function addon:UNIT_ENTERED_VEHICLE(unitID, hasVehicleUI,arg3,vehicleID, destGUID, isPlayerControlled, canAim)
	local sourceGUID = UnitGUID(unitID)
	local sourceName = UnitName(unitID)
	local slots = 0
	if vehicleID and vehicleID ~= 0 then
		local t,i = GetVehicleUIIndicator(vehicleID)
		slots = i
	end
	local eD = string.format("%s:%s:%s:%s", (hasVehicleUI and 1 or 0), slots, (isPlayerControlled and 1 or 0), (canAim and 1 or 0))
	local t = {
		['e'] = 54,
		['t'] = GetTime(),
		['sG'] = sourceGUID or 'NONE',
		['cN'] = sourceName or 'NONE',
		['tN'] = unitID or nil,
		['dG'] = destGUID,
		['sN'] = iEET.fakeSpells.VehicleEntered.name,
		['sI'] = iEET.fakeSpells.VehicleEntered.spellID,
		['eD'] = eD,
	}
	table.insert(iEET.data, t);
	iEET:OnscreenAddMessages(t)
end
function addon:UNIT_EXITING_VEHICLE(unitID)
	local sourceGUID = UnitGUID(unitID)
	local sourceName = UnitName(unitID)
	local t = {
		['e'] = 55,
		['t'] = GetTime(),
		['sG'] = sourceGUID or 'NONE',
		['cN'] = sourceName or 'NONE',
		['tN'] = unitID or nil,
		['sN'] = iEET.fakeSpells.VehicleExiting.name,
		['sI'] = iEET.fakeSpells.VehicleExiting.spellID,
	}
	table.insert(iEET.data, t);
	iEET:OnscreenAddMessages(t)
end
function addon:UNIT_EXITED_VEHICLE(unitID)
	local sourceGUID = UnitGUID(unitID)
	local sourceName = UnitName(unitID)
	local t = {
		['e'] = 56,
		['t'] = GetTime(),
		['sG'] = sourceGUID or 'NONE',
		['cN'] = sourceName or 'NONE',
		['tN'] = unitID or nil,
		['sN'] = iEET.fakeSpells.VehicleExited.name,
		['sI'] = iEET.fakeSpells.VehicleExited.spellID,
	}
	table.insert(iEET.data, t);
	iEET:OnscreenAddMessages(t)
end
function addon:COMBAT_LOG_EVENT_UNFILTERED()
	local args = {CombatLogGetCurrentEventInfo()}
	-- args[2] = sub event
	if cleuEventsToTrack[args[2]] then
		local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
		if args[4] then -- sourceGUID, fix for arena id's
			unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", args[4]) -- sourceGUID
		end
		if args[2] == 'UNIT_DIED' then
			unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", args[8]) -- destGUID
			if iEET.ignoreFilters or (unitType == 'Creature') or (unitType == 'Vehicle') or (unitType == 'Player') then
				if iEET.ignoreFilters or not iEET.npcIgnoreList[tonumber(npcID)] then
					local t = {
						['e'] = 25,
						['t'] = GetTime(),
						['sG'] = args[8] or 'NONE', -- destGUID
						['cN'] = args[9] or 'NONE', -- destName
						['sN'] = iEET.fakeSpells.Death.name,
						['sI'] = iEET.fakeSpells.Death.spellID,
					}
					table.insert(iEET.data, t)
					iEET:OnscreenAddMessages(t)
				end
			end
		elseif iEET:shouldTrack(args[2], unitType, npcID, args[12], args[4], args[3]) then
					-- args[4] = sourceGUID, arg[8] = destGUID
					local eD
					if iEET.raidComp then
						if iEET.raidComp[args[8]] or iEET.raidComp[args[4]] then --destGUID, sourceGUID
							local toColor = 1
							local guidToColor = args[8]
							if iEET.raidComp[args[8]] and iEET.raidComp[args[4]] then
								toColor = 3 -- both
								guidToColor = {args[4],args[8]}
							elseif iEET.raidComp[args[8]] then
								toColor = 2 -- target
								guidToColor = args[8]
							else
								toColor = 1 -- source
								guidToColor = args[4]
							end
							--eD = toColor..'\n'..iEET.raidComp[destGUID].class..'\n'..iEET.raidComp[destGUID].role
							if toColor < 3 then -- source or target
								eD = toColor..'\n'..iEET.raidComp[guidToColor].class..'\n'..iEET.raidComp[guidToColor].role
							else -- both
								eD = toColor..'\n'..iEET.raidComp[guidToColor[1]].class..'\n'..iEET.raidComp[guidToColor[1]].role .. ';' .. '\n'..iEET.raidComp[guidToColor[2]].class..'\n'..iEET.raidComp[guidToColor[2]].role
							end
						end
					end
					local t = {
						['e'] = iEET.events.toID[args[2]],
						['t'] = GetTime(),
						['sG'] = args[4] or 'NONE', -- sourceGUID
						['cN'] = args[5] or 'NONE', -- sourceName
						['tN'] = args[9] or nil, -- destName
						['dG'] = args[8] or nil, -- destGUID
						['sN'] = args[13] or 'NONE', -- spellName
						['sI'] = args[12] or 'NONE', -- spellID
						['eD']= eD,
						['hp']= iEET.auraEvents[args[2]] and (args[15] == 'DEBUFF' and '-' or '+') or nil, -- auraType for spell_aura_*
					}
					table.insert(iEET.data, t)
					iEET:OnscreenAddMessages(t)
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
	local t = {
		['e'] = 33,
		['t'] = GetTime(),
		['sG'] = npcNames or 'NONE',
		['cN'] = sourceName or 'NONE',
		['tN'] = unitID,
		['sN'] = iEET.fakeSpells.SpawnNPCs.name,
		['sI'] = iEET.fakeSpells.SpawnNPCs.spellID,
	}
	table.insert(iEET.data, t)
	iEET:OnscreenAddMessages(t)
end
function addon:CHAT_MSG_MONSTER_EMOTE(msg, sourceName)
	local t = {
		['e'] = 29,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName,
		['sG'] = sourceName,
	}
	table.insert(iEET.data, t)
	iEET:OnscreenAddMessages(t)
end
function addon:CHAT_MSG_MONSTER_SAY(msg, sourceName)
	local t = {
		['e'] = 30,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName,
		['sG'] = sourceName,
	}
	table.insert(iEET.data, t);
	iEET:OnscreenAddMessages(t)
end
function addon:CHAT_MSG_MONSTER_YELL(msg, sourceName)
	local t = {
		['e'] = 31,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName,
		['sG'] = sourceName,
	}
	table.insert(iEET.data, t);
	iEET:OnscreenAddMessages(t)
end
function addon:RAID_BOSS_EMOTE(msg, sourceName,_,_,destName)
	local t = {
		['e'] = 43,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName or UNKNOWN,
		['sG'] = sourceName or UNKNOWN,
		['tN'] = destName and destName or nil,
	}
	table.insert(iEET.data, t)
	iEET:OnscreenAddMessages(t)
end
function addon:RAID_BOSS_WHISPER(msg, sourceName) -- im not sure if there is sourceName, needs testing
	local t = {
		['e'] = 44,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName or UNKNOWN,
		['sG'] = sourceName or UNKNOWN,
		['tN'] = 'player', -- meh
	}
	table.insert(iEET.data, t)
	iEET:OnscreenAddMessages(t)
end
function addon:CHAT_MSG_RAID_BOSS_EMOTE(msg, sourceName,_,_,destName)
	local t = {
		['e'] = 46,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName or UNKNOWN,
		['sG'] = sourceName or UNKNOWN,
		['tN'] = destName and destName or nil,
	}
	table.insert(iEET.data, t)
	iEET:OnscreenAddMessages(t)
end
function addon:CHAT_MSG_RAID_BOSS_WHISPER(msg, sourceName)
	local t = {
		['e'] = 45,
		['t'] = GetTime(),
		['sI'] = msg,
		['cN'] = sourceName or UNKNOWN,
		['sG'] = sourceName or UNKNOWN,
		['tN'] = 'player',
	}
	table.insert(iEET.data, t)
	iEET:OnscreenAddMessages(t)
end
function addon:PLAYER_REGEN_DISABLED()
	local t = {['e'] = 35, ['t'] = GetTime() ,['cN'] = '+Combat'}
	table.insert(iEET.data, t)
	iEET:OnscreenAddMessages(t)
end
function addon:PLAYER_REGEN_ENABLED()
	local t = {['e'] = 36, ['t'] = GetTime() ,['cN'] = '-Combat'}
	table.insert(iEET.data, t)
	iEET:OnscreenAddMessages(t)
end
function addon:PLAY_MOVIE(movieID)
	local t = {
		['e'] = 57,
		['t'] = GetTime(),
		['sN'] = iEET.fakeSpells.PlayMovie.name,
		['sI'] = iEET.fakeSpells.PlayMovie.spellID,
		['tN'] = movieID,
	}
	table.insert(iEET.data, t);
	iEET:OnscreenAddMessages(t)
end
function iEET:BigWigsData(event,...)
	local t
	if event == 'BigWigs_BarCreated' then
		local key, text, time, cd = ...
		t = {
			['e'] = 47,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['cN'] = time,
			['tN'] = key,
			['sN'] = text,
			['sI'] = key or text, -- nil check for pull timers etc
			['hp'] = cd and 'CD' or nil,
		}
	elseif event == 'BigWigs_Message' then
		local key,text = ...
		t = {
			['e'] = 48,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['tN'] = key,
			['sN'] = text,
			['sI'] = key or text, -- nil check for pull timers etc
		}
	elseif event == 'BigWigs_PauseBar' then
		local text = ...
		t = {
			['e'] = 49,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['sN'] = text,
			['sI'] = text,
		}
	elseif event == 'BigWigs_ResumeBar' then
		local text = ...
		t = {
			['e'] = 50,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['sN'] = text,
			['sI'] = text,
		}
	elseif event == 'BigWigs_StopBar' then
		local text = ...
		t =  {
			['e'] = 51,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['sN'] = text or 'Stop bar: no key',
			['sI'] = text or 'BWStopBarNoKey',
		}
	elseif event == 'BigWigs_StopBars' then
		t = {
			['e'] = 52,
			['t'] = GetTime(),
			['sG'] = 'BigWigs',
			['sN'] = 'Stop all bars',
			['sI'] = 'BWStopAllBars',
		}
	end
	if not t then return end
	table.insert(iEET.data, t)
	iEET:OnscreenAddMessages(t)
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
	addon:RegisterEvent('UNIT_POWER_UPDATE')
	addon:RegisterEvent('UNIT_SPELLCAST_START')
	addon:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START')
	addon:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE')
	addon:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE')
	addon:RegisterEvent('RAID_BOSS_EMOTE')
	addon:RegisterEvent('RAID_BOSS_WHISPER')
	addon:RegisterEvent('CHAT_MSG_RAID_BOSS_EMOTE')
	addon:RegisterEvent('CHAT_MSG_RAID_BOSS_WHISPER')
	addon:RegisterEvent('UNIT_ENTERING_VEHICLE')
	addon:RegisterEvent('UNIT_ENTERED_VEHICLE')
	addon:RegisterEvent('UNIT_EXITING_VEHICLE')
	addon:RegisterEvent('UNIT_EXITED_VEHICLE')
	addon:RegisterEvent('PLAY_MOVIE')
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
	addon:UnregisterEvent('UNIT_POWER_UPDATE')
	addon:UnregisterEvent('UNIT_SPELLCAST_START')
	addon:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START')
	addon:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE')
	addon:UnregisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE')
	addon:UnregisterEvent('RAID_BOSS_EMOTE')
	addon:UnregisterEvent('RAID_BOSS_WHISPER')
	addon:UnregisterEvent('CHAT_MSG_RAID_BOSS_EMOTE')
	addon:UnregisterEvent('CHAT_MSG_RAID_BOSS_WHISPER')
	addon:UnregisterEvent('UNIT_ENTERING_VEHICLE')
	addon:UnregisterEvent('UNIT_ENTERED_VEHICLE')
	addon:UnregisterEvent('UNIT_EXITING_VEHICLE')
	addon:UnregisterEvent('UNIT_EXITED_VEHICLE')
	addon:UnregisterEvent('PLAY_MOVIE')
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
	local t
	if start then
		iEET:StartRecording(true)
		t = {['e'] = 37, ['t'] = GetTime() ,['cN'] = 'Start Logging'}
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
		t = {['e'] = 38, ['t'] = GetTime() ,['cN'] = 'End Logging'}
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