local libName, libVersion = "GS16Data", 100
local lib = {}
lib.libName = libName
lib.defaults = {
  ["ItemLink"] = {},
  ["AccountNames"] = {},
  ["GuildNames"] = {},
}

local function Initialize()
  if not GS16DataSavedVariables then
    GS16DataSavedVariables = lib.defaults
  end
  lib['data'] = GS16DataSavedVariables
end

local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GS16Data = lib