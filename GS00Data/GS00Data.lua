local libName, libVersion = "GS00Data", 100
local lib = {}
lib.libName = libName

local function Initialize()
  if not GS00DataSavedVariables then GS00DataSavedVariables = { ['data'] = {} } end
  lib['data'] = GS00DataSavedVariables
end

local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS00Data = lib
