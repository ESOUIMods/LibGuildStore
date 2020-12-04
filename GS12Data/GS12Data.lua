local libName, libVersion = "GS12Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS12DataSavedVariables then GS12DataSavedVariables = {} end
  lib['data'] = GS12DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS12Data = lib