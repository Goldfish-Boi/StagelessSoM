local marketplaceService = game:GetService("MarketplaceService")

local Ids = {
	["Gravity Coil"] = 1031433733,
	["Vertical Mobility"] = 1032895955,
}

local active = false

script.Parent.MultiTowerServer.Initiated.Event:Connect(function()
	active = true
end)

local function CharacterAdded(char)
	local plr = game.Players:GetPlayerFromCharacter(char)
	
	for item, id in pairs(Ids) do
		if marketplaceService:UserOwnsGamePassAsync(plr.UserId, id) == true then
			print(item .. " " .. id)
			local clonedItem = script:FindFirstChild(item):Clone()
			clonedItem.Parent = plr.Backpack
		end
	end
end

local function PlayerAdded(player)
	--Connect the event
	player.CharacterAdded:Connect(CharacterAdded)

	--Take care of when it already exists
	local char = player.Character
	if char then
		CharacterAdded(char)
	end
end

--Connect the event
game.Players.PlayerAdded:Connect(PlayerAdded)

--Take care of when it already exists
for i,v in pairs(game.Players:GetPlayers()) do
	PlayerAdded(v)
end
