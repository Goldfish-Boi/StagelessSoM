game.StarterGui:SetCore("BadgesNotificationsActive", false)

local BadgeService = game:GetService("BadgeService")
local TweenService = game:GetService("TweenService")

local NotificationEvent = game.ReplicatedStorage.Communicators.Remotes.Events.Notification

local gui = script.Parent
local holder = gui.Holder
local badgeTemplate = holder.BadgeTemplate

local notificationsGiven = 0

NotificationEvent.OnClientEvent:Connect(function(messageType, badgeId)
	print("Notification")
	
	if messageType == "Badge" then
		if BadgeService:UserHasBadgeAsync(game.Players.LocalPlayer.UserId, badgeId) == false then
			notificationsGiven += 1
			
			local message = badgeTemplate:Clone()
			local badgeInfo = BadgeService:GetBadgeInfoAsync(badgeId)
			
			message.LayoutOrder = -(notificationsGiven)
			message.BadgeName.Text = badgeInfo.Name
			message.BadgeName.MaxVisibleGraphemes = 0
			message.Glow.ImageTransparency = 1
			message.BadgeImage.Image = "rbxassetid://" .. badgeInfo.IconImageId
			message.Size = UDim2.fromScale(0, 0)
			message.Visible = true
			message.Parent = holder
			
			script.BadgeSound:Play()
			
			task.spawn(function()
				TweenService:Create(message.Glow, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = message.Glow.Rotation + 360}):Play()
				TweenService:Create(message.Glow, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {ImageTransparency = 0}):Play()
				TweenService:Create(message.BadgeName, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {MaxVisibleGraphemes = string.len(badgeInfo.Name)}):Play()
			end)
			
			TweenService:Create(message, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromScale(0.95, 0.175)}):Play()
			
			task.wait(5)
			
			TweenService:Create(message, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.fromScale(0.95, 0)}):Play()
			TweenService:Create(message.BadgeName, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {MaxVisibleGraphemes = 0}):Play()
			
			task.wait(1)
			
			message:Destroy()
		end
	end
end)
