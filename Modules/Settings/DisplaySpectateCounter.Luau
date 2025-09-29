local module = {}

local TweenService = game:GetService("TweenService")

local value

local settingsNotch = script.Parent
local bg = settingsNotch.BG
local switch = bg.Switch
local btn = bg.Button

local db = false
local initilized = false

local tweenInf = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

function module.setValue(plrSettings)
	value = plrSettings["DisplaySpectateCounter"]

	if value == nil then value = true end

	module.apply()

	return
end

function module.apply()
	--print(tostring(value) .. ": " .. tostring(data))
	if initilized == true then
		if value ~= true then TweenService:Create(switch, tweenInf, {Position = UDim2.new(0, 0, 0, 0), AnchorPoint = Vector2.new(0, 0)}):Play() else TweenService:Create(switch, tweenInf, {Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0)}):Play() end
		if value ~= true then TweenService:Create(bg, tweenInf, {BackgroundColor3 = Color3.fromRGB(191, 73, 73)}):Play() else TweenService:Create(bg, tweenInf, {BackgroundColor3 = Color3.fromRGB(73, 191, 73)}):Play() end
		if value ~= true then TweenService:Create(bg.UIStroke, tweenInf, {Color = Color3.fromRGB(124, 50, 50)}):Play() else TweenService:Create(bg.UIStroke, tweenInf, {Color = Color3.fromRGB(50, 124, 50)}):Play() end
	else
		if value ~= true then switch.Position = UDim2.new(0, 0, 0, 0); switch.AnchorPoint = Vector2.new(0, 0) else switch.Position = UDim2.new(1, 0, 0, 0); switch.AnchorPoint = Vector2.new(1, 0) end
		if value ~= true then bg.BackgroundColor3 = Color3.fromRGB(191, 73, 73) else bg.BackgroundColor3 = Color3.fromRGB(73, 191, 73) end
		if value ~= true then bg.UIStroke.Color = Color3.fromRGB(124, 50, 50) else bg.UIStroke.Color = Color3.fromRGB(50, 124, 50) end
		
		initilized = true
	end
	
	if value == true then script.Parent.Description.Text = "Spectate counter is visible" else script.Parent.Description.Text = "Spectate counter is hidden" end
end

btn.MouseButton1Click:Connect(function()
	if not db then
		db = true

		if value == true then value = false else value = true end

		module.apply()

		task.wait(0.25)

		db = false
	end
end)

function module.ReturnData()
	return value
end

return module
