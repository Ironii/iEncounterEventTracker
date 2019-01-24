local _, iEET = ...
local startTime = 0
local currentFightData = {}
local function GetSpellData(sourceGUID, event, spellID, timestamp)
  if not sourceGUID then return nil,nil end
  if not currentFightData[sourceGUID] then
    currentFightData[sourceGUID] = {
      [event] = {
        [spellID] = {
          lastCast = timestamp,
          count = 1,
        },
      },
    }
    return nil, 1
  end
  if not currentFightData[sourceGUID][event] then
    currentFightData[sourceGUID][event] = {
        [spellID] = {
          lastCast = timestamp,
          count = 1,
        },
    }
    return nil, 1
  end
  if not currentFightData[sourceGUID][event][spellID] then
    currentFightData[sourceGUID][event][spellID] = {
      lastCast = timestamp,
      count = 1,
    }
    return nil, 1
  end
  local interval = timestamp - currentFightData[sourceGUID][event][spellID].lastCast
  currentFightData[sourceGUID][event][spellID].lastCast = timestamp
  currentFightData[sourceGUID][event][spellID].count = currentFightData[sourceGUID][event][spellID].count + 1
  return interval, currentFightData[sourceGUID][event][spellID].count
end
function iEET:OnscreenAddMessages(data)
  if not iEETConfig.onscreen.enabled or iEETConfig.onscreen.ignoredEvents[data.e] then return end
  if not iEET.onscreen then iEET:CreateOnscreenFrame() end
  if data.e == 27 or data.e == 37 then -- ENCOUNTER_START
    startTime = data.t
  end
  if data.e == 27 or data == 37 then -- ENCOUNTER_START,MANUAL_LOGGING_START
    currentFightData = {}
  end
  local timestamp = data.t - startTime
  local interval, count = GetSpellData(data.sG, data.e, data.sI, data.t)
  --local event,timestamp,event,casterName,targetName,spellName,spellID,interval,count,sourceGUID,hp,extraData,destGUID,realTimeStamp
  local color = iEET:getColor(data.e, data.sG, data.sI)
	iEET:addMessages(3, 1, timestamp, color, '\124HiEETTotaltime:' .. timestamp..':'.. data.t..'\124h%s\124h')
	iEET:addMessages(3, 2, interval, color, interval and ('\124HiEETtime:' .. interval ..'\124h%s\124h') or nil)
	iEET:addMessages(3, 3, iEET.events.fromID[data.e].s, color)
	if data.e == 29 or data.e == 30 or data.e == 31 or data.e == 43 or data.e == 44 or data.e == 45 or data.e == 46 then -- MONSTER_EMOTE = 29, MOSNTER_SAY = 30, MONSTER_YELL = 31, RAID_BOSS_EMOTE = 43, RAID_BOSS_WHISPER = 44
		local msg = data.sI
		if data.e == 29 or data.e == 43 or data.e == 44 or data.e == 45 or data.e == 46 then --trying to fix monster emotes, MONSTER_EMOTE
			msg = iEET:removeExtras(data.sI, true)
		end
    if data.e == 43 or data.e == 44 or data.e == 45 or data.e == 46 then --RAID_BOSS_EMOTE,RAID_BOSS_WHISPER,CHAT_MSG_RAID_BOSS_WHISPER,CHAT_MSG_RAID_BOSS_EMOTE
      local sID = msg:match('spell;;(%d+)')
			if sID then
				local s = 'Message'
				local sN = Spell:CreateFromSpellID(sID):GetSpellName() or 'Message'
				iEET:addMessages(3, 4, sN, color, '\124HiEETcustomyell:' .. data.e .. ':' .. msg .. '\124h%s\124h')
			else
				iEET:addMessages(3, 4, 'Message', color, '\124HiEETcustomyell:' .. data.e .. ':' .. msg .. '\124h%s\124h') -- NEEDS CHANGING
			end
		else
			iEET:addMessages(3, 4, 'Message', color, '\124HiEETcustomyell:' .. data.e .. ':' .. msg .. '\124h%s\124h') -- NEEDS CHANGING
		end
	elseif data.e == 47 or data.e == 48 or data.e == 49 or data.e == 50 or data.e == 51 or data.e == 52 then -- BigWigs
		local spellName = iEET:removeExtras(data.sN)
		if data.e == 52 then -- BigWigs_StopBars
			iEET:addMessages(3, 4, spellName, color)
		elseif data.e == 47 or data.e == 48 then -- BigWigs_BarCreated, BigWigs_Message
      local sn
      local spellID = tonumber(data.sI)
			if spellID then
				if spellID > 0 then -- spellID
					sn = Spell:CreateFromSpellID(spellID):GetSpellName()
					if not sn then -- PTR nil check
						sn = spellID
					end
				else -- Encounter journal section ID
					sn = C_EncounterJournal.GetSectionInfo(-spellID)
          if sn then
            sn = sn.title
          else -- PTR nil check, shouldn't be needed but copy-paste ftw, maybe change it later
						sn = spellID
					end
				end
			else
				sn = data.sI
			end
			iEET:addMessages(3, 4, sn, color, '\124HiEETBW:' .. data.e .. ':' .. spellName .. '\124h%s\124h')
		else -- BigWigs_PauseBar, BigWigs_ResumeBar, BigWigs_StopBar
			iEET:addMessages(3, 4, spellName:gsub(';;', ':'), color, '\124HiEETBW_NOKEY:' .. data.e .. ':' .. spellName .. '\124h%s\124h')
		end
	elseif data.sI then
		if data.sI == iEET.fakeSpells.SpawnNPCs.spellID then -- INSTANCE_ENCOUNTER_ENGAGE_UNIT
			iEET:addMessages(3, 4, data.sN, color,'\124HiEETNpcList:' .. data.sG .. '\124h%s\124h')
		elseif data.e and data.e == 34 then -- UNIT_POWER
			iEET:addMessages(3, 4, data.sN, color,'\124HiEETList:' .. (data.eD and string.gsub(data.eD, '%%', '%%%%') or 'Empty List;Contact Ironi') .. '\124h%s\124h')
		else
			local unitType, _, serverID, instanceID, zoneID, npcID, spawnID
      if data.sG then
        if string.find(data.sG, 'boss') then
          npcID = data.sG
        else
          unitType, _, serverID, instanceID, zoneID, npcID, spawnID = strsplit("-", data.sG)
        end
			else
				npcID = 'NONE'
			end
			iEET:addMessages(3, 4, data.sN, color, '\124HiEETcustomspell:' .. data.e ..
				':' .. data.sI .. ':' .. string.gsub(data.sN, '%%', '%%%%') ..
				':' .. (npcID and (npcID .. (spawnID and ('!' .. spawnID) or '')) or 'NONE')
				.. ((data.dG and data.dG:len() > 0) and (':'.. data.dG) or '')
				..'\124h%s\124h')
		end
	elseif data.e == 27 or data.e == 28 then -- ENCOUNTER_START, ENCOUNTER_END
			iEET:addMessages(3, 4, data.sN, color)
	else
		iEET.onscreenContent4:AddMessage(' ')
	end
	local targetColor,sourceColor, classColor, sourceHyperlink, targetHyperlink
	if iEETConfig.classColors then
		if data.eD and data.eD:match('^%d-\n%d-\n%-*') then
			local toColor = string.match(data.eD,'^(%d-)\n')
			if toColor == '3' then
				local stringToSplit = string.gsub(data.eD,'^(%d-)\n', '')
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
				local _,classIndex, role = strsplit('\n',data.eD)
				local localizedClass, class = GetClassInfo(tonumber(classIndex))
				if toColor == '1' then
					sourceColor = {RAID_CLASS_COLORS[class].r,RAID_CLASS_COLORS[class].g,RAID_CLASS_COLORS[class].b}
					sourceHyperlink = '\124HiEETList:' .. localizedClass .. '\n' .. role .. '\124h%s\124h'
				elseif toColor == '2' then
					targetColor = {RAID_CLASS_COLORS[class].r,RAID_CLASS_COLORS[class].g,RAID_CLASS_COLORS[class].b}
					targetHyperlink = '\124HiEETList:' .. localizedClass .. '\n' .. role .. '\124h%s\124h'
				end
			end
		end
	end
	iEET:addMessages(3, 5, data.cN, (sourceColor or color),sourceHyperlink)
	iEET:addMessages(3, 6, data.tN, (targetColor or color),targetHyperlink)
	iEET:addMessages(3, 7, count, color)
  iEET:addMessages(3, 8, data.hp, color)
  if data == 28 or data == 38 then --ENCOUNTER_END,MANUAL_LOGGING_END
    currentFightData = {}
  end
end

