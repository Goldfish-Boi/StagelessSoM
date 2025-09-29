local TweenService = game:GetService("TweenService")

local concurrent = 0

game.Players.PlayerAdded:Connect(function(plr)
	concurrent += 1
	
	TweenService:Create(script.Parent.Frame.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.fromScale(concurrent / game.Players.MaxPlayers, 1)}):Play()
	script.Parent.Frame.Concurrent.Text = concurrent .. " / " .. game.Players.MaxPlayers

	game.Players.PlayerRemoving:Connect(function()
		concurrent -= 1
		
		TweenService:Create(script.Parent.Frame.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.fromScale(concurrent / game.Players.MaxPlayers, 1)}):Play()
		script.Parent.Frame.Concurrent.Text = concurrent .. " / " .. game.Players.MaxPlayers
	end)
end)
