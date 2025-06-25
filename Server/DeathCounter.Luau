local serverDeaths = 0

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		local hum:Humanoid = char:FindFirstChild("Humanoid")
		
		if hum then
			hum.Died:Connect(function()
				serverDeaths += 1
				script.Parent.TextLabel.Text = "Server oofs: " .. serverDeaths
			end)
		end
	end)
end)
