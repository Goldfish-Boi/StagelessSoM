--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

--> Initialize Script (yes it's that simple)
local Manager = require(ReplicatedStorage:WaitForChild("Background Music").MusicSystemManager)

--> Initialize Button
local gui = script.MuteButtonGui
if (not Manager.Config.UseDefaultMuteButton) or (playerGui:FindFirstChild(gui.Name) ~= nil) then
	return
end
gui.Parent = playerGui
gui.Handler.Enabled = true
