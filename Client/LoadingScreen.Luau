local players = game:GetService("Players")
local replicatedFirst = game:GetService("ReplicatedFirst")
local contentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

replicatedFirst:RemoveDefaultLoadingScreen()

local plr = players.LocalPlayer
local plrGUI = plr:WaitForChild("PlayerGui")

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

local loadingScreen = script:WaitForChild("LoadingScreen"):Clone()
loadingScreen.Parent = plrGUI

local active = true

TweenService:Create(loadingScreen.MainFrame.Progress, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = loadingScreen.MainFrame.Progress.Rotation + 360}):Play()
local loadingScreenTips = require(script.loadingScreenTips)

local assets = game:GetChildren()

--task.wait(10)

local left = loadingScreen.MainFrame.Progress:WaitForChild("Left")
local right = loadingScreen.MainFrame.Progress:WaitForChild("Right")

local ti = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local numValue = Instance.new("NumberValue")
numValue.Value = 0


numValue.Changed:Connect(function()
	local rightRot = math.clamp(numValue.Value - 180, -180, 0)
	right.UIGradient.Rotation = rightRot

	if numValue.Value >= 180 then
		right.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
		local leftRot = math.clamp(numValue.Value - 360, -180, 0)
		left.UIGradient.Rotation = leftRot
		left.Visible = true
	elseif numValue.Value == 360 then
		right.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
		left.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
	end
end)

task.spawn(function()
	while task.wait(3) do
		if active == true then
			loadingScreen.MainFrame.SillyText.Text = loadingScreenTips[math.random(1, #loadingScreenTips)]
		else
			break
		end
	end
end)

for index, asset in ipairs(assets) do
	loadingScreen.MainFrame.Loading.Text = "Loading " .. asset.Name .. ": " ..  index .. " / " .. #assets
	contentProvider:PreloadAsync({asset})

	TweenService:Create(numValue, ti, {Value = 360 * (index / #assets)}):Play()

	task.wait()
end

task.wait(0.25)

right.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
left.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))

active = false

TweenService:Create(loadingScreen.MainFrame.Progress, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()
TweenService:Create(loadingScreen.MainFrame.Loading, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()
TweenService:Create(loadingScreen.MainFrame.SillyText, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()

for count = 1, 10 do
	local left:Frame = loadingScreen.MainFrame:FindFirstChild("Left" .. count)
	local right:Frame = loadingScreen.MainFrame:FindFirstChild("Right" .. count)

	TweenService:Create(left, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(-1.1, left.Position.Y.Scale)}):Play()

	task.wait(0.04)

	TweenService:Create(right, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(1.1, right.Position.Y.Scale)}):Play()

	task.wait(0.04)
end

task.wait(2)

loadingScreen:Destroy()

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
