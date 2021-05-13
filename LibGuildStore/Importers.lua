local lib = _G["LibGuildStore"]
local internal = _G["LibGuildStore_Internal"]
local sales_data = _G["LibGuildStore_SalesData"]
local listings_data = _G["LibGuildStore_ListingsData"]
local sr_index = _G["LibGuildStore_SalesIndex"]
local ASYNC = LibAsync

----------------------------------------
----- iterateOverSalesData         -----
----------------------------------------

function internal:ImportMasterMerchantSales(datastore, task)
  GS16DataSavedVariables["temp"] = {}
  local function SetMasterMerchant(hash)
    return _G[string.format("MM%02dDataSavedVariables", hash)]
  end
  local addedCount = 0
  local skippedCount = 0
  local added = false
  local mmDataSet = SetMasterMerchant(datastore)
  local mmSaveData = mmDataSet.Default.MasterMerchant["$AccountWide"].SalesData
  task:For(pairs(mmSaveData)):Do(function(itemID, itemData)
    task:For(pairs(itemData)):Do(function(itemIndex, itemIndexData)
      if itemIndexData["sales"] then
        task:For(pairs(itemIndexData['sales'])):Do(function(key, sale)
          added = false
          local duplicate = internal:CheckForDuplicate(sale.itemLink, sale.id)
          if not duplicate then
            local linkHash = internal:AddSalesTableData("itemLink", sale.itemLink)
            local buyerHash = internal:AddSalesTableData("accountNames", sale.buyer)
            local sellerHash = internal:AddSalesTableData("accountNames", sale.seller)
            local guildHash = internal:AddSalesTableData("guildNames", sale.guild)
            added = internal:addToHistoryTables(sale, linkHash, buyerHash, sellerHash, guildHash)
            -- task:Then(function(task) internal:dm("Debug", sale) end)
          end
          if added then
            addedCount = addedCount + 1
          else
            skippedCount = skippedCount + 1
          end
        end)
      end
    end)
  end)
  task:Then(function(task) internal:dm("Debug", string.format("addedCount: %s", addedCount)) end)
  task:Then(function(task) internal:dm("Debug", string.format("skippedCount: %s", skippedCount)) end)
end

function internal:ImportAllMasterMerchantSales()
  local task = ASYNC:Create("ImportAllMasterMerchantSales")
  task:Call(function(task) internal:DatabaseBusy(true) end)
      :Then(function(task) internal:ImportMasterMerchantSales(00, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(01, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(02, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(03, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(04, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(05, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(06, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(07, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(08, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(09, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(10, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(11, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(12, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(13, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(14, task) end)
      :Then(function(task) internal:ImportMasterMerchantSales(15, task) end)
      :Then(function(task) internal:dm("Debug", "ImportAllMasterMerchantSales Done") end)
      :Finally(function(task) internal:DatabaseBusy(false) end)
end

function internal:ImportATTSales(datastore, task)
  if not ArkadiusTradeTools then return end
  local function SetATTSalesData(hash)
    return _G[string.format("ArkadiusTradeToolsSalesData%02d", hash)]
  end
  local attNameSpace = ""
  if GetWorldName() == 'NA Megaserver' then
    attMegaserver = "NA Megaserver"
  else
    attMegaserver = "EU Megaserver"
  end
  local theEvent = {}
  local addedCount = 0
  local skippedCount = 0
  local guildId = 0
  local added = false
  local attDataFile = SetATTSalesData(datastore)
  local attNameSpace = attDataFile[attMegaserver]
  local attSaveData = attNameSpace["sales"]
  task:For(pairs(attSaveData)):Do(function(saleId, saleData)
    theEvent = {
      buyer     = saleData["buyerName"],
      guild     = saleData["guildName"],
      itemLink  = saleData["itemLink"],
      quant     = saleData["quantity"],
      timestamp = saleData["timeStamp"],
      price     = saleData["price"],
      seller    = saleData["sellerName"],
      wasKiosk  = false,
      id        = tostring(saleId),
    }
    local guildFound = false
    for k, v in pairs(LibHistoire_GuildNames[attMegaserver]) do
      if theEvent.guild == v then
        guildId = k
        guildFound = true
        break
      end
    end
    if guildFound then
      theEvent.wasKiosk = (internal.guildMemberInfo[guildId][string.lower(theEvent.buyer)] == nil)
    end
    added = false
    local duplicate = internal:CheckForDuplicate(theEvent.itemLink, theEvent.id)
    if not duplicate then
      local linkHash = internal:AddSalesTableData("itemLink", theEvent.itemLink)
      local buyerHash = internal:AddSalesTableData("accountNames", theEvent.buyer)
      local sellerHash = internal:AddSalesTableData("accountNames", theEvent.seller)
      local guildHash = internal:AddSalesTableData("guildNames", theEvent.guild)
      added = internal:addToHistoryTables(theEvent, linkHash, buyerHash, sellerHash, guildHash)
      -- task:Then(function(task) internal:dm("Debug", theEvent) end)
    end
    if added then
      addedCount = addedCount + 1
    else
      skippedCount = skippedCount + 1
    end
  end)
  task:Then(function(task) internal:dm("Debug", string.format("addedCount: %s", addedCount)) end)
  task:Then(function(task) internal:dm("Debug", string.format("skippedCount: %s", skippedCount)) end)
end

function internal:ImportAllATTSales()
  local task = ASYNC:Create("ImportAllATTSales")
  task:Call(function(task) internal:DatabaseBusy(true) end)
      :Then(function(task) internal:ImportATTSales(01, task) end)
      :Then(function(task) internal:ImportATTSales(02, task) end)
      :Then(function(task) internal:ImportATTSales(03, task) end)
      :Then(function(task) internal:ImportATTSales(04, task) end)
      :Then(function(task) internal:ImportATTSales(05, task) end)
      :Then(function(task) internal:ImportATTSales(06, task) end)
      :Then(function(task) internal:ImportATTSales(07, task) end)
      :Then(function(task) internal:ImportATTSales(08, task) end)
      :Then(function(task) internal:ImportATTSales(09, task) end)
      :Then(function(task) internal:ImportATTSales(10, task) end)
      :Then(function(task) internal:ImportATTSales(11, task) end)
      :Then(function(task) internal:ImportATTSales(12, task) end)
      :Then(function(task) internal:ImportATTSales(13, task) end)
      :Then(function(task) internal:ImportATTSales(14, task) end)
      :Then(function(task) internal:ImportATTSales(15, task) end)
      :Then(function(task) internal:ImportATTSales(16, task) end)
      :Then(function(task) internal:dm("Debug", "ImportAllATTSales Done") end)
      :Finally(function(task) internal:DatabaseBusy(false) end)
end
