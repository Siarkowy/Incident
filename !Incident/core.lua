--------------------------------------------------------------------------------
-- Inc!dent (c) 2012-2013 by Siarkowy
-- Released under the terms of GNU GPL v3 license.
--------------------------------------------------------------------------------

local Incident = CreateFrame("frame", "Incident")
Incident.name = "Incident"
Incident.author = GetAddOnMetadata("!Incident", "Author")
Incident.version = GetAddOnMetadata("!Incident", "Version")
Incident.events = {}

local byte = string.byte
local date = date
local format = string.format
local pairs = pairs
local select = select
local time = time
local tinsert = table.insert
local tostring = tostring
local type = type
local unpack = unpack

local GetRealZoneText = GetRealZoneText

local capture
local captures      = { }
local events        = Incident.events
local filter
local output        = ChatFrame3
local params        = { }
local suspend

local formats = {
    ["boolean"]     = "|cFFFF9100%s|r",
    ["function"]    = "|cFFFFA500%s|r",
    ["nil"]         = "|cFFFF7F7Fnil|r",
    ["number"]      = "|cFFFF7FFF%d|r",
    ["string"]      = "|cFF00FF00%q|r",
    ["table"]       = "table",
    ["thread"]      = "thread",
    ["userdata"]    = "udata",
}

local function multimatch(patterns, ...)
    for pattern in patterns:gmatch("[^|]+") do
        for i = 1, select("#", ...) do
            if tostring(select(i, ...)):lower():match(pattern) then
                return true
            end
        end
    end

    return false
end

local function tostringall(x, ...)
    if select('#', ...) > 0 then return tostring(x), tostringall(...)
    else return tostring(x) end
end

Incident.tostringall = tostringall

local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
function Incident:Print(...) DEFAULT_CHAT_FRAME:AddMessage("|cFF56A3FFIncident:|r " .. format(...)) end
function Incident:Echo(...) DEFAULT_CHAT_FRAME:AddMessage(format(...)) end
function Incident:Filter(val) filter = val end
function Incident:SetOutput(frame) output = frame end
function Incident:ToggleSuspend() suspend = not suspend return suspend end

function Incident:StartCapture(name)
    local name = name ~= "" and name
    if not name then
        name = format("%s %s", date("%Y-%m-%d %H:%M:%S"), GetRealZoneText())
    end
    IncDB[name] = IncDB[name] or { }
    capture = IncDB[name]
    return name
end

function Incident:StopCapture()
    local wasActive = not not capture
    capture = nil
    return wasActive
end

function Incident:Dump(output, ...)
    for i = 1, select("#", ...) do
        local val = select(i, ...)
        local t = type(val)

        if t == "string" then
            val = val:gsub("|", "||"):gsub(".", function(c)
                if byte(c) < 32 then
                    return format("|cFFFF3333#%03d|cFF00FF00", byte(c))
                end
            end)
        end

        tinsert(params, format("%d:" .. formats[t], i, tostring(val)))
    end

    -- print to frame
    output:AddMessage(strjoin(", ", unpack(params)))

    -- clear params
    for k, v in pairs(params) do params[k] = nil end
end

-- shortcut utility functions
dump   = dump   or function(...) Incident:Dump(DEFAULT_CHAT_FRAME, ...) end
dumpf  = dumpf  or function(n, ...) Incident:Dump(_G["ChatFrame" .. n], ...) end
print  = print  or function(...) DEFAULT_CHAT_FRAME:AddMessage(...) end
printf = printf or function(...) DEFAULT_CHAT_FRAME:AddMessage(format(...)) end

function Incident:OnEvent(event, ...)
    if suspend then return end
    if filter and not multimatch(filter, event, ...) then return end
    self:Dump(output, event, ...)
    if capture then tinsert(capture, strjoin("\007", tostringall(time() + GetTime() % 1, event, ...))) end
    if events[event] then events[event](self, ...) end
end

function Incident:ADDON_LOADED()
    self:UnregisterEvent("ADDON_LOADED")
    IncDB = IncDB or {}
    self:SetScript("OnEvent", self.OnEvent)
    self:Print("Version %s loaded.", Incident.version)
end

Incident:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
Incident:RegisterEvent("ADDON_LOADED")
