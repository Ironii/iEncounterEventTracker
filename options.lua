local _, iEET = ...
local spairs = iEET.spairs
iEET.optionsMenu = {}
iEET.optionsMenuFrame = CreateFrame('Frame', 'iEETOptionsListMenu', UIParent, 'UIDropDownMenuTemplate')
function iEET:updateOptionsMenu()
	iEET.optionsMenu = nil
	iEET.optionsMenu = {}
	local onscreenIgnoredEvents = {}
	for eventName,eventID in spairs(iEET.events.toID) do
		table.insert(onscreenIgnoredEvents, {
			text = eventName,
			isNotRadio = true,
			checked = iEETConfig.onscreen.ignoredEvents[eventID],
			keepShownOnClick = true,
			func = function()
				if iEETConfig.onscreen.ignoredEvents[eventID] then
					iEETConfig.onscreen.ignoredEvents[eventID] = false
				else
					iEETConfig.onscreen.ignoredEvents[eventID] = true
				end
			end,
		})
	end
  table.insert(iEET.optionsMenu, {text = 'Options', isTitle = true, notCheckable = true})
  table.insert(iEET.optionsMenu, {text = 'Onscreen display', notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = {
    {text ='Enabled', isNotRadio = true, checked = iEETConfig.onscreen.enabled, keepShownOnClick = false, func = function()
			if iEETConfig.onscreen.enabled then
				iEETConfig.onscreen.enabled = false
				iEET:print('Onscreen display is now off.')
			else
				iEETConfig.onscreen.enabled = true
				iEET:print('Onscreen display is now on.')
			end
			iEET:updateOptionsMenu()
      EasyMenu(iEET.optionsMenu, iEET.optionsMenuFrame, iEET.optionsList, 0 , 0, 'MENU');
      iEET:ToggleOnscreenDisplay(true)
		end},
		{text = 'Ignored events', notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = onscreenIgnoredEvents},

  }})
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
      {text = 'Onscreen',
			notCheckable = true,
			hasArrow = true,
			keepShownOnClick = true,
			menuList = {
				{text = 'Background',
				notCheckable = true,
				hasArrow = false,
				keepShownOnClick = false,
				func = function()
					iEET:ShowColorPicker('onscreenBG')
				end},
				{text = 'Border',
				notCheckable = true,
				hasArrow = false,
				keepShownOnClick = false,
				func = function()
				  iEET:ShowColorPicker('onscreenBorder')
				end},
				{text = 'Reset',
				notCheckable = true,
				hasArrow = false,
				keepShownOnClick = false,
				func = function()
					iEETConfig.colors.onscreen = {
						['bg'] = {['r'] = 0.1, ['g'] = 0.1, ['b'] = 0.1, ['a'] = 0.7},
						['border'] = {['r'] = 0.64, ['g'] = 0, ['b'] = 0, ['a'] = 1},
					}
					iEET:UpdateColors('onscreen',nil,true) --force update after reset
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
				{text = 'Clear all fights', notCheckable = true, keepShownOnClick = false, func = function()
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
	table.insert(iEET.optionsMenu, { text = 'Start recording without filters', notCheckable = true, func = function () iEET:StartRecordingWithoutFiltersPopup() end})
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
			text = iEET.events.fromID[k].l,
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
							text = (v.k == 1 and '+ ' or '- ') .. v.fT .. ' (' .. v.pT .. ')' .. (v.lN and (' - ' .. v.lN) or ''),
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