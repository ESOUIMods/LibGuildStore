local libName, libVersion = "GS08Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS08DataSavedVariables then GS08DataSavedVariables = { ['data'] = {} } end
  lib['data'] = GS08DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS08Data = lib