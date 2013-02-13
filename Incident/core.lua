--------------------------------------------------------------------------------
-- Inc!dent (c) 2012-2013 by Siarkowy
-- Released under the terms of GNU GPL v3 license.
--------------------------------------------------------------------------------

local Incident = CreateFrame("frame", "Incident")

Incident.name       = "Incident"
Incident.author     = GetAddOnMetadata("Incident", "Author")
Incident.version    = GetAddOnMetadata("Incident", "Version")

local byte          = string.byte
local filter
local output        = ChatFrame1
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

local function tostringall(x, ...)
    if select('#', ...) > 0 then return tostring(x), tostringall(...)
    else return tostring(x) end
end

Incident.tostringall = tostringall

Incident:SetScript("OnEvent", function(self, event, ...)
    if suspend then return end
    if filter and not strjoin("\007", tostringall(event, ...)):lower():match(filter) then return end
    self:Dump(event, ...)
    if self[event] and self[event](self, ...) then return end
end)

function Incident:Print(...) DEFAULT_CHAT_FRAME:AddMessage("|cFF56A3FFIncident:|r " .. format(...)) end
function Incident:Echo(...) DEFAULT_CHAT_FRAME:AddMessage(format(...)) end
function Incident:Filter(val) filter = val end
function Incident:SetOutput(frame) output = frame end
function Incident:ToggleSuspend() suspend = not suspend return suspend end

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

Incident:Print("Version %s loaded." , Incident.version)
