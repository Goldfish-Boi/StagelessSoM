local ContextActionService = game:GetService("ContextActionService")
local VRService = game:GetService("VRService")
local Priority = Enum.ContextActionPriority.Default.Value

local function round(number)
	return math.floor(number + 0.5)
end

local RotateAngle = math.pi * 0.1875
local RoundAmount = math.pi * 0.25

local UpPanAmount = math.rad(15)
local MaxY = math.rad(80)
local MinY = math.rad(-80)

local function panHorizontal(multiplier)
	local camera = workspace.CurrentCamera
	
	if camera then
		local distance = (camera.CFrame.Position - camera.Focus.Position).Magnitude
		
		local x, y, z = camera.CFrame:ToOrientation()
		
		y = round((y + (RotateAngle * multiplier)) / RoundAmount) * RoundAmount
		
		camera.CFrame = CFrame.new(camera.Focus.Position) * CFrame.fromOrientation(x, y, z) * CFrame.new(0, 0, distance)
	end
end

local function panVertical(multiplier)
	local camera = workspace.CurrentCamera
	
	if camera then
		local distance = (camera.CFrame.Position - camera.Focus.Position).Magnitude
		
		local x, y, z = camera.CFrame:ToOrientation()
		
		x = math.clamp(x + (UpPanAmount * multiplier), MinY, MaxY)
		
		camera.CFrame = CFrame.new(camera.Focus.Position) * CFrame.fromOrientation(x, y, z) * CFrame.new(0, 0, distance)
	end
end

--Taken from the camera scripts
local function onKeyPress(name, state, input)
	if not game:IsLoaded() and VRService.VREnabled then
		return Enum.ContextActionResult.Pass
	end

	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	if input.KeyCode == Enum.KeyCode.Comma then
		panHorizontal(1)
	elseif input.KeyCode == Enum.KeyCode.Period then
		panHorizontal(-1)
	elseif input.KeyCode == Enum.KeyCode.PageUp then
		panVertical(-1)
	elseif input.KeyCode == Enum.KeyCode.PageDown then
		panVertical(1)
	end
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindActionAtPriority("BaseCameraKeyboardPan", onKeyPress, false, Priority,
	Enum.KeyCode.Comma, Enum.KeyCode.Period, Enum.KeyCode.PageUp, Enum.KeyCode.PageDown)
