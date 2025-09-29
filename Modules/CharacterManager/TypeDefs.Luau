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

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiManager = ReplicatedStorage.Framework.Kit.Managers.GuiManager

export type __VALID_DAMAGEBRICKS = {
	kills: number,
	double: number,
	ouch: number,
	instakills: number,
    custom: number,
	heals: string,
	[string]: any,
}

--[=[
	@interface BoostData
	@within CharacterManager
	.isPad boolean
	.startTime number
	.mode string
	.type string
	.power number
	.duration number
	.timerDecimals boolean
	.hideGUI boolean
	.startTweenInfo TweenInfo
	.endtweenInfo TweenInfo
	.infinite boolean
	.multiplier number
	.timeLeft number
]=]
export type BoostData = {
	-- used by either
	isPad: boolean,
	type: string,
	power: number,
	frame: typeof(GuiManager.BoostFrame)?, -- created later

	-- values calculated on the fly, stored here to be used in
	-- other scripts using this type
	multiplier: number,
	timeLeft: number,

	-- regular boosters only
	startTime: number,
	mode: string,
	duration: number,
	infinite: boolean,
	timerDecimals: number,
	hideGUI: boolean,
	startTweenInfo: TweenInfo,
	endTweenInfo: TweenInfo,
}

export type CharacterManager = {
	--> BaseController
	Init: (self: CharacterManager) -> CharacterManager,
	__initialized: boolean,

	--> CharacterManager
	VALID_DAMAGEBRICKS: __VALID_DAMAGEBRICKS,

	-- damage functions
	Damage: (self: CharacterManager, damage: BasePart | number | string) -> (),
	ValidateDamageBrick: (self: CharacterManager, brick: BasePart) -> (number | string)?,

	-- helper functions
	GetHumanoid: (self: CharacterManager, player: Player) -> Humanoid?,

	-- booster functions
	StartBoost: (self: CharacterManager, boostData: BoostData) -> (),
	UpdateBoost: (self: CharacterManager, boostData: BoostData, boostEnded: boolean?) -> (),
	RemoveBoost: (self: CharacterManager, boostData: BoostData) -> (),

	GetActiveBoost: (self: CharacterManager, type: string, isPad: boolean?) -> BoostData?,
	GetActiveBoosts: (self: CharacterManager) -> { BoostData },
	IsBoostInfinite: (self: CharacterManager, boostData: BoostData) -> boolean,
}

return nil
