local remotes = game.ReplicatedStorage.Communicators.Remotes

local Admin = {"Cheaty123457"}

game:GetService("Players").PlayerAdded:Connect(function(plr)
	local plrIsAdmin = false
	
	if table.find(Admin, plr.Name) then plrIsAdmin = true end

	plr.Chatted:Connect(function(message)
		local args = message:split(" ")
		local cmd = args[1]:lower()
		
		print(cmd)

		if cmd == "!reset" or cmd == "!restart" then
			remotes.Events.ClientCommand:FireClient(plr, cmd, args)
		elseif cmd == "!rejoin" then
			remotes.Events.ClientCommand:FireClient(plr, cmd, args)
		elseif cmd == "!return" then
			remotes.Events.ClientCommand:FireClient(plr, cmd, args)
		elseif cmd == "!exit" then
			remotes.Events.ClientCommand:FireClient(plr, cmd, args)
		elseif cmd == "!tpplayer" then
			local player1:Player = game.Players:FindFirstChild(args[2])
			local player2:Player = game.Players:FindFirstChild(args[3])
			
			player1.Character:PivotTo(player2.Character.PrimaryPart.CFrame)
		end
	end)
end)
