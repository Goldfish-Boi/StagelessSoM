local TweenService = game:GetService("TweenService")

local concurrent = 0
local uniquePlrs = {}

game.Players.PlayerAdded:Connect(function(plr)
	concurrent += 1
	
	if not table.find(uniquePlrs, plr.UserId, 1) then
		table.insert(uniquePlrs, plr.UserId)
	end
	
	script.Parent.Concurrent.Text = "Concurrent Players: " .. concurrent
	script.Parent.Total.Text = "Total Unique Players: " .. #uniquePlrs
	
	game.Players.PlayerRemoving:Connect(function()
		concurrent -= 1
		
		script.Parent.Concurrent.Text = "Concurrent Players: " .. concurrent
	end)
end)
