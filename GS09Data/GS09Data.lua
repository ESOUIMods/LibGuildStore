local libName, libVersion = "GS09Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS09DataSavedVariables then GS09DataSavedVariables = {} end
  lib['data'] = GS09DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS09Data = lib