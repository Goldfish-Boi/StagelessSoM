local changeAvatar = script.Parent.ChangeAvatar

changeAvatar.OnServerEvent:Connect(function(plr, Rig, button)
	Rig.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(game.Players:GetUserIdFromNameAsync(button.Name)))
end)
