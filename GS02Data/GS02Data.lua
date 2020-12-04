local libName, libVersion = "GS02Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS02DataSavedVariables then GS02DataSavedVariables = {} end
  lib['data'] = GS02DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS02Data = lib