local lib = _G["LibGuildStore"]
local internal = _G["LibGuildStore_Internal"]
local LGH = LibHistoire

function internal.concat(a, ...)
  if a == nil and ... == nil then
    return ''
  elseif a == nil then
    return internal.concat(...)
  else
    if type(a) == 'boolean' then
      --d(tostring(a) .. ' ' .. internal.concat(...))
    end
    return tostring(a) .. ' ' .. internal.concat(...)
  end
end

function internal:NonContiguousNonNilCount(tableObject)
  local count = 0

  for _, v in pairs(tableObject)
  do
    if v ~= nil then count = count + 1 end
  end

  return count
end

-- uses mod to determine which save files to use
function internal:MakeHashString(itemLink)
  local hash = HashString(itemLink) % 16
  return hash
end

-- The index consists of the item's required level, required vet
-- level, quality, and trait(if any), separated by colons.
function internal:MakeIndexFromLink(itemLink)
  --Standardize Level to 1 if the level is not relevent but is stored on some items (ex: recipes)
  local levelReq = 1
  local itemType = GetItemLinkItemType(itemLink)
  if itemType ~= ITEMTYPE_RECIPE then
    levelReq = GetItemLinkRequiredLevel(itemLink)
  end
  local vetReq = GetItemLinkRequiredChampionPoints(itemLink) / 10
  local itemQuality = GetItemLinkQuality(itemLink)
  local itemTrait = GetItemLinkTraitType(itemLink)
  local theLastNumber
  --Add final number in the link to handle item differences like 2 and 3 buff potions
  if itemType == ITEMTYPE_MASTER_WRIT then
    theLastNumber = 0
  else
    theLastNumber = string.match(itemLink, '|H.-:item:.-:(%d-)|h') or 0
  end

  local index = levelReq .. ':' .. vetReq .. ':' .. itemQuality .. ':' .. itemTrait .. ':' .. theLastNumber

  return index
end

function internal:AddSearchToItem(itemLink)
  --Standardize Level to 1 if the level is not relevent but is stored on some items (ex: recipes)
  local requiredLevel = 1
  local itemType = GetItemLinkItemType(itemLink)
  if itemType ~= ITEMTYPE_RECIPE then
    requiredLevel = GetItemLinkRequiredLevel(itemLink) -- verified
  end

  local requiredVeteranRank = GetItemLinkRequiredChampionPoints(itemLink) -- verified
  local vrAdder = GetString(MM_CP_RANK_SEARCH)

  local adder = ''
  if (requiredLevel > 0 or requiredVeteranRank > 0) then
    if (requiredVeteranRank > 0) then
      adder = vrAdder .. string.format('%02d', requiredVeteranRank)
    else
      adder = GetString(MM_REGULAR_RANK_SEARCH) .. string.format('%02d', requiredLevel)
    end
  else
    adder = vrAdder .. '00 ' .. GetString(MM_REGULAR_RANK_SEARCH) .. '00'
  end

  -- adds green blue
  local itemQuality = GetItemLinkDisplayQuality(itemLink) -- verified
  if (itemQuality == ITEM_DISPLAY_QUALITY_NORMAL) then adder = internal.concat(adder, GetString(GS_COLOR_WHITE)) end
  if (itemQuality == ITEM_DISPLAY_QUALITY_MAGIC) then adder = internal.concat(adder, GetString(GS_COLOR_GREEN)) end
  if (itemQuality == ITEM_DISPLAY_QUALITY_ARCANE) then adder = internal.concat(adder, GetString(GS_COLOR_BLUE)) end
  if (itemQuality == ITEM_DISPLAY_QUALITY_ARTIFACT) then adder = internal.concat(adder, GetString(GS_COLOR_PURPLE)) end
  if (itemQuality == ITEM_DISPLAY_QUALITY_LEGENDARY) then adder = internal.concat(adder, GetString(GS_COLOR_GOLD)) end
  if (itemQuality == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE) then adder = internal.concat(adder, GetString(GS_COLOR_ORANGE)) end

  -- adds Mythic Legendary
  adder = internal.concat(adder, zo_strformat("<<t:1>>", GetString("SI_ITEMDISPLAYQUALITY", itemQuality))) -- verified

  -- adds Heavy
  local armorType = GetItemLinkArmorType(itemLink) -- verified
  if (armorType ~= 0) then
    adder = internal.concat(adder, zo_strformat("<<t:1>>", GetString("SI_ARMORTYPE", armorType)))
  end

  -- adds Apparel
  local filterType = GetItemLinkFilterTypeInfo(itemLink) -- verified
  if (filterType ~= 0) then
    adder = internal.concat(adder, zo_strformat("<<t:1>>", GetString("SI_ITEMFILTERTYPE", filterType)))
  end
  -- declared above
  -- local itemType = GetItemLinkItemType(itemLink) -- verified
  if (itemType ~= 0) then
    adder = internal.concat(adder, zo_strformat("<<t:1>>", GetString("SI_ITEMTYPE", itemType)))
  end

  -- adds Mark of the Pariah
  local isSetItem, setName = GetItemLinkSetInfo(itemLink) -- verified
  if (isSetItem) then
    adder = internal.concat(adder, 'set', setName)
  end

  -- adds Sword, Healing Staff
  local weaponType = GetItemLinkWeaponType(itemLink) -- verified
  if (weaponType ~= 0) then
    adder = internal.concat(adder, zo_strformat("<<t:1>>", GetString("SI_WEAPONTYPE", weaponType)))
  end

  -- adds chest two-handed
  local itemEquip = GetItemLinkEquipType(itemLink) -- verified
  if (itemEquip ~= 0) then
    adder = internal.concat(adder, zo_strformat("<<t:1>>", GetString("SI_EQUIPTYPE", itemEquip)))
  end

  -- adds Precise
  local itemTrait = GetItemLinkTraitType(itemLink) -- verified
  if (itemTrait ~= 0) then
    adder = internal.concat(adder, zo_strformat("<<t:1>>", GetString("SI_ITEMTRAITTYPE", itemTrait)))
  end

  resultTable = {}
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
  if not GS16DataSavedVariables["AccountNames"] then GS16DataSavedVariables["AccountNames"] = {} end
  for key, value in pairs(GS16DataSavedVariables["AccountNames"]) do
    internal.accountNameByIdLookup[value] = key
  end
end
function internal:BuildItemLinkNameLookup()
  if not GS16DataSavedVariables["ItemLink"] then GS16DataSavedVariables["ItemLink"] = {} end
  for key, value in pairs(GS16DataSavedVariables["ItemLink"]) do
    internal.itemLinkNameByIdLookup[value] = key
  end
end
function internal:BuildGuildNameLookup()
  if not GS16DataSavedVariables["GuildNames"] then GS16DataSavedVariables["GuildNames"] = {} end
  for key, value in pairs(GS16DataSavedVariables["GuildNames"]) do
    internal.guildNameByIdLookup[value] = key
  end
end

function internal:InitSalesData(hash, theIID)
  local dataTable = _G[string.format("GS%02dData", hash)]
  local savedVars = dataTable['data']
  savedVars[theIID] = {}
  return savedVars
end

function internal:SetSalesData(hash)
  local dataTable = _G[string.format("GS%02dData", hash)]
  local savedVars = dataTable['data']
  return savedVars
end

function internal:setSalesTableData(key)
  local savedVars = GS16DataSavedVariables
  local lookupData = savedVars
  lookupData[key] = {}
  return lookupData[key]
end

function internal:AddSalesTableData(key, value)
  if not GS16DataSavedVariables[key] then
    GS16DataSavedVariables[key] = internal:setSalesTableData(key)
  end
  if not GS16DataSavedVariables[key][value] then
    local index = internal:NonContiguousNonNilCount(GS16DataSavedVariables[key]) + 1
    GS16DataSavedVariables[key][value] = index
    if key == "AccountNames" then
      internal.accountNameByIdLookup[index] = value
    end
    if key == "ItemLink" then
      internal.itemLinkNameByIdLookup[index] = value
    end
    if key == "GuildNames" then
      internal.guildNameByIdLookup[index] = value
    end
    return index
  end
  return nil
end

function internal:CheckForDuplicate(itemLink, eventID)
  local dupe = false
  --[[ we need to be able to calculate theIID and itemIndex
  when not used with addToHistoryTables() event though
  the function will calculate them.
  ]]--
  local theIID = GetItemLinkItemId(itemLink)
  if theIID == nil then return end
  local itemIndex = internal:MakeIndexFromLink(itemLink)
  local hash = internal:MakeHashString(itemLink)
  local saveData = internal:SetSalesData(hash)

  if saveData[theIID] and saveData[theIID][itemIndex] then
    for k, v in pairs(saveData[theIID][itemIndex]) do
      if v.id == eventID then
        dupe = true
        break
      end
    end
  end
  return dupe
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
  local linkHash = internal:AddSalesTableData("ItemLink", theEvent.itemLink)
  local buyerHash = internal:AddSalesTableData("AccountNames", theEvent.buyer)
  local sellerHash = internal:AddSalesTableData("AccountNames", theEvent.seller)
  local guildHash = internal:AddSalesTableData("GuildNames", theEvent.guild)

  --[[The quality effects itemIndex although the ID from the
  itemLink may be the same. We will keep them separate.
  ]]--
  local itemIndex = internal:MakeIndexFromLink(theEvent.itemLink)
  --[[theIID is used in the SRIndex so define it here.
  ]]--
  local theIID = GetItemLinkItemId(theEvent.itemLink)
  if theIID == nil then return end
  local hash = internal:MakeHashString(theEvent.itemLink)
  --[[If the ID from the itemLink doesn't exist determine which
  file or container it will belong to using setSalesData()
  ]]--
  saveData = internal:SetSalesData(hash)

  if not saveData[theIID] then
    saveData = internal:InitSalesData(hash, theIID)
  end

  local insertedIndex = 1

  local searchItemDesc = ""
  local searchItemAdderText = ""

  if saveData[theIID][itemIndex] then
    local nextLocation = #saveData[theIID][itemIndex]['sales'] + 1
    searchItemDesc = saveData[theIID][itemIndex].itemDesc
    searchItemAdderText = saveData[theIID][itemIndex].itemAdderText
    if saveData[theIID][itemIndex]['sales'][nextLocation] == nil then
      table.insert(saveData[theIID][itemIndex]['sales'], nextLocation, theEvent)
      insertedIndex = nextLocation
    else
      table.insert(saveData[theIID][itemIndex]['sales'], theEvent)
      insertedIndex = #saveData[theIID][itemIndex]['sales']
    end
  else
    searchItemDesc = GetItemLinkName(theEvent.itemLink)
    searchItemAdderText = internal:AddSearchToItem(theEvent.itemLink)
    saveData[theIID][itemIndex] = {
      itemIcon      = GetItemLinkInfo(theEvent.itemLink),
      itemAdderText = searchItemAdderText,
      itemDesc      = searchItemDesc,
      sales         = { theEvent } }
  end
end

function internal:SetupListener(guildID)
  -- listener
  internal.LibHistoireListener[guildID] = LGH:CreateGuildHistoryListener(guildID, GUILD_HISTORY_STORE)
  local lastReceivedEventID
  if LibGuildStore_SavedVariables["lastReceivedEventID"][guildID] then
    --internal.dm("Info", string.format("internal Saved Var: %s, GuildID: (%s)", internal.systemSavedVariables["lastReceivedEventID"][guildID], guildID))
    lastReceivedEventID = StringToId64(LibGuildStore_SavedVariables["lastReceivedEventID"][guildID])
    --internal.dm("Info", string.format("lastReceivedEventID set to: %s", lastReceivedEventID))
    internal.LibHistoireListener[guildID]:SetAfterEventId(lastReceivedEventID)
  end
  internal.LibHistoireListener[guildID]:SetEventCallback(function(eventType, eventId, eventTime, p1, p2, p3, p4, p5, p6)
    if eventType == GUILD_EVENT_ITEM_SOLD then
      if not lastReceivedEventID or CompareId64s(eventId, lastReceivedEventID) > 0 then
        LibGuildStore_SavedVariables["lastReceivedEventID"][guildID] = Id64ToString(eventId)
        lastReceivedEventID = eventId
      end
      local guildName = GetGuildName(guildID)
      local thePlayer = string.lower(GetDisplayName())
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
      local theEvent = {
        buyer     = p2,
        guild     = guildName,
        itemLink  = p4,
        quant     = p3,
        timestamp = eventTime,
        price     = p5,
        seller    = p1,
        wasKiosk  = false,
        id        = Id64ToString(eventId)
      }
      theEvent.wasKiosk = (internal.guildMemberInfo[guildID][string.lower(theEvent.buyer)] == nil)

      local isDuplicate = internal:CheckForDuplicate(theEvent.itemLink, theEvent.id)

      if not isDuplicate then
        internal:addToHistoryTables(theEvent)
      end
      -- (doAlert and (internal.systemSavedVariables.showChatAlerts or internal.systemSavedVariables.showAnnounceAlerts))
      if not isDuplicate and string.lower(theEvent.seller) == thePlayer then
        --internal.dm("Debug", "alertQueue updated")
        table.insert(internal.alertQueue[theEvent.guild], theEvent)
      end
      if not isDuplicate then
        -- internal:PostScanParallel(guildName, true)
      end
    end
  end)
  internal.LibHistoireListener[guildID]:Start()
end
