local _, iEET = ...
local starttime = 0

local intervals = {}
local counts = {}
local sformat = string.format

local maxLengths = iEET.frameSizes.maxLengths
local function trim(str, col)
	if not str then return " " end
	if type(str) ~= "string" then
		str = tostring(str)
		return str:sub(1, maxLengths[col]) 
	end
	if str == "" then return " " end
	str = str:gsub('|c........', '') -- Colors
	str = str:gsub('|r', '') -- Colors
	str = str:gsub('|T.+|t', '') -- Textures
	str = str:gsub('%%', '%%%%')
	str = str:gsub('|h', '') -- Spells
	str = str:gsub('|H', '') -- Spells
	str = str:gsub('\r', '')
	str = str:sub(1, maxLengths[col])
  return str
end
local function formatForOnscreen(str, col)
  return trim(str, col)
end
local function _addToOnscreen(intervallGUID, eventID, id, _time, interval, col4, col5, col6, col7, count)
  local color = iEET:getColor(intervallGUID)
  iEET:addMessages(3, 1, formatForOnscreen(sformat("%.1f",_time), 1), color)
  iEET:addMessages(3, 2, formatForOnscreen(interval and sformat("%.1f",interval) or nil, 2), color)
  iEET:addMessages(3, 3, formatForOnscreen(iEET.events.fromID[eventID].s, 3), color)
  iEET:addMessages(3, 4, formatForOnscreen(col4, 4), color)
  iEET:addMessages(3, 5, formatForOnscreen(col5, 5), color)
  iEET:addMessages(3, 6, formatForOnscreen(col6, 6), color)
	iEET:addMessages(3, 7, formatForOnscreen(col7, 7), color)
	iEET:addMessages(3, 8, formatForOnscreen(count, 8), color)
end

function iEET:OnscreenAddMessages(data)
  if not iEETConfig.onscreen.enabled or iEETConfig.onscreen.ignoredEvents[data[1]] then return end
  if not iEET.onscreen then iEET:CreateOnscreenFrame() end
	local intervallGUID, specialCategory, col4, col5, col6, col7, collectorData = iEET.eventFunctions[data[1]].gui(data)
	local _time = data[2]
	local timeFromStart
	if starttime == 0 then
		timeFromStart = 0
	else
		timeFromStart = _time - starttime
	end
	if specialCategory == iEET.specialCategories.StartLogging then
		intervals = {}
		counts = {}
		starttime = _time
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
	_addToOnscreen(intervallGUID, data[1], 0, timeFromStart, interval, col4, col5, col6, col7, count)
end