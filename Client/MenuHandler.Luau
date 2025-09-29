local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local collectionService = game:GetService("CollectionService")
local runService = game:GetService("RunService")

local plr = game.Players.LocalPlayer
local hum:Humanoid = plr.Character

local timer = plr.PlayerGui.TowerGUI.TimerPanel

local gui = script.Parent
local frames = gui.Frames
local settingsFrame = frames.Settings
local open = script.Parent.Open
local exit = script.Parent.Exit

local menuOpened = false

local infoBubble = script.Parent.InfoBubble
local infoBubbleTextBox = infoBubble.Frame.TextLabel

local function CharacterAdded(char)
	hum = char:WaitForChild("Humanoid")
	hum.Died:Connect(function()
		playerDied()
	end)
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

function adjustTextSize()
	for i, object in ipairs(gui:GetDescendants()) do
		if object:IsA("TextLabel") and object ~= infoBubbleTextBox then
			object.TextSize = object.AbsoluteSize.Y / 2
		end
	end
end

workspace.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	adjustTextSize()
end)

adjustTextSize()

for i, button in ipairs(gui:GetChildren()) do
	if button:IsA("TextButton") then
		button.MouseEnter:Connect(function()
			TweenService:Create(button.UIAspectRatioConstraint, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {AspectRatio = 1.75}):Play()

			button.MouseLeave:Connect(function()
				TweenService:Create(button.UIAspectRatioConstraint, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {AspectRatio = 2}):Play()
			end)
		end)
	end
end

open.MouseButton1Click:Connect(function()
	menuOpened = true
	
	script.Parent.Main.Position = UDim2.new(0.5, 0, 0.55, 0)
	exit.Position = UDim2.new(0.008, 0, 0.475, 0)
	
	workspace.Camera.CameraType = Enum.CameraType.Scriptable
	workspace.Camera.CFrame = workspace.Menu.Cam.CFrame
	
	open.Visible = false
	exit.Visible = true
	script.Parent.Main.Visible = true
	
	TweenService:Create(timer, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
	TweenService:Create(exit, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.008, 0, 0.5, 0)}):Play()
	TweenService:Create(script.Parent.Main, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
	
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	
	workspace.Camera.CameraType = Enum.CameraType.Scriptable
	local menu = game.ReplicatedStorage.Menu:Clone()
	menu.Parent = workspace.Camera
	menu.AnimationController:LoadAnimation(menu.Animations.Entrances[math.random(1, #menu.Animations.Entrances:GetChildren())]):Play()
	
	task.wait(0.3)
	
	menu:SetPrimaryPartCFrame(workspace.Camera.CFrame)
end)

exit.MouseButton1Click:Connect(function()
	menuOpened = false
	
	open.Position = UDim2.new(0.008, 0, 0.475, 0)
	
	workspace.Camera.CameraType = Enum.CameraType.Custom
	
	open.Visible = true
	exit.Visible = false
	script.Parent.Main.Visible = false
	
	for i, frame in ipairs(frames:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end
	
	TweenService:Create(timer, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.015, 0)}):Play()
	TweenService:Create(open, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.008, 0, 0.5, 0)}):Play()
	
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	
	workspace.Camera.CameraType = Enum.CameraType.Custom
	
	Debris:AddItem(workspace.Camera:WaitForChild("Menu"), 0)
end)

function playerDied()
	if menuOpened == true then
		open.Position = UDim2.new(0.008, 0, 0.475, 0)

		workspace.Camera.CameraType = Enum.CameraType.Custom

		open.Visible = true
		exit.Visible = false
		script.Parent.Main.Visible = false

		for i, frame in ipairs(frames:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		end

		TweenService:Create(timer, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.015, 0)}):Play()
		TweenService:Create(open, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.008, 0, 0.5, 0)}):Play()

		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)

		workspace.Camera.CameraType = Enum.CameraType.Custom

		Debris:AddItem(workspace.Camera:WaitForChild("Menu"), 0)
	end
	
	menuOpened = false
end

for i, button in ipairs(script.Parent.Main.ScrollingFrame.Buttons:GetChildren()) do
	if button:IsA("TextButton") then
		button.MouseEnter:Connect(function()
			TweenService:Create(button.UIAspectRatioConstraint, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {AspectRatio = 1.125}):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button.UIAspectRatioConstraint, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {AspectRatio = 1}):Play()
		end)
		button.MouseButton1Click:Connect(function()
			local frame:Frame = frames:FindFirstChild(button.Name)
			
			frame.Position = UDim2.new(0.5, 0, 0.55, 0)
			frame.Visible = true
			TweenService:Create(frame, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
			
			gui.Main.Visible = false
		end)
	end
end

for i, button in ipairs(frames:GetDescendants()) do
	if button:IsA("TextButton") and button.Name == "Exit" then
		button.MouseButton1Click:Connect(function()
			button.Parent.Visible = false
			
			gui.Main.Position = UDim2.new(0.5, 0, 0.55, 0)
			gui.Main.Visible = true
			TweenService:Create(gui.Main, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		end)
	end
end



local function updateInfoBubbleSize()
	TweenService:Create(infoBubble.Frame, TweenInfo.new(0.25), {Size = UDim2.new(0, gui.AbsoluteSize.X / (gui.AbsoluteSize.X / 250), 0, infoBubbleTextBox.TextBounds.Y + 20)}):Play()
end

for i, object:GuiObject in ipairs(collectionService:GetTagged("InfoObject")) do
	object.MouseEnter:Connect(function(x, y)
		infoBubble.Position = UDim2.fromOffset(object.AbsolutePosition.X + (object.AbsoluteSize.X / 2), object.AbsolutePosition.Y)
		infoBubble.Frame.Size = UDim2.fromOffset(gui.AbsoluteSize.X / (gui.AbsoluteSize.X / 250), gui.AbsoluteSize.Y / (gui.AbsoluteSize.Y / 97))
		infoBubbleTextBox.TextSize = gui.AbsoluteSize.X / (gui.AbsoluteSize.X / 20)
		infoBubble.Visible = true
		infoBubbleTextBox.Text = object:GetAttribute("Info")
		infoBubbleTextBox.MaxVisibleGraphemes = 0
		
		TweenService:Create(infoBubbleTextBox, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {MaxVisibleGraphemes = utf8.len(infoBubbleTextBox.Text)}):Play()
		
		updateInfoBubbleSize()
	end)
	object.MouseLeave:Connect(function()
		infoBubble.Visible = false
		infoBubbleTextBox.Text = ""

		updateInfoBubbleSize()
	end)
end

script.Parent.Main.ScrollingFrame.Buttons.UIGridLayout.CellSize = UDim2.fromOffset(script.Parent.Main.ScrollingFrame.Buttons.Settings.AbsoluteSize.X, script.Parent.Main.ScrollingFrame.Buttons.Settings.AbsoluteSize.Y)
