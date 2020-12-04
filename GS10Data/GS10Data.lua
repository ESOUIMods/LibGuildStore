local libName, libVersion = "GS10Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS10DataSavedVariables then GS10DataSavedVariables = {} end
  lib['data'] = GS10DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS10Data = lib