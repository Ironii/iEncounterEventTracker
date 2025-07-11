local _, iEET = ...
local spairs = iEET.spairs
local tinsert, tremove, sformat, tconcat = table.insert, table.remove, string.format, table.concat
local options = {}
local addNewFilterOptions = {}
local totalWidth = 500
local totalHeight = 600
local function tcopy(data)
	local t = {}
	for k,v in pairs(data) do
		if type(v) == "table" then
			t[k] = tcopy(v)
		else
			t[k] = v
		end
	end
	return t
end
local function showTooltipOnCursor(...)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR", 0, 0)
	for _,v in ipairs({...}) do
		if v then
			GameTooltip:AddLine(v)
		end
	end
	GameTooltip:Show()
end
local function utf8_charbytes (s, i)
	-- argument defaults
	i = i or 1
	local c = string.byte(s, i)
	
	-- determine bytes needed for character, based on RFC 3629
	if c > 0 and c <= 127 then
		 -- UTF8-1
		 return 1
	elseif c >= 194 and c <= 223 then
		 -- UTF8-2
		 local c2 = string.byte(s, i + 1)
		 return 2
	elseif c >= 224 and c <= 239 then
		 -- UTF8-3
		 local c2 = s:byte(i + 1)
		 local c3 = s:byte(i + 2)
		 return 3
	elseif c >= 240 and c <= 244 then
		 -- UTF8-4
		 local c2 = s:byte(i + 1)
		 local c3 = s:byte(i + 2)
		 local c4 = s:byte(i + 3)
		 return 4
	end
end
local function utf8_len (s)
	local pos = 1
	local bytes = string.len(s)
	local len = 0
	local c = string.byte(s,pos)
	while pos <= bytes and len ~= c do
		 len = len + 1		 
		 pos = pos + utf8_charbytes(s, pos)
	end
	if c ~= nil then
		 return pos - 1
	end	
	return len
end
local function utf8_sub (s, i, j)
	j = j or -1

	if i == nil then
		 return ""
	end
	
	local pos = 1
	local bytes = string.len(s)
	local len = 0

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or utf8_len(s)
	local startChar = (i >= 0) and i or l + i + 1
	local endChar = (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if startChar > endChar then
		 return ""
	end
	
	-- byte offsets to pass to string.sub
	local startByte, endByte = 1, bytes
	
	while pos <= bytes do
		 len = len + 1
		 
		 if len == startChar then
	startByte = pos
		 end
		 
		 pos = pos + utf8_charbytes(s, pos)
		 
		 if len == endChar then
	endByte = pos - 1
	break
		 end
	end
	
	return string.sub(s, startByte, endByte)
end
local function trimText(self)
	while self.text:GetWidth() > self:GetWidth() do
		self.text:SetText(utf8_sub(self.text:GetText(), 1, -2))
	end
end
--http://lua-users.org/wiki/TableUtils
local tableUtils = {}
function tableUtils.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and tableUtils.tostring( v ) or
      tostring( v )
  end
end

function tableUtils.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. tableUtils.val_to_str( k ) .. "]"
  end
end

function tableUtils.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, tableUtils.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
				tableUtils.key_to_str( k ) .. "=" .. tableUtils.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end
StaticPopupDialogs["IEET_ARE_YOU_SURE"] = {
  text = "%s",
  button1 = YES,
  button2 = CANCEL,
	OnAccept = function(self, data, data2)
		if type(data) == "function" then
			data()
		else
			iEET:print("Error: popup function not found.")
		end
  end,
	OnCancel = function (self, data, data2)
		if type(data2) == "function" then
			data2()
		end
  end,
  hideOnEscape = true,
}
do
	local holderFrame = CreateFrame("frame")
	local frames = {
		title = {},
		bg = {},
		button = {},
		editbox = {},
		fs = {},
		scrollframe = {},
		checkbox = {},
	}
	local modeColors = {
		any = {
			bg = {0,0,0,.25},
			border = {0,0,0,1}
		},
		enabled = {
			bg = {0,.5,0,.5},
			border = {0,1,0,1}
		},
		disabled = {
			bg = {.5,0,0,.5},
			border = {1,0,0,1}
		},
	}
	function addNewFilterOptions:getSpecificBG(id)
		return frames.bg[id]
	end
	local function getFrame(_type)
		for k,f in pairs(frames[_type]) do
			if not f.usedBy then
				return f 
			end
		end
	end
	do
		local function _resetFrame(f, new)
			if not new then
				f.usedBy = nil
				f:ClearAllPoints()
				f:SetParent(holderFrame)
				f:Hide()
			end
			if f.frameType == "bg" then
				f:SetBackdropColor(0,0,0,0)
				f:SetBackdropBorderColor(0,0,0,0)
			elseif f.frameType == "button" then
				f:SetBackdropColor(0,0,0,0)
				f:SetBackdropBorderColor(0,0,0,.5)
			elseif f.frameType == "editbox" then
				f:SetBackdropColor(0,0,0,0)
				f:SetBackdropBorderColor(0,0,0,.5)
			elseif f.frameType == "checkbox" then
				f:SetChecked(false)
			end
			return f
		end
		function addNewFilterOptions:ResetFrames(usedBys)
			local hasCleared = false
			for _, v in pairs(frames) do
				for i, f in pairs(v) do
					if not usedBys then
						if f.usedBy then
							_resetFrame(f)
							hasCleared = true
						end
					elseif f.usedBy and usedBys[f.usedBy] then
						_resetFrame(f)
						hasCleared = true
					end
				end
			end
			return hasCleared
		end
		function addNewFilterOptions:GetFrame(frameType, usedBy)
			if not usedBy then print("Error: addNewFilterOptions:GetFrame(frameType, usedBy) missing usedBy.") end
			local f = getFrame(frameType)
			if f then f.usedBy = usedBy return f end
			if frameType == "title" then
				local id = #frames.title+1
				frames.title[id] = CreateFrame("frame", nil, holderFrame)
				f = frames.title[id]
				f.id = id
				f.frameType = "title"
				f.usedBy = usedBy
				f:SetSize(300, 1)
				f.tex = f:CreateTexture()
				f.tex:SetColorTexture(1,0,0,.75)
				f.tex:SetAllPoints(f)
				f.text = f:CreateFontString()
				f.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
				f.text:SetPoint('bottom', f, 'top', 0,0)
				return f
			elseif frameType == "bg" then
				local id = #frames.bg+1
				frames.bg[id] = CreateFrame("frame", nil, holderFrame, "BackdropTemplate")
				f = frames.bg[id]
				f.id = id
				f.frameType = "bg"
				f.usedBy = usedBy
				f:SetBackdrop(iEET.backdrop);
				f = _resetFrame(f, true)
				return f
			elseif frameType == "button" then
				local id = #frames.button+1
				frames.button[id] = CreateFrame("frame", nil, holderFrame, "BackdropTemplate")
				f = frames.button[id]
				f.id = id
				f:HookScript("OnShow", trimText)
				C_Timer.After(0, function() 
					trimText(f)
				end
				)
				f.frameType = "button"
				f.usedBy = usedBy
				f:SetBackdrop(iEET.backdrop);
				f = _resetFrame(f, true)
				f.text = f:CreateFontString()
				f.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
				f.text:SetPoint('center', f, 'center', 0,0)
				f:EnableMouse()
				return f
			elseif frameType == "editbox" then
				local id = #frames.editbox+1
				frames.editbox[id] = CreateFrame('editbox', nil, holderFrame, "BackdropTemplate")
				f = frames.editbox[id]
				f.id = id
				f.frameType = "editbox"
				f.usedBy = usedBy
				f:SetAutoFocus(false)
				f:SetTextInsets(2, 2, 1, 0)
				f:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
				f:SetBackdrop(iEET.backdrop)
				f = _resetFrame(f, true)
				f.info = f:CreateFontString()
				f.info:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
				f.info:SetPoint('center', f, 'center', 0,0)
				f.info:SetTextColor(1,1,1,.5)
				f.info:Hide()
				return f
			elseif frameType == "fs" then
				local id = #frames.fs+1
				frames.fs[id] = holderFrame:CreateFontString()
				f = frames.fs[id]
				f.id = id
				f.frameType = "fs"
				f.usedBy = usedBy
				f:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
				f:SetTextColor(1,1,1,1)
				return f
			elseif frameType == "scrollframe" then
				local id = #frames.scrollframe+1
				frames.scrollframe[id] = CreateFrame('ScrollFrame', nil, holderFrame, "BackdropTemplate")
				f = frames.scrollframe[id]
				f.id = id
				f.frameType = "scrollframe"
				f.usedBy = usedBy
				
				f:SetBackdrop(iEET.backdrop)
				f:SetBackdropColor(0,0,0,0)
				f:SetBackdropBorderColor(0,0,0,0)
				f:EnableMouseWheel(true)
				--f:SetSize(10,10)
				f.content = CreateFrame('frame', nil, f)
				f.content:SetWidth(totalWidth)
				f.content:SetHeight(1000)
				f.content:SetPoint('topleft', f, 'topleft', 0,0)
				f:SetScrollChild(f.content)
				--Scroll
				f.slider = CreateFrame('Slider', nil, f, "BackdropTemplate")
				f.slider:SetWidth(4)
				f.slider:SetThumbTexture('Interface\\AddOns\\iEncounterEventTracker\\media\\thumb')
				f.slider:SetBackdrop(iEET.backdrop)
				f.slider:SetBackdropColor(0.1,0.1,0.1,0.9)
				f.slider:SetBackdropBorderColor(0,0,0,1)
				f.slider:SetPoint("topright", f, "topright", 0, 0)
				f.slider:SetPoint("bottom", f, "bottomright", 0, 0)

				f.slider:SetMinMaxValues(0, 500)
				f.slider:SetValue(0)
				f.slider:EnableMouseWheel(true)
				f.slider:SetScript('OnValueChanged', function(self, value)
					f:SetVerticalScroll(value)
				end)
				local contentScrollFunc = function(self, delta)
					if delta == -1 then --down
						local value = f.slider:GetValue()+20
						local min, max = f.slider:GetMinMaxValues()
						value = math.min(value, max)
						f.slider:SetValue(value)
					else -- up
						local value = f.slider:GetValue()-20
						value = math.max(0, value)
						f.slider:SetValue(value)
					end
				end
				f.resizeContent = function(height)
					height = math.ceil(height)
					f.content:SetHeight(math.floor(height))
					f.slider:SetMinMaxValues(0, math.max(height-f.slider:GetHeight(),0))
				end
				f:SetScript('OnMouseWheel', contentScrollFunc)
				f.slider:SetScript('OnMouseWheel', contentScrollFunc)
				return f
			elseif frameType == "checkbox" then
				local id = #frames.checkbox+1
				frames.checkbox[id] = CreateFrame("CheckButton", nil, holderFrame, "BackdropTemplate")
				local f = frames.checkbox[id]
				f.id = id
				f.frameType = "checkbox"
				f.usedBy = usedBy
				f:SetBackdrop(iEET.backdrop);
				f = _resetFrame(f, true)
				f.text = f:CreateFontString()
				f.text:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
				f.text:SetPoint('bottomleft', f, 'bottomright', 3,0)
				f:SetScript("PostClick", function(self)
					if self:GetChecked() then
						f:SetBackdropColor(0,1,0,.25)
						f:SetBackdropBorderColor(0,0,0,1)
					else
						f:SetBackdropColor(0,0,0,.25)
						f:SetBackdropBorderColor(1,0,0,1)
					end
				end)
				return f
			else
				iEET:print(string.format("Error: '%s' frame type not found.", frameType or "nil"))
			end
		end
	end
	function addNewFilterOptions:ReColorFrame(mode, f, all, pageOptions)
		if all then
			local frameType = pageOptions and pageOptions.t or f.frameType
			local usedBy = pageOptions and pageOptions.p or f.usedBy
			for k,v in pairs(frames[frameType]) do
				if v.usedBy == usedBy then
					v:SetBackdropColor(modeColors[mode].bg[1], modeColors[mode].bg[2], modeColors[mode].bg[3], modeColors[mode].bg[4])
					v:SetBackdropBorderColor(modeColors[mode].border[1], modeColors[mode].border[2], modeColors[mode].border[3], modeColors[mode].border[4])
				end
			end
		else
			f:SetBackdropColor(modeColors[mode].bg[1], modeColors[mode].bg[2], modeColors[mode].bg[3], modeColors[mode].bg[4])
			f:SetBackdropBorderColor(modeColors[mode].border[1], modeColors[mode].border[2], modeColors[mode].border[3], modeColors[mode].border[4])
		end
	end
end
do
	local titleTexts = {
		cast = "Casts",
		channel = "Channels",
		aura = "Auras",
		heal = "Heals",
		chat = "Chats",
		misc = "Miscellaneous",
		bigwigs = "BigWigs",
		dbm = "DeadlyBossMods",
		dmg = "Damage"
	}
	local sortedEvents = {}
	for k,v in spairs(iEET.events.fromID, function(t,a,b) return t[b].l > t[a].l end) do
		if not sortedEvents[v.t] then
			sortedEvents[v.t] = {}
		end
		tinsert(sortedEvents[v.t], {
			id = k,
			name = v.l,
			shortName = v.s,
			isCleu = v.c,
		})
	end
	local currentlySelectedEvents = {}
	local function count(t)
		local c = 0
		for _ in pairs(t) do
			c = c + 1
		end
		return c
	end
	local function generateEvents(eventType, titleText)
		local bg = addNewFilterOptions:GetFrame("bg", "eventPage")
		bg:SetWidth(totalWidth)
		local title = addNewFilterOptions:GetFrame("title", "eventPage")
		title:ClearAllPoints()
		title:SetParent(bg)
		title:SetPoint("top", bg, "top", 0, 0)
		title.text:SetText(titleText)
		title:Show()
		local i = 1
		local height = 20
		local width = totalWidth/5
		local editMode = false
		if count(currentlySelectedEvents) > 0 then
			editMode = true
		end
		for id, v in pairs(sortedEvents[eventType]) do
			local f = addNewFilterOptions:GetFrame("button", "eventPage")
			f:SetParent(bg)
			f:Show()
			f:SetSize(width-1, height)
			f:ClearAllPoints()
			addNewFilterOptions:ReColorFrame(editMode and (currentlySelectedEvents[v.id] and "enabled" or "disabled") or "any", f)
			f:SetPoint("topleft", bg, "topleft", ((i-1) % 5)*width, -math.floor((i-1)/5)*(height+1)-3)
			f.text:SetText(v.shortName)
			f:SetScript("OnEnter", function()
				if v.isCleu then
					showTooltipOnCursor(sformat("%s (CLEU)", v.name))
				else
					showTooltipOnCursor(v.name)
				end
			end)
			f:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			f:SetScript("OnMouseDown", function()
				if currentlySelectedEvents[v.id] then
					currentlySelectedEvents[v.id] = nil
					if count(currentlySelectedEvents) == 0 then
						addNewFilterOptions:ReColorFrame("any", f, true)
					else
						addNewFilterOptions:ReColorFrame("disabled", f)
					end
				else
					currentlySelectedEvents[v.id] = true
					if count(currentlySelectedEvents) == 1 then -- first selected, recolor rest
						addNewFilterOptions:ReColorFrame("disabled", f, true)
					end
					addNewFilterOptions:ReColorFrame("enabled", f)
				end
			end)
			i = i + 1
		end
		bg:SetHeight(math.ceil((i-1)/5)*(height+1))
		return bg
	end
	local function generatePopup(frame, t, func, lineID, reverse)
		lineID = lineID.."popup"
		if addNewFilterOptions:ResetFrames({[lineID] = true}) then
			return
		end
		local bg = addNewFilterOptions:GetFrame("bg", lineID)
		bg:SetParent(frame)
		bg:SetFrameStrata('DIALOG')
		bg:SetFrameLevel(20)
		bg:ClearAllPoints()
		bg:SetAllPoints(frame)
		bg:Show()
		local lastFrame
		local row = 0
		local col = 0
		for k,v in spairs(t) do
			local f = addNewFilterOptions:GetFrame("button",lineID)
			f:SetParent(bg)
			f:Show()
			f:SetSize(100, 18)
			f:ClearAllPoints()
			f:SetBackdropColor(0,0,0,.75)
			f:SetBackdropBorderColor(1,0,0,1)
			f:SetScript("OnEnter", nil)
			f:SetScript("OnLeave", nil)
			f.text:SetText(reverse and k or v)
			if row == 21 then
				col = col + 1
				row = 1
				f:SetPoint("top", bg, "bottom", col*99, 0)	
			elseif lastFrame then
					f:SetPoint("top", lastFrame, "bottom", 0, 1)
					row = row + 1
			else
				f:SetPoint("top", bg, "bottom", 0, 0)
				row = row + 1
			end
			lastFrame = f
			
			f:SetScript("OnMouseDown", function(self)
				func(v, k)
				addNewFilterOptions:ResetFrames({[lineID] = true})
			end)
		end
	end
	local function generateToggle(titleText, data, callback)
		local bg = addNewFilterOptions:GetFrame("bg", "togglePage")
		bg:SetWidth(totalWidth)
		local title = addNewFilterOptions:GetFrame("title", "togglePage")
		title:SetParent(bg)
		title:SetPoint("top", bg, "top", 0, 0)
		title.text:SetText(titleText)
		title:Show()
		local i = 1
		local height = 20
		local width = totalWidth/5
		for k,v in spairs(data) do
			local f = addNewFilterOptions:GetFrame("button", "togglePage")
			f:SetParent(bg)
			f:Show()
			f:SetSize(width-1, height)
			f:ClearAllPoints()
			addNewFilterOptions:ReColorFrame(v and "disabled" or "any", f)
			f:SetPoint("topleft", bg, "topleft", ((i-1) % 5)*width, -math.floor((i-1)/5)*(height+1)-3)
			f.text:SetText(tonumber(k) and Spell:CreateFromSpellID(k):GetSpellName() or k)
			f:SetScript("OnEnter", function()
				showTooltipOnCursor(k)
			end)
			f:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			f:SetScript("OnMouseDown", function()
				addNewFilterOptions:ReColorFrame(callback(k, f) and "disabled" or "any", f)
			end)
			i = i + 1
		end
		bg:SetHeight(math.ceil((i-1)/5)*(height+1))
		return bg
	end
	do
		local operators = {
			str = {
				contains = "contains",
				exact = "exactly",
			},
			number = {
				higher = ">=",
				lower = "<=",
				between = ">= & <="
			},
			id = {
				is = "=",
			},
			role = {
				DAMAGER = "dps",
				TANK = "tank",
				HEALER = "healer",
				NONE = "none",
			},
			class = { -- Make dynamic?
				"warrior", -- 1
				"paladin", -- 2
				"hunter", -- 3
				"rogue", -- 4
				"priest", -- 5
				"death knight", -- 6
				"shaman", -- 7
				"mage", -- 8
				"warlock", -- 9
				"monk", -- 10
				"druid", -- 11
				"demon hunter", -- 12
			},
			auraType = {
				BUFF = "buff",
				DEBUFF = "debuff",
			}
		}
		local operatorPreviews = {
			contains = "%s contains %s",
			exact = "%s is exactly %s",
			between = "%s is exactly or between %s and %s",
			higher = "%s >= %s",
			lower = "%s <= %s",
			is = "%s is %s",
			class = "%s: %s",
			role = "%s: %s",
			auraType = "%s: %s",
		}
		local keyTypes = {
			time = "number",
			hp = "number",
			stacks = "number",
			auraType = "auraType",
			spellID = "id",
			extraSpellID = "id",
			destRole = "role",
			sourceRole = "role",
			sourceClass = "class",
			destClass = "class",
			widgetType = "id",
			widgetID = "id",
			widgetSetID = "id",
			amount = "number",
			amountOver = "number",
			absorbed = "number",
			powerPercent = "number",
			bw_stage = "number",
		}
		local noEditbox = {
			auraType = true,
			role = true,
			class = true,
		}
		local function formatFilterPreviews(t)
			if t.operator == "between" then
				return sformat(operatorPreviews.between, t.key, t.val.from, t.val.to)
			end
			local _type = keyTypes[t.key] or "str"
			if noEditbox[_type] then
				if _type == "class" then
					return sformat(operatorPreviews[t.operator], t.key, GetClassInfo(t.val))
				else
					return sformat(operatorPreviews[t.operator], t.key, operators[_type][t.val])
				end
			else
				return sformat(operatorPreviews[t.operator], t.key, t.val)
			end
		end
		local function generateKeyValLine(lineID, updateFunc, alreadyUsedKeysFunc, keys, oldData)
			local bg = addNewFilterOptions:GetFrame("bg", lineID)
			bg:SetParent(UIParent)
			bg:SetFrameStrata('DIALOG')
			bg:SetFrameLevel(2)
			bg:SetSize(totalWidth, 18)
			bg:SetBackdropColor(0,0,0,0)
			bg:SetBackdropBorderColor(0,0,0,0)
			local currentlySelectedOperatorType = "str"
			local lineData = {
				key = "any",
				operator = "contains",
				val = "",
				isReady = false,
			}
			if oldData then
				lineData = {
					key = oldData.key,
					operator = oldData.operator,
					val = oldData.val,
					isReady = true,
				}
				currentlySelectedOperatorType = keys[oldData.key]
			else
				local t = alreadyUsedKeysFunc()
				if t.any then
					for k,v in spairs(keys) do
						if not t[k] then
							lineData.key = k
							if v == "id" then
								lineData.operator = "is"
							elseif v == "number" then
								lineData.operator = "between"
							else
								lineData.operator = "contains"
							end
							currentlySelectedOperatorType = v
						end
					end
				end
				updateFunc(lineID, lineData)
			end

			local chooseKey = addNewFilterOptions:GetFrame("button", lineID)
			chooseKey:SetParent(bg)
			chooseKey:Show()
			chooseKey:SetSize(100, 18)
			chooseKey:ClearAllPoints()
			chooseKey:SetBackdropColor(0,0,0,.25)
			chooseKey:SetBackdropBorderColor(1,0,0,.1)
			chooseKey:SetPoint("topleft", bg, "topleft", 3, 0)
			chooseKey.text:SetText(lineData.key)
			chooseKey:SetScript("OnEnter", function()
				showTooltipOnCursor("Choose key")
			end)
			chooseKey:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			local operator = addNewFilterOptions:GetFrame("button", lineID)
			operator:SetParent(bg)
			operator:Show()
			operator:SetSize(100, 18)
			operator:ClearAllPoints()
			operator:SetBackdropColor(0,0,0,.25)
			operator:SetBackdropBorderColor(1,0,0,.1)
			operator:SetPoint("left", chooseKey, "right", 5, 0)
			if oldData then
				if noEditbox[currentlySelectedOperatorType] then
					operator.text:SetText(operators[currentlySelectedOperatorType][lineData.val])
				else
					operator.text:SetText(operators[currentlySelectedOperatorType][lineData.operator])
				end
			else
				operator.text:SetText("choose")
			end
			operator:SetScript("OnEnter", function()
				showTooltipOnCursor("Choose operator")
			end)
			operator:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			local function reColorEditbox(valid, f)
				if valid then 
					f:SetBackdropColor(0,0,0,0)
				else
					f:SetBackdropColor(1,0,0,.5)
				end
			end
			local function createEditbox(anchorFrame, to)
				local editBoxID = lineID.."editBox"
				if to then
					editBoxID = editBoxID .. "2"
				end
				local editbox = addNewFilterOptions:GetFrame("editbox", editBoxID)
				editbox:SetParent(bg)
				editbox:Show()
				editbox:SetSize(100, 18)
				editbox:ClearAllPoints()
				editbox:SetBackdropColor(0,0,0,.25)
				editbox:SetBackdropBorderColor(1,0,0,.1)
				editbox:SetPoint("left", anchorFrame, "right", 5, 0)
				if lineData.operator == "between" then
					reColorEditbox(false, editbox)
					editbox.info:SetText(to and "to" or "from")
					editbox.info:Show()
				end
				editbox:SetScript('OnTextChanged', function(self)
					local text = self:GetText()
					if not text or text:len() == 0 then 
						self.info:Show()
					else
						self.info:Hide()
					end
					if currentlySelectedOperatorType == "id" or currentlySelectedOperatorType == "number" then
						text = tonumber(text)
						if text then
							if lineData.operator == "between" then
								if to then
									lineData.val.to = text
								else
									lineData.val.from = text
								end
							else
								lineData.val = text
							end
							reColorEditbox(true, self)
							lineData.isReady = true
						else
							lineData.isReady = false
							reColorEditbox(false, self)
						end
					else
						if text:len() <= 3 then
							reColorEditbox(false, self)
							lineData.isReady = false
						else
							lineData.val = text
							reColorEditbox(true, self)
							lineData.isReady = true
						end
					end
					updateFunc(lineID, lineData)
				end)
				editbox:SetScript('OnEnterPressed', function(self)
					self:ClearFocus()
				end)
				return editbox
			end
			if oldData and not noEditbox[currentlySelectedOperatorType] then
				local editbox = createEditbox(operator)
				if lineData.operator == "between" then
					editbox:SetText(lineData.val.from or "")
					reColorEditbox(true, editbox)
					editbox.info:Show()
					local editboxTo = createEditbox(editbox, true)
					editboxTo:SetText(lineData.val.to or "")
					editboxTo.info:Show()
					reColorEditbox(true, editboxTo)
				else
					editbox:SetText(lineData.val or "")
					editbox.info:Show()
					reColorEditbox(true, editbox)
				end
				editbox.info:Show()
			end
			operator:SetScript("OnMouseDown", function(self)
				generatePopup(self, operators[currentlySelectedOperatorType], function(val,_type)
					lineData.operator = _type
					operator.text:SetText(val)
					addNewFilterOptions:ResetFrames({[lineID.."editBox"] = true, [lineID.."editBox2"] = true})
					if noEditbox[currentlySelectedOperatorType] then
						lineData.operator = currentlySelectedOperatorType
						lineData.val = _type
						lineData.isReady = true
					else
						if lineData.operator == "between" then
							lineData.val = {from = 0,to = 0}
						else
							lineData.val = ""
						end
						--Generate editbox(s)
						local editbox = createEditbox(self)
						editbox:SetText('')
						if lineData.operator == "between" then
							lineData.val = {
								from = 0,
								to = 0,
							}
							local editbox2 = createEditbox(editbox, true)
							editbox2:SetText('')
						end
					end
					updateFunc(lineID, lineData)
				end, lineID)
			end)
			chooseKey:SetScript("OnMouseDown", function(self)
				local t = {}
				local alreadyUsed = alreadyUsedKeysFunc()
				for k,v in pairs(keys) do
					if not alreadyUsed[k] then
						t[k] = v
					end
				end
				generatePopup(self, t, function(_type, val)
					addNewFilterOptions:ResetFrames({[lineID.."editBox"] = true, [lineID.."editBox2"] = true})
					lineData.key = val
					currentlySelectedOperatorType = _type
					updateFunc(lineID, lineData)
					operator.text:SetText("choose")
					operator:Show()
					chooseKey.text:SetText(val)
				end, lineID, true)
			end)
			local deleteThis = addNewFilterOptions:GetFrame("button", lineID)
			deleteThis:SetParent(bg)
			deleteThis:Show()
			deleteThis:SetSize(18, 18)
			deleteThis:ClearAllPoints()
			deleteThis:SetBackdropColor(0,0,0,.25)
			deleteThis:SetBackdropBorderColor(1,0,0,.1)
			deleteThis:SetPoint("topright", bg, "topright", -3, 0)
			deleteThis.text:SetText("x")
			deleteThis:SetScript("OnEnter", function()
				showTooltipOnCursor("Delete this filter")
			end)
			deleteThis:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			deleteThis:SetScript("OnMouseDown", function(self)
				updateFunc(lineID, nil)
				addNewFilterOptions:ResetFrames({[lineID] = true, [lineID.."editBox"] = true, [lineID.."editBox2"] = true})
			end)
			return bg, keys
		end
		local function generateFilterPreview(id, data, refreshFunc, editFunc, frameID)
			local bg = addNewFilterOptions:GetFrame("bg", frameID)
			bg:SetBackdropColor(0,0,0,.25)
			bg:SetBackdropBorderColor(1,0,0,1)
			bg:SetWidth(totalWidth-6)
			local fs = addNewFilterOptions:GetFrame("fs", frameID)
			fs:ClearAllPoints()
			fs:SetParent(bg)
			fs:SetPoint("topleft", bg, "topleft", 3,-3)
			fs:SetWidth(totalWidth-6)
			fs:SetJustifyH("left")
			fs:SetJustifyV("top")
			local str = ""
			if not data.events then
				str = "Events: any"
			else
				local t = {}
				for k,v in spairs(data.events, function(t,a,b)
					return iEET.events.fromID[b].s > iEET.events.fromID[a].s end
				) do
					tinsert(t, iEET.events.fromID[k].s)
				end
				str = "Events: " .. tconcat(t, ", ")
			end
			if not data.filters then
				str = sformat("%s\n%s", str, "Only check eventIDs")
			else
				for k,v in ipairs(data.filters) do
					str = sformat("%s\n%s", str, formatFilterPreviews(v))
				end
			end
			if data.timestamps and data.timestamps.before then
				str = sformat("%s\nShow everything >%ss< before and >%ss< after.", str, data.timestamps.before, data.timestamps.after)
			end
			fs:SetText(str)
			fs:Show()
			bg:SetHeight(fs:GetHeight()+10)

			local delete = addNewFilterOptions:GetFrame("button", frameID)
			delete:SetParent(bg)
			delete:Show()
			delete:SetSize(50, 18)
			delete:SetFrameStrata('DIALOG')
			delete:SetFrameLevel(2)
			delete:ClearAllPoints()
			delete:SetPoint("topright", bg, "bottomright", 0, 1)
			delete:SetBackdropColor(0,0,0,.75)
			delete:SetBackdropBorderColor(1,0,0,1)
			delete:SetScript("OnEnter", function()
				showTooltipOnCursor("Delete this filter")
			end)
			delete:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			delete:SetScript("OnMouseDown", function()
				tremove(iEETConfig.filtering, id)
				refreshFunc()
			end)
			delete.text:SetText("del")
			
			local edit = addNewFilterOptions:GetFrame("button", frameID)
			edit:SetParent(bg)
			edit:Show()
			edit:SetSize(50, 18)
			edit:SetFrameStrata('DIALOG')
			edit:SetFrameLevel(2)
			edit:ClearAllPoints()
			edit:SetPoint("topleft", bg, "bottomleft", 0, 1)
			edit:SetBackdropColor(0,0,0,.75)
			edit:SetBackdropBorderColor(1,0,0,1)
			edit:SetScript("OnEnter", function()
				showTooltipOnCursor("Edit this filter")
			end)
			edit:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			edit:SetScript("OnMouseDown", function()
				editFunc(id)
			end)
			edit.text:SetText("edit")
						
			local duplicate = addNewFilterOptions:GetFrame("button", frameID)
			duplicate:SetParent(bg)
			duplicate:Show()
			duplicate:SetSize(75, 18)
			duplicate:SetFrameStrata('DIALOG')
			duplicate:SetFrameLevel(2)
			duplicate:ClearAllPoints()
			duplicate:SetPoint("left", edit, "right", 1, 0)
			duplicate:SetBackdropColor(0,0,0,.75)
			duplicate:SetBackdropBorderColor(1,0,0,1)
			duplicate:SetScript("OnEnter", function()
				showTooltipOnCursor("Duplicate this filter")
			end)
			duplicate:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			duplicate:SetScript("OnMouseDown", function()
				if not iEETConfig.filtering[id] then
					iEET:print("Error when duplicating filter, id not found.")
					return
				end
				local t = tcopy(iEETConfig.filtering[id])
				tinsert(iEETConfig.filtering, t)
				refreshFunc()
			end)
			duplicate.text:SetText("duplicate")
			return bg
		end
		local function getSpecialCatName(id)
			for k,v in pairs(iEET.specialCategories) do
				if v == id then return k end
			end
			return UNKNOWN
		end
		local pages = {
			event = function(configID)
				currentlySelectedEvents = nil
				currentlySelectedEvents = {}
				if configID then
					if not iEETConfig.filtering[configID] then iEET:print("Error: filtering id not found. Please report this.") 
					else
						if iEETConfig.filtering[configID].events then
							for k,v in pairs(iEETConfig.filtering[configID].events) do
								currentlySelectedEvents[k] = true
							end
						end
					end
				end
				local lastID
				local bg = addNewFilterOptions:GetFrame("bg", "eventMainPage")
				bg:SetParent(UIParent)
				bg:SetFrameStrata('DIALOG')
				bg:SetFrameLevel(2)
				bg:Show()
				for k,_ in spairs(sortedEvents) do
					local f = generateEvents(k, titleTexts[k] or k)
					f:ClearAllPoints()
					f:SetParent(bg)
					f:Show()
					if not lastID then
						f:SetPoint('top', bg, 'top', 0, 0)
					else
						f:SetPoint('top', addNewFilterOptions:getSpecificBG(lastID), 'bottom', 0, -15)
					end
					lastID = f.id
				end
				-- reset
				local resetButton = addNewFilterOptions:GetFrame("button", "eventMainPage")
				resetButton:SetParent(bg)
				resetButton:Show()
				resetButton:SetSize(75, 15)
				resetButton:ClearAllPoints()
				resetButton:SetBackdropColor(0,0,0,.25)
				resetButton:SetBackdropBorderColor(1,0,0,.25)
				resetButton:SetPoint("bottomleft", bg, "bottomleft", 3, 3)
				resetButton.text:SetText("reset")
				resetButton:SetScript("OnEnter", function()
					showTooltipOnCursor("reset selections")
				end)
				resetButton:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				resetButton:SetScript("OnMouseDown", function()
					currentlySelectedEvents = nil
					currentlySelectedEvents = {}
					addNewFilterOptions:ReColorFrame("any", nil, true, {t = "button", p = "eventPage"})
				end)
				local nextButton = addNewFilterOptions:GetFrame("button", "eventMainPage")
				nextButton:SetParent(bg)
				nextButton:Show()
				nextButton:SetSize(125, 20)
				nextButton:ClearAllPoints()
				nextButton:SetBackdropColor(0,0,0,.25)
				nextButton:SetBackdropBorderColor(0,1,0,1)
				nextButton:SetPoint("bottom", bg, "bottom", 0, 3)
				nextButton.text:SetText("next")
				nextButton:SetScript("OnEnter", function()
					showTooltipOnCursor("go to the next page")
				end)
				nextButton:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				nextButton:SetScript("OnMouseDown", function()
					addNewFilterOptions:ResetFrames({eventMainPage = true, eventPage = true})
					addNewFilterOptions:GetPage("keyVal", configID)
				end)
				local filterUsingEvents = addNewFilterOptions:GetFrame("button", "eventMainPage")
				filterUsingEvents:SetParent(bg)
				filterUsingEvents:Show()
				filterUsingEvents:SetSize(100, 17)
				filterUsingEvents:ClearAllPoints()
				filterUsingEvents:SetBackdropColor(0,0,0,.25)
				filterUsingEvents:SetBackdropBorderColor(0,1,0,.25)
				filterUsingEvents:SetPoint("bottomright", bg, "bottomright", -78, 3)
				filterUsingEvents.text:SetText("Use events only")
				filterUsingEvents:SetScript("OnEnter", function()
					showTooltipOnCursor("Create filter using only event IDs")
				end)
				filterUsingEvents:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				filterUsingEvents:SetScript("OnMouseDown", function()
					addNewFilterOptions:ResetFrames({eventMainPage = true, eventPage = true})
					local t = tcopy(currentlySelectedEvents)
					if configID and iEETConfig.filtering[configID] then
						iEETConfig.filtering[configID] = {events = t}
					else
						tinsert(iEETConfig.filtering, {events = t})
					end
					addNewFilterOptions:GetPage()
				end)
				local cancel = addNewFilterOptions:GetFrame("button", "eventMainPage")
				cancel:SetParent(bg)
				cancel:Show()
				cancel:SetSize(75, 15)
				cancel:ClearAllPoints()
				cancel:SetBackdropColor(0,0,0,.25)
				cancel:SetBackdropBorderColor(1,0,0,.25)
				cancel:SetPoint("bottomright", bg, "bottomright", -3, 3)
				cancel.text:SetText("cancel")
				cancel:SetScript("OnEnter", function()
					showTooltipOnCursor("cancel creating filter")
				end)
				cancel:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				cancel:SetScript("OnMouseDown", function()
					addNewFilterOptions:ResetFrames({eventMainPage = true, eventPage = true})
					if #iEETConfig.filtering > 0 then
						addNewFilterOptions:GetPage()
					else
						addNewFilterOptions:Close()
					end
				end)
				return bg
			end,
			keyVal = function(configID)
				local pageID = "keyValMainPage"
				local bg = addNewFilterOptions:GetFrame("bg", pageID)
				bg:SetParent(UIParent)
				bg:SetFrameStrata('DIALOG')
				bg:SetFrameLevel(2)
				bg:Show()
				bg.subUsedBys = {}
				local keys
				--generate all possible common keys from selected events
				if currentlySelectedEvents and count(currentlySelectedEvents) > 0 then
					for eventID in pairs(currentlySelectedEvents) do
						if not keys then
							keys = {}
							for key in pairs(iEET.eventFunctions[eventID].data) do
								if key ~= "event" and key ~= "time" then
									keys[key] = keyTypes[key] or "str"
								end
							end
						else
							for k in pairs(keys) do
								if not iEET.eventFunctions[eventID].data[k] then
									keys[k] = nil
								end
							end
						end
					end
				else
					keys = {}
					for key in pairs(iEET.allPossibleKeys) do
						if key ~= "event" and key ~= "time" then
							keys[key] = keyTypes[key] or "str"
						end
					end
				end
				keys.any = "str"
				keys.time = "number"
				local lines = {}
				local filterData = {}
				local linesCreated = 0
				local latestLine
				local keyCount = count(keys)
				local usedKeyCount = 0
				local timestamps = {before = false, after = false}
				local addNewFilter = addNewFilterOptions:GetFrame("button", pageID)
				local nextButton = addNewFilterOptions:GetFrame("button", pageID)
				local fromTo = addNewFilterOptions:GetFrame("checkbox", pageID)
				local function checkOK()
					for k,v in pairs(filterData) do
						if not v.isReady then
							nextButton:Hide()
							return
						end
					end
					if fromTo:GetChecked() then
						if not (timestamps.before and timestamps.after) then
							nextButton:Hide()
							return
						end
					end
					nextButton:Show()
				end
				local function getAlreadyUsedKeys()
					local t = {}
					local i = 0
					for k,v in pairs(filterData) do
						i = i + 1
						t[v.key] = true
					end
					usedKeyCount = i
					return t
				end
				local isEmpty = true
				if configID then
					if iEETConfig.filtering[configID].filters then
						isEmpty = false
						for k,v in pairs(iEETConfig.filtering[configID].filters) do
							if keys[v.key] then
								filterData[pageID..k] = tcopy(v)
							else
								iEET:print(sformat("%s is no longer valid key, removing it.", k))
							end
						end
					end
					if iEETConfig.filtering[configID].timestamps then
						timestamps = iEETConfig.filtering[configID].timestamps
					end
					getAlreadyUsedKeys()
				end
				local function updateFunc(lineID, t)
					if t then
						filterData[lineID] = t
						getAlreadyUsedKeys()
						if keyCount == usedKeyCount then
							addNewFilter:Hide()
						end
					else
						bg.subUsedBys[lineID] = nil
						filterData[lineID] = nil
						lines[lineID] = nil
						getAlreadyUsedKeys()
						if not addNewFilter:IsShown() then
							addNewFilter:Show()
						end
						local lastLine
						for _, f in spairs(lines, function(t,a,b) return t[b].lineID > t[a].lineID end) do
							f:ClearAllPoints()
							if not lastLine then
								f:SetPoint("topleft", bg, "topleft", 0, 0)
							else
								f:SetPoint("topleft", lastLine, "bottomleft", 0, -3)
							end
							lastLine = f
						end
						latestLine = lastLine
						if latestLine then
							addNewFilter:ClearAllPoints()
							addNewFilter:SetPoint("top", latestLine, "bottom", 0, -30)
						else
							addNewFilter:SetPoint("top", bg, "top", 0, -30)
						end
					end
					checkOK()
				end
				do
					if configID and not isEmpty then
						for k,v in spairs(filterData) do
							linesCreated = linesCreated + 1
							local lineID = pageID .. linesCreated
							local line = generateKeyValLine(lineID, updateFunc, getAlreadyUsedKeys, keys, v)
							bg.subUsedBys[lineID] = true
							bg.subUsedBys[lineID.."editBox"] = true
							bg.subUsedBys[lineID.."editBox2"] = true
							line:ClearAllPoints()
							line:SetParent(bg)
							line:SetFrameStrata('DIALOG')
							line:SetFrameLevel(2)
							line:Show()
							if not latestLine then
								line:SetPoint("topleft", bg, "topleft", 0, 0)
							else
								line:SetPoint("topleft", latestLine, "bottomleft", 0, -3)
							end
							line.lineID = linesCreated
							lines[lineID] = line
							latestLine = lines[lineID]
						end
					else
						linesCreated = 1
						local line = generateKeyValLine(pageID.."1", updateFunc, getAlreadyUsedKeys, keys)
						bg.subUsedBys[pageID.."1"] = true
						bg.subUsedBys[pageID .."1editBox"] = true
						bg.subUsedBys[pageID .. "1editBox2"] = true
						line:ClearAllPoints()
						line:SetParent(bg)
						line:SetFrameStrata('DIALOG')
						line:SetFrameLevel(2)
						line:Show()
						line:SetPoint("topleft", bg, "topleft", 0, 0)
						line.lineID = 1
						lines[pageID.."1"] = line
						latestLine = lines[pageID.."1"]
					end
				end

				local fromToBG = addNewFilterOptions:GetFrame("bg", pageID)
				fromToBG:ClearAllPoints()
				fromToBG:SetParent(bg)
				fromToBG:Show()
				fromToBG:SetPoint("top", latestLine, "bottom", 0, -80)
				fromToBG:SetSize(totalWidth-6, 1)

				fromTo:ClearAllPoints()
				fromTo:SetParent(bg)
				fromTo:Show()
				fromTo.text:SetText("Use as from/to filter")
				fromTo:SetSize(10,10)
				fromTo:SetPoint("topleft", fromToBG, "topleft", 180, 0)
				fromTo:SetBackdropBorderColor(0,0,0,1)
				fromTo:SetBackdropColor(0,0,0,.25)
				fromTo:SetScript("OnClick", function(self)
					local editBoxID = pageID.."editBox"
					if self:GetChecked() then
						if not timestamps.before then
							timestamps = {before = 1.5, after = 1.5}
						end
						do -- BEFORE
							local editboxBefore = addNewFilterOptions:GetFrame("editbox", editBoxID)
							editboxBefore:SetParent(bg)
							editboxBefore:Show()
							editboxBefore:SetSize(40, 14)
							editboxBefore:ClearAllPoints()
							editboxBefore:SetBackdropColor(0,0,0,.25)
							editboxBefore:SetBackdropBorderColor(1,0,0,.1)
							editboxBefore:SetPoint("top", fromToBG, "bottom", 0, -20)
							editboxBefore:SetBackdropColor(0,0,0,0)
							editboxBefore:SetScript('OnTextChanged', function(self)
								local text = self:GetText()
								text = tonumber(text)
								if not text then
									self:SetBackdropColor(1,0,0,.5)
									timestamps.before = false
								else
									self:SetBackdropColor(0,0,0,0)
									timestamps.before = text
								end
								checkOK()
							end)
							editboxBefore:SetScript('OnEnterPressed', function(self)
								self:ClearFocus()
							end)
							editboxBefore:SetText(timestamps.before)
							local beforeFSPart1 = addNewFilterOptions:GetFrame("fs", editBoxID)
							beforeFSPart1:ClearAllPoints()
							beforeFSPart1:SetParent(bg)
							beforeFSPart1:SetPoint("bottomright", editboxBefore, "bottomleft", -3,0)
							beforeFSPart1:SetWidth(totalWidth/3)
							beforeFSPart1:SetJustifyH("right")
							beforeFSPart1:SetJustifyV("bottom")
							beforeFSPart1:SetText("Show all events")
							beforeFSPart1:Show()
							local beforeFSPart2 = addNewFilterOptions:GetFrame("fs", editBoxID)
							beforeFSPart2:ClearAllPoints()
							beforeFSPart2:SetParent(bg)
							beforeFSPart2:SetPoint("bottomleft", editboxBefore, "bottomright", 3,0)
							beforeFSPart2:SetWidth(totalWidth/3)
							beforeFSPart2:SetJustifyH("left")
							beforeFSPart2:SetJustifyV("bottom")
							beforeFSPart2:SetText("seconds BEFORE this event.")
							beforeFSPart2:Show()
						end
						do -- AFTER
							local editboxAfter = addNewFilterOptions:GetFrame("editbox", editBoxID)
							editboxAfter:SetParent(bg)
							editboxAfter:Show()
							editboxAfter:SetSize(40, 14)
							editboxAfter:ClearAllPoints()
							editboxAfter:SetBackdropColor(0,0,0,.25)
							editboxAfter:SetBackdropBorderColor(1,0,0,.1)
							editboxAfter:SetPoint("top", fromToBG, "bottom", 0, -40)
							editboxAfter:SetBackdropColor(0,0,0,0)
							editboxAfter:SetScript('OnTextChanged', function(self)
								local text = self:GetText()
								text = tonumber(text)
								if not text then
									timestamps.after = false
									self:SetBackdropColor(1,0,0,.5)
								else
									timestamps.after = text
									self:SetBackdropColor(0,0,0,0)
								end
								checkOK()
							end)
							editboxAfter:SetScript('OnEnterPressed', function(self)
								self:ClearFocus()
							end)
							editboxAfter:SetText(timestamps.after)
							local beforeFSPart1 = addNewFilterOptions:GetFrame("fs", editBoxID)
							beforeFSPart1:ClearAllPoints()
							beforeFSPart1:SetParent(bg)
							beforeFSPart1:SetPoint("bottomright", editboxAfter, "bottomleft", -3,0)
							beforeFSPart1:SetWidth(totalWidth/3)
							beforeFSPart1:SetJustifyH("right")
							beforeFSPart1:SetJustifyV("bottom")
							beforeFSPart1:SetText("Show all events")
							beforeFSPart1:Show()
							local beforeFSPart2 = addNewFilterOptions:GetFrame("fs", editBoxID)
							beforeFSPart2:ClearAllPoints()
							beforeFSPart2:SetParent(bg)
							beforeFSPart2:SetPoint("bottomleft", editboxAfter, "bottomright", 3,0)
							beforeFSPart2:SetWidth(totalWidth/3)
							beforeFSPart2:SetJustifyH("left")
							beforeFSPart2:SetJustifyV("bottom")
							beforeFSPart2:SetText("seconds AFTER this event.")
							beforeFSPart2:Show()
							checkOK()
						end
					else
						timestamps = {before = false, after = false}
						checkOK()
						addNewFilterOptions:ResetFrames({[editBoxID] = true})
					end
				end)
				if timestamps.before then
					fromTo:Click()
				end
				addNewFilter:SetParent(bg)
				addNewFilter:Show()
				addNewFilter:SetSize(125, 20)
				addNewFilter:ClearAllPoints()
				addNewFilter:SetPoint("top", latestLine, "bottom", 0, -30)
				addNewFilter:SetBackdropColor(0,0,0,.25)
				addNewFilter:SetBackdropBorderColor(1,0,0,1)
				addNewFilter.text:SetText("Add new")
				addNewFilter:SetScript("OnEnter", function()
					showTooltipOnCursor("Add new")
				end)
				addNewFilter:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				addNewFilter:SetScript("OnMouseDown", function(self)
					linesCreated = linesCreated + 1
					local lineID = pageID..linesCreated
					local line = generateKeyValLine(lineID, updateFunc, getAlreadyUsedKeys, keys)
					bg.subUsedBys[lineID] = true
					bg.subUsedBys[lineID .."editBox"] = true
					bg.subUsedBys[lineID .."editBox2"] = true
					line:ClearAllPoints()
					line:SetParent(bg)
					line:SetFrameStrata('DIALOG')
					line:SetFrameLevel(2)
					line.lineID = linesCreated
					line:Show()
					if not latestLine then
						line:SetPoint("topleft", bg, "topleft", 0, 0)
					else
						line:SetPoint("topleft", latestLine, "bottomleft", 0, -3)
					end
					lines[lineID] = line
					latestLine = lines[lineID]
					self:ClearAllPoints()
					self:SetPoint("top", latestLine, "bottom", 0, -30)
					fromToBG:SetPoint("topleft", latestLine, "bottomleft", 0, -80)
				end)

				nextButton:SetParent(bg)
				nextButton:Hide()
				nextButton:SetSize(125, 20)
				nextButton:ClearAllPoints()
				nextButton:SetBackdropColor(0,0,0,.25)
				nextButton:SetBackdropBorderColor(0,1,0,1)
				nextButton:SetPoint("bottom", bg, "bottom", 0, 3)
				nextButton.text:SetText("Add filter")
				nextButton:SetScript("OnEnter", function()
					showTooltipOnCursor("Add this filter")
				end)
				nextButton:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				nextButton:SetScript("OnMouseDown", function()
					local t = {[pageID] = true, keyValPage = true, [pageID.."editBox"] = true}
					for k in pairs(bg.subUsedBys) do
						t[k] = true
					end
					local filters = {}
					for k,v in pairs(filterData) do
						if k ~= "isReady" then
							tinsert(filters, tcopy(v))
						end
					end
					addNewFilterOptions:ResetFrames(t)
					if configID and iEETConfig.filtering[configID] then -- should be useless nil check
						iEETConfig.filtering[configID] = {events = count(currentlySelectedEvents) > 0 and tcopy(currentlySelectedEvents) or false, filters = filters, timestamps = timestamps.before and timestamps or {}}
					else
						tinsert(iEETConfig.filtering, {events = count(currentlySelectedEvents) > 0 and tcopy(currentlySelectedEvents) or false, filters = filters, timestamps = timestamps.before and timestamps or {}})
					end
					addNewFilterOptions:GetPage("filterOverview")
				end)
				local cancel = addNewFilterOptions:GetFrame("button", "keyValMainPage")
				cancel:SetParent(bg)
				cancel:Show()
				cancel:SetSize(75, 15)
				cancel:ClearAllPoints()
				cancel:SetBackdropColor(0,0,0,.25)
				cancel:SetBackdropBorderColor(1,0,0,.25)
				cancel:SetPoint("bottomright", bg, "bottomright", -3, 3)
				cancel.text:SetText("cancel")
				cancel:SetScript("OnEnter", function()
					showTooltipOnCursor("cancel creating filter")
				end)
				cancel:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				cancel:SetScript("OnMouseDown", function()
					local t = {keyValMainPage = true, keyValPage = true, [pageID.."editBox"] = true}
					for k in pairs(bg.subUsedBys) do
						t[k] = true
					end
					addNewFilterOptions:ResetFrames(t)
					addNewFilterOptions:GetPage("event")
				end)
				return bg
			end,
			filterOverview = function()
				local pageID = "filterOverview"
				local bg = addNewFilterOptions:GetFrame("bg", pageID)
				bg:ClearAllPoints()
				bg:SetParent(UIParent)
				bg:SetFrameStrata('DIALOG')
				bg:SetFrameLevel(2)
				bg:Show()
				local sf = addNewFilterOptions:GetFrame("scrollframe", pageID)
				sf:ClearAllPoints()
				sf:SetParent(bg)
				sf:SetFrameStrata('DIALOG')
				sf:SetFrameLevel(3)
				sf:SetPoint("topleft", bg, "topleft", 0, 0)
				sf:SetPoint("bottomright", bg, "bottomright", 0, 30)
				sf:Show()
				--sf.content:Show()
				local function editFunc(id)
					addNewFilterOptions:ResetFrames({[pageID] = true})
					addNewFilterOptions:GetPage("event", id)
				end
				local function refreshPage()
					addNewFilterOptions:ResetFrames({[pageID] = true})
					addNewFilterOptions:GetPage("filterOverview")
				end
				local contentHeight = 0
				local lastFrame
				for k,v in pairs(iEETConfig.filtering) do
					local filterPreview = generateFilterPreview(k, v, refreshPage, editFunc, pageID)
					filterPreview:ClearAllPoints()
					filterPreview:SetParent(sf.content)
					filterPreview:SetFrameStrata('DIALOG')
					filterPreview:SetFrameLevel(2)
					filterPreview:Show()
					if not lastFrame then
						filterPreview:SetPoint("topleft", sf.content, "topleft", 0, 0)
						contentHeight = contentHeight + filterPreview:GetHeight()
					else
						filterPreview:SetPoint("top", lastFrame, "bottom", 0, -30)
						contentHeight = contentHeight + filterPreview:GetHeight()+30
					end
					lastFrame = filterPreview
				end
				C_Timer.After(0, function() sf.resizeContent(contentHeight + 15) end)

				local bgLine = addNewFilterOptions:GetFrame("title", pageID)
				bgLine:ClearAllPoints()
				bgLine:SetParent(UIParent)
				bgLine:SetFrameStrata('DIALOG')
				bgLine:SetFrameLevel(3)
				bgLine:SetPoint("bottom", bg, "bottom", 0, 30)

				local createNew = addNewFilterOptions:GetFrame("button", pageID)
				createNew:SetParent(bg)
				createNew:Show()
				createNew:SetSize(125, 20)
				createNew:ClearAllPoints()
				createNew:SetPoint("bottom", bg, "bottom", 0, 3)
				createNew:SetBackdropColor(0,0,0,.25)
				createNew:SetBackdropBorderColor(0,1,0,1)
				createNew.text:SetText("Create new")
				createNew:SetScript("OnEnter", function()
					showTooltipOnCursor("Create new filter")
				end)
				createNew:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				createNew:SetScript("OnMouseDown", function(self)
					addNewFilterOptions:ResetFrames({[pageID] = true})
					addNewFilterOptions:GetPage("event")
				end)

				local apply = addNewFilterOptions:GetFrame("button", pageID)
				apply:SetParent(bg)
				apply:Show()
				apply:SetSize(75, 18)
				apply:ClearAllPoints()
				apply:SetPoint("bottomleft", bg, "bottomleft", 3, 3)
				apply:SetBackdropColor(0,0,0,.25)
				apply:SetBackdropBorderColor(0,1,0,1)
				apply.text:SetText("Apply")
				apply:SetScript("OnEnter", function()
					showTooltipOnCursor("Use filters on current encounter")
				end)
				apply:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				apply:SetScript("OnMouseDown", function(self)
					iEET:loopData(nil, true)
				end)

				local close = addNewFilterOptions:GetFrame("button", pageID)
				close:SetParent(bg)
				close:Show()
				close:SetSize(75, 18)
				close:ClearAllPoints()
				close:SetPoint("bottomleft", apply, "bottomright", 3, 0)
				close:SetBackdropColor(0,0,0,.25)
				close:SetBackdropBorderColor(0,1,0,1)
				close.text:SetText("Close")
				close:SetScript("OnEnter", function()
					showTooltipOnCursor("Use filters on current encounter")
				end)
				close:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				close:SetScript("OnMouseDown", function(self)
					addNewFilterOptions:Close()
					iEET:loopData(nil, true)
				end)

				local deleteAllFilters = addNewFilterOptions:GetFrame("button", pageID)
				deleteAllFilters:SetParent(bg)
				deleteAllFilters:Show()
				deleteAllFilters:SetSize(100, 18)
				deleteAllFilters:ClearAllPoints()
				deleteAllFilters:SetPoint("bottomright", bg, "bottomright", -3, 3)
				deleteAllFilters:SetBackdropColor(1,0,0,.25)
				deleteAllFilters:SetBackdropBorderColor(1,0,0,1)
				deleteAllFilters.text:SetText("Delete all")
				deleteAllFilters:SetScript("OnEnter", function()
					showTooltipOnCursor("Delete all filters")
				end)
				deleteAllFilters:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				deleteAllFilters:SetScript("OnMouseDown", function(self)
					local dialog = StaticPopup_Show("IEET_ARE_YOU_SURE", "Are you sure you want to delete all filters?")
					if dialog then
						dialog.data = function()
							iEETConfig.filtering = {}
							refreshPage()
						end
					else
						iEET:print("Error: Dialog not found (delete all filters)!")
					end
				end)
				local importFilters = addNewFilterOptions:GetFrame("button", pageID)
				importFilters:SetParent(bg)
				importFilters:Show()
				importFilters:SetSize(12, 12)
				importFilters:SetBackdropColor(0,0,0,.25)
				importFilters:SetBackdropBorderColor(1,0,0,1)
				importFilters.text:SetText("▼")
				importFilters:SetScript("OnEnter", function()
					showTooltipOnCursor("Import all filters")
				end)
				importFilters:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				importFilters:SetScript("OnMouseDown", function(self)
					local editbox = addNewFilterOptions:GetFrame("editbox", pageID)
					editbox:SetParent(bg)
					editbox:Show()
					editbox:SetSize(300, 18)
					editbox:ClearAllPoints()
					editbox:SetBackdropColor(0,0,0,.75)
					editbox:SetBackdropBorderColor(1,0,0,.5)
					editbox:SetPoint("bottom", bg, "top", 0, 28)
					editbox:SetScript('OnTextChanged', function(self)
					end)
					editbox:SetScript('OnEnterPressed', function(self)
						local ls, e = loadstring("return "..self:GetText() or "")
						local data = ""
						if ls then
							data = ls()
						end
						if e then
							iEET:print(e)
						else
							if type(data) == "table" then
								for k,v in pairs(data) do
									if type(v) == "table" then
										table.insert(iEETConfig.filtering, v)
									else
										iEET:print("Error importing, data is not a valid table.")		
									end
								end
							else
								iEET:print("Error importing, data is not a valid table.")
							end
						end
						self:Hide()
						refreshPage()
					end)
					editbox:SetText("")
				end)
				local exportFilters = addNewFilterOptions:GetFrame("button", pageID)
				exportFilters:SetParent(bg)
				exportFilters:Show()
				exportFilters:SetSize(12, 12)
				--exportFilters:ClearAllPoints()
				--exportFilters:SetPoint("bottomright", bg, "bottomright", -3, 3)
				exportFilters:SetBackdropColor(0,0,0,.25)
				exportFilters:SetBackdropBorderColor(1,0,0,1)
				exportFilters.text:SetText("▲")
				exportFilters:SetScript("OnEnter", function()
					showTooltipOnCursor("Export all filters")
				end)
				exportFilters:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				exportFilters:SetScript("OnMouseDown", function(self)
					local editbox = addNewFilterOptions:GetFrame("editbox", pageID)
					editbox:SetParent(bg)
					editbox:Show()
					editbox:SetSize(300, 18)
					editbox:ClearAllPoints()
					editbox:SetBackdropColor(0,0,0,.75)
					editbox:SetBackdropBorderColor(1,0,0,.5)
					editbox:SetPoint("bottom", bg, "top", 0, 28)
					editbox:SetScript('OnTextChanged', function(self)
					end)
					editbox:SetScript('OnEnterPressed', function(self)
						self:Hide()
					end)
					editbox:SetText(tableUtils.tostring(iEETConfig.filtering))
					editbox:HighlightText()
					editbox:SetFocus()
				end)
				return bg, {importFilters, exportFilters}
			end,
			filterEvents = function()
				currentlySelectedEvents = nil
				currentlySelectedEvents = {}
				for k,v in pairs(iEETConfig.tracking) do
					currentlySelectedEvents[k] = v
				end
				local lastID
				local bg = addNewFilterOptions:GetFrame("bg", "eventMainPage")
				bg:SetParent(UIParent)
				bg:SetFrameStrata('DIALOG')
				bg:SetFrameLevel(2)
				bg:Show()
				for k,_ in spairs(sortedEvents) do
					local f = generateEvents(k, titleTexts[k] or k)
					f:ClearAllPoints()
					f:SetParent(bg)
					f:Show()
					if not lastID then
						f:SetPoint('top', bg, 'top', 0, 0)
					else
						f:SetPoint('top', addNewFilterOptions:getSpecificBG(lastID), 'bottom', 0, -15)
					end
					lastID = f.id
				end
				-- reset
				local resetButton = addNewFilterOptions:GetFrame("button", "eventMainPage")
				resetButton:SetParent(bg)
				resetButton:Show()
				resetButton:SetSize(75, 15)
				resetButton:ClearAllPoints()
				resetButton:SetBackdropColor(0,0,0,.25)
				resetButton:SetBackdropBorderColor(1,0,0,.25)
				resetButton:SetPoint("bottomleft", bg, "bottomleft", 3, 3)
				resetButton.text:SetText("enable all")
				resetButton:SetScript("OnEnter", function()
					showTooltipOnCursor("enable all")
				end)
				resetButton:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				resetButton:SetScript("OnMouseDown", function()
					currentlySelectedEvents = nil
					currentlySelectedEvents = {}
					for k,v in pairs(iEETConfig.tracking) do
						currentlySelectedEvents[k] = true
					end
					addNewFilterOptions:ReColorFrame("enabled", nil, true, {t = "button", p = "eventPage"})
				end)
				local saveButton = addNewFilterOptions:GetFrame("button", "eventMainPage")
				saveButton:SetParent(bg)
				saveButton:Show()
				saveButton:SetSize(125, 20)
				saveButton:ClearAllPoints()
				saveButton:SetBackdropColor(0,0,0,.25)
				saveButton:SetBackdropBorderColor(0,1,0,1)
				saveButton:SetPoint("bottom", bg, "bottom", 0, 3)
				saveButton.text:SetText("Save")
				saveButton:SetScript("OnEnter", function()
					showTooltipOnCursor("Save selections")
				end)
				saveButton:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				saveButton:SetScript("OnMouseDown", function()
					addNewFilterOptions:ResetFrames({eventMainPage = true, eventPage = true})
					for k,v in pairs(iEETConfig.tracking) do
						iEETConfig.tracking[k] = currentlySelectedEvents[k] or false
					end
					addNewFilterOptions:Close()
					iEET:loopData()
					local hasDisabledEvents = false
					for k,v in pairs(iEETConfig.tracking) do
						if not v then 
							hasDisabledEvents = true
							iEET.eventlist:SetBackdropBorderColor(1,0,0,1)
							break
						end
					end
					if not hasDisabledEvents then
						iEET.eventlist:SetBackdropBorderColor(iEETConfig.colors.main.border.r,iEETConfig.colors.main.border.g,iEETConfig.colors.main.border.b,iEETConfig.colors.main.border.a)
					end
				end)
				local disableAll = addNewFilterOptions:GetFrame("button", "eventMainPage")
				disableAll:SetParent(bg)
				disableAll:Show()
				disableAll:SetSize(75, 15)
				disableAll:ClearAllPoints()
				disableAll:SetBackdropColor(0,0,0,.25)
				disableAll:SetBackdropBorderColor(1,0,0,.25)
				disableAll:SetPoint("bottomright", bg, "bottomright", -3, 3)
				disableAll.text:SetText("disable all")
				disableAll:SetScript("OnEnter", function()
					showTooltipOnCursor("disable all")
				end)
				disableAll:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				disableAll:SetScript("OnMouseDown", function()
					currentlySelectedEvents = nil
					currentlySelectedEvents = {}
					addNewFilterOptions:ReColorFrame("disabled", nil, true, {t = "button", p = "eventPage"})
				end)
				return bg
			end,
			npcs = function()
				local pageID = "npcs"
				local temp = {
					npcNames = {},
					unitIDs = {},
				}
				if not iEET.collector then return end
				for k,v in pairs(iEET.collector.npcNames) do
					temp.npcNames[k] = iEET.ignoring.npcNames[k] or false
				end

				for k,v in pairs(iEET.collector.unitIDs) do
					temp.unitIDs[k] = iEET.ignoring.unitIDs[k] or false
				end
				local bg = addNewFilterOptions:GetFrame("bg", pageID)
				bg:ClearAllPoints()
				bg:SetParent(UIParent)
				bg:SetFrameStrata('DIALOG')
				bg:SetFrameLevel(2)
				bg:Show()
				local sf = addNewFilterOptions:GetFrame("scrollframe", pageID)
				sf:ClearAllPoints()
				sf:SetParent(bg)
				sf:SetFrameStrata('DIALOG')
				sf:SetFrameLevel(3)
				sf:SetPoint("topleft", bg, "topleft", 0, 0)
				sf:SetPoint("bottomright", bg, "bottomright", 0, 30)
				sf:Show()
				local contentHeight = 0
				-- NPCs
				local function npcCallback(k, f)
					if temp.npcNames[k] then
						temp.npcNames[k] = false
						return false
					else
						temp.npcNames[k] = true
						return true
					end
				end
				local NPCPart = generateToggle("Filter by name", temp.npcNames, npcCallback)
				NPCPart:ClearAllPoints()
				NPCPart:SetParent(sf.content)
				NPCPart:SetPoint("top", sf, "top", 0, -30)
				NPCPart:SetFrameStrata('DIALOG')
				NPCPart:SetFrameLevel(2)
				NPCPart:Show()
				contentHeight = NPCPart:GetHeight()
				
				-- UnitIDs
				local function unitIDCallback(k, f)
					if temp.unitIDs[k] then
						temp.unitIDs[k] = false
						return false
					else
						temp.unitIDs[k] = true
						return true
					end
				end
				local UnitIDPart = generateToggle("Filter by unitID", temp.unitIDs, unitIDCallback)
				UnitIDPart:ClearAllPoints()
				UnitIDPart:SetParent(sf.content)
				UnitIDPart:SetFrameStrata('DIALOG')
				UnitIDPart:SetFrameLevel(2)
				UnitIDPart:Show()
				UnitIDPart:SetPoint("top", NPCPart, "bottom", 0, -30)
				contentHeight = contentHeight + UnitIDPart:GetHeight()+30

				C_Timer.After(0, function() sf.resizeContent(contentHeight + 15) end) -- Resize after next frame for accurate values

				-- reset
				local resetButton = addNewFilterOptions:GetFrame("button", pageID)
				resetButton:SetParent(bg)
				resetButton:Show()
				resetButton:SetSize(75, 15)
				resetButton:ClearAllPoints()
				resetButton:SetBackdropColor(0,0,0,.25)
				resetButton:SetBackdropBorderColor(1,0,0,.25)
				resetButton:SetPoint("bottomleft", bg, "bottomleft", 3, 3)
				resetButton.text:SetText("reset")
				resetButton:SetScript("OnEnter", function()
					showTooltipOnCursor("reset")
				end)
				resetButton:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				resetButton:SetScript("OnMouseDown", function()
					temp = nil
					temp = {
						npcNames = {},
						unitIDs = {},
					}
					for k,v in pairs(iEET.collector.npcNames) do
						temp.npcNames[k] = false
					end
	
					for k,v in pairs(iEET.collector.unitIDs) do
						temp.unitIDs[k] = false
					end
					addNewFilterOptions:ReColorFrame("any", nil, true, {t = "button", p = "togglePage"})
				end)
				local saveButton = addNewFilterOptions:GetFrame("button", pageID)
				saveButton:SetParent(bg)
				saveButton:Show()
				saveButton:SetSize(125, 20)
				saveButton:ClearAllPoints()
				saveButton:SetBackdropColor(0,0,0,.25)
				saveButton:SetBackdropBorderColor(0,1,0,1)
				saveButton:SetPoint("bottom", bg, "bottom", 0, 3)
				saveButton.text:SetText("Save")
				saveButton:SetScript("OnEnter", function()
					showTooltipOnCursor("Save selections")
				end)
				saveButton:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				saveButton:SetScript("OnMouseDown", function()
					for cat,d in pairs(temp) do
						for k,v in pairs(d) do
							if not v and iEET.ignoring[cat][k] then
								iEET.ignoring[cat][k] = nil
							elseif v then
								iEET.ignoring[cat][k] = true
							end
						end
					end
					addNewFilterOptions:Close()
					iEET:loopData(nil, true)
				end)
				return bg
			end,
			spells = function()
				local pageID = "spells"
				local temp = {
					spellIDs = {},
					specialCategories = {},
				}
				if not iEET.collector then return end
				for k,v in pairs(iEET.collector.spellIDs) do
					temp.spellIDs[k] = iEET.ignoring.spellIDs[k] or false
				end

				for k,v in pairs(iEET.collector.specialCategories) do
					temp.specialCategories[getSpecialCatName(k)] = iEET.ignoring.specialCategories[k] or false
				end
				
				local bg = addNewFilterOptions:GetFrame("bg", pageID)
				bg:ClearAllPoints()
				bg:SetParent(UIParent)
				bg:SetFrameStrata('DIALOG')
				bg:SetFrameLevel(2)
				bg:Show()
				local sf = addNewFilterOptions:GetFrame("scrollframe", pageID)
				sf:ClearAllPoints()
				sf:SetParent(bg)
				sf:SetFrameStrata('DIALOG')
				sf:SetFrameLevel(3)
				sf:SetPoint("topleft", bg, "topleft", 0, 0)
				sf:SetPoint("bottomright", bg, "bottomright", 0, 30)
				sf:Show()
				local contentHeight = 0

				-- spell IDs
				local function spellCallback(k, f)
					if temp.spellIDs[k] then
						temp.spellIDs[k] = false
						return false
					else
						temp.spellIDs[k] = true
						return true
					end
				end
				local spellPart = generateToggle("Filter by spellID", temp.spellIDs, spellCallback, pageID)
				spellPart:ClearAllPoints()
				spellPart:SetParent(sf.content)
				spellPart:SetFrameStrata('DIALOG')
				spellPart:SetFrameLevel(2)
				spellPart:Show()
				spellPart:SetPoint("top", sf, "top", 0, -30)
				contentHeight = spellPart:GetHeight()

				-- Common/SpecialCat
				local function specialCategoriesCallback(k, f)
					if temp.specialCategories[k] then
						temp.specialCategories[k] = false
						return false
					else
						temp.specialCategories[k] = true
						return true
					end
				end
				local commonSpells = generateToggle("Common spells", temp.specialCategories, specialCategoriesCallback)
				commonSpells:ClearAllPoints()
				commonSpells:SetParent(sf.content)
				commonSpells:SetPoint("top", spellPart, "bottom", 0, -30)
				commonSpells:SetFrameStrata('DIALOG')
				commonSpells:SetFrameLevel(2)
				commonSpells:Show()
				
				contentHeight = contentHeight + commonSpells:GetHeight()+30

				C_Timer.After(0, function() sf.resizeContent(contentHeight + 15) end) -- Resize after next frame for accurate values

				-- reset
				local resetButton = addNewFilterOptions:GetFrame("button", pageID)
				resetButton:SetParent(bg)
				resetButton:Show()
				resetButton:SetSize(75, 15)
				resetButton:ClearAllPoints()
				resetButton:SetBackdropColor(0,0,0,.25)
				resetButton:SetBackdropBorderColor(1,0,0,.25)
				resetButton:SetPoint("bottomleft", bg, "bottomleft", 3, 3)
				resetButton.text:SetText("reset")
				resetButton:SetScript("OnEnter", function()
					showTooltipOnCursor("reset")
				end)
				resetButton:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				resetButton:SetScript("OnMouseDown", function()
					temp = nil
					temp = {
						spellIDs = {},
						specialCategories = {},
					}
					for k,v in pairs(iEET.collector.spellIDs) do
						temp.spellIDs[k] = false
					end
	
					for k,v in pairs(iEET.collector.specialCategories) do
						temp.specialCategories[getSpecialCatName(k)] = false
					end
					addNewFilterOptions:ReColorFrame("any", nil, true, {t = "button", p = "togglePage"})
				end)
				local saveButton = addNewFilterOptions:GetFrame("button", pageID)
				saveButton:SetParent(bg)
				saveButton:Show()
				saveButton:SetSize(125, 20)
				saveButton:ClearAllPoints()
				saveButton:SetBackdropColor(0,0,0,.25)
				saveButton:SetBackdropBorderColor(0,1,0,1)
				saveButton:SetPoint("bottom", bg, "bottom", 0, 3)
				saveButton.text:SetText("Save")
				saveButton:SetScript("OnEnter", function()
					showTooltipOnCursor("Save selections")
				end)
				saveButton:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				saveButton:SetScript("OnMouseDown", function()
					for spellID,v in pairs(temp.spellIDs) do
						if not v and iEET.ignoring.spellIDs[spellID] then
							iEET.ignoring.spellIDs[spellID] = nil
						elseif v then
							iEET.ignoring.spellIDs[spellID] = true
						end
					end
					for catName,v in pairs(temp.specialCategories) do
						local catID = iEET.specialCategories[catName]
						if not v and iEET.ignoring.specialCategories[catID] then
							iEET.ignoring.specialCategories[catID] = nil
						elseif v then
							iEET.ignoring.specialCategories[catID] = true
						end
					end
					addNewFilterOptions:Close()
					iEET:loopData(nil, true)
				end)
				return bg
			end,
		}
		function addNewFilterOptions:GetPage(page, id, data)
			if not page then -- called when opening up filters
				--if #iEETConfig.filtering > 0 then
					page = "filterOverview"
				--else
					--page = "event"
				--end
			end
			if page == "event" then
				local f = pages.event(id)
				f:ClearAllPoints()
				f:SetParent(addNewFilterOptions.mainFrame)
				f:SetSize(totalWidth,totalHeight-15)
				f:SetPoint("top", addNewFilterOptions.mainFrame, "top", 0, -15)
				addNewFilterOptions.titleInfo:SetText('Select events')
				return f
			elseif page == "keyVal" then
				local f = pages.keyVal(id)
				f:ClearAllPoints()
				f:SetParent(addNewFilterOptions.mainFrame)
				f:SetSize(totalWidth,totalHeight-15)
				f:SetPoint("top", addNewFilterOptions.mainFrame, "top", 0, -15)
				addNewFilterOptions.titleInfo:SetText('Choose search values')
				return f
			elseif page == "filterOverview" then
				local f, titleButtons = pages.filterOverview()
				f:ClearAllPoints()
				f:SetParent(addNewFilterOptions.mainFrame)
				f:SetSize(totalWidth,totalHeight-3)
				f:SetPoint("top", addNewFilterOptions.mainFrame, "top", 0, -3)
				if titleButtons then
					for i,v in ipairs(titleButtons) do
						if i == 1 then
							v:ClearAllPoints()
							v:SetPoint("right", addNewFilterOptions.title, "right", -3,0)
						else
							v:ClearAllPoints()
							v:SetPoint("right", titleButtons[i-1], "left", -2,0)
						end
					end
				end
				addNewFilterOptions.titleInfo:SetText('Filtering overview')
				return f
			elseif page == "filterEvents" then
				local f = pages.filterEvents()
				f:ClearAllPoints()
				f:SetParent(addNewFilterOptions.mainFrame)
				f:SetSize(totalWidth,totalHeight-15)
				f:SetPoint("top", addNewFilterOptions.mainFrame, "top", 0, -15)
				addNewFilterOptions.titleInfo:SetText('Shown events')
				return f
			elseif page == "npcs" then
				local f = pages.npcs(data)
				f:ClearAllPoints()
				f:SetParent(addNewFilterOptions.mainFrame)
				f:SetSize(totalWidth,totalHeight-15)
				f:SetPoint("top", addNewFilterOptions.mainFrame, "top", 0, -15)
				addNewFilterOptions.titleInfo:SetText('NPC filtering')
				return f
			elseif page == "spells" then
				local f = pages.spells(data)
				f:ClearAllPoints()
				f:SetParent(addNewFilterOptions.mainFrame)
				f:SetSize(totalWidth,totalHeight-15)
				f:SetPoint("top", addNewFilterOptions.mainFrame, "top", 0, -15)
				addNewFilterOptions.titleInfo:SetText('Spell filtering')
				return f
			end
		end
	end
end
function addNewFilterOptions:Close()
	addNewFilterOptions:ResetFrames()
	if addNewFilterOptions.mainFrame then
		addNewFilterOptions.mainFrame:Hide()
	end
end
function addNewFilterOptions:Reset() -- TODO , reset for adding new filters

end
function addNewFilterOptions:Open(empty, keepOpen)
	if addNewFilterOptions.mainFrame and addNewFilterOptions.mainFrame:IsShown() then -- just a protection for incorrect func calls, clean up at some point
		if not keepOpen then
			addNewFilterOptions:Close()
			return 
		end
	end
	if not addNewFilterOptions.mainFrame then
		addNewFilterOptions.mainFrame = CreateFrame('Frame', nil, UIParent, "BackdropTemplate")
		addNewFilterOptions.mainFrame:SetSize(totalWidth + 6,totalHeight + 6)
		addNewFilterOptions.mainFrame:SetFrameStrata('DIALOG')
		addNewFilterOptions.mainFrame:SetPoint('CENTER', UIParent, 'CENTER', iEETConfig.spawnOffset,0)
		if iEETConfig.scales.filters then
			addNewFilterOptions.mainFrame:SetScale(iEETConfig.scales.filters)
		end
		addNewFilterOptions.mainFrame:SetBackdrop(iEET.backdrop);
		addNewFilterOptions.mainFrame:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		addNewFilterOptions.mainFrame:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		addNewFilterOptions.mainFrame:Show()
		addNewFilterOptions.mainFrame:EnableMouse(true)
		addNewFilterOptions.mainFrame:SetMovable(true)

		addNewFilterOptions.title = CreateFrame('FRAME', nil, addNewFilterOptions.mainFrame, "BackdropTemplate")
		addNewFilterOptions.title:SetSize(totalWidth + 6,20)
		addNewFilterOptions.title:SetPoint('BOTTOM', addNewFilterOptions.mainFrame, 'TOP', 0, 1)
		addNewFilterOptions.title:SetBackdrop(iEET.backdrop);
		addNewFilterOptions.title:SetBackdropColor(iEETConfig.colors.options.bg.r,iEETConfig.colors.options.bg.g,iEETConfig.colors.options.bg.b,iEETConfig.colors.options.bg.a)
		addNewFilterOptions.title:SetBackdropBorderColor(iEETConfig.colors.options.border.r,iEETConfig.colors.options.border.g,iEETConfig.colors.options.border.b,iEETConfig.colors.options.border.a)
		addNewFilterOptions.title:SetScript('OnMouseDown', function(self,button)
			addNewFilterOptions.mainFrame:StartMoving()
		end)
		addNewFilterOptions.title:SetScript('OnMouseUp', function(self, button)
			addNewFilterOptions.mainFrame:StopMovingOrSizing()
		end)
		addNewFilterOptions.title:EnableMouse(true)
		addNewFilterOptions.title:Show()
		addNewFilterOptions.title:SetFrameStrata('DIALOG')
		addNewFilterOptions.title:SetFrameLevel(1)
		
		addNewFilterOptions.titleInfo = addNewFilterOptions.mainFrame:CreateFontString()
		addNewFilterOptions.titleInfo:SetFont(iEET.font, iEET.fontsize, 'OUTLINE')
		addNewFilterOptions.titleInfo:SetPoint('CENTER', addNewFilterOptions.title, 'CENTER', 0,0)
		addNewFilterOptions.titleInfo:Show()
		
	else
		addNewFilterOptions:Reset()
		addNewFilterOptions.mainFrame:Show()
	end
	if not empty then
		addNewFilterOptions:GetPage()
	end
end

function iEET:Options()
	addNewFilterOptions:Open()
end

function iEET:GetPageFromFilters(pageid, id, data)
	if not iEET.encounterInfoData then
		if pageid ~= "filterEvents" then return end
	else
		local oldFormat = tonumber(iEET.encounterInfoData.v)
		if oldFormat and oldFormat < 2 then return end
	end
	--local _major,_minor,_patch = iEET.encounterInfoData.v:match("^(%d-)%.(%d-)%.(%d-)$")
	addNewFilterOptions:ResetFrames()
	addNewFilterOptions:Open(true, true)
	addNewFilterOptions:GetPage(pageid, id, data)
end