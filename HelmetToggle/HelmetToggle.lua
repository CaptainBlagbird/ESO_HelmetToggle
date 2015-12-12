--[[

Helmet Toggle
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
local AddonName = "HelmetToggle"
local UIName = AddonName.."UI"

-- Local variables
local savedVariables = {}
local tlw
local label
local button


-- Convert string to boolean by using a list of keywords
local function tobool(str)
	local list = {}
	list["true"]  = true
	list["on"]    = true
	list["1"]     = true
	list["false"] = false
	list["off"]   = false
	list["0"]     = false
	
	-- If input is "?", then return a list of all possible options
	if str == "?" then
		local strKeys = ""
		for k,v in pairs(list) do
			if strKeys == "" then
				strKeys = k
			else
				strKeys = strKeys .. " / " .. k
			end
		end
		return strKeys
	end
	
	-- Return the value for that key
	return list[str]
end

-- Change helmet setting
local function ToggleHelmet(arg)
	-- Check if argument specified
	if type(arg) == "boolean" then
		-- Use argument as new setting
		SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, tostring(not arg), 1)
	else
		-- No argument specified, toggle current setting
		local old = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM)
		SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, tostring(not tobool(old)), 1)
	end
end

-- UI position restore
local function RestoreUIPosition()
	HelmetToggleUI:ClearAnchors()
	HelmetToggleUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVariables.left, savedVariables.top)
end

-- Event handler function for EVENT_RETICLE_HIDDEN_UPDATE
local function OnReticleHidden(eventCode, isHidden)
	if isHidden and not ZO_Compass:IsHidden() then
		HelmetToggleUI:SetHidden(false)
	else
		HelmetToggleUI:SetHidden(true)
	end
end

-- Event handler function for EVENT_PLAYER_COMBAT_STATE
local function OnCombatStateChange(eventCode, inCombat)
	ToggleHelmet(inCombat)
end

-- Slash command function
local function SlashCommand(argument)
	-- Trim whitespaces from input string
	argument = argument:gsub("^%s*(.-)%s*$", "%1")
	-- Convert string to lower case
	argument = argument:lower()
	-- No argument toggles current mode
	if argument == "" then
		if savedVariables.auto == nil then
			savedVariables.auto = true
		else
			savedVariables.auto = not savedVariables.auto
		end
	else
		local boolArg = tobool(argument)
		if boolArg == nil or argument == "?" then
			-- Display error message
			d("|c70C0DE[HelmetToggle]|r Invalid argument, valid options: |cC5C29E" .. tobool("?") .. " and no argument|r")
			return
		else
			savedVariables.auto = boolArg
		end
	end
	-- Start of output string
	local str = "|c70C0DE[HelmetToggle]|r Auto mode "
	-- (Un)Register event
	if savedVariables.auto then
		ToggleHelmet(false)
		EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChange)
		str = str .. "|c00FF00enabled|r"
	else
		EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_PLAYER_COMBAT_STATE)
		str = str .. "|cFF0000disabled|r"
	end
	-- Finally display output string with changed mode
	d(str)
end

-- UI initialisation
local function InitUI()
	-- Top level window
	tlw = WINDOW_MANAGER:CreateTopLevelWindow(UIName)
	tlw:SetMouseEnabled(true)
	tlw:SetMovable(true)
	tlw:SetDimensions(170, 24)
	tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	tlw:SetHandler("OnMoveStop", function()
			savedVariables.left = tlw:GetLeft()
			savedVariables.top = tlw:GetTop()
		end)
	tlw:SetHandler("OnUpdate", function()
			if ZO_Compass:IsHidden() or not ZO_Loot:IsHidden() then
				tlw:SetHidden(true)
			end
		end)
	-- Label
	label = WINDOW_MANAGER:CreateControl(UIName.."_Label", tlw, CT_LABEL)
	label:SetFont("ZoFontGameLargeBoldShadow")
	label:SetColor(0.77, 0.76, 0.62) --> #C5C29E --> ESO gold
	label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	label:SetVerticalAlignment(CENTER)
	label:SetText("Helmet:")
	label:SetAnchor(LEFT, tlw, LEFT, 15, 0)
	-- Button
	button = WINDOW_MANAGER:CreateControlFromVirtual(UIName.."_Button", tlw, "ZO_DefaultButton")
	button:SetText("Toggle")
	button:SetDimensions(100, 24)
	button:SetAnchor(RIGHT, tlw, RIGHT, 0, 0)
	button:SetHandler("OnClicked", function()
			ToggleHelmet()
			if savedVariables.auto then
				SlashCommand("false")
			end
		end)
end

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(event, addonName)
	-- Set up SavedVariables object
	savedVariables = ZO_SavedVars:New("HelmetToggleSavedVariables", 1, nil, {})
	
	-- Register slash command and link function
	SLASH_COMMANDS["/helmettoggle"] = SlashCommand
	
	-- Make sure the event is registered if auto mode is on
	if savedVariables.auto then
		EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChange)
	end
	
	-- Create UI and restore button position
	InitUI()
	RestoreUIPosition()
	
	-- Register events that use the UI
	EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_RETICLE_HIDDEN_UPDATE, OnReticleHidden)
	
	EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)