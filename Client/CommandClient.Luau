local teleportService = game:GetService("TeleportService")
local ReplicatedStorage = game.ReplicatedStorage
local plr = game.Players.LocalPlayer

--local remotes = game.ReplicatedStorage.Communicators

local RemotesFolder:Folder = ReplicatedStorage.Communicators

local RemoteEvents:{[string]:RemoteEvent} = {}

do 
	for k:number, v:Instance in RemotesFolder:GetDescendants() do
		if v:IsA("RemoteEvent") then
			RemoteEvents[v.Name] = v
		end
	end
end

RemoteEvents.ClientCommand.OnClientEvent:Connect(function(cmd, args)
	if cmd == "!reset" or cmd == "!restart" then
		RemoteEvents.RestartRequested:FireServer()
	elseif cmd == "!rejoin" then
		teleportService:Teleport(game.PlaceId, plr)
	elseif cmd == "!return" then
		teleportService:Teleport(108617994947204, plr)
	elseif cmd == "!exit" then
		RemoteEvents.ExitRequested:FireServer()
	end
end)
