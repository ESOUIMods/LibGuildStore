local libName, libVersion = "GS01Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS01DataSavedVariables then GS01DataSavedVariables = {} end
  lib['data'] = GS01DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS01Data = lib