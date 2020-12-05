local libName, libVersion = "GS06Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS06DataSavedVariables then GS06DataSavedVariables = { ['data'] = {} } end
  lib['data'] = GS06DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS06Data = lib