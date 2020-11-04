local _, iEET = ...
local spairs = iEET.spairs

local maxLengths = iEET.frameSizes.maxLengths

local function _addMessages(col, msg)
  if msg and _maxLengths[col] then msg = msg:sub(1, _maxLengths[col]) end
  iEET['content' .. col]:AddMessage(msg or " ")
end

local function _addToContent(timestamp,event,casterName,targetName,spellName,spellID,interval,count,sourceGUID, hp, extraData, destGUID, realTimeStamp, id)
	_addMessages(1, timestamp and string.format("%.1f",timestamp) or nil)
  _addMessages(2, interval and string.format("%.1f",interval) or nil)
  _addMessages(3, iEET.events.fromID[event].s)
  _addMessages(4, spellName)
	_addMessages(5, casterName)
	_addMessages(6, targetName)
  _addMessages(7, hp)
  _addMessages(8, count)
end
local function _oldLoopData()
  if iEET.encounterInfo then
    iEET.encounterInfo:SetBackdropBorderColor(0,0,1,1)
  end
	iEET.loopDataCall = GetTime()
	iEET.frame:Hide() -- avoid fps spiking from ScrollingMessageFrame adding too many messages
	if iEET.encounterInfoData and iEET.encounterInfoData.eN then
		iEET.encounterInfo.text:SetText(string.format('%s(%s) %s %s, %s by %s', iEET.encounterInfoData.eN,string.sub(GetDifficultyInfo(iEET.encounterInfoData.d),1,1),(iEET.encounterInfoData.k == 1 and '+' or '-'),iEET.encounterInfoData.fT, iEET.encounterInfoData.pT, iEET.encounterInfoData.lN or UNKNOWN))
	end
	local starttime = 0
	local intervals = {}
	local counts = {}
	for i=1, 8 do
		iEET['content' .. i]:Clear()
	end
	iEET.encounterAbilitiesContent:Clear()
	iEET.commonAbilitiesContent:Clear()
	for k,v in ipairs(iEET.data) do
		if v.e == 27 or v.e == 37 then -- ENCOUNTER_START
			starttime = v.t
		end
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
    _addToContent(timestamp,v.e,v.cN,v.tN,v.sN,v.sI,interval,count,v.sG,v.hp,v.eD, v.dG, v.t, k)
		end
	end
	-- Update Slider values
	iEET.maxScrollRange = iEET['content' .. 1]:GetMaxScrollRange()
	iEET.mainFrameSlider:SetMinMaxValues(0, iEET.maxScrollRange)
	iEET.mainFrameSlider:SetValue(iEET.maxScrollRange)
	iEET.frame:Show()
end

function iEET:oldImport(dataKey)
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
	_oldLoopData()
	iEET:print(string.format('!! OLD log!! Imported %s on %s (%s), %sman (%s), Time: %s, Logger: %s.',iEET.encounterInfoData.eN,GetDifficultyInfo(iEET.encounterInfoData.d),iEET.encounterInfoData.fT, iEET.encounterInfoData.rS, (iEET.encounterInfoData.k == 1 and 'kill' or 'wipe'), iEET.encounterInfoData.pT, iEET.encounterInfoData.lN or UNKNOWN))
end