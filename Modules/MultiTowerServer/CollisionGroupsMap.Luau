--!strict
--[[
--------------------------------------------------------------------------------
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
⚠️  WARNING - PLEASE READ! ⚠️
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

If you are submitting to EToH: 
PLEASE, **DO NOT** make any script edits to this script. 
This is a core script and any edits you make to this script will NOT work 
elsewhere.

If you have any suggestions, please let us know.
Thank you
--------------------------------------------------------------------------------
]]

local COLLISION_MAP = {
	ClientObjects = {},
	OnlyCollideWithPlayers2 = {
		"Default",
		"DoNotCollideWithPlayers",
		"ClientObjects",
		"NeverCollide",
		"OnlyCollideWithDefault",
		"DoNotCollideWithSelf",
	},
	AlwaysCollide = {},
	DoNotCollideWithPlayers = {},
	OnlyCollideWithDefault = { "NeverCollide", "ClientObjects", "DoNotCollideWithPlayers", "DoNotCollideWithSelf" },
	Player = { "OtherPlayers", "DoNotCollideWithPlayers", "NeverCollide", "OnlyCollideWithDefault" },
	NeverCollide = {
		"NeverCollide",
		"Default",
		"ClientObjects",
		"DoNotCollideWithPlayers",
		"DoNotCollideWithSelf",
		"AlwaysCollide",
	},
	DoNotCollideWithSelf = { "DoNotCollideWithSelf" },
	OnlyCollideWithPlayers = {
		"OnlyCollideWithPlayers",
		"Default",
		"DoNotCollideWithPlayers",
		"ClientObjects",
		"OnlyCollideWithPlayers2",
		"NeverCollide",
		"OnlyCollideWithDefault",
		"DoNotCollideWithSelf",
	},
	OtherPlayers = {
		"ClientObjects",
		"DoNotCollideWithPlayers",
		"OnlyCollideWithPlayers",
		"OnlyCollideWithPlayers2",
		"NeverCollide",
		"AlwaysCollide",
		"OnlyCollideWithDefault",
		"DoNotCollideWithSelf",
	},
} :: { [string]: { string } }

return COLLISION_MAP
