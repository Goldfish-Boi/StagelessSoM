local TweenService = game:GetService("TweenService")

local serverDeaths = 0
local label = script.Parent.TextLabel

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		local hum:Humanoid = char:FindFirstChild("Humanoid")
		
		if hum then
			hum.Died:Connect(function()
				serverDeaths += 1
				
				label.Text = "Server oofs: " .. serverDeaths
				label.TextColor3 = Color3.fromRGB(255, 0, 0)
				label.UIStroke.Color = Color3.fromRGB(255, 0, 0)
				
				TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
				TweenService:Create(label.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Color = Color3.fromRGB(255, 255, 255)}):Play()
			end)
		end
	end)
end)
