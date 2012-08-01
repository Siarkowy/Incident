--------------------------------------------------------------------------------
--	Inc!dent (c) 2012 by Siarkowy
--	Released under the terms of GNU GPL v3 license.
--------------------------------------------------------------------------------

local _G = _G

Incident = {
	frame = CreateFrame("frame", "UIParent"),
	name = "Inc!dent",
	outputFrame = 3,
	suspend = false,
	version = GetAddOnMetadata("Inc!dent", "Version"),
}

local self = Incident

local function tostringall(...)
	if select('#', ...) > 1 then return tostring(select(1, ...)), tostringall(select(2, ...))
	else return tostring(select(1, ...)) end
end

function Incident:Init()
	self.frame:SetScript("OnEvent", self.OnEvent)
	SlashCmdList.INCIDENT = self.OnSlashCmd
	
	SLASH_INCIDENT1 = "/incident"
	SLASH_INCIDENT2 = "/!"
end

local formats = {
	["boolean"] = "|cffff9100%s|r",
	["function"] = "func",
	["nil"] = "|cffff7f7fnil|r",
	["number"] = "|cffff7fff%d|r",
	["string"] = "|cff00ff00%q|r",
	["table"] = "{tab}",
	["thread"] = "thread",
	["userdata"] = "udata",
}

local params = { }

function Incident.Print(...)
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		local varType = type(value)
		if varType == "string" then
			value = value:gsub("|", "||"):gsub("\a", "<A>"):gsub("\t", "<T>")
		end
		tinsert(params, i .. ':' .. formats[varType]:format(value))
	end
	_G[format("ChatFrame%d", self.outputFrame or 1)]:AddMessage(strjoin("; ", unpack(params)))
	for k, v in pairs(params) do params[k] = nil end
end

dump	= Incident.Print
print	= function(...) ChatFrame1:AddMessage(...) end
printf	= function(...) ChatFrame1:AddMessage(format(...)) end

function Incident.OnEvent(frame, event, ...)
	if not self.suspend then
		if not self.filter or strjoin("\a", tostringall(event, ...)):lower():match(self.filter) then
			self.Print(event, ...)
		end
	end
end

local abbreviations = {
	CLE		= "COMBAT_LOG_EVENT",
	CLEU	= "COMBAT_LOG_EVENT_UNFILTERED",
	CMA		= "CHAT_MSG_ADDON",
	CMC		= "CHAT_MSG_CHANNEL",
	CMG		= "CHAT_MSG_GUILD",
	CMS		= "CHAT_MSG_SYSTEM",
}

do
	local actions = {
		["+all"] = function()
			self.frame:RegisterAllEvents()
		end,
		["-all"] = function()
			self.frame:UnregisterAllEvents()
		end,
		["filter"] = function(param)
			self.filter = (param ~= "") and param or nil
		end,
		["help"] = function()
			ChatFrame1:AddMessage("")
		end,
		["output"] = function(param)
			self.outputFrame = tonumber(param) or 3
		end,
		["state"] = function()
			ChatFrame1:AddMessage(self.suspend and "Suspended." or "Dumping.")
		end,
		["toggle"] = function()
			if self.suspend then
				self.suspend = false
			else
				self.suspend = true
			end
		end,
	}

	function Incident.OnSlashCmd(msg)
		local command, param = msg:lower():match("([^%s]+)%s*(.*)")
		if actions[command] then
			actions[command](param)
		else
			local first, rest = msg:match("(.)(.*)")
			if rest then rest = rest:upper():gsub("(%S+)", abbreviations) end
			if first == '+' then
				self.frame:RegisterEvent(rest)
			elseif first == '-' then
				self.frame:UnregisterEvent(rest)
			end
		end
	end
end

Incident:Init()
