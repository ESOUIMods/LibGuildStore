local lib           = _G["LibGuildStore"]
local internal      = _G["LibGuildStore_Internal"]
local sales_data    = _G["LibGuildStore_SalesData"]
local listings_data = _G["LibGuildStore_ListingsData"]
local sr_index      = _G["LibGuildStore_SalesIndex"]
local LGH           = LibHistoire

function internal:concat(a, ...)
  if a == nil and ... == nil then
    return ''
  elseif a == nil then
    return internal:concat(...)
  else
    if type(a) == 'boolean' then
      --d(tostring(a) .. ' ' .. internal:concat(...))
    end
    return tostring(a) .. ' ' .. internal:concat(...)
  end
end

function internal:concatHash(a, ...)
  if a == nil and ... == nil then
    return ''
  elseif a == nil then
    return internal:concat(...)
  else
    if type(a) == 'boolean' then
      --d(tostring(a) .. ' ' .. internal:concat(...))
    end
    return tostring(a) .. ' ' .. internal:concat(...)
  end
end

function internal:GetIndexByString(key, stringName)
  if internal:is_empty_or_nil(GS16DataSavedVariables[key]) then return nil end
  if GS16DataSavedVariables[key] and GS16DataSavedVariables[key][stringName] then
    return GS16DataSavedVariables[key][stringName]
  end
  return nil
end

function internal:GetStringByIndex(key, index)
  if key == internal.GS_CHECK_ACCOUNTNAME then
    if internal:is_empty_or_nil(internal.accountNameByIdLookup[index]) then return nil end
    return internal.accountNameByIdLookup[index]
  end
  if key == internal.GS_CHECK_ITEMLINK then
    if internal:is_empty_or_nil(internal.itemLinkNameByIdLookup[index]) then return nil end
    return internal.itemLinkNameByIdLookup[index]
  end
  if key == internal.GS_CHECK_GUILDNAME then
    if internal:is_empty_or_nil(internal.guildNameByIdLookup[index]) then return nil end
    return internal.guildNameByIdLookup[index]
  end
end

-- uses mod to determine which save files to use
function internal:MakeHashString(itemLink)
  name       = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink)))
  local hash = 0
  for c in string.gmatch(name, '.') do
    if c then hash = hash + string.byte(c) end
  end
  return hash % 16
end

local function GetLevelAndCPRequirementFromItemLink(itemLink)
  local link = { ZO_LinkHandler_ParseLink(itemLink) }
  return tonumber(link[5]), tonumber(link[6])
end

local function GetPotionPowerLevel(itemLink)
  local CP, level = GetLevelAndCPRequirementFromItemLink(itemLink)
  if level < 50 then
    return level
  end
  return CP
end
-- The index consists of the item's required level, required vet
-- level, quality, and trait(if any), separated by colons.
function internal:MakeIndexFromLink(itemLink)
  --Standardize Level to 1 if the level is not relevent but is stored on some items (ex: recipes)
  local levelReq                      = 1
  local itemType, specializedItemType = GetItemLinkItemType(itemLink)
  if itemType ~= ITEMTYPE_RECIPE then
    levelReq = GetItemLinkRequiredLevel(itemLink)
  end
  local vetReq      = GetItemLinkRequiredChampionPoints(itemLink) / 10
  local itemQuality = GetItemLinkQuality(itemLink)
  local itemTrait   = GetItemLinkTraitType(itemLink)
  local theLastNumber
  --Add final number in the link to handle item differences like 2 and 3 buff potions
  if itemType == ITEMTYPE_MASTER_WRIT then
    theLastNumber = 0
  else
    theLastNumber = string.match(itemLink, '|H.-:item:.-:(%d-)|h') or 0
  end
  if itemType == ITEMTYPE_POISON or itemType == ITEMTYPE_POTION then
    local value = GetPotionPowerLevel(itemLink)
    itemTrait   = internal.potionVarientTable[value] or "0"
  end
  local index = levelReq .. ':' .. vetReq .. ':' .. itemQuality .. ':' .. itemTrait .. ':' .. theLastNumber

  return index
end

function internal:AddSearchToItem(itemLink)
  --Standardize Level to 1 if the level is not relevent but is stored on some items (ex: recipes)
  local requiredLevel = 1
  local itemType      = GetItemLinkItemType(itemLink)
  if itemType ~= ITEMTYPE_RECIPE then
    requiredLevel = GetItemLinkRequiredLevel(itemLink) -- verified
  end

  local requiredVeteranRank = GetItemLinkRequiredChampionPoints(itemLink) -- verified
  local vrAdder             = GetString(GS_CP_RANK_SEARCH)

  local adder               = ''
  if (requiredLevel > 0 or requiredVeteranRank > 0) then
    if (requiredVeteranRank > 0) then
      adder = vrAdder .. string.format('%02d', requiredVeteranRank)
    else
      adder = GetString(GS_REGULAR_RANK_SEARCH) .. string.format('%02d', requiredLevel)
    end
  else
    adder = vrAdder .. '00 ' .. GetString(GS_REGULAR_RANK_SEARCH) .. '00'
  end

  -- adds green blue
  local itemQuality = GetItemLinkDisplayQuality(itemLink) -- verified
  if (itemQuality == ITEM_DISPLAY_QUALITY_NORMAL) then adder = internal:concat(adder, GetString(GS_COLOR_WHITE)) end
  if (itemQuality == ITEM_DISPLAY_QUALITY_MAGIC) then adder = internal:concat(adder, GetString(GS_COLOR_GREEN)) end
  if (itemQuality == ITEM_DISPLAY_QUALITY_ARCANE) then adder = internal:concat(adder, GetString(GS_COLOR_BLUE)) end
  if (itemQuality == ITEM_DISPLAY_QUALITY_ARTIFACT) then adder = internal:concat(adder, GetString(GS_COLOR_PURPLE)) end
  if (itemQuality == ITEM_DISPLAY_QUALITY_LEGENDARY) then adder = internal:concat(adder, GetString(GS_COLOR_GOLD)) end
  if (itemQuality == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE) then adder = internal:concat(adder,
    GetString(GS_COLOR_ORANGE)) end

  -- adds Mythic Legendary
  adder           = internal:concat(adder,
    zo_strformat("<<t:1>>", GetString("SI_ITEMDISPLAYQUALITY", itemQuality))) -- verified

  -- adds Heavy
  local armorType = GetItemLinkArmorType(itemLink) -- verified
  if (armorType ~= 0) then
    adder = internal:concat(adder, zo_strformat("<<t:1>>", GetString("SI_ARMORTYPE", armorType)))
  end

  -- adds Apparel
  local filterType = GetItemLinkFilterTypeInfo(itemLink) -- verified
  if (filterType ~= 0) then
    adder = internal:concat(adder, zo_strformat("<<t:1>>", GetString("SI_ITEMFILTERTYPE", filterType)))
  end
  -- declared above
  -- local itemType = GetItemLinkItemType(itemLink) -- verified
  if (itemType ~= 0) then
    adder = internal:concat(adder, zo_strformat("<<t:1>>", GetString("SI_ITEMTYPE", itemType)))
  end

  -- adds Mark of the Pariah
  local isSetItem, setName = GetItemLinkSetInfo(itemLink) -- verified
  if (isSetItem) then
    adder = internal:concat(adder, 'set', setName)
  end

  -- adds Sword, Healing Staff
  local weaponType = GetItemLinkWeaponType(itemLink) -- verified
  if (weaponType ~= 0) then
    adder = internal:concat(adder, zo_strformat("<<t:1>>", GetString("SI_WEAPONTYPE", weaponType)))
  end

  -- adds chest two-handed
  local itemEquip = GetItemLinkEquipType(itemLink) -- verified
  if (itemEquip ~= 0) then
    adder = internal:concat(adder, zo_strformat("<<t:1>>", GetString("SI_EQUIPTYPE", itemEquip)))
  end

  -- adds Precise
  local itemTrait = GetItemLinkTraitType(itemLink) -- verified
  if (itemTrait ~= 0) then
    adder = internal:concat(adder, zo_strformat("<<t:1>>", GetString("SI_ITEMTRAITTYPE", itemTrait)))
  end

  resultTable  = {}
  resultString = string.gmatch(adder, '%S+')
  for word in resultString do
    if next(resultTable) == nil then
      table.insert(resultTable, word)
    elseif not internal:is_in(word, resultTable) then
      table.insert(resultTable, " " .. word)
    end
  end
  adder = table.concat(resultTable)
  return string.lower(adder)
end

function internal:BuildAccountNameLookup()
  internal:dm("Debug", "BuildAccountNameLookup")
  if not GS16DataSavedVariables["accountNames"] then GS16DataSavedVariables["accountNames"] = {} end
  for key, value in pairs(GS16DataSavedVariables["accountNames"]) do
    internal.accountNameByIdLookup[value] = key
  end
end
function internal:BuildItemLinkNameLookup()
  internal:dm("Debug", "BuildItemLinkNameLookup")
  if not GS16DataSavedVariables["itemLink"] then GS16DataSavedVariables["itemLink"] = {} end
  for key, value in pairs(GS16DataSavedVariables["itemLink"]) do
    internal.itemLinkNameByIdLookup[value] = key
  end
end
function internal:BuildGuildNameLookup()
  internal:dm("Debug", "BuildGuildNameLookup")
  if not GS16DataSavedVariables["guildNames"] then GS16DataSavedVariables["guildNames"] = {} end
  for key, value in pairs(GS16DataSavedVariables["guildNames"]) do
    internal.guildNameByIdLookup[value] = key
  end
end

function internal:InitGuildStoreData(hash, identifier, itemLink)
  local hashVerify = internal:MakeHashString(itemLink)
  if hash ~= hashVerify then internal:dm("Debug", "There is a hash issue") end
  local dataTable       = _G[string.format("GS%02dDataSavedVariables", hash)]
  local savedVars       = dataTable[internal.dataNamespace]
  savedVars[identifier] = {}
  return savedVars
end

function internal:SetGuildStoreData(itemLink, theIID)
  local hash        = internal:MakeHashString(itemLink)
  local dataTable   = _G[string.format("GS%02dDataSavedVariables", hash)]
  local savedVars   = dataTable[internal.dataNamespace]
  savedVars[theIID] = {}
  return savedVars[theIID], hash
end

function internal:setStorageTableData(key)
  local savedVars  = GS16DataSavedVariables
  local lookupData = savedVars[key]
  return lookupData
end

function internal:AddSalesTableData(key, value)
  local saveData = GS16DataSavedVariables[key]
  if not saveData[value] then
    local index     = internal:NonContiguousNonNilCount(GS16DataSavedVariables[key]) + 1
    saveData[value] = index
    if key == "accountNames" then
      internal.accountNameByIdLookup[index] = value
    end
    if key == "itemLink" then
      internal.itemLinkNameByIdLookup[index] = value
    end
    if key == "guildNames" then
      internal.guildNameByIdLookup[index] = value
    end
    return index
  else
    return saveData[value]
  end
end

function internal:CheckForDuplicateUniqueId(purchasesData, itemUniqueId)
  -- purchasesData is the table of data to verify against
  local dupe = false
  for k, v in pairs(purchasesData) do
    if v.id == itemUniqueId then
      dupe = true
      break
    end
  end
  return dupe
end

function internal:CheckForDuplicate(itemLink, eventID)
  --[[ we need to be able to calculate theIID and itemIndex
  when not used with addToHistoryTables() event though
  the function will calculate them.
  ]]--
  local theIID = GetItemLinkItemId(itemLink)
  if theIID == nil or theIID == 0 then return end
  local itemIndex = internal:MakeIndexFromLink(itemLink)

  if sales_data[theIID] and sales_data[theIID][itemIndex] then
    for k, v in pairs(sales_data[theIID][itemIndex]['sales']) do
      if v.id == eventID then
        return true
      end
    end
  end
  return false
end

-- And here we add a new item
function internal:addToHistoryTables(theEvent)

  -- DEBUG  Stop Adding
  --do return end

  --[[
  local theEvent = {
    buyer = p2,
    guild = guildName,
    itemName = p4,
    quant = p3,
    saleTime = eventTime,
    salePrice = p5,
    seller = p1,
    kioskSale = false,
    id = Id64ToString(eventId)
  }
  local newSalesItem =
    {buyer = theEvent.buyer,
    guild = theEvent.guild,
    itemLink = theEvent.itemName,
    quant = tonumber(theEvent.quant),
    timestamp = tonumber(theEvent.saleTime),
    price = tonumber(theEvent.salePrice),
    seller = theEvent.seller,
    wasKiosk = theEvent.kioskSale,
    id = theEvent.id
  }
  [1] =
  {
    ["price"] = 120,
    ["itemLink"] = "|H0:item:45057:359:50:26848:359:50:0:0:0:0:0:0:0:0:0:5:0:0:0:0:0|h|h",
    ["id"] = 1353657539,
    ["guild"] = "Unstable Unicorns",
    ["buyer"] = "@Traeky",
    ["quant"] = 1,
    ["wasKiosk"] = true,
    ["timestamp"] = 1597969403,
    ["seller"] = "@cherrypick",
  },
  ]]--

  -- first add new data looks to their tables
  local linkHash   = internal:AddSalesTableData("itemLink", theEvent.itemLink)
  local buyerHash  = internal:AddSalesTableData("accountNames", theEvent.buyer)
  local sellerHash = internal:AddSalesTableData("accountNames", theEvent.seller)
  local guildHash  = internal:AddSalesTableData("guildNames", theEvent.guild)

  --[[The quality effects itemIndex although the ID from the
  itemLink may be the same. We will keep them separate.
  ]]--
  local itemIndex  = internal:MakeIndexFromLink(theEvent.itemLink)
  --[[theIID is used in the SRIndex so define it here.
  ]]--
  local theIID     = GetItemLinkItemId(theEvent.itemLink)
  if theIID == nil or theIID == 0 then return false end

  --[[If the ID from the itemLink doesn't exist determine which
  file or container it will belong to using SetGuildStoreData()
  ]]--
  local hashUsed = "alreadyExisted"
  if not sales_data[theIID] then
    sales_data[theIID], hashUsed = internal:SetGuildStoreData(theEvent.itemLink, theIID)
  end
  local expectedHash        = internal:MakeHashString(theEvent.itemLink)

  local insertedIndex       = 1

  local searchItemDesc      = ""
  local searchItemAdderText = ""

  local newEvent            = ZO_DeepTableCopy(theEvent)
  newEvent.itemLink         = linkHash
  newEvent.buyer            = buyerHash
  newEvent.seller           = sellerHash
  newEvent.guild            = guildHash

  if sales_data[theIID][itemIndex] then
    local nextLocation  = #sales_data[theIID][itemIndex]['sales'] + 1
    searchItemDesc      = sales_data[theIID][itemIndex].itemDesc
    searchItemAdderText = sales_data[theIID][itemIndex].itemAdderText
    if sales_data[theIID][itemIndex]['sales'][nextLocation] == nil then
      table.insert(sales_data[theIID][itemIndex]['sales'], nextLocation, newEvent)
      insertedIndex = nextLocation
    else
      table.insert(sales_data[theIID][itemIndex]['sales'], newEvent)
      insertedIndex = #sales_data[theIID][itemIndex]['sales']
    end
  else
    searchItemDesc      = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(theEvent.itemLink))
    searchItemAdderText = internal:AddSearchToItem(theEvent.itemLink)
    if sales_data[theIID][itemIndex] == nil then sales_data[theIID][itemIndex] = {} end
    if sales_data[theIID][itemIndex]['sales'] == nil then sales_data[theIID][itemIndex]['sales'] = {} end
    sales_data[theIID][itemIndex] = {
      itemIcon = GetItemLinkInfo(theEvent.itemLink),
      itemAdderText = searchItemAdderText,
      itemDesc = searchItemDesc,
      sales = { newEvent } }
    --internal:dm("Debug", newEvent)
  end
  sales_data[theIID][itemIndex].wasAltered = true

  -- this section adds the sales to the lists for the MM window
  local guild
  local adderDescConcat                    = searchItemDesc .. ' ' .. searchItemAdderText

  guild                                    = internal.guildSales[theEvent.guild] or MMGuild:new(theEvent.guild)
  internal.guildSales[theEvent.guild]      = guild
  guild:addSaleByDate(theEvent.seller, theEvent.timestamp, theEvent.price, theEvent.quant, false)

  guild                                   = internal.guildPurchases[theEvent.guild] or MMGuild:new(theEvent.guild)
  internal.guildPurchases[theEvent.guild] = guild
  guild:addSaleByDate(theEvent.buyer, theEvent.timestamp, theEvent.price, theEvent.quant, theEvent.wasKiosk)

  guild                               = internal.guildItems[theEvent.guild] or MMGuild:new(theEvent.guild)
  internal.guildItems[theEvent.guild] = guild
  guild:addSaleByDate(theEvent.itemLink, theEvent.timestamp, theEvent.price, theEvent.quant, false, nil,
    adderDescConcat)

  local playerName = string.lower(GetDisplayName())
  local isSelfSale = playerName == string.lower(theEvent.seller)

  if isSelfSale then
    guild                            = internal.myItems[theEvent.guild] or MMGuild:new(theEvent.guild)
    internal.myItems[theEvent.guild] = guild;
    guild:addSaleByDate(theEvent.itemLink, theEvent.timestamp, theEvent.price, theEvent.quant, false, nil,
      adderDescConcat)
  end

  local temp       = { 'b', '', ' s', '', ' ', '', ' ', '', ' ', '', ' ', '' }
  local searchText = ""
  if LibGuildStore_SavedVariables["minimalIndexing"] then
    if isSelfSale then
      searchText = internal.PlayerSpecialText
    else
      searchText = ''
    end
  else
    temp[2]  = theEvent.buyer or ''
    temp[4]  = theEvent.seller or ''
    temp[6]  = theEvent.guild or ''
    temp[8]  = searchItemDesc or ''
    temp[10] = searchItemAdderText or ''
    if isSelfSale then
      temp[12] = internal.PlayerSpecialText
    else
      temp[12] = ''
    end
    searchText = string.lower(table.concat(temp, ''))
  end

  local searchByWords = string.gmatch(searchText, '%S+')
  local wordData      = { theIID, itemIndex, insertedIndex }

  -- Index each word
  for i in searchByWords do
    if sr_index[i] == nil then sr_index[i] = {} end
    table.insert(sr_index[i], wordData)
  end

  return true
end

function internal:SetupListener(guildId)
  -- listener
  internal.LibHistoireListener[guildId] = LGH:CreateGuildHistoryListener(guildId, GUILD_HISTORY_STORE)
  local lastReceivedEventID
  if LibGuildStore_SavedVariables["lastReceivedEventID"][guildId] then
    --internal:dm("Info", string.format("internal Saved Var: %s, guildId: (%s)", LibGuildStore_SavedVariables["lastReceivedEventID"][guildId], guildId))
    lastReceivedEventID = StringToId64(LibGuildStore_SavedVariables["lastReceivedEventID"][guildId])
    --internal:dm("Info", string.format("lastReceivedEventID set to: %s", lastReceivedEventID))
    internal.LibHistoireListener[guildId]:SetAfterEventId(lastReceivedEventID)
  end
  internal.LibHistoireListener[guildId]:SetEventCallback(function(eventType, eventId, eventTime, p1, p2, p3, p4, p5, p6)
    if eventType == GUILD_EVENT_ITEM_SOLD and not internal.isDatabaseBusy then
      if not lastReceivedEventID or CompareId64s(eventId, lastReceivedEventID) > 0 then
        LibGuildStore_SavedVariables["lastReceivedEventID"][guildId] = Id64ToString(eventId)
        lastReceivedEventID                                          = eventId
      end
      local guildName           = GetGuildName(guildId)
      local thePlayer           = string.lower(GetDisplayName())
      local added               = false
      --[[
      local theEvent = {
        buyer = p2,
        guild = guildName,
        itemName = p4,
        quant = p3,
        saleTime = eventTime,
        salePrice = p5,
        seller = p1,
        kioskSale = false,
        id = Id64ToString(eventId)
      }
      local newSalesItem =
        {buyer = theEvent.buyer,
        guild = theEvent.guild,
        itemLink = theEvent.itemName,
        quant = tonumber(theEvent.quant),
        timestamp = tonumber(theEvent.saleTime),
        price = tonumber(theEvent.salePrice),
        seller = theEvent.seller,
        wasKiosk = theEvent.kioskSale,
        id = theEvent.id
      }
      [1] =
      {
        ["price"] = 120,
        ["itemLink"] = "|H0:item:45057:359:50:26848:359:50:0:0:0:0:0:0:0:0:0:5:0:0:0:0:0|h|h",
        ["id"] = 1353657539,
        ["guild"] = "Unstable Unicorns",
        ["buyer"] = "@Traeky",
        ["quant"] = 1,
        ["wasKiosk"] = true,
        ["timestamp"] = 1597969403,
        ["seller"] = "@cherrypick",
      },
      ]]--
      local theEvent            = {
        buyer = p2,
        guild = guildName,
        itemLink = p4,
        quant = p3,
        timestamp = eventTime,
        price = p5,
        seller = p1,
        wasKiosk = false,
        id = Id64ToString(eventId)
      }
      theEvent.wasKiosk         = (internal.guildMemberInfo[guildId][string.lower(theEvent.buyer)] == nil)

      local daysOfHistoryToKeep = GetTimeStamp() - internal.oneDayInSeconds * LibGuildStore_SavedVariables["historyDepth"]
      if (theEvent.timestamp > daysOfHistoryToKeep) then
        local duplicate = internal:CheckForDuplicate(theEvent.itemLink, theEvent.id)
        if not duplicate then
          added = internal:addToHistoryTables(theEvent)
        end
        -- (doAlert and (internal.systemSavedVariables.showChatAlerts or internal.systemSavedVariables.showAnnounceAlerts))
        if added and string.lower(theEvent.seller) == thePlayer then
          --internal:dm("Debug", "alertQueue updated")
          table.insert(internal.alertQueue[theEvent.guild], theEvent)
        end
        if added then
          MasterMerchant:PostScanParallel(guildName, true)
          MasterMerchant:SetMasterMerchantWindowDirty()
        end
      end
    end
  end)
  internal.LibHistoireListener[guildId]:Start()
end

function internal:addListing(listing, addBuyer)
  local linkHash   = internal:AddSalesTableData("itemLink", listing.ItemLink)
  local buyerHash  = internal:AddSalesTableData("accountNames", GetDisplayName())
  local sellerHash = internal:AddSalesTableData("accountNames", listing.Seller)
  local guildHash  = internal:AddSalesTableData("guildNames", listing.Guild)

  local itemIndex  = internal:MakeIndexFromLink(listing.itemLink)
  local theIID     = GetItemLinkItemId(listing.itemLink)
  if theIID == nil or theIID == 0 then return end

  if not listings_data[theIID] then
    listings_data[theIID], hashUsed = internal:SetGuildStoreData(listing.itemLink, theIID)
  end

  local duplicate = internal:CheckForDuplicateUniqueId(saveData, itemUniqueId)
  if not duplicate then
    local buyerData = nil
    if addBuyer then
      buyerData = buyerHash -- yourself
    end
    table.insert(saveData, {
      Buyer = buyerData, -- yourself unless not a purchace
      Seller = sellerHash, -- who listed the item
      ItemLink = listing.ItemLink,
      -- ItemLink = linkHash,
      Quantity = listing.Quantity,
      Price = listing.Price,
      Guild = guildHash,
      TimeStamp = listing.TimeStamp,
      id = listing.id,
    })
  end
end

function internal:onTradingHouseEvent(eventCode, slotId, isPending)
  if not AwesomeGuildStore then
    local CurrentPurchase                                                                                                          = {}
    local icon, itemName, displayQuality, quantity, seller, timeRemaining, price, currencyType, itemUniqueId, purchasePricePerUnit = GetTradingHouseSearchResultItemInfo(slotId)
    local guildId, guild, guildAlliance                                                                                            = GetCurrentTradingHouseGuildDetails()
    CurrentPurchase.ItemLink                                                                                                       = GetTradingHouseSearchResultItemLink(slotId)
    CurrentPurchase.Quantity                                                                                                       = quantity
    CurrentPurchase.Price                                                                                                          = price
    CurrentPurchase.Seller                                                                                                         = seller
    CurrentPurchase.Guild                                                                                                          = guild
    CurrentPurchase.id                                                                                                             = Id64ToString(itemUniqueId)
    CurrentPurchase.TimeStamp                                                                                                      = GetTimeStamp()
    internal:addListing(CurrentPurchase, addBuyer)
    --ShoppingList.List:Refresh()
  end
end

function internal:AddAwesomeGuildStoreListing(listing)
  --internal:dm("Debug", listing)
end

function internal:processAwesomeGuildStore(itemDatabase)
  local guildCounts = {}
  for guildIndex, guildData in pairs(itemDatabase) do
    local guildName        = GetGuildName(guildIndex)
    guildCounts[guildName] = internal:NonContiguousNonNilCount(itemDatabase[guildIndex])
    for dataIndex, listingData in pairs(guildData) do
      local index = Id64ToString(dataIndex)
      --internal:dm("Debug", index)
      internal:AddAwesomeGuildStoreListing(listingData)
      break
    end
  end
  --[[
  local icon, itemName, displayQuality, quantity, seller, timeRemaining, price, currencyType, itemUniqueId, purchasePricePerUnit = GetTradingHouseSearchResultItemInfo(slotId)
  local guildId, guild, guildAlliance = GetCurrentTradingHouseGuildDetails()
  CurrentPurchase.ItemLink = GetTradingHouseSearchResultItemLink(slotId)
  CurrentPurchase.Quantity = quantity
  CurrentPurchase.Price = price
  CurrentPurchase.Seller = seller:gsub("|c.-$", "")
  CurrentPurchase.Guild = guild
  CurrentPurchase.itemUniqueId = Id64ToString(itemUniqueId)
  CurrentPurchase.TimeStamp = GetTimeStamp()
  internal:addListing(CurrentPurchase)
  ]]--
  --ShoppingList.List:Refresh()
end

-- Handle the reset button - clear out the search and scan tables,
-- and set the time of the last scan to nil, then force a scan.
function internal:DoReset()
  internal:dm("Info", "DoReset is not ready yet")
  local notReady = true
  if notReady then return end

  local sales_data                  = {}
  local sr_index                    = {}
  _G["LibGuildStore_SalesData"]     = sales_data
  _G["LibGuildStore_SalesIndex"]    = sr_index

  MM00Data.savedVariables.SalesData = {}
  MM01Data.savedVariables.SalesData = {}
  MM02Data.savedVariables.SalesData = {}
  MM03Data.savedVariables.SalesData = {}
  MM04Data.savedVariables.SalesData = {}
  MM05Data.savedVariables.SalesData = {}
  MM06Data.savedVariables.SalesData = {}
  MM07Data.savedVariables.SalesData = {}
  MM08Data.savedVariables.SalesData = {}
  MM09Data.savedVariables.SalesData = {}
  MM10Data.savedVariables.SalesData = {}
  MM11Data.savedVariables.SalesData = {}
  MM12Data.savedVariables.SalesData = {}
  MM13Data.savedVariables.SalesData = {}
  MM14Data.savedVariables.SalesData = {}
  MM15Data.savedVariables.SalesData = {}

  self.guildPurchases               = {}
  self.guildSales                   = {}
  self.guildItems                   = {}
  self.myItems                      = {}
  if MasterMerchantGuildWindow:IsHidden() then
    internal.scrollList:RefreshData()
  else
    internal.guildScrollList:RefreshData()
  end
  self:setScanning(false)
  internal:dm("Info", internal:concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_RESET_DONE)))
  internal:dm("Info", internal:concat(GetString(MM_APP_MESSAGE_NAME), GetString(SK_REFRESH_START)))
  self.veryFirstScan = true
  -- self:ScanStoresParallel(true)
  --[[needs updating so start and stop the listener then
  init everyting
  ]]--
end
