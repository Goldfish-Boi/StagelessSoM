local dataStoreService = game:GetService("DataStoreService")
local playerCompletions = dataStoreService:GetDataStore("Completions")
local towerCompletions = dataStoreService:GetDataStore("Completions", "TowerCompletions")
local replicatedStorage = game.ReplicatedStorage

local players = game:GetService("Players")

local events = replicatedStorage.Communicators.Remotes.Events
local winEvent = events.OnTowerWin

local towerData = nil

local data = require(replicatedStorage.Modules.Data)

task.spawn(function()
	towerData = data.LoadTowerData()
end)

players.PlayerAdded:Connect(function(plr)
	local stats = plr:WaitForChild("leaderstats")

	local Towers = Instance.new("IntValue", stats)
	Towers.Name = "Towers"

	-- ///// DATA STORES ///// --
	
	
	--[[local success, Tcompletions = pcall(function()
		return towerCompletions:GetAsync(plr.UserId)
	end)
	
	winEvent.OnServerEvent:Connect(function(winingPlr, towerName)
		print(towerName)
		
		if table.find(Tcompletions, towerName) == nil then
			
			table.insert(Tcompletions, towerName)
		end
	end)
	
	--towerCompletions:SetAsync(plr.UserId, {})
	
	for i, item in ipairs(Tcompletions) do
		print(item)
	end
	
	players.PlayerRemoving:Connect(function()
		local success, error = pcall(function()
			towerCompletions:SetAsync(plr.UserId, Tcompletions)
		end)
	end)]]
	
	
	
	data.LoadPlayerData(plr)
	
	Towers.Value = data.ReturnDataLength("Towers")
end)
