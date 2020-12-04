local libName, libVersion = "GS15Data", 100
local lib = {}
lib.libName = libName
 
local function Initialize()
  if not GS15DataSavedVariables then GS15DataSavedVariables = {} end
  lib['data'] = GS15DataSavedVariables
end
 
local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS15Data = lib