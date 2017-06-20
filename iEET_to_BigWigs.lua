local _, iEET = ...

function iEET:ExportToBigWigs(eventData, func)
	local str = ''
	if func == 1 then -- :Log
		str = string.format(self:Log('"%s", "%s", %s) -- %s', iEET.events.fromID[eventData.e], eventData.sN:gsub(' ', ''), eventData.sI, eventData.sN)
	end
end
