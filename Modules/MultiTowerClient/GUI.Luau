-- Written by fanofpixels

local m = {}
-- Important Stuff
local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Util = require(script.Parent.Util)
local TowerGui:ScreenGui = PlayerGui:WaitForChild("TowerGUI")
TowerGui.Enabled = true

-- Elements
local TowerAcronym:TextLabel? = TowerGui:FindFirstChild("TowerAcronym",true)::TextLabel
local TowerRushProgress:TextLabel? = TowerGui:FindFirstChild("TowerRushProgress",true)::TextLabel
local Timer:TextLabel? = TowerGui:FindFirstChild("Timer",true)::TextLabel
local BoostsUsed:TextLabel? = TowerGui:FindFirstChild("BoostsUsed",true)::TextLabel
local RestartLabel = TowerGui:FindFirstChild("RestartPanel")

if RestartLabel then
	RestartLabel.Visible = false
end

function m:SetTowerAcronym(Acronym:string)
	if TowerAcronym then
		TowerAcronym.Text = Acronym
		TowerAcronym.Visible = Acronym ~= "" 
	end
end

function m:SetTowerColor(Color:Color3)
	if TowerAcronym then
		TowerAcronym.TextColor3 = Color
	end
end

function m:SetTowerRush(Progress:number, Max:number)
	if TowerRushProgress then
		TowerRushProgress.Text = tostring(Progress) .. "/" .. tostring(Max)
		TowerRushProgress.Visible = Max ~= 0
	end
end

function m:SetTowerTimer(Time:number)
	if Timer then
		Timer.Text = Util:FormatTimer(Time)
	end
end

function m:SetBoostsUsed(Val:boolean)
	if BoostsUsed then
		BoostsUsed.Visible = Val
	end
end

function m:SetRestartLabel(T:number)
	--[[if RestartLabel then
		RestartLabel.TextTransparency = 1-T
	end]]--
	
	TweenService:Create(RestartLabel.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = T * 360}):Play()
	TweenService:Create(RestartLabel.Bg.Progress, TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Size = UDim2.new(T, 0, 1, 0)}):Play()
end

function m:OpenRestartLabel(enabled)
	if game.StarterGui:GetCore("ChatActive") == false then
		if enabled == true then
			RestartLabel.Position = UDim2.new(0.5, 0, 0.7, 0)
			RestartLabel.Visible = true

			TweenService:Create(RestartLabel, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.65, 0), BackgroundTransparency = 0}):Play()

			for i, object in ipairs(RestartLabel:GetDescendants()) do
				if object:IsA("TextLabel") then
					TweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
				elseif object:IsA("Frame") then
					TweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
				elseif object:IsA("ImageLabel") then
					TweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0}):Play()
				elseif object:IsA("UIStroke") then
					TweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0}):Play()
				end
			end
		else
			TweenService:Create(RestartLabel, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()

			for i, object in ipairs(RestartLabel:GetDescendants()) do
				if object:IsA("TextLabel") then
					TweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
				elseif object:IsA("Frame") then
					TweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
				elseif object:IsA("ImageLabel") then
					TweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 1}):Play()
				elseif object:IsA("UIStroke") then
					TweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 1}):Play()
				end
			end
		end
	end
end

return m
