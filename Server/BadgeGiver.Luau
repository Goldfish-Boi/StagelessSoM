local badgeService = game:GetService("BadgeService")
local remote = game.ReplicatedStorage.Communicators.Remotes.Events.AwardBadge

remote.OnServerEvent:Connect(function(plr, badgeID)
	game.ReplicatedStorage.Communicators.Remotes.Events.Notification:FireClient(plr, "Badge", badgeID)
	badgeService:AwardBadge(plr.UserId, badgeID)
end)
