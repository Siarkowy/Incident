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
    msg = msg:gsub("[A-Z_]+", abbrevs)
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

    elseif cmd == "start" then
        local name = self:StartCapture(param ~= "" and param)
        self:Print("Capture %q started.", name)

    elseif cmd == "stop" then
        if self:StopCapture() then
            self:Print("Capture stopped.")
        end

    elseif cmd == "" or cmd == "help" then
        self:Print("Usage: /! { +<event> || +<event>$ fn $ || -<event> || +all || -all || filter <string> || output <no> || start <name> || stop || toggle }")
        self:Echo("   +<event> - Registers <event>.")
        self:Echo("   +<event>$ body $ - Registers <event> with handler function. " ..
            "The handler will have predefined locals: self (=Incident), _ (=dummy) and A, B, C through Z, which stand for consecutive event parameters.")
        self:Echo("   -<event> - Unregisters <event>.")
        self:Echo("   +all - Registers all events.")
        self:Echo("   -all - Unregisters all events.")
        self:Echo("   filter <string> - Sets filter to <string>.")
        self:Echo("   output <no> - Sets output to ChatFrame<no>.")
        self:Echo("   start <name> - Starts event capture with optional <name>.")
        self:Echo("   stop - Stops event capture.")
        self:Echo("   toggle - Toggles suspend mode on or off.")

    else
        for event, fn, err in msg:gmatch("%+([A-Z_]+)(%b$$)") do
            fn = fn:sub(2, -2) -- get rid of $
            fn = format("local self,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,_ = ... %s", fn)
            fn, err = loadstring(fn)
            self.events[event] = fn

            self:Print(fn and "Handler for %s assigned successfully."
                or "Error in %s handler: %s", event, err)
        end

        for action, event in msg:gmatch("([+-])([A-Z_]+)") do
            if action == "+" then self:RegisterEvent(event)
            else self:UnregisterEvent(event) end

            self:Print("%s %s.", event, action == "+" and "registered" or "unregistered")
        end
    end
end

SLASH_INCIDENT1 = "/incident"
SLASH_INCIDENT2 = "/!"

SlashCmdList.INCIDENT = function(msg) Incident:OnSlashCmd(msg) end
