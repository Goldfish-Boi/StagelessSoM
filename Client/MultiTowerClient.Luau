--!strict
-- Written by fanofpixels, Modified by Cheaty123457

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- Folders
local RemotesFolder:Folder = ReplicatedStorage.Communicators

-- Remotes
local RemoteEvents:{[string]:RemoteEvent} = {}
local RemoteFunctions:{[string]:RemoteFunction} = {}
local ResetEffectGui:BindableEvent = RemotesFolder:FindFirstChild("ResetEffectGui", true)::BindableEvent

do 
	for k:number, v:Instance in RemotesFolder:GetDescendants() do
		if v:IsA("RemoteEvent") then
			RemoteEvents[v.Name] = v
		elseif v:IsA("RemoteFunction") then
			RemoteFunctions[v.Name] = v
		end
	end
end
-- Difficulties
local DifColors = {
	['Easy'] = Color3.fromRGB(100,225,75); --Easy
	['Medium'] = Color3.fromRGB(255,255,0); --Medium
	['Hard'] = Color3.fromRGB(225, 115, 0); --Hard
	['Difficult'] = Color3.fromRGB(255,0,0); --Difficult
	['Challenging'] = Color3.fromRGB(170,0,0); --Challanging
	['Intense'] = Color3.fromRGB(50,85,110); --Intense
	['Rage'] = Color3.fromRGB(90, 0, 90); --Rage
	['Remorseless'] = Color3.fromRGB(255,0,225); --Remorseless
	['Treacherous'] = Color3.fromRGB(95, 35, 205); --Treacherous
	['Insane'] = Color3.fromRGB(0,70,255);--Insane
	['Extreme'] = Color3.fromRGB(55,155,255); --Extreme
	['Terrifying'] = Color3.fromRGB(0,255,255);--Terrifying
	['Catastrophic'] = Color3.fromRGB(225,225,225);--Cata
	['Horrific'] = Color3.fromRGB(150,150,255);--Horri
	['Unreal'] = Color3.fromRGB(75,0,255);--Unreal
	['Nil'] = Color3.fromRGB(99, 95, 98);--Nil
};

-- Modules
local ClientObjects = require(script.ClientObjects)
local GUI = require(script.GUI)
local PlayerCollision = require(script.PlayerCollision)
local Announcements = require(script.Announcements)
local Lighting = require(script.Lighting)
local Util = require(script.Util)
local CharacterManager = require(ReplicatedStorage.Framework.Kit.Managers.CharacterManager):Init()
local FlipManager = require(ReplicatedStorage.Framework.Kit.Managers.FlipManager):Init()
local LightingManager = require(ReplicatedStorage.Framework.Kit.Managers.LightingManager):Init()
local ClientObjectManager = require(ReplicatedStorage.Framework.Kit.Managers.ClientObjectManager):Init()
local GuiManager = require(ReplicatedStorage.Framework.Kit.Managers.GuiManager):Init()

-- Misc Stuff
local LocalPlayer = Players.LocalPlayer
local TowerTimer:number = 0
local RestartTime:number = 0
local RestartTimeMax:number = 5
local RestartDebounce:boolean = false
local TimerPaused:boolean = false
local CurrentTower:string = ""

local RequestCOFolder = ReplicatedStorage.Framework.Remotes.Towers.Objects.RequestCOFolder

local ClientParts = workspace:FindFirstChild("ClientParts")
	or (function()
		local newFolder = Instance.new("Folder")
		newFolder.Name = "ClientParts"
		newFolder.Parent = workspace
		return newFolder
	end)()

function LoadTower(Acronym:string, Purist:boolean, ResetTimer:boolean)
	TimerPaused = false
	CurrentTower = Acronym
	if ResetTimer then
		TowerTimer = 0
		GUI:SetBoostsUsed(false)
	end
	local h = workspace.Portals:GetChildren()
	for i = 1,#h do
		if h[i]:FindFirstChild("TowerPortal") ~= nil then
			if h[i].TowerPortal.Value == Acronym then
				GUI:SetTowerColor(DifColors[h[i].Name])
			end
		end
	end
	GUI:SetTowerAcronym(Acronym)
	ResetEffectGui:Fire()
	
	RestartTime = 0
	-- If the restart time is hitting the maximum, enable the debounce so that we don't accidentally restart again
	if RestartTime >= RestartTimeMax then
		RestartDebounce = true
	end
	
	-- If this tower is purist we can skip the client objects
	if not Purist then
		local COFolder:Instance? = LocalPlayer:WaitForChild("ClientSidedObjects", 10)
		
		print(COFolder)
		
		if COFolder then
			-- Let the module dedicated to loading client objects load the client objects
			print(Acronym)
			print(workspace.Towers:FindFirstChild(Acronym):HasTag("v6"))
			
			if workspace.Towers:FindFirstChild(Acronym):HasTag("v6") == true then
				--> Request server for objects
				local customRepository = ReplicatedStorage:FindFirstChild("ExternalRepositories")

				local currentlyLoading = false
				local objectScope
				
				local function requestObjects()
					if currentlyLoading then
						return
					end
					currentlyLoading = true

					local receivedObjects, warnings = RequestCOFolder:InvokeServer("request", COFolder)
					local objects = receivedObjects:Clone()
					receivedObjects:Destroy()
					-- Tell server to clean up objects since they have already been replicated
					RequestCOFolder:InvokeServer("cleanup")

					objectScope = ClientObjectManager:LoadClientObjects(
						objects,
						ClientParts,
						Acronym,
						customRepository:FindFirstChild(Acronym)
					)
					currentlyLoading = false
					receivedObjects = nil
					objects = nil

					if warnings then
						for _, warningTable in warnings do
							objectScope:log(warningTable)
						end
					end
				end
				
				
				requestObjects()
				--ClientObjects:LoadClientObjects(COFolder, false)
			else
				ClientObjects:LoadClientObjects(COFolder, false)
			end
		else
			error("A tower has attempted to loaded in. It wasn't marked as purist but no ClientSidedObjects folder was sent over. Bad internet connection?")
		end
	end
end

function UnloadTower()
	CurrentTower = ""
	TowerTimer = 0
	RestartTime = 0
	
	ResetEffectGui:Fire()
	ClientObjects:UnloadClientObjects()
	ClientObjectManager:UnloadClientObjects()
	
	GUI:SetTowerAcronym("")
	GUI:SetTowerTimer(0)
	GUI:SetTowerRush(0,0)
	GUI:SetBoostsUsed(false)
	GUI:SetRestartLabel(0)
end

-- Should fire every ~2 or so seconds to ensure the client's timer and the server's timer aren't out of sync
-- If they are out of sync, both are using DeltaTime to increment the timer so the margin of error should be very small
function CorrectTimer(Time:number)
	TowerTimer = Time
end

function UpdateTowerRush(Index:number, End:number)
	GUI:SetTowerRush(Index,End)
end

function CharacterAdded(Character:Model)
	Character.ChildAdded:Connect(function(Ins:Instance)
		-- If item equipped:
		if Ins:IsA("Tool") then
			local BoostName:string? = Ins:GetAttribute("BoostName")
			
			-- If this is a boost item and the player is in a tower
			if BoostName and BoostName ~= "" and CurrentTower ~= "" then
				GUI:SetBoostsUsed(true)
			end
		end
	end)
end

function CreateBoostBarrier(Winpad:Instance)
	local BoostBarrier = ReplicatedStorage.Barrier:Clone()
	
	BoostBarrier.Parent = Winpad.Parent
	
	if Winpad:IsA("Part") or Winpad:IsA("MeshPart") or Winpad:IsA("UnionOperation") then
		BoostBarrier.CFrame = Winpad.CFrame
		BoostBarrier.Size = Vector3.new(Winpad.Size.X + 10, Winpad.Size.Y + 10, Winpad.Size.Z + 10)
	elseif Winpad:IsA("Model") then
		local cframe, size = Winpad:GetBoundingBox()
		
		BoostBarrier.CFrame = cframe
		BoostBarrier.Size = Vector3.new(size.X + 10, size.Y + 10, size.Z + 10)
	end
end

local RestartCurrentlyHeld = false

function pauseTimer()
	TimerPaused = true
end

function onCutscene(triggerPart, cutsceneType)
	if cutsceneType == "Win" then
		pauseTimer()
	end
end

function Step(DeltaTime:number)
	if TimerPaused == true then GUI:OpenRestartLabel(false) return end
	
	if CurrentTower == "" then
		TowerTimer = 0
		RestartTime = 0
	else
		TowerTimer += DeltaTime
		
		local PreviousRestartTime:number = RestartTime
		
		-- If the user is holding the restart key, and the debounce is false
		if UserInputService:IsKeyDown(Enum.KeyCode.R) then
			if not RestartDebounce then
				if RestartCurrentlyHeld == false then
					RestartCurrentlyHeld = true
					GUI:OpenRestartLabel(true)
				end
				RestartTime = math.min(RestartTime + DeltaTime, RestartTimeMax)
				if RestartTime >= RestartTimeMax then
					-- Enable the debounce so that we don't spam the server
					RestartDebounce = true
					RemoteEvents.RestartRequested:FireServer()
				end
			end
		else 
			RestartTime = 0
			RestartDebounce = false
			if RestartCurrentlyHeld == true then
				RestartCurrentlyHeld = false
				GUI:OpenRestartLabel(false)
			end
		end
	end
	GUI:SetRestartLabel(RestartTime / RestartTimeMax)
	GUI:SetTowerTimer(TowerTimer)
end

RemoteEvents.UpdateTowerTimer.OnClientEvent:Connect(CorrectTimer)
RemoteEvents.UpdateTowerRush.OnClientEvent:Connect(UpdateTowerRush)
RemoteEvents.LoadTower.OnClientEvent:Connect(LoadTower)
RemoteEvents.UnloadTower.OnClientEvent:Connect(UnloadTower)
RemoteEvents.Effect.OnClientEvent:Connect(onCutscene)
RemoteEvents.CreateBarrier.OnClientEvent:Connect(CreateBoostBarrier)
RunService.RenderStepped:Connect(Step)

do
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	
	PlayerCollision:Init()
	Lighting:Init()
	Announcements:SetRemoteEvents(RemoteEvents)
	
	local ECOs:boolean, ECOFolder:Folder? = RemoteFunctions.RequestEverpresentCOs:InvokeServer()
	if ECOs and ECOFolder then
		--ECOFolder.Parent = workspace
		--ClientObjects:LoadClientObjects(ECOFolder, true)
		
		--> Request server for objects
		local customRepository = ReplicatedStorage:FindFirstChild("ExternalRepositories")

		local currentlyLoading = false
		local objectScope

		local function requestObjects()
			if currentlyLoading then
				return
			end
			currentlyLoading = true

			local receivedObjects, warnings = RequestCOFolder:InvokeServer("request", ECOFolder)
			local objects = receivedObjects:Clone()
			receivedObjects:Destroy()
			-- Tell server to clean up objects since they have already been replicated
			RequestCOFolder:InvokeServer("cleanup")

			objectScope = ClientObjectManager:LoadClientObjects(
				objects,
				ClientParts,
				"Everpresent",
				customRepository:FindFirstChild("Everpresent")
			)
			currentlyLoading = false
			receivedObjects = nil
			objects = nil

			if warnings then
				for _, warningTable in warnings do
					objectScope:log(warningTable)
				end
			end
		end


		requestObjects()
		--ClientObjects:LoadClientObjects(COFolder, false)
	end
	
	LocalPlayer.CharacterAdded:Connect(CharacterAdded)
	
	GUI:SetTowerTimer(0)
	GUI:SetTowerAcronym("")
	GUI:SetTowerRush(0,0)
end

script.RestartTime.Changed:Connect(function(v)
	RestartTimeMax = v
end)
