--!strict
-- Written by fanofpixels

type ClientWinMessageInfo = {
	PlayerName:string,
	EndingName:string,
	Time:number,
	BoostsUsed:{[string]:string},
	
	Color:Color3,
	FancyFont:boolean
}

local m = {}
local Config = require(script.Parent.Config)::any
local Util = require(script.Parent.Util)::any
local RemoteEvents:{[string]:RemoteEvent} = {}
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

function m:DisplayWinMessage(Info:ClientWinMessageInfo)
	-- Convert boost dictionary to list
	local BoostsUsed:{string} = {}
	for k:string, v:string in Info.BoostsUsed do
		table.insert(BoostsUsed,v)
	end
	
	-- Construct the win message
	local Message:string = Config.WinMessage
	Message = Message:gsub("{PlayerName}", Info.PlayerName)
	Message = Message:gsub("{EndingName}", Info.EndingName)
	Message = Message:gsub("{Time}", "{Time:"..tostring(Info.Time).."}")
	
	-- If boosts were used, construct the list and replace {BoostsUsed} with the list
	-- Otherwise, simply omit it
	if #BoostsUsed > 0 then
		local BoostList:string = ""
		for k:number, v:string in BoostsUsed do
			BoostList ..= v
			if k < #BoostsUsed then
				BoostList ..= ", "
			end
		end
		Message = Message:gsub("{BoostsUsed}",Config.WinMessageBoostsUsed)
		Message = Message:gsub("{BoostList}", BoostList)
	else
		Message = Message:gsub("{BoostsUsed}","")
	end
	
	m:DisplayMessage(Message, Info.Color, Info.FancyFont)
end

function m:DisplayMessage(Message:string, Color:Color3, FancyText:boolean?)
	-- Format instances of "{Time:???}"
	local Message:string = Util:FormatTimeSyntax(Message)
	
	-- If the legacy chat system is being used, pass the arguments to the function meant to handle it instead
	if TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
		DisplayMessageLegacyChat(Message, Color, FancyText)
		return
	end
	
	-- Get folder of text channels
	local Channels:Instance? = TextChatService:FindFirstChild("TextChannels")
	if Channels then
		
		-- Get the appropriate text channel
		local TextChannel:Instance? = Channels:FindFirstChild(Config.ChatChannel)
		if TextChannel and TextChannel:IsA("TextChannel") then
			-- Construct information to use with the font XML tag
			local ColorString:string = "rgb("..
				tostring(math.floor(Color.R * 255))..","..
				tostring(math.floor(Color.G * 255))..","..
				tostring(math.floor(Color.B * 255))..")"
			local FaceString:string = (
				FancyText and
				Config.ChatFancyFontFace or 
				Config.ChatFontFace
			)
			local SizeString:string = (
				FancyText and
				Config.ChatFancyFontSize or 
				Config.ChatFontSize
			)
			
			-- Apply the strings to the tag
			local FinalMessage:string = Config.ChatFont
			FinalMessage = FinalMessage:gsub("{FontColor}", ColorString)
			FinalMessage = FinalMessage:gsub("{FontFace}", FaceString)
			FinalMessage = FinalMessage:gsub("{FontSize}", SizeString)
			FinalMessage = FinalMessage:gsub("{Message}", Message)
			
			-- Finally, actually display the message
			TextChannel:DisplaySystemMessage(FinalMessage, "MTKv4System")
		else
			error("Could not find appropriate TextChannel, likely because either ChatChannel wasn't configured properly, or TextChatService.CreateDefaultTextChannels is disabled")
		end
	else
		error("Message could not be displayed, could not find TextChannels folder")
	end
end

function DisplayMessageLegacyChat(Message:string, Color:Color3, FancyText:boolean?)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = Message,
		Color = Color,
		Font = (
			FancyText and 
			Config.LegacyChatFancyFontFace or 
			Config.LegacyChatFontFace
		),
		TextSize = (
			FancyText and 
			Config.LegacyChatFancyFontSize or 
			Config.LegacyChatFontSize
		)
	})
end

function m:CreateChatChannel()
	
end

function m:SetRemoteEvents(EventsTable:{[string]:RemoteEvent})
	RemoteEvents = EventsTable
	
	RemoteEvents.GameAnnouncement.OnClientEvent:Connect(function(...)
		m:DisplayMessage(...)
	end)
	RemoteEvents.GameWinAnnouncement.OnClientEvent:Connect(function(...)
		m:DisplayWinMessage(...)
	end)
end

return m
