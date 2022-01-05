local _, iEET = ...
local spairs = iEET.spairs
local tinsert = table.insert
iEET.optionsMenu = {}
iEET.ENUMS.SPREADSHEETS = {
	GOOGLE = 1,
	OPENOFFICE = 2,
	EXCEL = 3,
}
iEET.optionsMenuFrame = CreateFrame('Frame', 'iEETOptionsListMenu', UIParent, 'UIDropDownMenuTemplate')
function iEET:updateOptionsMenu()
	iEET.optionsMenu = nil
	iEET.optionsMenu = {}
	local onscreenIgnoredEvents = {}
	for eventName,eventID in spairs(iEET.events.toID) do
		tinsert(onscreenIgnoredEvents, {
			text = string.format("%s%s", eventName, iEET.events.fromID[eventID].c and " (CLEU)" or ""),
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
  tinsert(iEET.optionsMenu, {text = 'Options', isTitle = true, notCheckable = true})
  tinsert(iEET.optionsMenu, {text = 'Onscreen display', notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = {
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
	tinsert(iEET.optionsMenu, {text = 'Mass delete options', notCheckable = true, func = function() iEET:toggleDeleteOptions() end})
	tinsert(iEET.optionsMenu, {text = 'Color', notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = {
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
	tinsert(iEET.optionsMenu, {text = 'Automatic saving', isNotRadio = true, checked = iEETConfig.autoSave, keepShownOnClick = false, func = function()
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
	tinsert(iEET.optionsMenu, {text = 'Use automatic saving only inside raid instances', isNotRadio = true, checked = iEETConfig.onlyRaids, keepShownOnClick = false, func = function()
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
		tinsert(iEET.optionsMenu, {text = 'Expansion specific ignore', notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = {
			{text ='Vanilla - raid', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.VANILLA], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.VANILLA, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Vanilla - 5man', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.VANILLA5MAN], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.VANILLA5MAN, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil	end
			end},
			{text ='The Burning Crusade - raid', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.TBC], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.TBC5, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='The Burning Crusade - 5man', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.TBC5MAN], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.TBC5MAN, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Wrath of the Lich King - raid', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.WOTLK], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.WOTLK, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Wrath of the Lich King - 5man', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.WOTLK5MAN], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.WOTLK5MAN, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Cataclysm - raid', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.CATACLYSM], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.CATACLYSM, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Cataclysm - 5man', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.CATACLYSM5MAN], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.CATACLYSM5MAN, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Mist of Pandaria - raid', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.MOP], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.MOP, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Mist of Pandaria - 5man', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.MOP5MAN], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.MOP5MAN, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Warlords of Draenor - raid', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.WOD], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.WOD, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Warlords of Draenor - 5man', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.WOD5MAN], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.WOD5MAN, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Legion - raid', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.LEGION], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.LEGION, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Legion - 5man', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.LEGION5MAN], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.LEGION5MAN, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Battle for Azeroth - raid', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.BFA], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.BFA, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Battle for Azeroth - 5man', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.BFA5MAN], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.BFA5MAN, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Shadowlands - raid', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.SHADOWLANDS], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.SHADOWLANDS, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
			{text ='Shadowlands - 5man', isNotRadio = true, checked = iEETConfig.expansionIgnore[iEET.ENUMS.EXPANSIONS.SHADOWLANDS5MAN], keepShownOnClick = true, arg1 = iEET.ENUMS.EXPANSIONS.SHADOWLANDS5MAN, func = function(self, arg1, arg2, checked)
				if checked then iEETConfig.expansionIgnore[arg1] = true else iEETConfig.expansionIgnore[arg1] = nil end
			end},
		}})
	tinsert(iEET.optionsMenu, {text = 'Class coloring', isNotRadio = true,	checked = iEETConfig.classColors, keepShownOnClick = true, func = function()
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
	tinsert(iEET.optionsMenu, {text = 'Clear all fights', notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = {
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
	tinsert(iEET.optionsMenu, {text = 'Export sorted fights to WTF file', notCheckable = true, func = function() iEET:ExportFightsToWTF() end})
	tinsert(iEET.optionsMenu, {text = 'Clear exported fights (iEET_ExportFromWTF)', notCheckable = true, func = function()
		iEET_ExportFromWTF = {}
		iEET:print('Export variable cleared.')
	end})
	tinsert(iEET.optionsMenu, {text = 'Start recording without filters', notCheckable = true, func = function () iEET:StartRecordingWithoutFiltersPopup() end})
	tinsert(iEET.optionsMenu, {text = "Spreadsheet exporting", notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = {
		{ text = 'Excel', notCheckable = true, func = function() iEET:copyCurrent(iEET.ENUMS.SPREADSHEETS.EXCEL) CloseDropDownMenus() end},
		{ text = 'Google', notCheckable = true, func = function() iEET:copyCurrent(iEET.ENUMS.SPREADSHEETS.GOOGLE) CloseDropDownMenus() end},
		{ text = 'OpenOffice', notCheckable = true, func = function() iEET:copyCurrent(iEET.ENUMS.SPREADSHEETS.OPENOFFICE) CloseDropDownMenus() end},
	}})
	tinsert(iEET.optionsMenu, { text = 'Close', notCheckable = true, func = function () CloseDropDownMenus(); end})
end

iEET.encounterListMenu = {}
iEET.encounterListMenuFrame = CreateFrame('Frame', 'iEETEncounterListMenu', UIParent, 'UIDropDownMenuTemplate')
function iEET:updateEncounterListMenu()
		iEET.encounterListMenu = nil
		iEET.encounterListMenu = {}
	if iEET_Data then
		local encountersTempTable = {}
		local groupSplitTemp = {}
		for k,_ in pairs(iEET_Data) do -- Get encounters
			local temp = {}
			for eK,eV in string.gmatch(k, '{(.-)=(.-)}') do
				if eK == 'd' or eK == 'rS' or eK == 's' or eK == 'k' or eK == 'v' or eK == 'zI' or eK == 'eI' then
					if tonumber(eV) then
						eV = tonumber(eV)
					end
				end
				temp[eK] = eV
			end
			local _, groupType = GetDifficultyInfo(temp.d)
			if groupType then
				if not groupSplitTemp[groupType] then
					groupSplitTemp[groupType] = {text = groupType, hasArrow = true, notCheckable = true, menuList = {}}
				end
				temp.groupType = groupType
			else
				if not groupSplitTemp[UNKNOWN] then
					groupSplitTemp[UNKNOWN] = {text = UNKNOWN, hasArrow = true, notCheckable = true, menuList = {}}
				end
				temp.groupType = UNKNOWN
			end

			temp.dataKey = k
			if temp.zI then
				local zone = temp.zI == -1 and "Custom" or GetRealZoneText(temp.zI)
				temp.zoneName = zone
			else
				temp.zoneName = UNKNOWN
			end
			if not encountersTempTable[temp.groupType] then
				encountersTempTable[temp.groupType] = {}
			end
			if not encountersTempTable[temp.groupType][temp.zoneName] then
				encountersTempTable[temp.groupType][temp.zoneName] = {}
			end
			if not encountersTempTable[temp.groupType][temp.zoneName][temp.eN] then
				encountersTempTable[temp.groupType][temp.zoneName][temp.eN] = {}
			end
			if not encountersTempTable[temp.groupType][temp.zoneName][temp.eN][temp.d] then
				encountersTempTable[temp.groupType][temp.zoneName][temp.eN][temp.d] = {}
			end
			tinsert(encountersTempTable[temp.groupType][temp.zoneName][temp.eN][temp.d], temp)
		end -- Sorted by encounter -> Sort by ids inside
		-- temp{} -> encounter{} -> difficulty{} -> fight{}
		for groupType, zoneInfo in spairs(encountersTempTable) do -- Get alphabetically sorted group types
			for zoneName, encountersTemp in spairs(zoneInfo) do -- Get alphabetically sorted zones
				local t3 = {text = zoneName, hasArrow = true, notCheckable = true, menuList = {}}
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
							tinsert(t2.menuList, fightEntry)
						end
						tinsert(t.menuList, t2)
					end
					tinsert(t3.menuList, t)
				end
				tinsert(groupSplitTemp[groupType].menuList, t3)
			end
		end
		for _,v in spairs(groupSplitTemp) do
			tinsert(iEET.encounterListMenu, v)
		end
	end
	tinsert(iEET.encounterListMenu, { text = 'Exit', notCheckable = true, func = function () CloseDropDownMenus() end})
end