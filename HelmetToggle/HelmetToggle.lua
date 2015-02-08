--[[

Helmet Toggle
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Namespace for the addon (top-level table) that will hold everything
HelmetToggle = {}
-- Name string
HelmetToggle.name = "HelmetToggle"

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

-- Event handler function, called when the UI was moved
function HelmetToggle.OnUIMoveStop()
	HelmetToggle.savedVariables.left = HelmetToggleUI:GetLeft()
	HelmetToggle.savedVariables.top = HelmetToggleUI:GetTop()
end

-- Event handler function, called when the button was clicked
function HelmetToggle.OnButtonClicked()
	HelmetToggle.ToggleHelmet()
end

-- Function to restore the position of the Button
function HelmetToggle:RestoreButtonPosition()
	local left = self.savedVariables.left
	local top = self.savedVariables.top

	HelmetToggleUI:ClearAnchors()
	HelmetToggleUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end
 
-- Event handler function for EVENT_ADD_ON_LOADED
function HelmetToggle.OnAddOnLoaded(event, addonName)
	-- Only continue if the loaded addon is this addon
	if addonName ~= HelmetToggle.name then return end

	-- Initialise addon
	HelmetToggle:Init()
end

-- Event handler function for EVENT_RETICLE_HIDDEN_UPDATE
function HelmetToggle.OnReticleHidden(eventCode, hidden)
	if (hidden) and not ZO_Compass:IsHidden() then
		HelmetToggleUI:SetHidden(false)
	else
		HelmetToggleUI:SetHidden(true)
	end
end

-- Event handler function, called when the UI was updated
function HelmetToggle.OnUIUpdate()
	if ZO_Compass:IsHidden() or not ZO_Loot:IsHidden() then
		HelmetToggleUI:SetHidden(true)
	end
end

-- Event handler function, called when the combat state changed
function HelmetToggle.OnCombatStateChange(event, inCombat)
	HelmetToggle.ToggleHelmet(inCombat)
end

-- Function for slash command
function HelmetToggle.ChatCommand(argument)
	-- Trim whitespaces from input string
	argument = argument:gsub("^%s*(.-)%s*$", "%1")
	-- Convert string to lower case
	argument = argument:lower()
	-- No argument toggles current mode
	if argument == "" then
		if HelmetToggle.savedVariables.auto == nil then
			HelmetToggle.savedVariables.auto = true
		else
			HelmetToggle.savedVariables.auto = not HelmetToggle.savedVariables.auto
		end
	else
		local boolArg = tobool(argument)
		if boolArg == nil or argument == "?" then
			-- Display error message
			d("|c70C0DE[HelmetToggle]|r Invalid argument, valid options: |cC5C29E" .. tobool("?") .. " and no argument|r")
			return
		else
			HelmetToggle.savedVariables.auto = boolArg
		end
	end
	-- Start of output string
	local str = "|c70C0DE[HelmetToggle]|r Auto mode "
	if HelmetToggle.savedVariables.auto then
		-- Register function for event
		EVENT_MANAGER:RegisterForEvent(HelmetToggle.name, EVENT_PLAYER_COMBAT_STATE, HelmetToggle.OnCombatStateChange)
		str = str .. "|c00FF00enabled|r"
	else
		-- Unregister function for event
		EVENT_MANAGER:UnregisterForEvent(HelmetToggle.name, EVENT_PLAYER_COMBAT_STATE)
		str = str .. "|cFF0000disabled|r"
	end
	-- Finally display output string with changed mode
	d(str)
end

-- Event handler function, called when the button was clicked
function HelmetToggle.ToggleHelmet(arg)
	-- Check if argument specified
	if arg ~= nil then
		-- Use argument as new setting
		SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, tostring(not arg), 1)
	else
		-- No argument specified, toggle current setting
		local old = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM)
		SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, tostring(not tobool(old)), 1)
	end
end
 
-- Initialisations
function HelmetToggle:Init()
	-- Set up SavedVariables object
	self.savedVariables = ZO_SavedVars:New("HelmetToggleSavedVariables", 1, nil, {})
	
	-- Register slash command and link function
	SLASH_COMMANDS["/helmettoggle"] = HelmetToggle.ChatCommand
	
	-- Make sure the event is registered if auto mode is on
	if HelmetToggle.savedVariables.auto then
		EVENT_MANAGER:RegisterForEvent(HelmetToggle.name, EVENT_PLAYER_COMBAT_STATE, HelmetToggle.OnCombatStateChange)
	end
	
	-- Restore button position
	self:RestoreButtonPosition()
end
 
-- Registering the event handler functions for the events
EVENT_MANAGER:RegisterForEvent(HelmetToggle.name, EVENT_ADD_ON_LOADED, HelmetToggle.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(HelmetToggle.name, EVENT_RETICLE_HIDDEN_UPDATE, HelmetToggle.OnReticleHidden)