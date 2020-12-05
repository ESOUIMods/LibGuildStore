local libName, libVersion = "LibGuildStore", 100
local lib = {}
local internal = {}
local dataStore = {}
_G["LibGuildStore"] = lib
_G["LibGuildStore_Internal"] = internal
lib.libName = libName

local logger = LibDebugLogger.Create(libName)
internal.logger = logger
internal.show_log = true
local SDLV = DebugLogViewer

local function create_log(log_type, log_content)
    if internal.logger and SDLV then
        if log_type == "Debug" then
            internal.logger:Debug(log_content)
        end
        if log_type == "Verbose" then
            internal.logger:Verbose(log_content)
        end
    else
        d(log_content)
    end
end

local function emit_message(log_type, text)
    if(text == "") then
        text = "[Empty String]"
    end
    create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
    indent          = indent or "."
    table_history    = table_history or {}

    for k, v in pairs(t) do
        local vType = type(v)

        emit_message(log_type, indent.."("..vType.."): "..tostring(k).." = "..tostring(v))

        if(vType == "table") then
            if(table_history[v]) then
                emit_message(log_type, indent.."Avoiding cycle on table...")
            else
                table_history[v] = true
                emit_table(log_type, v, indent.."  ", table_history)
            end
        end
    end
end

function internal.dm(log_type, ...)
    if not internal.show_log then return end
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        if(type(value) == "table") then
            emit_table(log_type, value)
        else
            emit_message(log_type, tostring(value))
        end
    end
end

function internal:is_in(search_value, search_table)
    for k, v in pairs(search_table) do
        if search_value == v then return true end
        if type(search_value) == "string" then
            if string.find(string.lower(v), string.lower(search_value)) then return true end
        end
    end
    return false
end

function internal:is_empty_or_nil(t)
  if not t then return true end
  if type(t) == "table" then
    if next(t) == nil then
      return true
    else
      return false
    end
  elseif type(t) == "string" then
    if t == nil then
      return true
    elseif t == "" then
      return true
    else
      return false
    end
  elseif type(t) == "nil" then
    return true
  end
end

internal.saveVarsDefaults = {
  lastReceivedEventID = {},
}

if not LibGuildStore_SavedVariables then LibGuildStore_SavedVariables = internal.saveVarsDefaults end
internal.LibHistoireListener = { } -- added for debug on 10-31
internal.alertQueue = { }
internal.guildMemberInfo = { }
internal.accountNameByIdLookup = { }
internal.itemLinkNameByIdLookup = { }
internal.guildNameByIdLookup = { }

internal.GS_CHECK_ACCOUNTNAME = "AccountNames"
internal.GS_CHECK_ITEMLINK = "ItemLink"
internal.GS_CHECK_GUILDNAME = "GuildNames"
