--!strict
-- Written by fanofpixels

local m = {}

local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local LocalPlayer:Player = Players.LocalPlayer
local ColGroupThis = "Player"
local ColGroupOthers = "OtherPlayers"

local function AffectCharacter(Character:Model,ColGroup:string)
	for k:number, v:Instance in Character:GetDescendants() do
		if v:IsA("BasePart") then
			--PhysicsService:SetPartCollisionGroup(v, ColGroup)
			v.CollisionGroup = ColGroup
		end
	end
	Character.DescendantAdded:Connect(function(NewIns:Instance)
		if NewIns:IsA("BasePart") then
			--PhysicsService:SetPartCollisionGroup(NewIns, ColGroup)
			NewIns.CollisionGroup = ColGroup
		end
	end)
end

local function CharacterAdded(Character:Model)
	local ColGroup:string = (Character == LocalPlayer.Character) and ColGroupThis or ColGroupOthers
	AffectCharacter(Character,ColGroup)
end

local function PlayerAdded(Plr:Player)
	if Plr.Character then
		CharacterAdded(Plr.Character)
	end
	Plr.CharacterAdded:Connect(CharacterAdded)
end

function m:Init()
	-- For every player, connect the appropriate events, and set collision groups if their character already exists
	for k:number, v:Player in Players:GetPlayers() do
		PlayerAdded(v)
	end
	
	-- Connect event for when new players join
	Players.PlayerAdded:Connect(PlayerAdded)
	
	-- Make sure the current player's collision is properly changed too
	LocalPlayer.CharacterAdded:Connect(CharacterAdded)
end

return m
