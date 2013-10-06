--------------------------------------------------------------------------------
-- Inc!dent (c) 2012-2013 by Siarkowy
-- Released under the terms of GNU GPL v3 license.
--------------------------------------------------------------------------------

local Incident = CreateFrame("frame", "Incident")
Incident.name = "Incident"
Incident.author = GetAddOnMetadata("Incident", "Author")
Incident.version = GetAddOnMetadata("Incident", "Version")

local byte = string.byte
local format = format
local pairs = pairs
local select = select
local time = time
local tinsert = tinsert
local tostring = tostring
local type = type
local unpack = unpack

local capture
local captures      = { }
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

function Incident:Print(...) DEFAULT_CHAT_FRAME:AddMessage("|cFF56A3FFIncident:|r " .. format(...)) end
function Incident:Echo(...) DEFAULT_CHAT_FRAME:AddMessage(format(...)) end
function Incident:Filter(val) filter = val end
function Incident:SetOutput(frame) output = frame end
function Incident:ToggleSuspend() suspend = not suspend return suspend end

function Incident:StartCapture(name)
    local name = name ~= "" and name or date("%x %X")
    IncDB[name] = IncDB[name] or { }
    capture = IncDB[name]
end

function Incident:StopCapture()
    capture = nil
end

function Incident:Dump(...)
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
dump   = dump   or function(...) Incident:Dump(...) end
print  = print  or function(...) DEFAULT_CHAT_FRAME:AddMessage(...) end
printf = printf or function(...) DEFAULT_CHAT_FRAME:AddMessage(format(...)) end

function Incident:OnEvent(event, ...)
    if suspend then return end
    if filter and not multimatch(filter, event, ...) then return end
    self:Dump(event, ...)
    if capture then tinsert(capture, strjoin("\007", tostringall(time() + GetTime() % 1, event, ...))) end
    if self[event] then self[event](self, ...) end
end

function Incident:ADDON_LOADED()
    self:UnregisterEvent("ADDON_LOADED")
    IncDB = IncDB or {}
    self:SetScript("OnEvent", self.OnEvent)
    self:Print("Version %s loaded.", Incident.version)
end

Incident:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
Incident:RegisterEvent("ADDON_LOADED")
