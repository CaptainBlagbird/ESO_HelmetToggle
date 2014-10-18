--[[

Helmet Toggle
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Namespace for the addon (top-level table) that will hold everything
HelmetToggle = {}
-- Name string
HelmetToggle.name = "HelmetToggle"

-- Event handler function, called when the UI was moved
function HelmetToggle.OnUIMoveStop()
	HelmetToggle.savedVariables.left = HelmetToggleUI:GetLeft()
	HelmetToggle.savedVariables.top = HelmetToggleUI:GetTop()
end

-- Event handler function, called when the button was clicked
function HelmetToggle.OnButtonClicked()
	-- Get setting of the hide/show helmet option
	local before = GetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM )
	-- Toggle the hide/show helmet option
	if before == "1" then
		SetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, "0", 1 )
	else
		SetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, "1", 1 )
	end
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
 
-- Initialisations
function HelmetToggle:Init()
	-- Set up SavedVariables object
	self.savedVariables = ZO_SavedVars:New("HelmetToggleSavedVariables", 1, nil, {})
	
	-- Restore button position
	self:RestoreButtonPosition()
end
 
-- Registering the event handler functions for the events
EVENT_MANAGER:RegisterForEvent(HelmetToggle.name, EVENT_ADD_ON_LOADED, HelmetToggle.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(HelmetToggle.name, EVENT_RETICLE_HIDDEN_UPDATE, HelmetToggle.OnReticleHidden)