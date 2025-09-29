function getPlatformColor(pl)
	if pl:FindFirstChild"ColorOverride" and pl.ColorOverride:IsA"Color3Value" then
		return pl.ColorOverride.Value
	else
		return pl.Color
	end
end
local p = game.Players:GetPlayerFromCharacter(script.Parent)
script.Parent:WaitForChild("Humanoid").Touched:connect(function(tP,hP)
	if tP.Name=='LightingChanger' and tP:IsA'BasePart' and tP:FindFirstChild'Configuration' then
		local c=require(tP.Configuration)
		if _G.SetLighting then
			_G:SetLighting(c)
		end
	end
	if tP:FindFirstChild("kills") then
		if (tP:FindFirstChild"ButtonActivated" and tP.ButtonActivated.Value) and not ((tP:FindFirstChild"Invert" == nil and _G.Button[getPlatformColor(tP)]) or (tP:FindFirstChild"Invert" ~= nil and not _G.Button[getPlatformColor(tP)])) then return end
		if (tP.Parent.Parent.Name == "Beat Blocks") and tP.CanCollide == false then return end
		if script.Parent.Humanoid.Health > 0 and hP.Name ~= "Part" then
			game.ReplicatedStorage.DamageEvent:FireServer()
		end
	end
	if tP:FindFirstChild("ouch") then
		if (tP:FindFirstChild"ButtonActivated" and tP.ButtonActivated.Value) and not ((tP:FindFirstChild"Invert" == nil and _G.Button[getPlatformColor(tP)]) or (tP:FindFirstChild"Invert" ~= nil and not _G.Button[getPlatformColor(tP)])) then return end
		if script.Parent.Humanoid.Health > 0 and hP.Name ~= "Part" then
			game.ReplicatedStorage.DamageEvent:FireServer('HighDamage')
		end
	end
	if tP:FindFirstChild("lava") or tP:FindFirstChild("instakills") then
		if (tP:FindFirstChild"ButtonActivated" and tP.ButtonActivated.Value) and not ((tP:FindFirstChild"Invert" == nil and _G.Button[getPlatformColor(tP)]) or (tP:FindFirstChild"Invert" ~= nil and not _G.Button[getPlatformColor(tP)])) then return end
		if (tP.Parent.Parent.Name == "Beat Blocks") and tP.CanCollide == false then return end
		if script.Parent.Humanoid.Health > 0 and hP.Name ~= "Part" then
			game.ReplicatedStorage.DamageEvent:FireServer('Instakill')
		end
	end
end)
