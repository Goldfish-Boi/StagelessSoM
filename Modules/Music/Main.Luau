--!strict

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

return function(musicFolder: Instance, config: ModuleScript?)
	SoundService.RespectFilteringEnabled = true --> Fixes music zones playing for everyone..

	--> Setup Script
	local initializer = script.MusicSystemInitializer
	local manager = script.MusicSystemManager
	if config then
		manager.Settings:Destroy()
		config:Clone().Parent = manager
	end
	initializer.Parent = StarterPlayer.StarterPlayerScripts

	--> Give Script to players who were in tha game before the script loaded
	for _, player in Players:GetPlayers() do
		local holder = Instance.new("SurfaceGui")
		holder.Name = "MusicScriptInitHolder"
		holder.ResetOnSpawn = false
		initializer:Clone().Parent = holder
		task.spawn(function()
			holder.Parent = player:WaitForChild("PlayerGui")
		end)
	end

	local zones = musicFolder:FindFirstChild("BackgroundMusicZones")

	--> WorldModel Conversion
	local worldZone = Instance.new("WorldModel")
	worldZone.Name = "BackgroundMusicZones"
	if zones then
		for _, child in zones:GetChildren() do
			child.Parent = worldZone
		end
	end

	local globalMusic = musicFolder:FindFirstChild("GlobalBackgroundMusic")
		or (function()
			local zone = Instance.new("Folder")
			zone.Name = "GlobalBackgroundMusic"
			return zone :: Instance
		end)()

	local newFolder = Instance.new("Folder")
	newFolder.Name = "Background Music"
	worldZone.Parent = newFolder
	globalMusic.Parent = newFolder
	manager.Parent = newFolder

	for _, song in newFolder:GetDescendants() do
		if not song:IsA("Sound") then
			continue
		end
		song.Looped = true
		if song.SoundId == "rbxassetid://0" then
			-- dude this is so annoying
			song.SoundId = ""
		end

		--~~ (TEMPORARY) PRELOAD FIX ~~--
		-- this is supposed to prevent roblox from preloading audios because
		-- it ends up eating a lot of ram
		if song:GetAttribute("PRELOAD") then
			-- please only use this attribute if you really need to have music
			-- sync or something
			continue
		end
		if song:IsDescendantOf(worldZone) then
			-- we only need to prevent it from loading music zones,
			-- global song is fine
			song:SetAttribute("_SOUNDID", song.SoundId)
			song.SoundId = ""
		end
	end

	newFolder.Parent = ReplicatedStorage
end
