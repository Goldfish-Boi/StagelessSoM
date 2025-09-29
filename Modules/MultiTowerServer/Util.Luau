--!strict
-- Written by fanofpixels

-- Get types
local Types = require(script.Parent.Types)

type List<T> = Types.List<T>
type Dictionary<T> = Types.Dictionary<T>
type PlayerInfo = Types.PlayerInfo
type TowerRush = Types.TowerRush
type TowerInfo = Types.TowerInfo
type EndingInfo = Types.EndingInfo
type Difficulty = Types.DifficultyInfo

--

local m = {}
local WarningTag:string = "[MTKv4] "

local RemoteEvents:Dictionary<RemoteEvent> = {}
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Config:Dictionary<any> = {}
local Difficulties:Dictionary<Difficulty> = {}

-- If the difficulty specified by something is unknown, fallback to this
local DefaultDifficuty:Difficulty = {
	Title = "unknown",
	Rating = 0,
	Color = Color3.new(1,1,1),
	
	FancyFont = false,
	GlobalAnnouncement = false
}
function m:GetDifficulty(DifficultyName:string):Difficulty
	local Search:Difficulty? = Difficulties[DifficultyName]
	return Search or DefaultDifficuty
end

function m:Warn(Msg:string)
	if Config.Quiet then return end
	warn(WarningTag..Msg)
end

function m:IsPlayerPart(Hit:BasePart):(boolean, string)
	if Hit.Parent and Hit.Parent:FindFirstChild("Humanoid") then
		local Plr:Player? = Players:GetPlayerFromCharacter(Hit.Parent)
		if Plr then
			return true, Plr.Name
		end
	end
	return false, ""
end

function m:IsPlayerAlive(Character:Model?):boolean
	if not Character then return false end
	local Humanoid:Humanoid? = (Character::Model):FindFirstChildOfClass("Humanoid")
	if Humanoid then
		return Humanoid.Health > 0
	end
	return false
end

function m:IsPointInPart(Point:Vector3, Part:BasePart):boolean
	local LocalPoint:Vector3 = Part.CFrame:PointToObjectSpace(Point)
	local UnitPoint:Vector3 = LocalPoint / Part.Size
	return (
		UnitPoint.X <= 0.5 and
		UnitPoint.X >= -0.5 and
		UnitPoint.Y <= 0.5 and
		UnitPoint.Y >= -0.5 and
		UnitPoint.Z <= 0.5 and
		UnitPoint.Z >= -0.5
	)
end

function m:Init(EventsTable:{[string]:RemoteEvent},GameData:Folder)
	RemoteEvents = EventsTable
	
	-- Using ::any to make Luau shut up about "unsupported require path"
	Config = require(GameData:WaitForChild("Config"))::any
	Difficulties = require(GameData:WaitForChild("Difficulties"))::any
end

return m
