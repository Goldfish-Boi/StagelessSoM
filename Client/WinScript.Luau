local debris = game:GetService("Debris")
local runService = game:GetService("RunService")
local replicatedStorage = game.ReplicatedStorage
local player = game.Players.LocalPlayer

local events = replicatedStorage.Communicators
local winEvent = events.Remotes.Events.OnTowerWin
local confetti = replicatedStorage.WinningConfetti
local winSound = script.WinSound

local playerData

if player == nil then
	repeat
		task.wait()
	until player
end

local RemotesFolder:Folder = replicatedStorage.Communicators

local RemoteEvents:{[string]:RemoteEvent} = {}
local BindableEvents:{[string]:BindableEvent} = {}

local RemoteFunctions:{[string]:RemoteFunction} = {}

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

BindableEvents.DataUpdate.Event:Connect(function(Type, data)
	if Type == "SettingsClient" then
		playerData = data
	end
end)

--local displayWinningConfetti:BoolValue = player:WaitForChild("Values"):WaitForChild("DisplayWinningConfetti")

winEvent.OnClientEvent:Connect(function(TowerName, TowerDif)
	winEvent:FireServer(TowerName, TowerDif)
	
	if playerData["DisplayWinningConfetti"] == true or not playerData then
		task.wait(3)
		
		local newConfetti = confetti:Clone()
		newConfetti.Parent = workspace.Camera
		winSound:Play()
		
		for i, object in ipairs(newConfetti:GetDescendants()) do
			if object:IsA("ParticleEmitter") then
				object:Emit(30)
			end
		end
		
		runService.RenderStepped:Connect(function()
			if newConfetti then
				newConfetti.CFrame = workspace.Camera.CFrame
			end
		end)
		
		debris:AddItem(newConfetti, 2)
	end
end)
