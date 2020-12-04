local libName, libVersion = "GS11Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS11DataSavedVariables then GS11DataSavedVariables = {} end
  lib['data'] = GS11DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS11Data = lib