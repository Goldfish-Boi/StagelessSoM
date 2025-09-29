local TweenService = game:GetService("TweenService")

local scrollingFrame = script.Parent
local player = script.Parent.Parent.Parent.Player
local changeAvatar = script.ChangeAvatar

local precSelec = ""

local TweenInf = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

for i, object in ipairs(scrollingFrame:GetChildren()) do
	if object:IsA("ImageButton") then	
		local open = false
		local debounce = true
		
		object.MouseButton1Click:Connect(function()
			if debounce == true then --closing
				if open then
					debounce = false
					open = false
					
					object.Closed.Visible = true
					object.Opened.Visible = false
					object.Closed.UIAspectRatioConstraint.AspectRatio = 1.5
					
					TweenService:Create(object.Closed.UIAspectRatioConstraint, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {AspectRatio = 1}):Play()
					TweenService:Create(object.ScrollingFrame, TweenInf, {Size = UDim2.new(1, 0, 0, 0), ScrollBarThickness = 0}):Play()
				else -- opening
					debounce = false
					open = true
					
					object.Closed.Visible = false
					object.Opened.Visible = true
					object.Opened.UIAspectRatioConstraint.AspectRatio = 1.5
					
					object.ScrollingFrame.Visible = true
					TweenService:Create(object.Opened.UIAspectRatioConstraint, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {AspectRatio = 1}):Play()
					TweenService:Create(object.ScrollingFrame, TweenInf, {Size = UDim2.new(1, 0, 3, 0), ScrollBarThickness = 15}):Play()
				end
			end
			
			task.spawn(function()
				task.wait(0.25)
				
				if open == false then
					object.ScrollingFrame.Visible = false
				end
				
				debounce = true
			end)
		end)
		
		for i, button:Instance in ipairs(object.ScrollingFrame:GetChildren()) do
			if button:IsA("TextButton") then
				button.MouseButton1Click:Connect(function()
					if button.Name == precSelec then
						player.ViewportFrame.Visible = false
						player.TextLabel.Text = "None Selected"
					else
						precSelec = button.Name
						
						player.ViewportFrame.Visible = true
						--player.ViewportFrame.WorldModel.Rig.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(game.Players:GetUserIdFromNameAsync(button.Name)))
						changeAvatar:FireServer(player.ViewportFrame.WorldModel.Rig, button)
						player.TextLabel.Text = button.Name
					end
				end)
			end
		end
	end
end
