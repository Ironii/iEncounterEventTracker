local _, iEET = ...
local spairs = iEET.spairs
function iEET:ShowColorPicker(frame)
	iEET.colorToChange = frame
	local r,g,b,a
	if frame == 'mainBG' then
		r,g,b,a = iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a
	elseif frame == 'mainBorder' then
		r,g,b,a = iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a
	elseif frame == 'optionsBG' then
		r,g,b,a = iEETConfig.colors.options.border.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a
	elseif frame == 'optionsBorder' then
		r,g,b,a = iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a
	elseif frame == 'onscreenBG' then
		r,g,b,a = iEETConfig.colors.onscreen.bg.r,iEETConfig.colors.onscreen.bg.g,iEETConfig.colors.onscreen.bg.b,iEETConfig.colors.onscreen.bg.a
	else -- onscreenBorder
		r,g,b,a = iEETConfig.colors.onscreen.border.r,iEETConfig.colors.onscreen.border.g,iEETConfig.colors.onscreen.border.b,iEETConfig.colors.onscreen.border.a
	end
	ColorPickerFrame:SetColorRGB(r,g,b)
	ColorPickerFrame.hasOpacity = true
	ColorPickerFrame.opacity = a
	ColorPickerFrame.previousValues = {r,g,b,a}
	ColorPickerFrame.func = function() iEET:UpdateColors(frame) end
	ColorPickerFrame.opacityFunc = function() iEET:UpdateColors(frame) end
	ColorPickerFrame.cancelFunc = function() iEET:UpdateColors(frame, {['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a}) end
	ColorPickerFrame:Hide() -- Need to run the OnShow handler.
	ColorPickerFrame:Show()
end
function iEET:UpdateColors(frame, prevColors, force)
	local a,r,g,b
	if not force then
		if not prevColors then
			a = OpacitySliderFrame:GetValue()
			r,g,b = ColorPickerFrame:GetColorRGB()
		else
			r,g,b,a = prevColors.r, prevColors.g, prevColors.b, prevColors.a
		end
		if iEET.colorToChange == 'mainBG' then
			frame = 'main'
			iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a = r,g,b,a
		elseif iEET.colorToChange == 'mainBorder' then
			iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a = r,g,b,a
			frame = 'main'
		elseif iEET.colorToChange == 'optionsBG' then
			iEETConfig.colors.options.border.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a = r,g,b,a
			frame = 'options'
		elseif iEET.colorToChange == 'optionsBorder' then
			iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a = r,g,b,a
			frame = 'options'
		elseif iEET.colorToChange == 'onscreenBG' then
			iEETConfig.colors.onscreen.bg.r,iEETConfig.colors.onscreen.bg.g,iEETConfig.colors.onscreen.bg.b,iEETConfig.colors.onscreen.bg.a = r,g,b,a
			frame = 'onscreen'
		else --onscreenBorder
			iEETConfig.colors.onscreen.border.r,iEETConfig.colors.onscreen.border.g,iEETConfig.colors.onscreen.border.b,iEETConfig.colors.onscreen.border.a = r,g,b,a
			frame = 'onscreen'
		end
	end
	local frames = {
		['main'] = {'top','encounterInfo','detailtop','encounterAbilities','contentAnchor1','contentAnchor2','contentAnchor3','contentAnchor4','contentAnchor5','contentAnchor6','contentAnchor7','contentAnchor8','detailAnchor1','detailAnchor2','detailAnchor3','detailAnchor5','detailAnchor6','detailAnchor7','encounterAbilitiesAnchor', 'editbox', 'eventlist', 'npcList', 'spellList','encounterListButton', 'filteringButton', 'optionsList', 'spreadsheetCopyButton', 'exitButton'},
		['options'] = {'optionsFrame','optionsFrameTop','infoFrame','optionsFrameSaveButton','optionsFrameSaveAndCloseButton','optionsFrameCancelButton', 'infoButton', 'optionsFrameEditbox'},
		['onscreen'] = {'onscreenAnchor1','onscreenAnchor2','onscreenAnchor3','onscreenAnchor4','onscreenAnchor5','onscreenAnchor6','onscreenAnchor7','onscreenAnchor8'},
	}
	for _,frameName in pairs(frames[frame]) do
		if iEET[frameName] then
			iEET[frameName]:SetBackdropColor(iEETConfig.colors[frame].bg.r,iEETConfig.colors[frame].bg.g,iEETConfig.colors[frame].bg.b,iEETConfig.colors[frame].bg.a)
			iEET[frameName]:SetBackdropBorderColor(iEETConfig.colors[frame].border.r,iEETConfig.colors[frame].border.g,iEETConfig.colors[frame].border.b,iEETConfig.colors[frame].border.a)
		end
	end
end
function iEET:ScrollContent(delta, fixedValue)
	if fixedValue then
		local offSet = iEET.maxScrollRange-fixedValue
		for i = 1, 8 do
			iEET['content' .. i]:SetScrollOffset(offSet)
		end
	else
		if delta == -1 then
			local offSet
			if IsShiftKeyDown() then
				offSet = iEET['content' .. 1]:GetScrollOffset()-75
			else
				offSet = iEET['content' .. 1]:GetScrollOffset()-1
			end

			for i = 1, 8 do
				iEET['content' .. i]:SetScrollOffset(offSet)
			end
			iEET.mainFrameSlider:SetValue(iEET.maxScrollRange-offSet)
		else
			local offSet
			if IsShiftKeyDown() then
				offSet = iEET['content' .. 1]:GetScrollOffset()+75
			else
				offSet = iEET['content' .. 1]:GetScrollOffset()+1
			end

			for i = 1, 8 do
				iEET['content' .. i]:SetScrollOffset(offSet)
			end
			iEET.mainFrameSlider:SetValue(iEET.maxScrollRange-offSet)
		end
	end
end
function iEET:ScrollDetails(delta)
	if delta == -1 then
		for i = 1, 7 do
			if i == 4 then
			else
				if IsShiftKeyDown() then
					for scrollFix=1, 15 do
						iEET['detailContent' .. i]:ScrollDown()
					end
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
					for scrollFix=1, 15 do
						iEET['detailContent' .. i]:ScrollUp()
					end
				else
					iEET['detailContent' .. i]:ScrollUp()
				end
			end
		end
	end
end
function iEET:ScrollOnscreen(delta)
	if delta == -1 then
		for i = 1, 8 do
			if IsShiftKeyDown() then
				for scrollFix=1, 15 do
					iEET['onscreenContent' .. i]:ScrollDown()
				end
			else
				iEET['onscreenContent' .. i]:ScrollDown()
			end
		end
	else
		for i = 1, 8 do
			if IsShiftKeyDown() then
				for scrollFix=1, 15 do
					iEET['onscreenContent' .. i]:ScrollUp()
				end
			else
				iEET['onscreenContent' .. i]:ScrollUp()
			end
		end
	end
end
iEET.searchMenuList = {}
iEET.searchMenuListFrame = CreateFrame('Frame', 'iEETSearchMenuList', UIParent, 'UIDropDownMenuTemplate')
function iEET:updateSearchMenu(key)
	iEET.searchMenuList = nil
	iEET.searchMenuList = {}
	table.insert(iEET.searchMenuList, {text = 'Search using:', isTitle = true, notCheckable = true})
	table.insert(iEET.searchMenuList, {text = 'Spell ID', notCheckable = true, func = function()
		CloseDropDownMenus()
		iEET:loopData(nil,{key,"sI"})
		end})
	table.insert(iEET.searchMenuList, {text = 'Spell name', notCheckable = true, func = function()
		CloseDropDownMenus()
		iEET:loopData(nil, {key, "sN"})
		end})
	table.insert(iEET.searchMenuList, {text = 'Source name', notCheckable = true, func = function()
		CloseDropDownMenus()
		iEET:loopData(nil ,{key, "cN"})
		end})
	table.insert(iEET.searchMenuList, {text = 'Target name', notCheckable = true, func = function()
		CloseDropDownMenus()
		iEET:loopData(nil, {key, "tN"})
		end})
	table.insert(iEET.searchMenuList, {text = 'Source GUID', notCheckable = true, func = function()
		CloseDropDownMenus()
		iEET:loopData(nil, {key, "sG"})
		end})
	table.insert(iEET.searchMenuList, {text = 'Target GUID', notCheckable = true, func = function()
		CloseDropDownMenus()
		iEET:loopData(nil, {key, "tG"})
		end})
	table.insert(iEET.searchMenuList, {text = 'Close', notCheckable = true, func = function()
		CloseDropDownMenus()
		end})

end
function iEET:CreateMainFrame()
	iEET.frame = CreateFrame("Frame", "iEETFrame", UIParent)
	iEET.frame:SetSize(598,834)
	iEET.frame:SetPoint('CENTER', UIParent, 'CENTER', iEETConfig.spawnOffset,0)
	if iEETConfig.scales.main then
		iEET.frame:SetScale(iEETConfig.scales.main)
	end
	iEET.frame:SetScript('OnMouseDown', function(self,button)
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
	iEET.top:SetSize(605, 25)
	iEET.top:SetPoint('BOTTOMLEFT', iEET.frame, 'TOPLEFT', 0, -1)
	iEET.top:SetBackdrop(iEET.backdrop);
	iEET.top:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.top:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
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
	iEET.encounterInfo:SetSize(470, 18)
	iEET.encounterInfo:SetPoint('BOTTOM', iEET.top, 'TOP', 0, -1)
	iEET.encounterInfo:SetBackdrop(iEET.backdrop);
	iEET.encounterInfo:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.encounterInfo:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
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

	-- Prev button
	iEET.prevEncounter = CreateFrame('FRAME', nil, iEET.frame)
	iEET.prevEncounter:SetSize(18, 18)
	iEET.prevEncounter:SetPoint('BOTTOMRIGHT', iEET.encounterInfo, 'BOTTOMLEFT', 0, 0)
	iEET.prevEncounter:SetBackdrop(iEET.backdrop);
	iEET.prevEncounter:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.prevEncounter:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.prevEncounter:SetScript('OnMouseDown', function(self,button)
		iEET:ImportData(iEET:getNextPrevEncounter(-1))
	end)
	iEET.prevEncounter:SetScript('OnEnter', function()
		GameTooltip:SetOwner(iEET.prevEncounter, 'ANCHOR_BOTTOMLEFT', 0, 20)
		GameTooltip:SetText(iEET:getTooltipForEncounter(iEET:getNextPrevEncounter(-1)))
	end)
	iEET.prevEncounter:SetScript('OnLeave', function()
		GameTooltip:ClearLines()
		GameTooltip:Hide()
	end)
	iEET.prevEncounter:EnableMouse(true)
	iEET.prevEncounter:Show()
	iEET.prevEncounter:SetFrameStrata('HIGH')
	iEET.prevEncounter:SetFrameLevel(2)
	iEET.prevEncounter.text = iEET.prevEncounter:CreateFontString()
	iEET.prevEncounter.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.prevEncounter.text:SetPoint('CENTER', iEET.prevEncounter, 'CENTER', 0,1)
	iEET.prevEncounter.text:SetText('<')
	iEET.prevEncounter.text:Show()

	-- Next button
	iEET.nextEncounter = CreateFrame('FRAME', nil, iEET.frame)
	iEET.nextEncounter:SetSize(18, 18)
	iEET.nextEncounter:SetPoint('BOTTOMLEFT', iEET.encounterInfo, 'BOTTOMRIGHT', 0, 0)
	iEET.nextEncounter:SetBackdrop(iEET.backdrop);
	iEET.nextEncounter:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.nextEncounter:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.nextEncounter:SetScript('OnMouseDown', function(self,button)
		iEET:ImportData(iEET:getNextPrevEncounter(1))
	end)
	iEET.nextEncounter:SetScript('OnEnter', function()
		GameTooltip:SetOwner(iEET.nextEncounter, 'ANCHOR_BOTTOMRIGHT', 0, 20)
		GameTooltip:SetText(iEET:getTooltipForEncounter(iEET:getNextPrevEncounter(1)))
	end)
	iEET.nextEncounter:SetScript('OnLeave', function()
		GameTooltip:ClearLines()
		GameTooltip:Hide()
	end)
	iEET.nextEncounter:EnableMouse(true)
	iEET.nextEncounter:SetFrameStrata('HIGH')
	iEET.nextEncounter:SetFrameLevel(2)
	iEET.nextEncounter:Show()
	iEET.nextEncounter.text = iEET.nextEncounter:CreateFontString()
	iEET.nextEncounter.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.nextEncounter.text:SetPoint('CENTER', iEET.nextEncounter, 'CENTER', 0,1)
	iEET.nextEncounter.text:SetText('>')
	iEET.nextEncounter.text:Show()
	iEET.detailtop = CreateFrame('FRAME', nil, iEET.frame)
	iEET.detailtop:SetSize(433, 25)
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
	iEET.detailtop:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.detailtop:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
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
	iEET.encounterAbilities:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.encounterAbilities:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
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
		[1] = 40,
		[2] = 40,
		[3] = 105,
		[4] = 131,
		[5] = 120,
		[6] = 97,
		[7] = 36,
		[8] = 36,
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
		iEET['contentAnchor' .. i]:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
		iEET['contentAnchor' .. i]:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
		---
		iEET['content' .. i] = CreateFrame('ScrollingMessageFrame', nil, iEET['contentAnchor' .. i])
		iEET['content' .. i]:SetSize(slices[i]-8,828)
		iEET['content' .. i]:SetPoint('CENTER', iEET['contentAnchor' .. i], 'CENTER', 0, 0)
		iEET['content' .. i]:SetFont(iEET.font, iEET.fontsize)
		iEET['content' .. i]:SetFading(false)
		--iEET['content' .. i]:SetClipsChildren(true)
		iEET['content' .. i]:SetInsertMode("BOTTOM")
		iEET['content' .. i]:SetJustifyH(iEET.justifyH)
		iEET['content' .. i]:SetMaxLines(10000)
		iEET['content' .. i]:SetSpacing(iEET.spacing)
		iEET['content' .. i]:EnableMouseWheel(true)
		--iEET['content' .. i]:SetFrameLevel(4)
		iEET['content' .. i]:SetScript("OnMouseWheel", function(self, delta)
			iEET:ScrollContent(delta)
		end)
		if i == 1 or i == 2 or i == 4 or i == 5 or i == 6 then --allow hyperlinks for encounter time, intervall time, spellName, sourceName, destName
			iEET['content' .. i]:SetHyperlinksEnabled(true)
			iEET['content' .. i]:SetScript("OnHyperlinkEnter", function(self, linkData, link)
				GameTooltip:SetOwner(iEET.frame, "ANCHOR_TOPRIGHT", 0-iEET.frame:GetWidth(), 0-iEET.frame:GetHeight())
				iEET:Hyperlinks(linkData, link)
			end)
			iEET['content' .. i]:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
			end)
			iEET['content' .. i]:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
				local mf = GetMouseFocus()
				if button == "RightButton" and mf and mf.messageInfo and mf.messageInfo.extraData and mf.messageInfo.extraData[1] then
					local key = tonumber(mf.messageInfo.extraData[1])
					if key then
						iEET:updateSearchMenu(key)
						EasyMenu(iEET.searchMenuList, iEET.searchMenuListFrame, "cursor", 0 , 0, 'MENU')
						return
					end
				end
				if string.find(linkData, 'iEETtime') then
					return
				elseif IsShiftKeyDown() and IsInRaid() then
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
		iEET['detailAnchor' .. i]:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
		iEET['detailAnchor' .. i]:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
		---
		iEET['detailContent' .. i] = CreateFrame('ScrollingMessageFrame', nil, iEET['detailAnchor' .. i])
		iEET['detailContent' .. i]:SetSize(slices[i]-8,392)
		iEET['detailContent' .. i]:SetPoint('CENTER', iEET['detailAnchor' .. i], 'CENTER', 0, 0)
		iEET['detailContent' .. i]:SetFont(iEET.font, iEET.fontsize)
		iEET['detailContent' .. i]:SetFading(false)
		iEET['detailContent' .. i]:SetInsertMode('BOTTOM')
		iEET['detailContent' .. i]:SetJustifyH(iEET.justifyH)
		iEET['detailContent' .. i]:SetMaxLines(10000)
		iEET['detailContent' .. i]:SetSpacing(iEET.spacing)
		iEET['detailContent' .. i]:EnableMouseWheel(true)
		iEET['detailContent' .. i]:SetScript("OnMouseWheel", function(self, delta)
			iEET:ScrollDetails(delta)
		end)
		if i == 1 or i == 2 or i == 5 or i == 6 then --allow hyperlinks for time,intervall,sourceName, targetName (IEEU, UNIT_POWER)
			iEET['detailContent' .. i]:SetHyperlinksEnabled(true)
			iEET['detailContent' .. i]:SetScript('OnHyperlinkEnter', function(self, linkData, link)
				GameTooltip:SetOwner(iEET.frame, "ANCHOR_TOPRIGHT", 0-iEET.frame:GetWidth(), 0-iEET.frame:GetHeight())
				iEET:Hyperlinks(linkData)
			end)
			iEET['detailContent' .. i]:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
			end)
		end
		iEET['detailContent' .. i]:EnableMouse(true)
		iEET['detailContent' .. i]:SetFrameStrata('HIGH')
		iEET['detailContent' .. i]:SetFrameLevel(2)
	end
	end
	--SPELL LISTING--
	do
		--Slider
		iEET.mainFrameSlider = CreateFrame('Slider', nil, iEET.frame)
		iEET.mainFrameSlider:SetSize(8,834)
		iEET.mainFrameSlider:SetThumbTexture('Interface\\AddOns\\iEncounterEventTracker\\media\\thumb')
		iEET.mainFrameSlider:SetBackdrop(bd)
		iEET.mainFrameSlider:SetBackdropColor(0.1,0.1,0.1,0.9)
		iEET.mainFrameSlider:SetBackdropBorderColor(0,0,0,1)
		iEET.mainFrameSlider:SetPoint('BOTTOMLEFT', iEET.frame, 'BOTTOMRIGHT', -1,0)
		iEET.mainFrameSlider:SetMinMaxValues(0, 10)
		iEET.mainFrameSlider:SetValue(0)
		iEET.mainFrameSlider:SetValueStep(1)
		iEET.mainFrameSlider:EnableMouseWheel(true)
		local lastValue = 0
		--iEET.maxScrollRange
		iEET.mainFrameSlider:SetScript('OnMouseDown', function(self, button)
			iEET.mainFrameSlider:SetScript('OnUpdate', function()
				local value = math.floor(self:GetValue())
				if value ~= lastValue then
					iEET:ScrollContent(delta, value)
					lastValue = value
				end
			end)
		end)
		iEET.mainFrameSlider:SetScript('OnMouseUp', function(self, button)
			iEET.mainFrameSlider:SetScript('OnUpdate', nil)
		end)
		iEET.mainFrameSlider:SetScript('OnMouseWheel', function(self, delta)
			iEET:ScrollContent(delta)
		end)
		iEET.mainFrameSliderBG = CreateFrame('FRAME', nil , iEET.frame)
		--iEET.contentAnchor8 = CreateFrame('FRAME', nil , iEET.frame)
		iEET.mainFrameSliderBG:SetSize(8, 834)
		iEET.mainFrameSliderBG:SetPoint('BOTTOMLEFT', iEET.frame, 'BOTTOMRIGHT', -1, 0)
		iEET.mainFrameSliderBG:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
			insets = {
				left = -1,
				right = -1,
				top = -1,
				bottom = -1,
			},
		})
		iEET.mainFrameSliderBG:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
		iEET.mainFrameSliderBG:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)

		iEET.encounterAbilitiesAnchor = CreateFrame('FRAME', nil, iEET.frame)
		iEET.encounterAbilitiesAnchor:SetSize(200, 400)
		--iEET.encounterAbilitiesAnchor:SetPoint('TOPLEFT', iEET.frame, 'TOPRIGHT', -1, 0)
		iEET.encounterAbilitiesAnchor:SetPoint('TOPLEFT', iEET.frame, 'TOPRIGHT', 6, 0)
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
		iEET.encounterAbilitiesAnchor:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
		iEET.encounterAbilitiesAnchor:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
		---
		iEET.encounterAbilitiesContent = CreateFrame('ScrollingMessageFrame', nil, iEET.encounterAbilitiesAnchor)
		iEET.encounterAbilitiesContent:SetSize(192,392)
		iEET.encounterAbilitiesContent:SetPoint('CENTER', iEET.encounterAbilitiesAnchor, 'CENTER', 0, 0)
		iEET.encounterAbilitiesContent:SetFont(iEET.font, iEET.fontsize)
		iEET.encounterAbilitiesContent:SetFading(false)
		iEET.encounterAbilitiesContent:SetInsertMode('BOTTOM')
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
		iEET.encounterAbilitiesContent:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
		end)
		iEET.encounterAbilitiesContent:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
			local spellID = tonumber(string.match(linkData, 'spell:(%d+)'))
			if spellID then
				iEET:loopData(nil, {spellID, "sI"}, true)
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

	iEET.commonAbilities = CreateFrame('FRAME', nil, iEET.frame)
	iEET.commonAbilities:SetSize(200, 25)
	iEET.commonAbilities:SetPoint('TOPLEFT', iEET.encounterAbilitiesAnchor, 'BOTTOMLEFT', 0, 0)
	iEET.commonAbilities:SetBackdrop({
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
	iEET.commonAbilities:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.commonAbilities:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.commonAbilities:Show()
	iEET.commonAbilities:SetScript("OnMouseDown", function(self,button)
		iEET.frame:ClearAllPoints()
		iEET.frame:StartMoving()
	end)
	iEET.commonAbilities:SetScript('OnMouseUp', function(self, button)
		iEET.frame:StopMovingOrSizing()
	end)
	iEET.commonAbilities:SetFrameStrata('HIGH')
	iEET.commonAbilities:SetFrameLevel(1)
	iEET.commonAbilities:EnableMouse(true)
	iEET.commonAbilitiesText = iEET.frame:CreateFontString('iEETCommonAbilitiesInfo')
	iEET.commonAbilitiesText:SetFont(iEET.font, iEET.fontsize, "OUTLINE")
	iEET.commonAbilitiesText:SetPoint("CENTER", iEET.commonAbilities, 'CENTER', 0,0)
	iEET.commonAbilitiesText:SetText("Common spells")
	iEET.commonAbilitiesText:Show()

	iEET.commonAbilitiesAnchor = CreateFrame('FRAME', nil, iEET.frame)
	iEET.commonAbilitiesAnchor:SetSize(200, 150)
	iEET.commonAbilitiesAnchor:SetPoint('TOPLEFT', iEET.commonAbilities, 'BOTTOMLEFT', 0, 0)
	iEET.commonAbilitiesAnchor:SetBackdrop({
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
	iEET.commonAbilitiesAnchor:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
	iEET.commonAbilitiesAnchor:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	---
	iEET.commonAbilitiesContent = CreateFrame('ScrollingMessageFrame', nil, iEET.commonAbilitiesAnchor)
	iEET.commonAbilitiesContent:SetSize(192,142)
	iEET.commonAbilitiesContent:SetPoint('CENTER', iEET.commonAbilitiesAnchor, 'CENTER', 0, 0)
	iEET.commonAbilitiesContent:SetFont(iEET.font, iEET.fontsize)
	iEET.commonAbilitiesContent:SetFading(false)
	iEET.commonAbilitiesContent:SetInsertMode('BOTTOM')
	iEET.commonAbilitiesContent:SetJustifyH(iEET.justifyH)
	iEET.commonAbilitiesContent:SetMaxLines(200)
	iEET.commonAbilitiesContent:SetSpacing(iEET.spacing)
	iEET.commonAbilitiesContent:EnableMouseWheel(true)
	iEET.commonAbilitiesContent:SetHyperlinksEnabled(true)
	iEET.commonAbilitiesContent:SetScript("OnMouseWheel", function(self, delta)
		if delta == -1 then
			if IsShiftKeyDown() then
				iEET.commonAbilitiesContent:PageDown()
			else
				iEET.commonAbilitiesContent:ScrollDown()
			end
		else
			if IsShiftKeyDown() then
				iEET.commonAbilitiesContent:PageUp()
			else
				iEET.commonAbilitiesContent:ScrollUp()
			end
		end
	end)
	iEET.commonAbilitiesContent:SetScript("OnHyperlinkEnter", function(self, linkData, link)
		GameTooltip:SetOwner(iEET.frame, "ANCHOR_TOPRIGHT", 0-iEET.frame:GetWidth(), 0-iEET.frame:GetHeight())
		GameTooltip:ClearLines()
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end)
	iEET.commonAbilitiesContent:SetScript("OnHyperlinkLeave", function()
			GameTooltip:Hide()
	end)
	iEET.commonAbilitiesContent:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
		local spellID = tonumber(string.match(linkData, 'spell:(%d+)'))
		if spellID then
			iEET:loopData(spellID)
		end
	end)
	iEET.commonAbilitiesContent:EnableMouse(true)
	iEET.commonAbilitiesContent:SetFrameStrata('HIGH')
	iEET.commonAbilitiesContent:SetFrameLevel(2)

	iEET.frame:EnableMouse(true)
	iEET.frame:SetMovable(true)
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
	iEET.editbox:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,0.2)
	iEET.editbox:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
	iEET.editbox:SetScript('OnEnterPressed', function()
		iEET.editbox:ClearFocus()
		local msg
		if iEET.editbox:GetText() ~= 'Search' then
			local txt = iEET.editbox:GetText()
			local from, to
			if string.lower(txt) == 'clear' then
				iEET:ClearFilteringArgs()
				iEET.editbox:SetText('')
			elseif string.len(txt) > 1 then
				msg = string.lower(txt)
			end
		end
		iEET:loopData(msg)
	end)
	iEET.editbox:SetAutoFocus(false)
	iEET.editbox:SetWidth(269)
	iEET.editbox:SetHeight(21)
	iEET.editbox:SetTextInsets(2, 2, 1, 0)
	iEET.editbox:SetPoint('RIGHT', iEET.top, 'RIGHT', -24,0)
	iEET.editbox:SetFrameStrata('HIGH')
	iEET.editbox:SetFrameLevel(3)
	iEET.editbox:Show()
	iEET.editbox:SetFont(iEET.font, iEET.fontsize+2, 'OUTLINE')
	local function createButton(name, buttonName, width, height, buttonText,point,anchorFrame,relativePoint,xOffset,yOffset)
		iEET[name] = CreateFrame('BUTTON', buttonName, iEET.frame)
		iEET[name]:SetSize(width, height)
		iEET[name]:SetBackdrop(iEET.backdrop);
		iEET[name]:SetBackdropColor(iEETConfig.colors.main.bg.r,iEETConfig.colors.main.bg.g,iEETConfig.colors.main.bg.b,iEETConfig.colors.main.bg.a)
		iEET[name]:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
		iEET[name].text = iEET[name]:CreateFontString()
		iEET[name].text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET[name].text:SetPoint('CENTER', iEET[name], 'CENTER', 0,0)
		iEET[name].text:SetText(buttonText)
		iEET[name]:SetPoint(point, iEET[anchorFrame], relativePoint, xOffset,yOffset)
		iEET[name]:SetFrameStrata('HIGH')
		iEET[name]:SetFrameLevel(4)
		iEET[name]:RegisterForClicks('AnyUp')
	end
	--[Events][NPCs][Spells][E(encounters)][F(filtering)][O(options)][S(spreadsheet)]
	----Event list:
	createButton('eventlist',nil,60,21,'Events','LEFT','top','LEFT',2,0)
	iEET.eventlist:SetScript('OnClick',function()
		iEET:updateEventMenu()
		EasyMenu(iEET.eventListMenu, iEET.eventListMenuFrame, iEET.eventlist, 0 , 0, 'MENU')
	end)
	--iEET:updateOptionMenu()
	--NPC list
	createButton('npcList', nil,60,21,'NPCs','LEFT','eventlist','RIGHT',1,0)
	iEET.npcList:SetScript('OnClick',function()
		iEET:updateNPCListMenu()
		EasyMenu(iEET.npcListMenu, iEET.npcListMenuFrame, iEET.npcList, 0 , 0, 'MENU')
	end)
	--Spells list
	createButton('spellList', nil,60,21,'Spells','LEFT','npcList','RIGHT',1,0)
	iEET.spellList:SetScript('OnClick',function()
		iEET:updateSpellListMenu()
		EasyMenu(iEET.spellListMenu, iEET.spellListMenuFrame, iEET.spellList, 0 , 0, 'MENU')
	end)
	----Encounter list button:
	createButton('encounterListButton',nil,60,21,'Fights','LEFT','spellList','RIGHT',1,0)
	iEET.encounterListButton:SetScript('OnClick',function()
		iEET:updateEncounterListMenu()
		EasyMenu(iEET.encounterListMenu, iEET.encounterListMenuFrame, iEET.encounterListButton, 0 , 0, 'MENU')
	end)
	----Filtering window button:
	createButton('filteringButton', nil,21,21,'F','LEFT','encounterListButton','RIGHT',1,0)
	iEET.filteringButton:SetScript('OnClick',function()
		iEET:Options()
	end)
	--Settings
	createButton('optionsList', nil,21,21,'O','LEFT','filteringButton','RIGHT',1,0)
	iEET.optionsList:SetScript('OnClick',function()
		iEET:updateOptionsMenu()
		EasyMenu(iEET.optionsMenu, iEET.optionsMenuFrame, iEET.optionsList, 0 , 0, 'MENU')
	end)
	----Spreadsheet export button:
	iEET.spreadsheetCopyMenu = {
		{ text = 'Excel', notCheckable = true, func = function() iEET:copyCurrent(3) end},
		{ text = 'Google', notCheckable = true, func = function() iEET:copyCurrent(1) end},
		{ text = 'OpenOffice', notCheckable = true, func = function() iEET:copyCurrent(2) end},
		{ text = 'Cancel', notCheckable = true, func = function() CloseDropDownMenus() end},
	}
	iEET.spreadsheetListMenuFrame = CreateFrame('Frame', 'iEETspreadsheetListMenu', UIParent, 'UIDropDownMenuTemplate')
	createButton('spreadsheetCopyButton',nil,21,21,'S','LEFT','optionsList','RIGHT',1,0)
	iEET.spreadsheetCopyButton:SetScript('OnClick',function()
		EasyMenu(iEET.spreadsheetCopyMenu, iEET.spreadsheetListMenuFrame, iEET.spreadsheetCopyButton, 0 , 0, 'MENU');
	end)
	--Main window exit button
	createButton('exitButton', nil,21,21,'X','LEFT','editbox','RIGHT',1,0)
	iEET.exitButton:SetScript('OnClick',function()
		iEET.frame:Hide()
	end)
	--fill window
	iEET:loopData()
	iEET.frame:Show()
	-- Check if fight is already saved, if its enable prev/next buttons, else hide
	if iEET.encounterInfoData then
		if iEET:getNextPrevEncounter(1) then
			iEET.prevEncounter:Show()
			iEET.nextEncounter:Show()
		else
			iEET.prevEncounter:Hide()
			iEET.nextEncounter:Hide()
		end
	else
		iEET.prevEncounter:Hide()
		iEET.nextEncounter:Hide()
	end
	--Contact information on first run
	if iEETConfig.cInfo then
		iEETConfig.cInfo = false
		iEET:print("This is one time only message with authors contact information, feel free to use any of them if you run into any problems.\nBnet:\n    Ironi#2880 (EU)\nDiscord:\n    Ironi#2880\n    https://discord.gg/stY2nyj")
	end
end
function iEET:CreateOptionsFrame()
	-- Options main frame
	iEET.optionsFrame = CreateFrame('Frame', 'iEETOptionsFrame', UIParent)
	iEET.optionsFrame:SetSize(650,500)
	iEET.optionsFrame:SetPoint('CENTER', UIParent, 'CENTER', iEETConfig.spawnOffset,0)
	if iEETConfig.scales.filters then
		iEET.optionsFrame:SetScale(iEETConfig.scales.filters)
	end
	iEET.optionsFrame:SetBackdrop(iEET.backdrop);
	iEET.optionsFrame:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.optionsFrame:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.optionsFrame:Show()
	iEET.optionsFrame:SetFrameStrata('DIALOG')
	iEET.optionsFrame:SetFrameLevel(1)
	iEET.optionsFrame:EnableMouse(true)
	iEET.optionsFrame:SetMovable(true)
	-- Options title frame
	iEET.optionsFrameTop = CreateFrame('FRAME', nil, iEET.optionsFrame)
	iEET.optionsFrameTop:SetSize(650, 25)
	iEET.optionsFrameTop:SetPoint('BOTTOMRIGHT', iEET.optionsFrame, 'TOPRIGHT', 0, -1)
	iEET.optionsFrameTop:SetBackdrop(iEET.backdrop);
	iEET.optionsFrameTop:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.optionsFrameTop:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
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
	iEET.lastShownOnClick = false
	local function infoFrame(forceHide,clicked)
		if iEET.infoFrame then
			if forceHide and clicked then -- OnClick with shown OnClick -> Hide
				iEET.infoFrame:Hide()
				iEET.lastShownOnClick = false
				return
			elseif not forceHide and clicked then -- OnClick -> force Show
				iEET.infoFrame:Show()
				iEET.lastShownOnClick = true
				return
			elseif not iEET.lastShownOnClick then -- Ignore OnEvent & OnLeave events
				if iEET.infoFrame:IsShown() or forceHide then
					iEET.infoFrame:Hide()
				else
					iEET.infoFrame:Show()
				end
			end
		else
			iEET.infoFrame = CreateFrame('Frame', 'iEETOptionsFrame', UIParent)
			iEET.infoFrame:SetPoint('TOPLEFT', iEET.optionsFrameTop, 'TOPRIGHT', -1,0)
			iEET.infoFrame:SetBackdrop(iEET.backdrop);
			iEET.infoFrame:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
			iEET.infoFrame:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
			iEET.infoFrame:Show()
			iEET.infoFrame:SetFrameStrata('DIALOG')
			iEET.infoFrame:SetFrameLevel(1)
			iEET.infoFrame.text = iEET.infoFrame:CreateFontString()
			iEET.infoFrame.text:SetFont(iEET.font, 11)
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
]]

			for i = 1, #iEET.events.fromID do
				infoText = infoText..string.format('\n%d - %s - %s', i, iEET.events.fromID[i].l, iEET.events.fromID[i].s)
			end
			iEET.infoFrame.text:SetText(infoText)
			iEET.infoFrame.text:Show()
			iEET.infoFrame:SetSize(iEET.infoFrame.text:GetStringWidth()+4,iEET.infoFrame.text:GetStringHeight()+4)
		end
	end
	--Info button
	iEET.infoButton = CreateFrame('FRAME', nil, iEET.optionsFrame)
	iEET.infoButton:SetSize(21, 21)
	iEET.infoButton:SetPoint('TOPRIGHT', iEET.optionsFrameTop, 'TOPRIGHT', -2, -2)
	iEET.infoButton:SetBackdrop(iEET.backdrop);
	iEET.infoButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.infoButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.infoButton:SetScript('OnEnter', function()
		infoFrame()
	end)
	iEET.infoButton:SetScript('OnLeave', function()
		infoFrame(true)
	end)
	iEET.infoButton:SetScript('OnMouseDown', function()
		if iEET.lastShownOnClick then
			infoFrame(true,true)
		else
			infoFrame(false,true)
		end
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
	iEET.optionsFrameFilterTexts:SetScript('OnMouseWheel', function(self, delta)
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
	iEET.optionsFrameEditbox:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,0.2)
	iEET.optionsFrameEditbox:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
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
	iEET:FillFilters()
	-- Save button
	iEET.optionsFrameSaveButton = CreateFrame('BUTTON', nil, iEET.optionsFrame)
	iEET.optionsFrameSaveButton:SetSize(100, 20)
	iEET.optionsFrameSaveButton:SetBackdrop(iEET.backdrop);
	iEET.optionsFrameSaveButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.optionsFrameSaveButton.text = iEET.optionsFrameSaveButton:CreateFontString()
	iEET.optionsFrameSaveButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.optionsFrameSaveButton.text:SetPoint('CENTER', iEET.optionsFrameSaveButton, 'CENTER', 0,0)
	iEET.optionsFrameSaveButton.text:SetText('Save')
	iEET.optionsFrameSaveButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.optionsFrameSaveButton:SetPoint('BOTTOMRIGHT', iEET.optionsFrame, 'BOTTOM', -54,4)
	iEET.optionsFrameSaveButton:Show()
	iEET.optionsFrameSaveButton:RegisterForClicks('AnyUp')
	iEET.optionsFrameSaveButton:SetScript('OnClick',function()
		--Parse filters from scrolling message frame
		iEET:ParseFilters()
		iEET:FillFilters()
	end)
	-- Save & Close
	iEET.optionsFrameSaveAndCloseButton = CreateFrame('BUTTON', nil, iEET.optionsFrame)
	iEET.optionsFrameSaveAndCloseButton:SetSize(100, 20)
	iEET.optionsFrameSaveAndCloseButton:SetBackdrop(iEET.backdrop);
	iEET.optionsFrameSaveAndCloseButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.optionsFrameSaveAndCloseButton.text = iEET.optionsFrameSaveAndCloseButton:CreateFontString()
	iEET.optionsFrameSaveAndCloseButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.optionsFrameSaveAndCloseButton.text:SetPoint('CENTER', iEET.optionsFrameSaveAndCloseButton, 'CENTER', 0,0)
	iEET.optionsFrameSaveAndCloseButton.text:SetText('Save & Close')
	iEET.optionsFrameSaveAndCloseButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.optionsFrameSaveAndCloseButton:SetPoint('BOTTOM', iEET.optionsFrame, 'BOTTOM', 0,4)
	iEET.optionsFrameSaveAndCloseButton:Show()
	iEET.optionsFrameSaveAndCloseButton:RegisterForClicks('AnyUp')
	iEET.optionsFrameSaveAndCloseButton:SetScript('OnClick',function()
		--Parse filters from scrolling message frame
		iEET:ParseFilters()
		if iEET.infoFrame then
			iEET.infoFrame:Hide()
		end
		iEET.optionsFrame:Hide()
	end)
	-- Cancel button
	iEET.optionsFrameCancelButton = CreateFrame('BUTTON', nil, iEET.optionsFrame)
	iEET.optionsFrameCancelButton:SetSize(100, 20)
	iEET.optionsFrameCancelButton:SetBackdrop(iEET.backdrop);
	iEET.optionsFrameCancelButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
	iEET.optionsFrameCancelButton.text = iEET.optionsFrameCancelButton:CreateFontString()
	iEET.optionsFrameCancelButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
	iEET.optionsFrameCancelButton.text:SetPoint('CENTER', iEET.optionsFrameCancelButton, 'CENTER', 0,0)
	iEET.optionsFrameCancelButton.text:SetText('Cancel')
	iEET.optionsFrameCancelButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
	iEET.optionsFrameCancelButton:SetPoint('BOTTOMLEFT', iEET.optionsFrame, 'BOTTOM', 54,4)
	iEET.optionsFrameCancelButton:Show()
	iEET.optionsFrameCancelButton:RegisterForClicks('AnyUp')
	iEET.optionsFrameCancelButton:SetScript('OnClick',function()
		-- clear unsaved args & close
		iEET.optionsFrameEditbox:SetText('')
		iEET.optionsFrame:Hide()
		if iEET.infoFrame then
			iEET.infoFrame:Hide()
		end
	end)
	iEET:FillFilters()
end

function iEET:toggleDeleteOptions()
	if not iEET.deleteOptions then
		--Delete options main frame
			local width = 310
		iEET.deleteOptions = {}
		iEET.deleteOptions.mainFrame = CreateFrame('Frame', 'iEETDeleteFrame', UIParent)
		iEET.deleteOptions.mainFrame:SetSize(width,110)
		iEET.deleteOptions.mainFrame:SetPoint('CENTER', UIParent, 'CENTER', iEETConfig.spawnOffset,0)
		iEET.deleteOptions.mainFrame:SetBackdrop(iEET.backdrop);
		iEET.deleteOptions.mainFrame:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.mainFrame:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.mainFrame:Show()
		iEET.deleteOptions.mainFrame:SetFrameStrata('DIALOG')
		iEET.deleteOptions.mainFrame:SetFrameLevel(1)
		iEET.deleteOptions.mainFrame:EnableMouse(true)
		iEET.deleteOptions.mainFrame:SetMovable(true)
		-- Options title frame
		iEET.deleteOptions.top = CreateFrame('FRAME', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.top:SetSize(width, 15)
		iEET.deleteOptions.top:SetPoint('BOTTOMRIGHT', iEET.deleteOptions.mainFrame, 'TOPRIGHT', 0, -1)
		iEET.deleteOptions.top:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.top:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.top:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.top:SetScript('OnMouseDown', function(self,button)
			iEET.deleteOptions.mainFrame:ClearAllPoints()
			iEET.deleteOptions.mainFrame:StartMoving()
		end)
		iEET.deleteOptions.top:SetScript('OnMouseUp', function(self, button)
			iEET.deleteOptions.mainFrame:StopMovingOrSizing()
		end)
		iEET.deleteOptions.top:EnableMouse(true)
		iEET.deleteOptions.top:Show()
		iEET.deleteOptions.top:SetFrameStrata('DIALOG')
		iEET.deleteOptions.top:SetFrameLevel(1)
		-- Options title text
		iEET.deleteOptions.top.text = iEET.deleteOptions.top:CreateFontString()
		iEET.deleteOptions.top.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.top.text:SetPoint('CENTER', iEET.deleteOptions.top, 'CENTER', 0,0)
		iEET.deleteOptions.top.text:SetText('Delete options')
		iEET.deleteOptions.top.text:Show()

		iEET.deleteOptions.top.exitButton = CreateFrame('FRAME', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.top.exitButton:SetSize(15, 15)
		iEET.deleteOptions.top.exitButton:SetPoint('TOPRIGHT', iEET.deleteOptions.top, 'TOPRIGHT', 0, 0)
		iEET.deleteOptions.top.exitButton:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.top.exitButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.top.exitButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.top.exitButton:SetScript('OnMouseDown', function(self,button)
			iEET.deleteOptions.mainFrame:Hide()
		end)
		iEET.deleteOptions.top.exitButton:EnableMouse(true)
		iEET.deleteOptions.top.exitButton:Show()
		iEET.deleteOptions.top.exitButton:SetFrameStrata('DIALOG')
		iEET.deleteOptions.top.exitButton:SetFrameLevel(2)
		iEET.deleteOptions.top.exitButton.text = iEET.deleteOptions.top.exitButton:CreateFontString()
		iEET.deleteOptions.top.exitButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.top.exitButton.text:SetPoint('CENTER', iEET.deleteOptions.top.exitButton, 'CENTER', 0,0)
		iEET.deleteOptions.top.exitButton.text:SetText('X')
		iEET.deleteOptions.top.exitButton.text:Show()


		local deleteOptionsVars = {
			dif = false,
			encounter = false,
			del = false,
		}
		local function setErrorText(check)
			if check then
				if deleteOptionsVars.encounter and deleteOptionsVars.del then
					return true
				else
					return false
				end
			end
			local errorText
			if not  deleteOptionsVars.encounter then
				errorText = 'Error: EncounterID has to be number, use "" or "*" to select all encounters. Use "0" to delete custom (force started) encounters.'
			end
			if not deleteOptionsVars.del then
				if errorText then
					errorText = errorText .. '\nError: Choose delete mode.'
				else
					errorText = 'Error: Choose delete mode.'
				end
			end
			if errorText then
				iEET.deleteOptions.errorText:SetText(errorText)
				iEET.deleteOptions.errorText:Show()
			else
				iEET.deleteOptions.errorText:SetText('')
				iEET.deleteOptions.errorText:Hide()
			end
		end
		local function getMenuTable(menuOption)
			local t = {}
			if menuOption == 'dif' then
				local tempKeys = {}
				for keyString, dataString in pairs(iEET_Data) do
					local dif = keyString:match('{d=(%d+)}')
					tempKeys[tonumber(dif)] = true
				end
				for difID, _ in spairs(tempKeys) do
					local difName, groupType = GetDifficultyInfo(difID)
					local temp = {}
					temp.text = string.format('%s (%s)', difName, groupType)
					temp.keepShownOnClick = false
					temp.isNotRadio = true
					temp.notCheckable = true
					temp.func = function()
						deleteOptionsVars.dif = difID
						iEET.deleteOptions.chooseDifficulty.text:SetText(string.format('%s (%s)', difName, groupType))
					end
					table.insert(t, temp)
				end
				table.insert(t, {text = 'Any', func = function()
					deleteOptionsVars.dif = false
					iEET.deleteOptions.chooseDifficulty.text:SetText('Any')
				end, notCheckable = true})
			else
				local opt = {
					[1] = {k = 'deleteAll', v = 'Delete all'},
					[2] = {k = 'saveLastKill', v = 'Save last kill'},
					[3] = {k = 'saveShortestKill', v = 'Save shortest kill'},
					[4] = {k = 'deleteAllWipes', v = 'Delete all wipes'},
					[5] = {k = 60, v = 'Delete under 60sec fights'},
					[6] = {k = 120, v = 'Delete under 120sec fights'},
					[7] = {k = 180, v = 'Delete under 180sec fights'},
					[8] = {k = 240, v = 'Delete under 240sec fights'},
					[9] = {k = 300, v = 'Delete under 300sec fights'},
					[10] = {k = 360, v = 'Delete under 360sec fights'},
					[11] = {k = 420, v = 'Delete under 420sec fights'},
				}
				for _, data in ipairs(opt) do
					local temp = {}
					temp.text = data.v
					temp.keepShownOnClick = false
					temp.isNotRadio = true
					temp.notCheckable = true
					temp.func = function()
						deleteOptionsVars.del = data.k
						iEET.deleteOptions.chooseDeleteMode.text:SetText(data.v)
						setErrorText()
					end
					table.insert(t, temp)
				end
			end
			table.insert(t, {text = 'Close', func = function() CloseDropDownMenus() end, notCheckable = true})
			return t
		end

		iEET.deleteOptions.chooseDifficulty = CreateFrame('button', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.chooseDifficulty:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.chooseDifficulty:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.chooseDifficulty:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.chooseDifficulty:SetSize(100,20)
		iEET.deleteOptions.chooseDifficulty:EnableMouse(true)
		iEET.deleteOptions.chooseDifficulty:SetPoint('TOPLEFT', iEET.deleteOptions.mainFrame, 'TOPLEFT', 3,-18)
		iEET.deleteOptions.chooseDifficulty.text = iEET.deleteOptions.chooseDifficulty:CreateFontString()
		iEET.deleteOptions.chooseDifficulty.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseDifficulty.text:SetPoint('CENTER', iEET.deleteOptions.chooseDifficulty, 'CENTER', 0,0)
		iEET.deleteOptions.chooseDifficulty.text:SetWidth(100)
		iEET.deleteOptions.chooseDifficulty.text:SetHeight(20)
		iEET.deleteOptions.chooseDifficulty.text:SetText('Any')
		iEET.deleteOptions.chooseDifficulty.title = iEET.deleteOptions.chooseDifficulty:CreateFontString()
		iEET.deleteOptions.chooseDifficulty.title:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseDifficulty.title:SetPoint('BOTTOM', iEET.deleteOptions.chooseDifficulty, 'TOP', 0,3)
		iEET.deleteOptions.chooseDifficulty.title:SetText('Difficulty')
		iEET.deleteOptions.chooseDifficulty.menu = CreateFrame('Frame', 'iEET_Delete_ChooseDifficulty', iEET.deleteOptions.mainFrame, 'UIDropDownMenuTemplate')
		iEET.deleteOptions.chooseDifficulty:SetScript('OnClick',function()
			if UIDROPDOWNMENU_OPEN_MENU then
				CloseDropDownMenus()
				return
			end
			EasyMenu(getMenuTable('dif'), iEET.deleteOptions.chooseDifficulty.menu, iEET.deleteOptions.chooseDifficulty, 0 , 0)
		end)
		iEET.deleteOptions.chooseEncounter = CreateFrame('editbox', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.chooseEncounter:SetSize(100,20)
		iEET.deleteOptions.chooseEncounter:SetAutoFocus(false)
		iEET.deleteOptions.chooseEncounter:SetTextInsets(2, 2, 1, 0)
		iEET.deleteOptions.chooseEncounter:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseEncounter:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.chooseEncounter:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.chooseEncounter:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.chooseEncounter:SetPoint('TOP', iEET.deleteOptions.mainFrame, 'TOP', 0,-18)
		iEET.deleteOptions.chooseEncounter:SetScript('OnTextChanged', function(self)
			local text = self:GetText()
			if tonumber(text) then
				deleteOptionsVars.encounter = tonumber(text)
				setErrorText()
			elseif text == '*' or text == '' then
				deleteOptionsVars.encounter = true
				setErrorText()
			else
				deleteOptionsVars.encounter = false
				setErrorText()
			end
		end)
		iEET.deleteOptions.chooseEncounter:SetScript('OnEnterPressed', function(self)
			self:ClearFocus()
		end)
		iEET.deleteOptions.chooseEncounter:SetText('*')
		iEET.deleteOptions.chooseEncounter.text = iEET.deleteOptions.chooseEncounter:CreateFontString()
		iEET.deleteOptions.chooseEncounter.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseEncounter.text:SetPoint('BOTTOM', iEET.deleteOptions.chooseEncounter, 'TOP', 0,3)
		iEET.deleteOptions.chooseEncounter.text:SetText('Encounter ID')

		iEET.deleteOptions.chooseDeleteMode = CreateFrame('button', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.chooseDeleteMode:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.chooseDeleteMode:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.chooseDeleteMode:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.chooseDeleteMode:SetSize(100,20)
		iEET.deleteOptions.chooseDeleteMode:EnableMouse(true)
		iEET.deleteOptions.chooseDeleteMode:SetPoint('TOPRIGHT', iEET.deleteOptions.mainFrame, 'TOPRIGHT', -3,-18)
		iEET.deleteOptions.chooseDeleteMode.text = iEET.deleteOptions.chooseDeleteMode:CreateFontString()
		iEET.deleteOptions.chooseDeleteMode.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseDeleteMode.text:SetPoint('CENTER', iEET.deleteOptions.chooseDeleteMode, 'CENTER', 0,0)
		iEET.deleteOptions.chooseDeleteMode.text:SetWidth(100)
		iEET.deleteOptions.chooseDeleteMode.text:SetHeight(20)
		iEET.deleteOptions.chooseDeleteMode.text:SetText('Choose')
		iEET.deleteOptions.chooseDeleteMode.title = iEET.deleteOptions.chooseDeleteMode:CreateFontString()
		iEET.deleteOptions.chooseDeleteMode.title:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.chooseDeleteMode.title:SetPoint('BOTTOM', iEET.deleteOptions.chooseDeleteMode, 'TOP', 0,3)
		iEET.deleteOptions.chooseDeleteMode.title:SetText('Delete option')
		iEET.deleteOptions.chooseDeleteMode.menu = CreateFrame('Frame', 'iEET_Delete_DeleteOption', iEET.deleteOptions.mainFrame, 'UIDropDownMenuTemplate')
		iEET.deleteOptions.chooseDeleteMode:SetScript('OnClick',function()
			if UIDROPDOWNMENU_OPEN_MENU then
				CloseDropDownMenus()
				return
			end
			EasyMenu(getMenuTable(), iEET.deleteOptions.chooseDeleteMode.menu, iEET.deleteOptions.chooseDeleteMode, 0 , 0)
		end)

		iEET.deleteOptions.deleteButton = CreateFrame('FRAME', nil, iEET.deleteOptions.mainFrame)
		iEET.deleteOptions.deleteButton:SetSize(width-6, 25)
		iEET.deleteOptions.deleteButton:SetPoint('BOTTOM', iEET.deleteOptions.mainFrame, 'BOTTOM', 0, 3)
		iEET.deleteOptions.deleteButton:SetBackdrop(iEET.backdrop)
		iEET.deleteOptions.deleteButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.deleteOptions.deleteButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.deleteOptions.deleteButton:SetScript('OnMouseDown', function(self,button)
			if setErrorText(true) then
				iEET:massDelete(deleteOptionsVars)
			end
		end)
		iEET.deleteOptions.deleteButton:EnableMouse(true)
		iEET.deleteOptions.deleteButton:Show()
		iEET.deleteOptions.deleteButton:SetFrameStrata('DIALOG')
		iEET.deleteOptions.deleteButton:SetFrameLevel(2)
		iEET.deleteOptions.deleteButton.text = iEET.deleteOptions.deleteButton:CreateFontString()
		iEET.deleteOptions.deleteButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.deleteButton.text:SetPoint('CENTER', iEET.deleteOptions.deleteButton, 'CENTER', 0,0)
		iEET.deleteOptions.deleteButton.text:SetText('Delete')
		iEET.deleteOptions.deleteButton.text:Show()

		iEET.deleteOptions.errorText = iEET.deleteOptions.mainFrame:CreateFontString()
		iEET.deleteOptions.errorText:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.deleteOptions.errorText:SetPoint('BOTTOM', iEET.deleteOptions.deleteButton, 'TOP', 0,3)
		iEET.deleteOptions.errorText:SetPoint('TOP', iEET.deleteOptions.chooseEncounter, 'BOTTOM', 0,-3)
		iEET.deleteOptions.errorText:SetWidth(width-20)
		iEET.deleteOptions.errorText:SetJustifyV('MIDDLE')
		iEET.deleteOptions.errorText:SetText('')
		iEET.deleteOptions.errorText:SetTextColor(1,0,0,1)
	elseif iEET.deleteOptions.mainFrame:IsShown() then
		iEET.deleteOptions.mainFrame:Hide()
	else
		iEET.deleteOptions.mainFrame:Show()
	end
end
function iEET:Options()
	if iEET.optionsFrame then
		if iEET.optionsFrame:IsShown() then
			iEET.optionsFrame:Hide()
			if iEET.infoFrame then
				iEET.infoFrame:Hide()
			end
		else
			iEET.optionsFrame:Show()
			if iEET.infoFrame and iEET.lastShownOnClick then
				iEET.infoFrame:Show()
			end
			iEET:FillFilters()
		end
	else
		iEET:CreateOptionsFrame()
	end
end
function iEET:Toggle(show)
	if not InCombatLockdown() then
		if not iEET.frame then
			for key, _ in pairs(iEET_Data) do
				if not key:find('{eI=(%d+)}') then
					iEET:ConvertOldReports()
					break
				end
			end
			iEET:CreateMainFrame()
		elseif iEET.frame:IsShown() and not show then
			iEET.frame:Hide()
		else
			iEET.frame:Show()
			iEET:updateEncounterListMenu()
			-- Check if fight is already saved, if its enable prev/next buttons, else hide
			if iEET.encounterInfoData then
				if iEET:getNextPrevEncounter(1) then
					iEET.prevEncounter:Show()
					iEET.nextEncounter:Show()
				else
					iEET.prevEncounter:Hide()
					iEET.nextEncounter:Hide()
				end
			else
				iEET.prevEncounter:Hide()
				iEET.nextEncounter:Hide()
			end
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
		iEET.copyFrame:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,0.2)
		iEET.copyFrame:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
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
		iEET.copyFrame:SetPoint('CENTER', UIParent, 'CENTER', iEETConfig.spawnOffset,0)
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
function iEET:CreateOnscreenFrame()
	iEET.onscreen = CreateFrame("Frame", "iEETOnscreen", UIParent)
	iEET.onscreen:SetSize(598,iEETConfig.onscreen.lines*11+2)
	iEET.onscreen:SetPoint(iEETConfig.onscreen.position.from, UIParent, iEETConfig.onscreen.position.to, iEETConfig.onscreen.position.x,iEETConfig.onscreen.position.y)
	if iEETConfig.scales.onscreen then
		iEET.onscreen:SetScale(iEETConfig.scales.onscreen)
	end
	iEET.onscreen:SetFrameStrata('HIGH')
	iEET.onscreen:SetFrameLevel(1)
	local lastframe = false
	local slices = {
		[1] = 40,
		[2] = 40,
		[3] = 105,
		[4] = 131,
		[5] = 120,
		[6] = 97,
		[7] = 36,
		[8] = 36,
	};
	for i=1, 8 do
		local fa = 'onscreenAnchor' .. i
		local fc = 'onscreenContent' .. i
		---anchor frame
		iEET[fa] = CreateFrame('FRAME', nil , iEET.onscreen)
		iEET[fa]:SetSize(slices[i], iEETConfig.onscreen.lines*11)
		if not lastframe then
			iEET[fa]:SetPoint('TOPLEFT', iEET.onscreen, 'TOPLEFT', 0, 0)
			lastframe = fa
		else
			iEET[fa]:SetPoint('LEFT', iEET[lastframe], 'RIGHT', -1,0)
			lastframe = fa
		end
		iEET[fa]:SetBackdrop({
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
		iEET[fa]:SetBackdropColor(iEETConfig.colors.onscreen.bg.r,iEETConfig.colors.onscreen.bg.g,iEETConfig.colors.onscreen.bg.b,iEETConfig.colors.onscreen.bg.a)
		iEET[fa]:SetBackdropBorderColor(iEETConfig.colors.onscreen.border.r,iEETConfig.colors.onscreen.border.g,iEETConfig.colors.onscreen.border.b,iEETConfig.colors.onscreen.border.a)
		---
		iEET[fc] = CreateFrame('ScrollingMessageFrame', nil, iEET[fa])
		iEET[fc]:SetSize(slices[i]-8,iEETConfig.onscreen.lines*11)
		iEET[fc]:SetPoint('CENTER', iEET[fa], 'CENTER', 0, 0)
		iEET[fc]:SetFont(iEET.font, iEET.fontsize)
		iEET[fc]:SetFading(false)
		iEET[fc]:SetInsertMode("BOTTOM")
		iEET[fc]:SetJustifyH(iEET.justifyH)
		iEET[fc]:SetMaxLines(iEETConfig.onscreen.historySize)
		iEET[fc]:SetSpacing(iEET.spacing)
		iEET[fc]:EnableMouseWheel(true)
		iEET[fc]:SetScript("OnMouseWheel", function(self, delta)
			iEET:ScrollOnscreen(delta)
		end)
		if i == 1 or i == 2 or i == 4 or i == 5 or i == 6 then --allow hyperlinks for encounter time, interval time, spellName, sourceName, destName
			iEET[fc]:SetHyperlinksEnabled(true)
			iEET[fc]:SetScript("OnHyperlinkEnter", function(self, linkData, link)
				GameTooltip:SetOwner(iEET.onscreen, "ANCHOR_TOPRIGHT", 0-iEET.onscreen:GetWidth(), 0-iEET.onscreen:GetHeight())
				iEET:Hyperlinks(linkData, link)
			end)
			iEET[fc]:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
			end)
			iEET[fc]:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
				if string.find(linkData, 'iEETtime') then
					return
				elseif IsShiftKeyDown() and IsInRaid() then
					local linkType = strsplit(':', linkData)
					if linkType == 'iEETcustomyell' then
						local _, event, spellID, spellName = strsplit(':',linkData)
						SendChatMessage(spellID, 'RAID')
					elseif linkType == 'iEETcustomspell' then
						local _, event, spellID, spellName, npcID = strsplit(':',linkData)
						SendChatMessage(GetSpellLink(tonumber(spellID)), 'RAID')
					end
				end
			end)
		end
		iEET[fc]:SetFrameStrata('HIGH')
		iEET[fc]:SetFrameLevel(2)
		iEET[fc]:EnableMouse(true)
	end
	iEET.onscreen:Show()
end

function iEET:ToggleOnscreenDisplay(EnabledChanged)
	if EnabledChanged then -- Call came from options menu
		if not iEETConfig.onscreen.enabled then -- disabled after gui was created
			if iEET.onscreen then
				iEET.onscreen:Hide()
			end
			return
		end
	end
	if not iEET.onscreen then
		iEET:CreateOnscreenFrame()
	elseif iEET.onscreen:IsShown() then
		iEET.onscreen:Hide()
	else
		iEET.onscreen:Show()
	end
end
function iEET:OnscreenDisplayUpdatePos()
	if not iEET.onscreen then return end
	iEET.onscreen:ClearAllPoints()
	iEET.onscreen:SetPoint(iEETConfig.onscreen.position.from, UIParent, iEETConfig.onscreen.position.to, iEETConfig.onscreen.position.x,iEETConfig.onscreen.position.y)
end
function iEET:StartRecordingWithoutFiltersPopup()
	if not iEET.noFiltersPopup then
			--Delete options main frame
		local width = 310
		iEET.noFiltersPopup = {}
		iEET.noFiltersPopup.mainFrame = CreateFrame('Frame', 'iEETnoFiltersPopup', UIParent)
		iEET.noFiltersPopup.mainFrame:SetSize(width,110)
		iEET.noFiltersPopup.mainFrame:SetPoint('CENTER', UIParent, 'CENTER', iEETConfig.spawnOffset,0)
		iEET.noFiltersPopup.mainFrame:SetBackdrop(iEET.backdrop);
		iEET.noFiltersPopup.mainFrame:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.noFiltersPopup.mainFrame:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.noFiltersPopup.mainFrame:Show()
		iEET.noFiltersPopup.mainFrame:SetFrameStrata('DIALOG')
		iEET.noFiltersPopup.mainFrame:SetFrameLevel(1)
		iEET.noFiltersPopup.mainFrame:EnableMouse(true)
		iEET.noFiltersPopup.mainFrame:SetMovable(true)
		-- Options title frame
		iEET.noFiltersPopup.top = CreateFrame('FRAME', nil, iEET.noFiltersPopup.mainFrame)
		iEET.noFiltersPopup.top:SetSize(width, 15)
		iEET.noFiltersPopup.top:SetPoint('BOTTOMRIGHT', iEET.noFiltersPopup.mainFrame, 'TOPRIGHT', 0, -1)
		iEET.noFiltersPopup.top:SetBackdrop(iEET.backdrop)
		iEET.noFiltersPopup.top:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.noFiltersPopup.top:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.noFiltersPopup.top:SetScript('OnMouseDown', function(self,button)
			iEET.noFiltersPopup.mainFrame:ClearAllPoints()
			iEET.noFiltersPopup.mainFrame:StartMoving()
		end)
		iEET.noFiltersPopup.top:SetScript('OnMouseUp', function(self, button)
			iEET.noFiltersPopup.mainFrame:StopMovingOrSizing()
		end)
		iEET.noFiltersPopup.top:EnableMouse(true)
		iEET.noFiltersPopup.top:Show()
		iEET.noFiltersPopup.top:SetFrameStrata('DIALOG')
		iEET.noFiltersPopup.top:SetFrameLevel(1)
		-- Options title text
		iEET.noFiltersPopup.top.text = iEET.noFiltersPopup.top:CreateFontString()
		iEET.noFiltersPopup.top.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.noFiltersPopup.top.text:SetPoint('CENTER', iEET.noFiltersPopup.top, 'CENTER', 0,0)
		iEET.noFiltersPopup.top.text:SetText('Start logging without filters')
		iEET.noFiltersPopup.top.text:Show()

		iEET.noFiltersPopup.top.exitButton = CreateFrame('FRAME', nil, iEET.noFiltersPopup.mainFrame)
		iEET.noFiltersPopup.top.exitButton:SetSize(15, 15)
		iEET.noFiltersPopup.top.exitButton:SetPoint('TOPRIGHT', iEET.noFiltersPopup.top, 'TOPRIGHT', 0, 0)
		iEET.noFiltersPopup.top.exitButton:SetBackdrop(iEET.backdrop)
		iEET.noFiltersPopup.top.exitButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.noFiltersPopup.top.exitButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.noFiltersPopup.top.exitButton:SetScript('OnMouseDown', function(self,button)
			iEET.noFiltersPopup.mainFrame:Hide()
		end)
		iEET.noFiltersPopup.top.exitButton:EnableMouse(true)
		iEET.noFiltersPopup.top.exitButton:Show()
		iEET.noFiltersPopup.top.exitButton:SetFrameStrata('DIALOG')
		iEET.noFiltersPopup.top.exitButton:SetFrameLevel(2)
		iEET.noFiltersPopup.top.exitButton.text = iEET.noFiltersPopup.top.exitButton:CreateFontString()
		iEET.noFiltersPopup.top.exitButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.noFiltersPopup.top.exitButton.text:SetPoint('CENTER', iEET.noFiltersPopup.top.exitButton, 'CENTER', 0,0)
		iEET.noFiltersPopup.top.exitButton.text:SetText('X')
		iEET.noFiltersPopup.top.exitButton.text:Show()


		local noFiltersPopupVars = {
			timer = false,
			name = false,
		}
		local function setErrorText(check)
			if check then
				local timer = tonumber(noFiltersPopupVars.timer)
				if (timer and timer > 0) and (noFiltersPopupVars.name and noFiltersPopupVars.name:len() > 2) then
					return true
				else
					return false
				end
			end
			local errorText
			if not tonumber(noFiltersPopupVars.timer) then
				errorText = 'Error: Timer has to be number.'
			end
			if not noFiltersPopupVars.name or noFiltersPopupVars.name:len() <= 2 then
				if errorText then
					errorText = errorText .. "\nError: Name has to be at least 2 characters long."
				else
					errorText = "Error: Name has to be at least 2 characters long."
				end
			end
			if errorText then
				iEET.noFiltersPopup.errorText:SetText(errorText)
				iEET.noFiltersPopup.errorText:Show()
			else
				iEET.noFiltersPopup.errorText:SetText('')
				iEET.noFiltersPopup.errorText:Hide()
			end
		end
		iEET.noFiltersPopup.timer = CreateFrame('editbox', nil, iEET.noFiltersPopup.mainFrame)
		iEET.noFiltersPopup.timer:SetSize(101,20)
		iEET.noFiltersPopup.timer:SetAutoFocus(false)
		iEET.noFiltersPopup.timer:SetTextInsets(2, 2, 1, 0)
		iEET.noFiltersPopup.timer:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.noFiltersPopup.timer:SetBackdrop(iEET.backdrop)
		iEET.noFiltersPopup.timer:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.noFiltersPopup.timer:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.noFiltersPopup.timer:SetPoint('TOPLEFT', iEET.noFiltersPopup.mainFrame, 'TOPLEFT', 3,-18)
		iEET.noFiltersPopup.timer:SetScript('OnTextChanged', function(self)
			local text = self:GetText()
				noFiltersPopupVars.timer = text
				setErrorText()
		end)
		iEET.noFiltersPopup.timer:SetScript('OnEnterPressed', function(self)
			self:ClearFocus()
		end)
		iEET.noFiltersPopup.timer:SetText('60')
		iEET.noFiltersPopup.timer.text = iEET.noFiltersPopup.timer:CreateFontString()
		iEET.noFiltersPopup.timer.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.noFiltersPopup.timer.text:SetPoint('BOTTOM', iEET.noFiltersPopup.timer, 'TOP', 0,3)
		iEET.noFiltersPopup.timer.text:SetText('Timer (sec)')

		iEET.noFiltersPopup.name = CreateFrame('editbox', nil, iEET.noFiltersPopup.mainFrame)
		iEET.noFiltersPopup.name:SetSize(201,20)
		iEET.noFiltersPopup.name:SetAutoFocus(false)
		iEET.noFiltersPopup.name:SetTextInsets(2, 2, 1, 0)
		iEET.noFiltersPopup.name:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.noFiltersPopup.name:SetBackdrop(iEET.backdrop)
		iEET.noFiltersPopup.name:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.noFiltersPopup.name:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.noFiltersPopup.name:SetPoint('TOPRIGHT', iEET.noFiltersPopup.mainFrame, 'TOPRIGHT', -3,-18)
		iEET.noFiltersPopup.name:SetScript('OnTextChanged', function(self)
			local text = self:GetText()
				noFiltersPopupVars.name = text
				setErrorText()
		end)
		iEET.noFiltersPopup.name:SetScript('OnEnterPressed', function(self)
			self:ClearFocus()
		end)
		iEET.noFiltersPopup.name:SetText('')
		iEET.noFiltersPopup.name.text = iEET.noFiltersPopup.timer:CreateFontString()
		iEET.noFiltersPopup.name.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.noFiltersPopup.name.text:SetPoint('BOTTOM', iEET.noFiltersPopup.name, 'TOP', 0,3)
		iEET.noFiltersPopup.name.text:SetText('Log name')


		iEET.noFiltersPopup.startButton = CreateFrame('FRAME', nil, iEET.noFiltersPopup.mainFrame)
		iEET.noFiltersPopup.startButton:SetSize(width-6, 25)
		iEET.noFiltersPopup.startButton:SetPoint('BOTTOM', iEET.noFiltersPopup.mainFrame, 'BOTTOM', 0, 3)
		iEET.noFiltersPopup.startButton:SetBackdrop(iEET.backdrop)
		iEET.noFiltersPopup.startButton:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		iEET.noFiltersPopup.startButton:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		iEET.noFiltersPopup.startButton:SetScript('OnMouseDown', function(self,button)
			if setErrorText(true) then
				iEET:ForceStartWithoutFilters(noFiltersPopupVars.timer,noFiltersPopupVars.name)
				iEET.noFiltersPopup.mainFrame:Hide()
				if iEET.frame then -- if someone somehow manages to open up this window without opening up main frame
					iEET.frame:Hide()
				end
			end
		end)
		iEET.noFiltersPopup.startButton:EnableMouse(true)
		iEET.noFiltersPopup.startButton:Show()
		iEET.noFiltersPopup.startButton:SetFrameStrata('DIALOG')
		iEET.noFiltersPopup.startButton:SetFrameLevel(2)
		iEET.noFiltersPopup.startButton.text = iEET.noFiltersPopup.startButton:CreateFontString()
		iEET.noFiltersPopup.startButton.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		iEET.noFiltersPopup.startButton.text:SetPoint('CENTER', iEET.noFiltersPopup.startButton, 'CENTER', 0,0)
		iEET.noFiltersPopup.startButton.text:SetText('Start')
		iEET.noFiltersPopup.startButton.text:Show()

		iEET.noFiltersPopup.errorText = iEET.noFiltersPopup.mainFrame:CreateFontString()
		iEET.noFiltersPopup.errorText:SetFont(iEET.font, iEET.fontsize+2, 'OUTLINE')
		iEET.noFiltersPopup.errorText:SetPoint('BOTTOM', iEET.noFiltersPopup.startButton, 'TOP', 0,3)
		iEET.noFiltersPopup.errorText:SetPoint('TOPLEFT', iEET.noFiltersPopup.timer, 'BOTTOMLEFT', 0,-3)
		iEET.noFiltersPopup.errorText:SetWidth(width-20)
		iEET.noFiltersPopup.errorText:SetJustifyV('MIDDLE')
		iEET.noFiltersPopup.errorText:SetText('')
		iEET.noFiltersPopup.errorText:SetTextColor(1,0,0,1)
	else
		iEET.noFiltersPopup.name:SetText('')
		iEET.noFiltersPopup.mainFrame:Show()

	end
end