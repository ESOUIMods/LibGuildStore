local libName, libVersion = "GS17Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS17DataSavedVariables then GS17DataSavedVariables = { ['data'] = {} } end
  lib['data'] = GS17DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS17Data = lib