--!strict
-- Written by fanofpixels

local m = {}

-- Hip offset to make sure teleports dont teleport you inside of the destination
local Hip:CFrame = CFrame.new(0,3,0)

-- Teleports the player's character
function m:TeleportPlayerToPart(Plr:Player, Destination:BasePart)
	local Character:Model? = Plr.Character
	if Character then
		Character:PivotTo(Destination.CFrame * Hip)
	end
end

-- Teleports the player's character, and if it isn't loaded, waits until it is
function m:TeleportPlayerToPartWithWait(Plr:Player,Destination:BasePart)
	local Character:Model? = Plr.Character
	if Character then
		Character:PivotTo(Destination.CFrame * Hip)
	else
		repeat 
			wait(0.05) 
			if Plr.Character then
				Plr.Character:PivotTo(Destination.CFrame * Hip)
			end
		until Plr.Character
	end
end

return m
