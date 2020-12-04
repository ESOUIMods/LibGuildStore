local libName, libVersion = "GS13Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS13DataSavedVariables then GS13DataSavedVariables = {} end
  lib['data'] = GS13DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS13Data = lib