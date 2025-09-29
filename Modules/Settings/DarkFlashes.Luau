local module = {}

local TweenService = game:GetService("TweenService")

local value
local isActive

local settingsNotch = script.Parent
local bg = settingsNotch.BG
local switch = bg.Switch
local btn = bg.Button

local db = false
local initilized = false

local tweenInf = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

function module.setValue(plrSettings)
	value = plrSettings["DarkFlashes"]
	isActive = plrSettings["DisplayFlashEffect"]

	if value == nil then value = false end
	if isActive == nil then isActive = true end

	module.apply()

	return
end

function module.apply()
	if initilized == true then
		if isActive == false then
			TweenService:Create(switch, tweenInf, {Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0)}):Play()
			TweenService:Create(bg, tweenInf, {BackgroundColor3 = Color3.fromRGB(125, 125, 125)}):Play()
			TweenService:Create(bg.UIStroke, tweenInf, {Color = Color3.fromRGB(75, 75, 75)}):Play()
			
			script.Parent.Description.Text = "Flashes are currently disabled"
			
			return
		end
		
		if value ~= true then TweenService:Create(switch, tweenInf, {Position = UDim2.new(0, 0, 0, 0), AnchorPoint = Vector2.new(0, 0)}):Play() else TweenService:Create(switch, tweenInf, {Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0)}):Play() end
		if value ~= true then TweenService:Create(bg, tweenInf, {BackgroundColor3 = Color3.fromRGB(191, 73, 73)}):Play() else TweenService:Create(bg, tweenInf, {BackgroundColor3 = Color3.fromRGB(73, 191, 73)}):Play() end
		if value ~= true then TweenService:Create(bg.UIStroke, tweenInf, {Color = Color3.fromRGB(124, 50, 50)}):Play() else TweenService:Create(bg.UIStroke, tweenInf, {Color = Color3.fromRGB(50, 124, 50)}):Play() end
	else
		if isActive == false then
			switch.Position = UDim2.new(0.5, 0, 0, 0)
			switch.AnchorPoint = Vector2.new(0.5, 0)
			bg.BackgroundColor3 = Color3.fromRGB(125, 125, 125)
			bg.UIStroke.Color = Color3.fromRGB(75, 75, 75)

			script.Parent.Description.Text = "Flashes are currently disabled"

			return
		end
		
		if value ~= true then switch.Position = UDim2.new(0, 0, 0, 0); switch.AnchorPoint = Vector2.new(0, 0) else switch.Position = UDim2.new(1, 0, 0, 0); switch.AnchorPoint = Vector2.new(1, 0) end
		if value ~= true then bg.BackgroundColor3 = Color3.fromRGB(191, 73, 73) else bg.BackgroundColor3 = Color3.fromRGB(73, 191, 73) end
		if value ~= true then bg.UIStroke.Color = Color3.fromRGB(124, 50, 50) else bg.UIStroke.Color = Color3.fromRGB(50, 124, 50) end
		
		initilized = true
	end
	
	if value == true then script.Parent.Description.Text = "Flashes will be black" else script.Parent.Description.Text = "Flashes will be white" end
end

btn.MouseButton1Click:Connect(function()
	if db or isActive == false then return end
	
	db = true

	if value == true then value = false else value = true end

	module.apply()

	task.wait(0.25)

	db = false
end)

function module.ReturnData()
	return value
end

game.ReplicatedStorage.Communicators.Bindables.Events.DataUpdate.Event:Connect(function(Type, data)
	if Type == "SettingsClient" then
		module.setValue(data)
	end
end)

return module
