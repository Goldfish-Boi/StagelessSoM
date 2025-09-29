local module = {}

local dataStoreService = game:GetService("DataStoreService")
local playerDatastore = dataStoreService:GetDataStore("PlayerData")
local towerDatastore = dataStoreService:GetDataStore("TowerData")
local replicatedStorage = game.ReplicatedStorage
local players = game:GetService("Players")

local towerInfo = require(script.Parent.TowerInfo)

local events = replicatedStorage.Communicators
local winEvent = events.Remotes.Events.OnTowerWin

PlayerDataTable = {}
TowerData = nil

events.Remotes.Functions.RequestData.OnServerInvoke = function(plr, Type)
	if Type == "TowerData"then
		if TowerData == nil then
			repeat
				task.wait()
			until TowerData ~= nil
		end
		return TowerData
	elseif Type == "Settings" then
		if PlayerDataTable[plr.UserId]["Settings"] == nil then
			repeat
				task.wait()
			until PlayerDataTable[plr.UserId]["Settings"] ~= nil
		end
		return PlayerDataTable[plr.UserId]["Settings"]
	elseif Type == "MiscCompletions" then
		if PlayerDataTable[plr.UserId]["MiscCompletions"] == nil then
			repeat
				task.wait()
			until PlayerDataTable[plr.UserId]["MiscCompletions"] ~= nil
		end
		return PlayerDataTable[plr.UserId]["MiscCompletions"]
	end
end

function module.LoadTowerData()
	local success, Tcompletions = pcall(function()
		return towerDatastore:GetAsync("Towers")
	end)
	
	TowerData = Tcompletions
	
	if TowerData == nil then TowerData = {} end
	
	for i, v in pairs(towerInfo) do
		if TowerData[tostring(i)] == nil then TowerData[tostring(i)] = {} end
		
		if TowerData[tostring(i)]["GlobalAttempts"] == nil then TowerData[tostring(i)]["GlobalAttempts"] = 0 end
		if TowerData[tostring(i)]["GlobalWins"] == nil then TowerData[tostring(i)]["GlobalWins"] = 0 end
		if TowerData[tostring(i)]["GlobalTimeSpent"] == nil then TowerData[tostring(i)]["GlobalTimeSpent"] = 0 end
	end
	
	events.Bindables.Events.IncrementGlobalData.Event:Connect(function(Tower, Type, Time)
		if TowerData[tostring(Tower)] then
			if Type == "Attempt" then
				TowerData[tostring(Tower)]["GlobalAttempts"] += 1
			elseif Type == "Win" then
				TowerData[tostring(Tower)]["GlobalWins"] += 1
			end
			
			if Time then
				TowerData[tostring(Tower)]["GlobalTimeSpent"] += Time
			end
			
			print(TowerData)
			
			local success, err = pcall(function()
				towerDatastore:UpdateAsync("Towers", function() return TowerData end)
			end)
			
			if err then
				warn(err)
			end
		end
	end)
	
	--towerDatastore:SetAsync("Towers", TowerData)
end

function module.LoadPlayerData(plr:Player)
	local success, Tcompletions = pcall(function()
		return playerDatastore:GetAsync(plr.UserId)
	end)
	
	PlayerData = Tcompletions
	
	if PlayerData == nil then PlayerData = {} end
	
	if PlayerData["TowerCompletions"] == nil then PlayerData["TowerCompletions"] = {} end
	
	for i, v in pairs(towerInfo) do
		if PlayerData["TowerCompletions"][tostring(i)] == nil then PlayerData["TowerCompletions"][tostring(i)] = {} end

		if PlayerData["TowerCompletions"][tostring(i)]["Attempts"] == nil then PlayerData["TowerCompletions"][tostring(i)]["Attempts"] = 0 end
		if PlayerData["TowerCompletions"][tostring(i)]["Wins"] == nil then PlayerData["TowerCompletions"][tostring(i)]["Wins"] = 0 end
		if PlayerData["TowerCompletions"][tostring(i)]["TimeSpent"] == nil then PlayerData["TowerCompletions"][tostring(i)]["TimeSpent"] = 0 end
	end
	
	if PlayerData["MiscCompletions"] == nil then PlayerData["MiscCompletions"] = {} end
	if PlayerData["Settings"] == nil then PlayerData["Settings"] = {} end
	
	PlayerDataTable[plr.UserId] = PlayerData
	
	print(PlayerDataTable)
	
	events.Remotes.Events.AddDataKey.OnServerEvent:Connect(function(player, stringToAdd)
		if player ~= plr then return end
		
		if table.find(PlayerData["MiscCompletions"], stringToAdd) then return end
		
		table.insert(PlayerData["MiscCompletions"], stringToAdd)
		
		PlayerDataTable[plr.UserId] = PlayerData
	end)
	
	events.Bindables.Events.UpdatePlayerData.Event:Connect(function(Tower, Type, Time)
		if PlayerData["TowerCompletions"][tostring(Tower)] then
			if Type == "Attempt" then
				PlayerData["TowerCompletions"][tostring(Tower)]["Attempts"] += 1
			elseif Type == "Win" then
				PlayerData["TowerCompletions"][tostring(Tower)]["Wins"] += 1
			end

			if Time then
				PlayerData["TowerCompletions"][tostring(Tower)]["TimeSpent"] += Time
			end
		end
		
		PlayerDataTable[plr.UserId] = PlayerData
	end)
	
	events.Remotes.Events.UpdatePlayerDataClient.OnServerEvent:Connect(function(player, dataType, data)
		if player ~= plr then return end
		
		if dataType == "Settings" then
			PlayerData[dataType] = data
		end
	end)
	
	--[[winEvent.OnServerEvent:Connect(function(winingPlr, towerName, towerDif)
		if towerDif == "TowerRush" then
			if table.find(PlayerData["MiscCompletions"], towerName) == nil then
				table.insert(PlayerData["MiscCompletions"], towerName)
			end
		else
			if table.find(PlayerData["TowerCompletions"], towerName) == nil then
				table.insert(PlayerData["TowerCompletions"], towerName)
			end
		end
	end)]]--

	--towerCompletions:SetAsync(plr.UserId, {})

	--[[for i, item in ipairs(PlayerData) do
		print(item)
	end]]--

	players.PlayerRemoving:Connect(function()
		local success, error = pcall(function()
			playerDatastore:SetAsync(plr.UserId, PlayerData)
			
			PlayerData = nil
			PlayerDataTable[plr.UserId] = nil
		end)
	end)
end

game:BindToClose(function()
	local success, error = pcall(function()
		for i, playerData in pairs(PlayerDataTable) do
			playerDatastore:SetAsync(i, PlayerData)

			PlayerData = nil
		end
	end)
end)

function module.CheckCompletion(towerName)
	if table.find(PlayerData["TowerCompletions"], towerName) ~= nil then
		return true
	else
		return false
	end
end

function module.ReturnDataLength(DataType)
	local count = 0
	
	if DataType == "Towers" then
		for i, item in pairs(PlayerData["TowerCompletions"]) do
			if item["Wins"] > 0 then
				count += 1
			end
		end
	end
	
	if count == nil then
		count = 0
	end

	return count
end

return module
