local lib = _G["LibGuildStore"]
local internal = _G["LibGuildStore_Internal"]

local function Initilizze()
  for i = 1, GetNumGuilds() do
    local guildID = GetGuildId(i)
    local guildName = GetGuildName(guildID)
    if not LibGuildStore_SavedVariables["lastReceivedEventID"][guildID] then LibGuildStore_SavedVariables["lastReceivedEventID"][guildID] = "0" end
    internal.alertQueue[guildName] = {}
    for m = 1, GetNumGuildMembers(guildID) do
      local guildMemInfo, _, _, _, _ = GetGuildMemberInfo(guildID, m)
      if internal.guildMemberInfo[guildID] == nil then internal.guildMemberInfo[guildID] = {} end
      internal.guildMemberInfo[guildID][string.lower(guildMemInfo)] = true
    end
    internal:SetupListener(guildID)
  end
end

local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    internal.dm("Debug", "LibGuildStore Loaded")
    Initilizze()
  end
end

EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)