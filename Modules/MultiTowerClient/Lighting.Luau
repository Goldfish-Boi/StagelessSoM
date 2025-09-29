--!strict
-- Written by fanofpixels

type LightingChangeType = 
	"Lighting" |
"ColorCorrectionEffect" |
"BlurEffect" |
"BloomEffect" |
"DepthOfFieldEffect"

type LightingChangeConfig = {[string]:any} | "Default"

type LightingChangeInfo = {
	Type: LightingChangeType,
	Configuration: LightingChangeConfig,
	TweenInfo: TweenInfo
}

local m = {}

local LightingService = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- This was absolutely stolen from LocalPartScript
local ConfigManifest:{[string]:{string}} = {
	["Lighting"] = {
		"Ambient", 
		"OutdoorAmbient", 
		"FogEnd", 
		"FogStart", 
		"FogColor", 
		"ClockTime", 
		"Brightness",

		"ColorShift_Bottom",
		"ColorShift_Top"
	},

	["ColorCorrectionEffect"] = {
		"Brightness", 
		"Contrast", 
		"Saturation", 
		"TintColor"
	},  
	["BlurEffect"] = {
		"Size"
	},
	["BloomEffect"] = {
		"Intensity", 
		"Size", 
		"Threshold"
	},
	["DepthOfFieldEffect"] = {
		"FarIntensity", 
		"FocusDistance", 
		"InFocusRadius", 
		"NearIntensity"
	},
}

-- Default lighting change tween built to match 5.4 and earlier's TweenInfo
local DefaultTweenInfo:TweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local DefaultLightingProperties:{[string]:{[string]:any}} = {}

-- This function adds legacy support for lighting changers from v5.4 of the JToH tower kit and earlier
-- It just compiles it's configuration into a v5.5 one and uses the normal function 
function m:LegacyChangeLighting(Config:LightingChangeConfig)
	local Info:LightingChangeInfo = {
		Type = "Lighting",
		Configuration = Config,
		TweenInfo = DefaultTweenInfo
	}
	m:ChangeLighting(Info)
end

function m.ResetLighting()
	for i, object in ipairs(LightingService:GetChildren()) do
		if object:HasTag("Default") == false then
			object:Destroy()
		end
	end
	
	local Info1:LightingChangeInfo = {
		Type = "Lighting",
		Configuration = 'Default',
		TweenInfo = DefaultTweenInfo
	}
	local Info2:LightingChangeInfo = {
		Type = "BloomEffect",
		Configuration = 'Default',
		TweenInfo = DefaultTweenInfo
	}
	local Info3:LightingChangeInfo = {
		Type = "BlurEffect",
		Configuration = 'Default',
		TweenInfo = DefaultTweenInfo
	}
	local Info4:LightingChangeInfo = {
		Type = "ColorCorrectionEffect",
		Configuration = 'Default',
		TweenInfo = DefaultTweenInfo
	}
	local Info5:LightingChangeInfo = {
		Type = "DepthOfFieldEffect",
		Configuration = 'Default',
		TweenInfo = DefaultTweenInfo
	}
	m:ChangeLighting(Info1)
	m:ChangeLighting(Info2)
	m:ChangeLighting(Info3)
	m:ChangeLighting(Info4)
	m:ChangeLighting(Info5)
end

-- This function actually tweens a lighting effect in accordance to a lighting changer's configuration
function m:ChangeLighting(Info:LightingChangeInfo)
	-- Determine what to tween
	local Target:Instance? = LightingService:FindFirstChild("MTK"..Info.Type)

	if Info.Type == "Lighting" or not Target then Target = LightingService end

	-- Determine the dictionary to use with the tween
	-- If the configuration is "Default", grab a dictionary from DefaultLightingProperties
	-- Otherwise, the configuration itself the dictionary to be used 
	local TweenDict:{[string]:any} = (
		(Info.Configuration == "Default")
		and DefaultLightingProperties[Info.Type] 
		or Info.Configuration::{[string]:any}
	)

	-- The tween is one time use, create it and immediately play it
	local Tween:Tween = TweenService:Create(Target, Info.TweenInfo, TweenDict)
	Tween:Play()
end

ReplicatedStorage.Communicators.Remotes.Events.ResetLighting.OnClientEvent:Connect(m.ResetLighting)

-- Init function, important for recording default lighting info at load time
function m:Init()
	-- Apply the function that lets lighting changers work pre 5.5
	_G.SetLighting = m.LegacyChangeLighting

	-- Record default effect properties
	for EffectName:string, EffectProperties:{string} in ConfigManifest do
		-- There's a special case for the lighting service itself, skip it
		if EffectName == "Lighting" then continue end

		-- Find the PostEffect
		local Effect:Instance? = LightingService:FindFirstChild("MTK"..EffectName)

		-- If not found, it probably doesn't exist yet, make it
		if not Effect then
			local NewEffect:PostEffect = Instance.new(EffectName)
			NewEffect.Name = "MTK"..EffectName
			NewEffect.Parent = LightingService

			-- Sensible defaults
			-- No case for ColorCorrectionEffect because it's default properties already don't do anything
			if NewEffect:IsA("BlurEffect") then
				NewEffect.Size = 0
			elseif NewEffect:IsA("DepthOfFieldEffect") then
				NewEffect.NearIntensity = 0
				NewEffect.FarIntensity = 0
			elseif NewEffect:IsA("BloomEffect") then
				NewEffect.Intensity = 1
				NewEffect.Size = 24
				NewEffect.Threshold = 2
			end
			
			NewEffect:AddTag("Default")
			
			Effect = NewEffect
		end
		
		-- Record all of the effects current (default) properties into a table
		if Effect and Effect:IsA("PostEffect") then
			local DefaultEffectProperties:{[string]:any} = {}

			for k:number, PropertyName:string in EffectProperties do
				DefaultEffectProperties[PropertyName] = Effect[PropertyName]
			end

			DefaultLightingProperties[EffectName] = DefaultEffectProperties
		end
	end

	-- Record default lighting properties
	DefaultLightingProperties.Lighting = {}
	for k:number, v:string in ConfigManifest.Lighting do
		DefaultLightingProperties.Lighting[v] = LightingService[v]
	end

	-- Connect the ChangeLighting event
	ReplicatedStorage.ChangeLighting.Event:Connect(function(Config)
		m:ChangeLighting(Config::LightingChangeInfo)
	end)
end

return m
