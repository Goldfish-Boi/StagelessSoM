--== Multi-Tower Kit Client Config ==--

return {
	-- What does the win announcement look like?
	WinMessage = "{PlayerName} has beaten {EndingName} in {Time}{BoostsUsed}",

	-- How will it display what boosts the player used?
	-- Setting this to an empty string effectively disables showing boosts used
	WinMessageBoostsUsed = ", Boosts used: {BoostList}",
	
	--==  IMPORTANT ==--
	-- if TextChatService.ChatVersion is set to LegacyChatService, change the legacy chat properties
	-- otherwise if it's TextChatService, change the ones below it
	
	-- The font to use for normal system messages in the legacy chat system
	LegacyChatFontFace = Enum.Font.SourceSansBold,
	LegacyChatFontSize = 18,
	
	-- The font to use for fancy system messages in the legacy chat system
	LegacyChatFancyFontFace = Enum.Font.Bodoni,
	LegacyChatFancyFontSize = 20,
	
	--== MODERN CHAT SYSTEM CONFIG==--
	
	-- The XML tag to wrap the win message in for the modern chat system
	ChatFont = "<font color='{FontColor}' size='{FontSize}' face='{FontFace}'>{Message}</font>",
	
	-- The chat channel to use for system messages
	ChatChannel = "RBXSystem",
	
	-- The font to use for normal system messages in the legacy chat system
	ChatFontFace = "GothamBold",
	ChatFontSize = 14,

	-- The font to use for fancy system messages in the legacy chat system
	ChatFancyFontFace = "Bodoni",
	ChatFancyFontSize = 18,
	
	
}
