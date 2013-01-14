local Incident = Incident

local abbrevs = {
    CLE     = "COMBAT_LOG_EVENT",
    CLEU    = "COMBAT_LOG_EVENT_UNFILTERED",
    CMA     = "CHAT_MSG_ADDON",
    CMC     = "CHAT_MSG_CHANNEL",
    CMG     = "CHAT_MSG_GUILD",
    CMS     = "CHAT_MSG_SYSTEM",
}

function Incident:OnSlashCmd(msg)
    local cmd, param = msg:lower():match("(%S*)%s*(.*)")

    if cmd == "+all" then
        self:RegisterAllEvents()
        self:Print("All events registered.")

    elseif cmd == "-all" then
        self:UnregisterAllEvents()
        self:Print("All events unregistered.")

    elseif cmd == "filter" then
        local val = param ~= "" and param
        self:Filter(val)
        self:Print(val and "Filter set to %q." or "Filter disabled.", val)

    elseif cmd == "output" then
        local name = "ChatFrame" .. (tonumber(param) or 1)
        local frame = _G[name] or ChatFrame1
        self:SetOutput(frame)
        self:Print("Output set to %s.", frame:GetName() or "<unnamed>")

    elseif cmd == "toggle" then
        self:Print(self:ToggleSuspend() and "Suspended." or "Enabled.")

    elseif cmd == "" or cmd == "help" then
        self:Print("Usage: /! { +<event> || -<event> || +all || -all || filter <string> || output <no> || toggle }")
        self:Echo("   +<event> - Registers <event>.")
        self:Echo("   -<event> - Unregisters <event>.")
        self:Echo("   +all - Registers all events.")
        self:Echo("   -all - Unregisters all events.")
        self:Echo("   filter <string> - Sets filter to <string>.")
        self:Echo("   output <no> - Sets output to ChatFrame<no>.")
        self:Echo("   toggle - Toggles suspend mode on or off.")

    else
        local msg = msg:upper():gsub("[A-Z_]+", abbrevs)

        for op, event in msg:gmatch("(.)([A-Z_]+)") do
            if op == "+" then self:RegisterEvent(event)
            else self:UnregisterEvent(event) end
            self:Print("%s %s.", event, op == "+" and "registered" or "unregistered")
        end
    end
end

SLASH_INCIDENT1 = "/incident"
SLASH_INCIDENT2 = "/!"

SlashCmdList.INCIDENT = function(msg) Incident:OnSlashCmd(msg) end
