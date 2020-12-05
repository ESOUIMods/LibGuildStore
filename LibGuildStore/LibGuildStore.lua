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
      internal:addPurchase(CurrentPurchase)
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
      --internal:addPurchase(CurrentPurchase)
      --ShoppingList.List:Refresh()
    end)
    
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.ITEM_POSTED, function(guildId, itemLink, price, stackCount)
      local saveData = GS17DataSavedVariables["postedItems"]
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
      local saveData = GS17DataSavedVariables["cancelledItems"]
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
  EVENT_MANAGER:RegisterForEvent(ShoppingList.Name, EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE, function(...) internal:onTradingHouseEvent(...) end)

end

local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    internal.dm("Debug", "LibGuildStore Loaded")
    Initilizze()
  end
end

EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)