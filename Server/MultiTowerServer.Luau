-- Written by fanofpixels
-- Modified by Goldfish_Boi for Stageless

-- Get the cool types
local Types = require(script.Types)
type List<T> = Types.List<T>
type Dictionary<T> = Types.Dictionary<T>
type PlayerInfo = Types.PlayerInfo
type TowerRush = Types.TowerRush
type TowerInfo = Types.TowerInfo
type EndingInfo = Types.EndingInfo
type Difficulty = Types.DifficultyInfo

-- Services
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")
local StarterPack = game:GetService("StarterPack")
local BadgeService = game:GetService("BadgeService")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

-- Modules
local LeaderStats = require(script.LeaderStatsManager)
local Attributes = require(script.Attributes)
local Util = require(script.Util)
local Teleport = require(script.Teleport)
local Announcements = require(script.Announcements)
local COLLISION_MAP = require(script.CollisionGroupMap)
local KitSettings = require(ReplicatedStorage.KitSettings)

-- Folders
local GameData = ServerScriptService.GameData
local RealmData = ServerScriptService.RealmData
local TowerFolder:Folder = workspace:WaitForChild("Towers")
local PortalFolder:Folder = workspace:WaitForChild("Portals")
local Markers:Folder = workspace:WaitForChild("Markers")
local ClientObjectsFolder:Folder = ServerStorage:WaitForChild("TowerClientObjects")
local TowerCheckpointsFolder:Folder = ServerStorage:WaitForChild("TowerCheckpoints")
local StarterPackStudio:Folder = ServerStorage:WaitForChild("StarterPackStudio")
local RemotesFolder = ReplicatedStorage:WaitForChild("Communicators")
local EverpresentCOs:Folder = TowerFolder:WaitForChild("EverpresentCOs")::Folder

local playerSettingsTable = {}

-- Remotes
local RemoteEvents:Dictionary<RemoteEvent> = {}
local BindableEvents:Dictionary<RemoteFunction> = {}

local RemoteFunctions:Dictionary<RemoteFunction> = {}

do 
	for k:number, v:Instance in RemotesFolder:GetDescendants() do
		if v:IsA("RemoteEvent") then
			RemoteEvents[v.Name] = v
		elseif v:IsA("BindableEvent") then
			BindableEvents[v.Name] = v
		elseif v:IsA("RemoteFunction") then
			RemoteFunctions[v.Name] = v
		end
	end
end

RemoteEvents.UpdatePlayerDataClient.OnServerEvent:Connect(function(plr, Type, data)
	if Type == "Settings" then
		playerSettingsTable[plr.Name] = data
	end
end)

do --> Collision Groups
	-- first iteration: register collision groups from the map
	for groupName in COLLISION_MAP do
		PhysicsService:RegisterCollisionGroup(groupName)
	end

	-- second iteration: set groups collidable
	for groupName, map in COLLISION_MAP do
		for _, doesNotCollideWith in map do
			PhysicsService:CollisionGroupSetCollidable(groupName, doesNotCollideWith, false)
		end
	end
end
	
-- Game data (including modules supplying)
local Config:Dictionary<any> = require(GameData.Config)
local Towers:Dictionary<TowerInfo> = {}
local Players:Dictionary<PlayerInfo> = {}
local TowerRushes:Dictionary<TowerRush> = require(RealmData.TowerRushes)::Dictionary<TowerRush>
local Difficulties:Dictionary<Difficulty> = require(GameData.Difficulties)::Dictionary<Difficulty>
local WinpadParticles:ParticleEmitter = ServerStorage.WinpadParticles
local Winpads:List<BasePart> = {}
local WinpadMaterials:List<Enum.Material> = require(script.WinpadMaterials)

local clones = {} :: { [Player]: Instance? }
function ReplicatedStorage.Framework.Remotes.Towers.Objects.RequestCOFolder.OnServerInvoke(player: Player, type: string, COFolder: Folder)
	if type == "request" then
		local playerGui = player:WaitForChild("PlayerGui")

		local clonedFolder = COFolder:Clone()
		clonedFolder.Parent = playerGui
		clones[player] = clonedFolder
		return clonedFolder
	elseif type == "cleanup" then
		local clone = clones[player]
		if clone then
			clone:Destroy()
		end
		clones[player] = nil
	end
end

function InitWinpad(TowerName:string, Winpad:BasePart)
	-- Give the winpad it's funny particles
	local Particles:ParticleEmitter = WinpadParticles:Clone()
	Particles.Parent = Winpad
	
	-- Figure out it's EndingID (if it has none, it's "default")
	local EndingID:string = Attributes:GetString(Winpad, "EndingID") or ""
	if EndingID == "" then
		Winpad:SetAttribute("EndingID", TowerName)
		EndingID = TowerName
	end
	
	-- Figure out the acronym of the tower this winpad belongs too
	-- A winpad inside of the tower folder will have this value implicitely figured out automatically (unless explicetely defined otherwise, though I'm not sure why you would want to do that lol)
	-- A winpad outside of the tower folder must explicitely define this property (or else error)
	local ParentTower:string = Attributes:GetString(Winpad, "ParentTower") or ""
	if ParentTower == "" then
		if TowerName == "" then
			error("Could not setup winpad \""..Winpad:GetFullName().."\ because it's parent tower is undefined (and could not be implicitely figured out)")
		end
		Winpad:SetAttribute("ParentTower", TowerName)
	end
	
	-- Get the tower this winpad says it belongs to
	local Tower:TowerInfo? = Towers[TowerName]
	if Tower then
		-- Construct the ending object,
		local Ending:EndingInfo = {
			Name = Attributes:GetString(Winpad,"EndingName") or Tower.Name,
			Difficulty = Attributes:GetString(Winpad,"Difficulty") or Tower.Difficulty,

			BadgeID = Attributes:GetInt(Winpad,"BadgeID") or 0,
			PreventTowerBadge = Attributes:GetBoolean(Winpad,"PreventTowerBadge") or false,

			ParentTower = TowerName,
			WinroomMarker = (
				Attributes:GetString(Winpad,"WinroomMarker") or
				Attributes:GetString(Winpad,"Winroom") or "" -- Backwards compatibility for PadsUltimatum
			)
		}
		
		-- and set it
		Tower.Endings[EndingID] = Ending
		
		local function Touch(Hit:BasePart)
			local IsPlayer:boolean, PlayerName:string = Util:IsPlayerPart(Hit)
			local Player:PlayerInfo = Players[PlayerName]
			if IsPlayer and not Player.TouchEventBusy then
				-- Guard clause to prevent player from winning while dead
				if not Util:IsPlayerAlive(Player.Player.Character) then return end
				
				PlayerTouchedWinpad(PlayerName,TowerName,EndingID)
			end		
		end
		Winpad.Touched:Connect(Touch)
		
	else
		error("Could not setup winpad \""..Winpad:GetFullName().."\ because it's parent tower does not exist")
	end
	
	--  Add the winpad to the list of winpads so we can give it a funny animation later
	table.insert(Winpads,Winpad)
end

function InitTower(TowerFolder:Instance):TowerInfo
	local Acronym:string = TowerFolder.Name
	
	-- Get the SpawnLocation
	local SpawnLocation:Instance? = TowerFolder:FindFirstChild("SpawnLocation")
	if not (SpawnLocation and SpawnLocation:IsA("BasePart")) then
		error(Acronym.." does not have a SpawnLocation!")
	end
	
	-- Get the ClientSidedObjects folder
	local ClientObjects:Instance? = (
		TowerFolder:FindFirstChild("ClientSidedObjects") or 
		ClientObjectsFolder:FindFirstChild(Acronym)
	)
	
	-- Get the Checkpoints
	local CheckpointsFolder:Instance? = (
		TowerFolder:FindFirstChild("Checkpoints") or
		TowerCheckpointsFolder:FindFirstChild(Acronym)
	)
	-- The checkpoints exist but isn't in ServerStorage
	if CheckpointsFolder and CheckpointsFolder.Parent ~= TowerCheckpointsFolder then
		CheckpointsFolder.Parent = TowerCheckpointsFolder
		CheckpointsFolder.Name = Acronym
		
		if Config.CheckpointsWorkspaceWarning then
			Util:Warn(Acronym.." is storing it's checkpoints in the workspace! consider moving the checkpoints folder to ServerStorage.TowerCheckpoints")
		end
	end
	local CheckpointsList:{BasePart} = {}
	local CheckpointCount:number = 0
	if CheckpointsFolder then
		-- There is a checkpoints folder! get it's contents
		for k:number,v:Instance in CheckpointsFolder:GetChildren() do
			local CheckpointName:string = tostring(k)
			local Checkpoint:Instance? = CheckpointsFolder:FindFirstChild(CheckpointName)
			if Checkpoint then
				if Checkpoint:IsA("BasePart") then
					table.insert(CheckpointsList,Checkpoint)
				else
					error(Acronym..": Checkpoint "..CheckpointName.." is not a BasePart")
				end
			else
				error(Acronym..": Could not find checkpoint "..CheckpointName)
			end
			CheckpointCount += 1
		end
	end
	-- No checkpoints found, throw a warning
	if (CheckpointCount == 0) and Config.CheckpointsMissingWarning then
		Util:Warn(Acronym.." has no checkpoints!")
	end
	
	-- Construct the tower object
	local Tower:TowerInfo = {
		Name = Attributes:GetString(TowerFolder,"ProperName") or Acronym,
		Difficulty = Attributes:GetString(TowerFolder,"Difficulty") or "default",
		BadgeID = Attributes:GetInt(TowerFolder,"BadgeID") or 0,
		
		Folder = TowerFolder,
		SpawnLocation = SpawnLocation::BasePart,
		ClientObjects = ClientObjects,
		
		Endings = {},
		
		MinimumTime = Attributes:GetNumber(TowerFolder,"MinimumTime") or 0,
		Checkpoints = CheckpointsList,
		CheckpointCount = CheckpointCount
		
	}
	-- If the tower has client objects (which it most likely has), send it to the COFolder
	if Tower.ClientObjects then
		Tower.ClientObjects.Parent = ClientObjectsFolder
		Tower.ClientObjects.Name = Acronym
	end
	
	-- Having no minimum time is a security risk, warn the user for that
	if Tower.MinimumTime == 0 and Config.NoMinimumTimeWarning then
		Util:Warn(Acronym.." has no minimum time, it is vulnerable to being cheesed!")
	end
	
	-- Register the tower object
	Towers[Acronym] = Tower
	
	-- Initialize the winpads
	-- We do this after registering it so that the winpad may reference it
	for k:number, v:Instance in TowerFolder:GetDescendants() do
		if v.Name == "WinPad" and v:IsA("BasePart") then
			InitWinpad(Acronym,v)
		end
	end
	
	return Tower
end

function InitTowers()
	for k:number, v:Instance in TowerFolder:GetChildren() do
		InitTower(v)
	end
end

function InitMarker(Marker:BasePart)
	if Marker.Name == "LobbyTP" then
		
		-- Find the lobby spawn
		local SpawnLocation:Instance = Markers:WaitForChild("SpawnLocation")
		if not (SpawnLocation and SpawnLocation:IsA("BasePart")) then
			error("Could not initialize LobbyTP because a SpawnLocation couldn't be found")
		end
		
		-- When touched, teleport the player to the lobby spawn
		local function Touch(Hit:BasePart)
			local IsPlayer:boolean, PlayerName:string = Util:IsPlayerPart(Hit)
			if IsPlayer then
				local Player = Players[PlayerName]
				Player.Player.Team = Teams.Start
				Teleport:TeleportPlayerToPart(Player.Player,SpawnLocation::BasePart)
			end
		end
		Marker.Touched:Connect(Touch)
	end
end

function InitMarkers()
	for k:number, v:Instance in Markers:GetChildren() do
		if v:IsA("BasePart") then
			InitMarker(v)
		end
	end
end

local LegacyTowerRushes:number = 0
function ConvertLegacyTowerRush(Module:ModuleScript):string
	local TowerRushData:any = require(Module)::any
	local TowerRush:TowerRush = {
		BadgeID = TowerRushData.BadgeID,
		Title = TowerRushData.ProperName,
		Difficulty = "unknown",
		WinroomMarker = "",
		
		Towers = {},
	}
	for i:number = 1, #TowerRushData, 1 do
		local TowerName:string = TowerRushData[i]
		table.insert(TowerRush.Towers, TowerName)
	end
	
	LegacyTowerRushes +=1
	local TowerRushName:string = "Unnamed" .. tostring(LegacyTowerRushes)
	
	TowerRushes[TowerRushName] = TowerRush
	return TowerRushName
end

local portalDb = false

function InitPortal(PortalPart:BasePart) 
	local TowerVal:Instance? = PortalPart:FindFirstChild("TowerPortal")
	local TowerRushVal:Instance? = PortalPart:FindFirstChild("TowerRush")
	local LegacyTowerRush:Instance? = PortalPart:FindFirstChild("TowerRushPortal")
	local LobbyTeleporter:Instance? = PortalPart:FindFirstChild("LobbyTeleporter")
	
	if TowerVal and TowerVal:IsA("StringValue") then
		-- The part is a tower portal that loads a single tower
		
		-- Relying on Lua closure for this to work
		local function Touch(Hit:BasePart)
			-- When the portal is touched, check to see if a player touched it, if so, load the appropriate tower
			local IsPlayer:boolean, PlayerName:string = Util:IsPlayerPart(Hit)
			if IsPlayer then
				if portalDb == true then return end
				
				portalDb = true
				-- A player touched this portal, load the appropriate tower
				PortalCutscene(PlayerName, PortalPart, "")
				
				if playerSettingsTable[PlayerName]["PortalTransitions"] and playerSettingsTable[PlayerName]["PortalTransitions"] == true then
					task.wait(2)
				end
				
				PlayerLoadTower(PlayerName,TowerVal.Value, true)
				
				portalDb = false
			end
		end
		PortalPart.Touched:Connect(Touch)
		
	elseif TowerRushVal and TowerRushVal:IsA("StringValue") then
		-- The part is a tower rush portal, and the tower rush must be loaded, aswell as it's first tower
		
		local function Touch(Hit:BasePart)
			local IsPlayer:boolean, PlayerName:string = Util:IsPlayerPart(Hit)
			if IsPlayer then
				if portalDb == true then return end

				portalDb = true
				-- A player touched this portal, load the appropriate tower rush
				PortalCutscene(PlayerName, PortalPart, TowerRushVal.Value)

				if playerSettingsTable[PlayerName]["PortalTransitions"] and playerSettingsTable[PlayerName]["PortalTransitions"] == true then
					task.wait(2)
				end
				
				PlayerLoadTowerRush(PlayerName,TowerRushVal.Value)
				
				portalDb = false
			end
		end
		PortalPart.Touched:Connect(Touch)
	elseif LegacyTowerRush and LegacyTowerRush:IsA("ModuleScript") then
		-- The part is a V3 tower rush, load it into the a V4 tower rush
		
		local TowerRushName:string = ConvertLegacyTowerRush(LegacyTowerRush)
		
		local function Touch(Hit:BasePart)
			local IsPlayer:boolean, PlayerName:string = Util:IsPlayerPart(Hit)
			if IsPlayer then
				-- A player touched this portal, load the appropriate tower rush
				PortalCutscene(PlayerName, PortalPart, "")

				if playerSettingsTable[PlayerName]["PortalTransitions"] and playerSettingsTable[PlayerName]["PortalTransitions"] == true then
					task.wait(2)
				end
				
				PlayerLoadTowerRush(PlayerName,TowerRushName)
			end
		end
		PortalPart.Touched:Connect(Touch)
	elseif LobbyTeleporter and LobbyTeleporter:IsA("StringValue") then
		-- The part is a lobby teleporter, find the part being referened in the markers folder and have it teleport players to that part
		local TargetPartName:string = LobbyTeleporter.Value
		local TargetPart:Instance? = Markers:FindFirstChild(LobbyTeleporter.Value, true)
		
		-- If the part being referenced exists, do stuff, otherwise, error
		if TargetPart and TargetPart:IsA("BasePart") then
			local function Touch(Hit:BasePart) 
				local IsPlayer:boolean, PlayerName:string = Util:IsPlayerPart(Hit)
				local Player:PlayerInfo = Players[PlayerName]
				if IsPlayer and not Player.TouchEventBusy then
					if portalDb == true then return end

					portalDb = true
					
					Player.TouchEventBusy = true
					Teleport:TeleportPlayerToPart(Player.Player, TargetPart)
					Player.TouchEventBusy = false
					
					task.wait(1)
					
					portalDb = false
				end
			end
			PortalPart.Touched:Connect(Touch)
		else
			Util:Warn("Could not setup teleporter \""..PortalPart:GetFullName().."\" because it does not reference a BasePart")
		end
	else
		-- The part isn't anything that should be in the portals folder
		Util:Warn("Part \""..PortalPart.Name.."\" was found in the portal folder but it isn't a portal")
	end
end

function InitPortals() 
	for k:number, v:Instance in PortalFolder:GetChildren() do
		if v:IsA("BasePart") then
			InitPortal(v)
		end
	end
end

function PortalCutscene(playerName:string, PortalPart, AdditionalData)
	local Player:PlayerInfo = Players[playerName]
	
	--RemoteEvents.CorrectAvatar:Fire(game.Players:FindFirstChild(playerName), game.Players:FindFirstChild(playerName).Character)
	
	if PortalPart:FindFirstChild("TowerRush") then
		RemoteEvents.Effect:FireClient(Player.Player, PortalPart, "TowerRush", TowerRushes[AdditionalData].Title)
	else
		RemoteEvents.Effect:FireClient(Player.Player, PortalPart, "Portal")
	end
end

function EverpresentCOsRequested(PlayerInstance:Player):(boolean,Folder?)
	local Player:PlayerInfo? = Players[PlayerInstance.Name]
	if Player then
		-- Prevent prevent potential DOS attack lol
		if Player.HasEverpresentCOs then
			return false,nil 
		end
		
		local PlayerECOs:Folder = EverpresentCOs:Clone()
		PlayerECOs.Parent = PlayerInstance
		
		Player.HasEverpresentCOs = true
		return true, PlayerECOs
	end
	return false, nil
end

-- Loads a tower by loading the COs, teleporting the player to the tower, and resetting their timer if needed
function PlayerLoadTower(PlayerName:string,TowerName:string, ResetTimer:boolean, Time:number)
	-- Get the player and tower info objects being referenced
	local Player:PlayerInfo? = Players[PlayerName]
	local Tower:TowerInfo? = Towers[TowerName]
	
	RemoteEvents.UnloadTower:FireClient(Player.Player)
	
	if Player and Tower then
		-- If the player is already currently loading a tower, don't do it twice
		if Player.IsLoadingTower then return end
		
		-- Set the player object's properties appropriately
		if ResetTimer then
			Player.TowerTimer = 0
			Player.BoostItemUsed = false
			Player.BoostItemNames = {}
		end
		
		if TowerFolder:HasTag("NoBoosts") then
			Tower.BoostsAllowed = false
		else 
			Tower.BoostsAllowed = true
		end
		
		if TowerFolder:HasTag("NoVM") then
			Tower.VMAllowed = false
		else 
			Tower.VMAllowed = true
		end
		
		Player.CurrentTower = TowerName
		Player.CurrentTowerCheckpoint = 1
		-- "this player is currently loading a tower, do not attempt to load a tower while this tower loading is in progress"
		Player.IsLoadingTower = true
		Tower.BarrierCreated = false
		
		-- Forcefully load the character
		-- should disrupt natural respawning
		Player.Player:LoadCharacter()
		repeat
			wait(0.05)
		until Player.Player.Character
		local Character:Model? = Player.Player.Character
		if Character then
			-- Destroy the forcefield if present
			local ForceField:Instance? = Character:FindFirstChildOfClass("ForceField")
			if ForceField then ForceField:Destroy() end
			
			-- Teleport the player to the tower
			Teleport:TeleportPlayerToPartWithWait(Player.Player, Tower.SpawnLocation)
		end
		
		-- Delete the ClientSidedObjects folder from the player if it exists, which in this case, shouldn't
		local OldCOFolder:Instance? = Player.Player:FindFirstChild("ClientSidedObjects")
		if OldCOFolder then
			OldCOFolder:Destroy()
		end
		
		-- Send over the client objects if they exist
		-- (If they don't, the tower is truely purist)
		local Purist:boolean = true
		if Tower.ClientObjects then
			Purist = false
			local COFolder:Instance = Tower.ClientObjects:Clone()
			COFolder.Name = "ClientSidedObjects"
			COFolder.Parent = Player.Player
		end
		
		if not Time then
			BindableEvents.IncrementGlobalData:Fire(TowerName, "Attempt")
			BindableEvents.UpdatePlayerData:Fire(TowerName, "Attempt")
		else
			BindableEvents.IncrementGlobalData:Fire(TowerName, "Attempt", Time)
			BindableEvents.UpdatePlayerData:Fire(TowerName, "Attempt", Time)
		end
		
		game:BindToClose(function()
			BindableEvents.IncrementGlobalData:Fire(TowerName, nil, Player.TowerTimer)
			BindableEvents.UpdatePlayerData:Fire(TowerName, nil, Player.TowerTimer)
		end)
		
		RemoteEvents.LoadTower:FireClient(Player.Player, TowerName, Purist, ResetTimer)
		
		Player.IsLoadingTower = false
	end
	if not Tower then
		Util:Warn("Unknown tower \""..TowerName.."\"")
	end
end

function returnCurrentTower(Plr, PlayerName)
	local Player:PlayerInfo? = Players[PlayerName]
	
	if Player then
		return Player.CurrentTower
	end
end

RemoteFunctions.RequestCurrentTower.OnServerInvoke = returnCurrentTower

function PlayerLoadTowerRush(PlayerName:string, TowerRushName:string)
	-- Get the player and tower rush info objects being referenced
	local Player:PlayerInfo? = Players[PlayerName]
	local TowerRush:TowerRush? = TowerRushes[TowerRushName]
	
	if Player and TowerRush then
		-- If the player is already currently loading a tower, don't load this tower rush again
		if Player.IsLoadingTower then return end
		
		-- Set the player info's appropriate information
		Player.CurrentTowerRush = TowerRushName
		Player.CurrentTowerRushIndex = 1
		Player.BoostItemUsed = false
		Player.BoostItemNames = {}
		
		-- Get the first tower in the tower rush and load it
		local FirstTower:string = TowerRush.Towers[1]
		local TowerCount:number = #TowerRush.Towers
		PlayerLoadTower(PlayerName,FirstTower, true)
		RemoteEvents.UpdateTowerRush:FireClient(Player.Player, 1, TowerCount)
		
		task.wait(5)
		
		RemoteEvents.Effect:FireClient(Player.Player, FirstTower, "Advance", workspace.Towers:FindFirstChild(FirstTower).ProperName.Value)
	end
	if not TowerRush then
		Util:Warn("Unknown tower rush \""..TowerRushName.."\"")
	end
end

function TeleportToWinroom(Player:PlayerInfo,WinroomMarker:string) 
	Player.TouchEventBusy = true
	
	if Player.Player.Character.Humanoid:FindFirstChild("JumpBoost") then
		Player.Player.Character.Humanoid.JumpBoost:Destroy()
	end
	if Player.Player.Character.Humanoid:FindFirstChild("SpeedBoost") then
		Player.Player.Character.Humanoid.SpeedBoost:Destroy()
	end
	
	-- Send player to the winner team and unload the current tower
	Player.Player.Team = Teams.Winners
	RemoteEvents.UnloadTower:FireClient(Player.Player)

	-- Clean up the player info
	ResetPlayerInfo(Player)
	
	-- Find the winroom
	local WinroomPart:Instance?
	if WinroomMarker ~= "" then
		WinroomPart = Markers:FindFirstChild(WinroomMarker,true)
	else
		WinroomPart = Markers:FindFirstChild("WinroomSpawn",true)
	end
	
	-- Teleport to the winroom
	if WinroomPart and WinroomPart:IsA("BasePart") then
		Teleport:TeleportPlayerToPartWithWait(Player.Player,WinroomPart)
	end

	Player.TouchEventBusy = false
end

function AdvanceTowerRush(PlayerName:string)
	local Player:PlayerInfo? = Players[PlayerName]
	if Player then
		
		local TowerRush:TowerRush? = TowerRushes[Player.CurrentTowerRush]
		if TowerRush then
			
			local TowerCount:number = #TowerRush.Towers
			
			if Player.CurrentTowerRushIndex == TowerCount then
				-- The player is at the end of the tower rush
				
				-- Win announcement
				local EndingDifficulty:Difficulty = Util:GetDifficulty(TowerRush.Difficulty)
				Announcements:WinAnnouncement(
					Player,
					TowerRush.Title,
					TowerRush.Difficulty
				)
				
				if TowerRush.BadgeID ~= 0 then
					RemoteEvents.Notification:FireClient(Player.Player, "Badge", TowerRush.BadgeID)
					BadgeService:AwardBadge(Player.Player.UserId, TowerRush.BadgeID)
				end
				
				BindableEvents.IncrementGlobalData:Fire(TowerRush.Title, "Win", Player.TowerTimer)
				BindableEvents.UpdatePlayerData:Fire(TowerRush.Title, "Win", Player.TowerTimer)
				
				RemoteEvents.EffectEvent:FireClient(Player.Player, script.Parent, "Win", nil)
				
				if playerSettingsTable[PlayerName]["FadeToWhiteOnWin"] and playerSettingsTable[PlayerName]["FadeToWhiteOnWin"] == true then
					task.wait(5)
				end
				
				TeleportToWinroom(Player,TowerRush.WinroomMarker)
				RemoteEvents.OnTowerWin:FireClient(Player.Player, TowerRush.Title, TowerRush.Difficulty)
			else
				-- The player is not at the end yet
				-- Advance to the next tower
				Player.CurrentTowerRushIndex += 1
				
				-- And load it
				local TowerName:string = TowerRush.Towers[Player.CurrentTowerRushIndex]
				PlayerLoadTower(PlayerName, TowerName, false)
				RemoteEvents.UpdateTowerRush:FireClient(Player.Player, Player.CurrentTowerRushIndex, TowerCount)
				
				RemoteEvents.Effect:FireClient(Player.Player, TowerName, "Advance", workspace.Towers:FindFirstChild(TowerName).ProperName.Value)
			end
		end	
	end
end

function PlayerTouchedWinpad(PlayerName:string, TowerName:string, EndingID:string)
	local Player:PlayerInfo = Players[PlayerName]
	local Tower:TowerInfo = Towers[TowerName]
	if Player and Tower then
		if Player.TouchEventBusy then return end
		Player.TouchEventBusy = true
		
		local Ending:EndingInfo = Tower.Endings[EndingID]
		if Ending then
			if Player.CurrentTower == "" then 
				Player.TouchEventBusy = false
				return 
			end
			-- Check to see if this ending is from this tower, if it's not, the player is probably cheating
			if Ending.ParentTower ~= Player.CurrentTower then
				Announcements:AntiCheatKick(Player.Player, "Touched the winpad of a tower you're not in")
				return	
			end	
			
			-- Anything checks inside this block do not apply if the player has equipped a debug item
			if not Player.DebugItemUsed then
				-- If the player completed the tower before the minumum time, they beat the tower too early! they must be cheating
				if (Tower.MinimumTime > 0) and (Player.TowerTimer < Tower.MinimumTime) then
					Announcements:AntiCheatKick(Player.Player, "Completed the tower too early")
					return	
				end
				
				-- If the player hasn't hit the checkpoints in order, they beat the tower out of order!
				if Player.CurrentTowerCheckpoint < Tower.CheckpointCount then
					Announcements:AntiCheatKick(Player.Player, "Completed the tower out of order")
					return	
				end
			end
			
			if Tower.Folder:HasTag("NoBoosts") and Player.BoostItemUsed == true then
				return
			end
			
			if Tower.Folder:HasTag("NoVM") and Player.VMUsed == true then
				return
			end
			
			print(Player.BoostItemUsed)
			print(Player.VMUsed)
			
			if Player.CurrentTowerRush == "" then
				-- The player is doing a singular tower
				
				-- The info that will be used in the win message
				local EndingDifficultyName = Tower.Difficulty
				local EndingName:string = Tower.Name
				local EndingWinroom:string = ""
				
				-- Override it if this isn't the default ending
				if EndingID ~= TowerName then
					EndingDifficultyName = Ending.Difficulty
					EndingName = Ending.Name
					EndingWinroom = Ending.WinroomMarker
				end
				local EndingDifficulty:Difficulty = Util:GetDifficulty(EndingDifficultyName)
				
				Announcements:WinAnnouncement(
					Player,
					EndingName,
					EndingDifficultyName
				)
				
				print(Player.TowerTimer)
				
				-- Award badge(s)
				
				if Tower.BadgeID ~= 0 and not Ending.PreventTowerBadge then
					print("Guh")
					RemoteEvents.Notification:FireClient(Player.Player, "Badge", Tower.BadgeID)
					BadgeService:AwardBadge(Player.Player.UserId, Tower.BadgeID)
				end
				if Ending.BadgeID ~= 0 then
					RemoteEvents.Notification:FireClient(Player.Player, "Badge", Ending.BadgeID)
					BadgeService:AwardBadge(Player.Player.UserId, Ending.BadgeID)
				end
				
				BindableEvents.IncrementGlobalData:Fire(TowerName, "Win", Player.TowerTimer)
				BindableEvents.UpdatePlayerData:Fire(TowerName, "Win", Player.TowerTimer)
				
				RemoteEvents.Effect:FireClient(Player.Player, script.Parent, "Win", nil)
				
				if playerSettingsTable[PlayerName]["FadeToWhiteOnWin"] and playerSettingsTable[PlayerName]["FadeToWhiteOnWin"] == true then
					task.wait(5)
				end
				
				TeleportToWinroom(Player,EndingWinroom)
				RemoteEvents.OnTowerWin:FireClient(Player.Player, Tower.Name, Tower.Difficulty)
			else
				-- The player is doing a tower rush
				AdvanceTowerRush(PlayerName)
			end
			
			RemoteEvents.ResetLighting:FireClient(Player.Player)
		else
			error(PlayerName.." touched a winpad in "..TowerName..", but the ending referenced does not exist")
		end
		
		task.wait(0.1)
		Player.TouchEventBusy = false
	end
end

function PlayerRequestedRestart(PlayerInstance:Player, Type:string)
	local Player:PlayerInfo = Players[PlayerInstance.Name]
	
	RemoteEvents.ResetLighting:FireClient(Player.Player)
	
	-- If the player is attempting to restart after the cooldown has ended
	if Player.GameTimer - Player.LastRestart >= Config.RestartCooldown then
		Player.LastRestart = Player.GameTimer
		
		-- The player isn't even in a tower
		if Player.CurrentTower == "" then return end
		if Player.CurrentTowerRush == "" then
			PlayerLoadTower(PlayerInstance.Name,Player.CurrentTower,true, Player.TowerTimer)
		else
			if Type == "Death" then
				PlayerLoadTowerRush(PlayerInstance.Name,Player.CurrentTowerRush, Player.TowerTimer)
			else
				PlayerLoadTower(PlayerInstance.Name,Player.CurrentTower,true, Player.TowerTimer)
			end
		end
	end
end

function PlayerEquippedTool(Player:PlayerInfo, Item:Tool)
	local barrierCreated:boolean = false
	local BoostUsed:boolean
	local VMUsed:boolean
	local IsDebugItem:boolean? = Item:GetAttribute("DebugItem")
	local BoostName:string? = Item:GetAttribute("BoostName")
	
	if BoostName and BoostName == "Vertical Mobility" then
		Player.VMUsed = true
		VMUsed = BoostName and BoostName ~= "" or false
	elseif BoostName and BoostName ~= "Vertical Mobility" then
		Player.BoostItemUsed = true
		BoostUsed = BoostName and BoostName ~= "" or false
	end
	
	-- If this is a debug item OR a boost item, we should effectively disable checkpoints
	-- Because boosts and debug items let a player fairly bypass checkpoints, so if they do equip an item, it would be unreasonable to kick them	
	if IsDebugItem or BoostUsed or VMUsed then
		Player.DebugItemUsed = true
	end
	if BoostUsed or VMUsed then
		Player.BoostItemNames[Item.Name] = BoostName or "Boost Item"
	end
	
	if Player.CurrentTower ~= "" then
		local tower:TowerInfo = Towers[Player.CurrentTower]
		
		if tower.BarrierCreated == false then
			if BoostUsed then
				if tower.Folder:HasTag("NoBoosts") then
					RemoteEvents.CreateBarrier:FireClient(Player.Player, tower.Folder:FindFirstChild("WinPad"))
					tower.BarrierCreated = true
				end
			elseif VMUsed then
				if tower.Folder:HasTag("NoVM") then
					RemoteEvents.CreateBarrier:FireClient(Player.Player, tower.Folder:FindFirstChild("WinPad"))
					tower.BarrierCreated = true
				end
			end
		end
	end
end

function CharacterAdded(Character:Model)
	local Humanoid:Humanoid? = Character:FindFirstChildOfClass("Humanoid")
	local Player:PlayerInfo? = Players[Character.Name]
	
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 and Config.R15Warning then
			Util:Warn("Character spawned with R15 rig type, most obbying techniques are impossible. Ensure that the rig type is R6 in game settings.")
		end
		
		if Player then
			Humanoid.Died:Connect(function()
				RemoteEvents.ResetLighting:FireClient(Player.Player)
			end)
		end
	end
	
	if Player then
		
		-- When the player equips a tool
		Character.ChildAdded:Connect(function(Item:Instance)
			if Item:IsA("Tool") then
				PlayerEquippedTool(Player,Item)
			end
		end)
		
		-- If the player is simply loading a tower in, we shouldn't be immediately unloading stuff, so don't
		if Player.IsLoadingTower then return end
		
		-- No need to call other events like UpdateTowerRush as the client will do so automatically
		RemoteEvents.UnloadTower:FireClient(Player.Player)
		ResetPlayerInfo(Player)
	end
end

function exitTower(plr:Player)
	local Player:PlayerInfo? = Players[plr.Name]
	
	if Player.CurrentTower ~= "" then
		BindableEvents.IncrementGlobalData:Fire(Player.CurrentTower, nil, Player.TowerTimer)
		BindableEvents.UpdatePlayerData:Fire(Player.CurrentTower, nil, Player.TowerTimer)

		if not Player.TouchEventBusy then
			Player.TouchEventBusy = true
			Teleport:TeleportPlayerToPart(Player.Player, Markers.SpawnLocation)
			Player.TouchEventBusy = false
		end
		
		RemoteEvents.ResetLighting:FireClient(Player.Player)
		RemoteEvents.UnloadTower:FireClient(Player.Player)
		ResetPlayerInfo(Player)
	end
end

function ResetPlayerInfo(Player:PlayerInfo)
	Player.TowerTimer = 0
	Player.CurrentTower = ""
	Player.CurrentTowerCheckpoint = 0
	Player.CurrentTowerRush = ""
	Player.CurrentTowerRushIndex = 0
	Player.BoostItemNames = {}
	Player.BoostItemUsed = false
	Player.DebugItemUsed = false
end

function PlayerAdded(PlayerInstance:Player)
	LeaderStats:InitPlayer(PlayerInstance)
	local Info:PlayerInfo = {
		Player = PlayerInstance,
		GameTimer = 0,
		LastRestart = 0,
		
		CurrentTower = "",
		CurrentTowerCheckpoint = 0,
		BoostItemNames = {},
		BoostItemUsed = false,
		TowerTimer = 0,
		
		CurrentTowerRush = "",
		CurrentTowerRushIndex = 0,
		
		TouchEventBusy = false,
		IsLoadingTower = false,
		HasEverpresentCOs = false,
		DebugItemUsed = false
	}
	Players[PlayerInstance.Name] = Info
	
	if PlayerInstance.Character then
		CharacterAdded(PlayerInstance.Character)
	end
	PlayerInstance.Team = Teams.Start
	PlayerInstance.CharacterAdded:Connect(CharacterAdded)
end

function PlayerRemoving(PlayerInstance:Player)
	local Player:PlayerInfo? = Players[PlayerInstance.Name]
	
	if Player.CurrentTower ~= "" then
		BindableEvents.IncrementGlobalData:Fire(Player.CurrentTower, nil, Player.TowerTimer)
		BindableEvents.UpdatePlayerData:Fire(Player.CurrentTower, nil, Player.TowerTimer)
	end
	
	Players[PlayerInstance.Name] = nil
	playerSettingsTable[PlayerInstance.Name] = nil
end

function Step(Time:number,DeltaTime:number)
	
	-- For every player
	for k:string, v:PlayerInfo in Players do
		
		-- Increment the time spent ingame..
		-- and the time spend in the tower, if in one
		v.GameTimer += DeltaTime
		if v.CurrentTower ~= "" then
			local OldTowerTimer:number = v.TowerTimer
			v.TowerTimer += DeltaTime
			
			local I:number = Config.TimerSyncInterval
			local A:number = math.floor(OldTowerTimer / I) * I
			local B:number = math.floor(v.TowerTimer / I) * I
			if B > A then
				RemoteEvents.UpdateTowerTimer:FireClient(v.Player,v.TowerTimer)
			end
		end
		-- Update the leaderboard respectively 
		LeaderStats:SetPlayerGameTime(v.Player.Name,v.GameTimer)
		
		-- Checkpoint detection
		local PrevInterval:number = math.floor((Time - DeltaTime) / Config.CheckpointInterval) * Config.CheckpointInterval
		local CurrentInterval:number = math.floor(Time / Config.CheckpointInterval) * Config.CheckpointInterval
		if PrevInterval < CurrentInterval then
			local Character:Model? = v.Player.Character
			-- If the player is in a tower
			if v.CurrentTower ~= "" and Character then
				local Tower:TowerInfo = Towers[v.CurrentTower]
				local Checkpoint:BasePart? = Tower.Checkpoints[v.CurrentTowerCheckpoint]
				if Checkpoint then
					local Point:Vector3 = Character:GetPivot().Position
					local Touching:boolean = Util:IsPointInPart(Point, Checkpoint)
					if Touching then
						v.CurrentTowerCheckpoint += 1
					end
				end
			end
		end
	end
	
	-- Winpad animation
	do
		-- If the animation time of a winpad has passed
		local PrevInterval:number = math.floor((Time - DeltaTime) / Config.WinpadInterval) * Config.WinpadInterval
		local CurrentInterval:number = math.floor(Time / Config.WinpadInterval) * Config.WinpadInterval
		if PrevInterval < CurrentInterval then
			for k:number, v:BasePart in Winpads do
				if Config.WinpadsChangeColor then
					v.Color = Color3.fromHSV(math.random(0,100)/100,1,1)
				end

				if Config.WinpadsChangeMaterial then
					v.Material = WinpadMaterials[math.random(1,#WinpadMaterials)]
				end
			end
		end
	end
end

local types={
	Normal=5,
	HighDamage=20,
	Instakill=math.huge, --scary number
}

do --> Damage Event
	local debounceArray = {} :: { [Player]: boolean? }
	ReplicatedStorage.DamageEvent.OnServerEvent:Connect(function(player: Player, type: string | number)
		if debounceArray[player] then
			return
		end

		local character = player.Character
		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		
		
		local damageValue = if typeof(type) == "number" then type else 5
		if type == "Heals" then
			damageValue = -(humanoid.MaxHealth - humanoid.Health)
		end

		if damageValue > 0 then -- no debounce for healing
			debounceArray[player] = true
			task.delay(0.1, function()
				debounceArray[player] = nil
			end)
		end

		humanoid:TakeDamage(damageValue)
		if humanoid.Health > humanoid.MaxHealth then
			humanoid.Health = humanoid.MaxHealth
		end
	end)
end

PlayersService.PlayerAdded:Connect(PlayerAdded)
PlayersService.PlayerRemoving:Connect(PlayerRemoving)
RemoteEvents.RestartRequested.OnServerEvent:Connect(PlayerRequestedRestart)
RemoteEvents.ExitRequested.OnServerEvent:Connect(exitTower)
RemoteFunctions.RequestEverpresentCOs.OnServerInvoke = EverpresentCOsRequested
RunService.Stepped:Connect(Step)

RemoteEvents.RespawnPlayer.OnServerEvent:Connect(function(plr)
	plr:LoadCharacter()
end)

do
	if RunService:IsStudio() then
		for k:number, v:Instance in StarterPackStudio:GetChildren() do
			v:SetAttribute("DebugItem",true)
			v.Parent = StarterPack
		end
	end
	-- Make sure all tools are tagged with the attribute, since a StringValue isn't secure
	for k:number,v:Instance in StarterPack:GetChildren() do
		if not v:IsA("Tool") then continue end
		local BoostNameValue:Instance? = v:FindFirstChild("BoostName")
		if BoostNameValue and BoostNameValue:IsA("StringValue") then
			Util:Warn("Boost item "..v.Name.." uses a StringValue for BoostName, please change it to an attribute, as a StringValue can be manipulated (or even deleted) by the client")
			v:SetAttribute("BoostName",BoostNameValue.Value)
		end
	end
	
	script.Initiated:Fire()
	
	Util:Init(RemoteEvents,GameData)
	Announcements:Init(RemoteEvents,GameData)	
	
	EverpresentCOs.Parent = ServerStorage
	
	InitTowers()
	InitPortals()
	InitMarkers()
end
