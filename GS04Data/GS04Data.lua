local libName, libVersion = "GS04Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS04DataSavedVariables then GS04DataSavedVariables = {} end
  lib['data'] = GS04DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS04Data = lib