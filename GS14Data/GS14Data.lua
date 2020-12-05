local libName, libVersion = "GS14Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS14DataSavedVariables then GS14DataSavedVariables = { ['data'] = {} } end
  lib['data'] = GS14DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS14Data = lib