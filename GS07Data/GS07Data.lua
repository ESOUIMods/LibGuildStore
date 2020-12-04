local libName, libVersion = "GS07Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS07DataSavedVariables then GS07DataSavedVariables = {} end
  lib['data'] = GS07DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS07Data = lib