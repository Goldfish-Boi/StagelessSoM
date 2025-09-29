--!strict
-- Written by fanofpixels

-- Not to be confused with the PlayerInfo type in MultiTowerServer
type PlayerInfo = {
	Player:Player,
	LeaderStatsFolder:Folder,
	
	GameTimeStat:NumberValue
}

local m = {}
local Players:{[string]:PlayerInfo} = {}

function m:InitPlayer(PlayerInstance:Player)
	local LeaderStatsFolder:Folder = Instance.new("Folder")
	LeaderStatsFolder.Name = "leaderstats"
	LeaderStatsFolder.Parent = PlayerInstance
	
	local GameTimeStat:NumberValue = Instance.new("NumberValue")
	GameTimeStat.Name = "Time"
	GameTimeStat.Parent = LeaderStatsFolder
	
	local Info:PlayerInfo = {
		Player = PlayerInstance,
		LeaderStatsFolder = LeaderStatsFolder,
		GameTimeStat = GameTimeStat
	}
	Players[PlayerInstance.Name] = Info
end

function m:SetPlayerGameTime(Name:string,Time:number)
	local Info:PlayerInfo? = Players[Name]
	if Info then
		Info.GameTimeStat.Value = math.floor(Time)
	end
end

return m
