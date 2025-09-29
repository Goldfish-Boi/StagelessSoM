local TweenService = game:GetService("TweenService")

cam = game.Workspace.CurrentCamera

local gui = script.Parent

local spectateCounter = gui.SpectateCounter

local bar = gui.Frame
local title = bar.Frame.Title
local prev = bar.Back
local nex = bar.Front
local button = script.Parent.Open

local isSpectating = false
local playerSettings = nil
local PeopleSpectatingYou = {}

local connection:RBXScriptConnection

function get()
	for i,v in pairs(game.Players:GetPlayers())do
		if v.Name == title.Text then
			return(i)
		end
	end
end

function specate(player:Player)
	if not player then returnToSelf() return end
	
	cam.CameraSubject = player.Character.Humanoid

	pcall(function()
		game.ReplicatedStorage.Communicators.Remotes.Events.SpectateRemote:FireServer(player.Name)
		title.Text = player.Name
	end)

	if game.Players:GetPlayerFromCharacter(cam.CameraSubject.Parent).Name == game.Players.LocalPlayer.Name then return end
	
	player.CharacterAdded:Connect(function()
		task.wait(0.125)
		
		specate(player)
	end)
end

function updateSpectateCounter(plr, plrGettingSpectated)
	if playerSettings and playerSettings["DisplaySpectateCounter"] == false then 
		spectateCounter.Visible = false
		return
	end
	
	if not plr and plrGettingSpectated then
		if #PeopleSpectatingYou > 0 then
			spectateCounter.Visible = true
			spectateCounter.Count.Text = #PeopleSpectatingYou
		elseif #PeopleSpectatingYou == 0 then
			spectateCounter.Visible = false
		end
		
		return
	end

	if plrGettingSpectated == game.Players.LocalPlayer.Name then
		if not table.find(PeopleSpectatingYou, plr) then
			spectateCounter.Visible = true

			table.insert(PeopleSpectatingYou, plr)

			spectateCounter.Count.Text = #PeopleSpectatingYou
		end
	elseif plrGettingSpectated ~= game.Players.LocalPlayer.Name then
		if table.find(PeopleSpectatingYou, plr) then
			table.remove(PeopleSpectatingYou, table.find(PeopleSpectatingYou, plr))

			if #PeopleSpectatingYou > 0 then
				spectateCounter.Count.Text = #PeopleSpectatingYou
			elseif #PeopleSpectatingYou == 0 then
				spectateCounter.Visible = false
			end
		end
	end
end

function returnToSelf()
	cam.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
end

game.ReplicatedStorage.Communicators.Bindables.Events.DataUpdate.Event:Connect(function(Type, data)
	if Type == "SettingsClient" then
		playerSettings = data
		
		updateSpectateCounter()
	end
end)

button.MouseButton1Click:connect(function()
	if isSpectating == false then
		isSpectating = true
		
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		
		bar.Position = UDim2.new(0, 0, -0.05, 0)
		TweenService:Create(bar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		
		pcall(function()
			game.ReplicatedStorage.Communicators.Remotes.Events.SpectateRemote:FireServer(game.Players.LocalPlayer.Name)
			returnToSelf()
		end)
	elseif isSpectating == true then
		isSpectating = false
		
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		
		pcall(function()
			game.ReplicatedStorage.Communicators.Remotes.Events.SpectateRemote:FireServer(nil)
			returnToSelf()
		end)
		
		bar.Position = UDim2.new(5, 0, 0, 0)
	end
end)

prev.MouseButton1Click:connect(function()
	prev.Position = UDim2.new(0.375, 0, 0.85, 0)
	TweenService:Create(prev, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.4, 0, 0.85, 0)}):Play()
	
	task.wait(.1)
	
	local players = game.Players:GetPlayers()
	local num = get()
	
	if not pcall(function() cam.CameraSubject = players[num-1].Character.Humanoid end) then
		cam.CameraSubject = players[#players].Character.Humanoid
	end
	
	specate(game.Players:GetPlayerFromCharacter(cam.CameraSubject.Parent))
end)

nex.MouseButton1Click:connect(function()	
	nex.Position = UDim2.new(0.625, 0, 0.85, 0)
	TweenService:Create(nex, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.6, 0, 0.85, 0)}):Play()
	
	task.wait(.1)
	
	local players = game.Players:GetPlayers()
	local num = get()
	
	if not pcall(function() cam.CameraSubject = players[num+1].Character.Humanoid end) then
		cam.CameraSubject = players[1].Character.Humanoid
	end
	
	specate(game.Players:GetPlayerFromCharacter(cam.CameraSubject.Parent))
end)

game.ReplicatedStorage.Communicators.Remotes.Events.SpectateRemote.OnClientEvent:Connect(function(plr, plrGettingSpectated)
	updateSpectateCounter(plr, plrGettingSpectated)
end)
