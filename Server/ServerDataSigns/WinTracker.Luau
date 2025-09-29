local TweenService = game:GetService("TweenService")

local labelReg = script.Parent.Regular
local labelSC = script.Parent.SoulCrushing

local normalWins = 0
local scWins = 0

local normalDifs = {
	"Easy",
	"Medium",
	"Hard",
	"Difficult",
	"Challenging",
	"Intense",
	"Remorseless",
}

local scDifs = {
	"Insane",
	"Extreme",
	"Terrifying",
	"Catastrophic",
	"TowerRush"
}

local colours = {
	Easy = Color3.fromRGB(119, 243, 71),
	Medium = Color3.fromRGB(255, 255, 0),
	Hard = Color3.fromRGB(255, 124, 0),
	Difficult = Color3.fromRGB(255, 0, 0),
	Challenging = Color3.fromRGB(194, 0, 0),
	Intense = Color3.fromRGB(25, 34, 45),
	Remorseless = Color3.fromRGB(200, 0, 200),
	Insane = Color3.fromRGB(0, 0, 255),
	Extreme = Color3.fromRGB(2, 128, 255),
	Terrifying = Color3.fromRGB(0, 255, 255), 
	Catastrophic = Color3.fromRGB(255, 255, 255),
	TowerRush = Color3.fromRGB(255, 255, 255),
}

game.ReplicatedStorage.Communicators.Remotes.Events.OnTowerWin.OnServerEvent:Connect(function(plr, towerName, towerDif:string)
	if table.find(normalDifs, towerDif) then
		normalWins += 1

		print(towerDif)

		labelReg.Text = "Regular: " .. normalWins
		labelReg.TextColor3 = colours[towerDif]
		labelReg.UIStroke.Color = colours[towerDif]

		TweenService:Create(labelReg, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
		TweenService:Create(labelReg.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Color = Color3.fromRGB(255, 255, 255)}):Play()
	elseif table.find(scDifs, towerDif) then
		scWins += 1

		labelSC.Text = "SC: " .. scWins

		if towerDif ~= "TowerRush" then
			labelSC.TextColor3 = colours[towerDif]
			labelSC.UIStroke.Color = colours[towerDif]
		else
			local hue = 0

			for count = 1, 359 do
				hue += 1

				labelSC.TextColor3 = Color3.fromHSV(0 + (1 * (hue / 360)), 1, 1)
				labelSC.UIStroke.Color = Color3.fromHSV(0 + (1 * (hue / 360)), 1, 0.5)

				task.wait()
			end
		end

		TweenService:Create(labelSC, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
		TweenService:Create(labelSC.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Color = Color3.fromRGB(255, 255, 255)}):Play()
	end
end)
