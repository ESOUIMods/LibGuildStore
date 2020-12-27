local lib = _G["LibGuildStore"]
local internal = _G["LibGuildStore_Internal"]

function internal:v(level, message)
  local verboseLevel = internal.verboseLevel or 4
  -- DEBUG
  if (level <= verboseLevel) then
    if message then
      if CHAT_ROUTER then
        CHAT_ROUTER:AddSystemMessage(message)
      elseif RequestDebugPrintText then
        RequestDebugPrintText(message)
      else
        d(message)
      end
    end
  end
end

-- /script d(internal.internal[622389]:GetPendingEventMetrics())
function internal:CheckStatus()
  internal.dm("Debug", "CheckStatus")
  for i = 1, GetNumGuilds() do
    local guildID                               = GetGuildId(i)
    local numEvents                             = GetNumGuildEvents(guildID, GUILD_HISTORY_STORE)
    local eventCount, processingSpeed, timeLeft = internal.LibHistoireListener[guildID]:GetPendingEventMetrics()
    if timeLeft > -1 or (eventCount == 1 and numEvents == 0) then internal.timeEstimated[guildID] = true end
    if (timeLeft == -1 and eventCount == 1 and numEvents == 0) and internal.timeEstimated[guildID] then internal.eventsNeedProcessing[guildID] = false end
    if eventCount == 0 and internal.timeEstimated[guildID] then internal.eventsNeedProcessing[guildID] = false end
    --if eventCount > 1 then
      internal:v(1, string.format("Events remaining: %s for %s and %s : %s", eventCount, GetGuildName(guildID), processingSpeed, timeLeft))
    --end
  end
  for i = 1, GetNumGuilds() do
    local guildID = GetGuildId(i)
    if internal.eventsNeedProcessing[guildID] then return true end
  end
  return false
end

function internal:QueueCheckStatus()
  internal.dm("Debug", "QueueCheckStatus")
  local eventsRemaining = internal:CheckStatus()
  if eventsRemaining then
    zo_callLater(function() internal:QueueCheckStatus()
    end, 500) -- 2 minutes
  else
    --[[
    MasterMerchant.CenterScreenAnnounce_AddMessage(
      'LibHistoireAlert',
      CSA_EVENT_SMALL_TEXT,
      LibGuildStore.systemSavedVariables.alertSoundName,
      "LibHistoire Ready"
    )
    ]]--
    internal.dm("Debug", "Thinks QueueCheckStatus is done")
    internal:v(2, "LibHistoire Ready")
    LibGuildStore.guildStoreReady = true
  end
end

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
  internal:QueueCheckStatus()

  if AwesomeGuildStore then
    -- register for purchace
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.ITEM_PURCHASED, function(itemData)
      local CurrentPurchase = {}
      CurrentPurchase.ItemLink = itemData.itemLink
      CurrentPurchase.Quantity = itemData.stackCount
      CurrentPurchase.Price = itemData.purchasePrice
      CurrentPurchase.Seller = itemData.sellerName
      CurrentPurchase.Guild = itemData.guildName
      CurrentPurchase.itemUniqueId = Id64ToString(itemData.itemUniqueId)
      CurrentPurchase.TimeStamp = GetTimeStamp()
      internal:addListing(CurrentPurchase)
      --ShoppingList.List:Refresh()
    end)

    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.ITEM_DATABASE_UPDATE, function(itemDatabase, guildId, hasAnyResultAlreadyStored)
      internal.guildStoreSearchResults = itemDatabase
      local allData = itemDatabase.data
      internal:processAwesomeGuildStore(allData)
      --[[
      local CurrentPurchase = {}
      CurrentPurchase.ItemLink = itemData.itemLink
      CurrentPurchase.Quantity = itemData.stackCount
      CurrentPurchase.Price = itemData.purchasePrice
      CurrentPurchase.Seller = itemData.sellerName
      CurrentPurchase.Guild = itemData.guildName
      CurrentPurchase.itemUniqueId = Id64ToString(itemData.itemUniqueId)
      CurrentPurchase.TimeStamp = GetTimeStamp()
      internal.dm("Debug", CurrentPurchase)
      ]]--
      --internal:addListing(CurrentPurchase)
      --ShoppingList.List:Refresh()
    end)
    
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.ITEM_POSTED, function(guildId, itemLink, price, stackCount)
      local saveData = GS16DataSavedVariables["postedItems"]
      table.insert(saveData, {
        ItemLink = itemLink,
        Quantity = stackCount,
        Price = price,
        Guild = GetGuildName(guildId),
        TimeStamp = GetTimeStamp()
      })
      --gettext("You have cancelled your listing of <<1>>x <<t:2>> for <<3>> in <<4>>", stackCount, itemLink, price, guildName)
      --internal.dm("Debug", guildId)
      --internal.dm("Debug", itemLink)
      --internal.dm("Debug", price)
      --internal.dm("Debug", stackCount)
    end)
    
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.ITEM_CANCELLED, function(guildId, itemLink, price, stackCount)
      local saveData = GS16DataSavedVariables["cancelledItems"]
      table.insert(saveData, {
        ItemLink = itemLink,
        Quantity = stackCount,
        Price = price,
        Guild = GetGuildName(guildId),
        TimeStamp = GetTimeStamp()
      })
      --gettext("You have cancelled your listing of <<1>>x <<t:2>> for <<3>> in <<4>>", stackCount, itemLink, price, guildName)
      --internal.dm("Debug", guildId)
      --internal.dm("Debug", itemLink)
      --internal.dm("Debug", price)
      --internal.dm("Debug", stackCount)
    end)
  end
  --[[
  AGS.callback.BEFORE_INITIAL_SETUP = "BeforeInitialSetup"
  AGS.callback.AFTER_INITIAL_SETUP = "AfterInitialSetup"
  AGS.callback.AFTER_FILTER_SETUP = "AfterFilterSetup"

  AGS.callback.STORE_TAB_CHANGED = "StoreTabChanged"
  AGS.callback.GUILD_SELECTION_CHANGED = "SelectedGuildChanged"
  AGS.callback.AVAILABLE_GUILDS_CHANGED = "AvailableGuildsChanged"
  AGS.callback.SELECTED_SEARCH_CHANGED = "SelectedSearchChanged"
  AGS.callback.SEARCH_LIST_CHANGED = "SearchChangedChanged"
  AGS.callback.SEARCH_LOCK_STATE_CHANGED = "SearchLockStateChanged"
  AGS.callback.ITEM_DATABASE_UPDATE = "ItemDatabaseUpdated"
  AGS.callback.CURRENT_ACTIVITY_CHANGED = "CurrentActivityChanged"
  AGS.callback.SEARCH_RESULT_UPDATE = "SearchResultUpdate"
  AGS.callback.SEARCH_RESULTS_RECEIVED = "SearchResultsReceived"

  -- fires when a filter value has changed
  -- filterId, ... (filter values)
  AGS.callback.FILTER_VALUE_CHANGED = "FilterValueChanged"
  -- fires when a filter is attached or detached
  -- filter
  AGS.callback.FILTER_ACTIVE_CHANGED = "FilterActiveChanged"
  -- fires on the next frame after any filter has changed. In other words after all FILTER_VALUE_CHANGED and FILTER_ACTIVE_CHANGED callbacks have fired
  -- activeFilters
  AGS.callback.FILTER_UPDATE = "FilterUpdate"
  AGS.callback.FILTER_PREPARED = "FilterPrepared"

  AGS.callback.ITEM_PURCHASED = "ItemPurchased"
  AGS.callback.ITEM_PURCHASE_FAILED = "ItemPurchaseFailed"
  AGS.callback.ITEM_CANCELLED = "ItemCancelled"
  AGS.callback.ITEM_POSTED = "ItemPosted"  ]]--

  -- for vanilla without AwesomeGuildStore
  EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE, function(...) internal:onTradingHouseEvent(...) end)

end

local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    internal.dm("Debug", "LibGuildStore Loaded")
    Initilizze()
  end
end

EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)