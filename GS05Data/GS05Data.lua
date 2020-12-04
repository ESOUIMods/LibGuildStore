local libName, libVersion = "GS05Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS05DataSavedVariables then GS05DataSavedVariables = {} end
  lib['data'] = GS05DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS05Data = lib