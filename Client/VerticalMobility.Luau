local UIS = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local plr = game.Players.LocalPlayer

local tool = script.Parent
local idleAnim = script.Parent:WaitForChild("Idle")
local frontAnim = script.Parent:WaitForChild("Front")
local backAnim = script.Parent:WaitForChild("Back")
local rightAnim = script.Parent:WaitForChild("Right")
local leftAnim = script.Parent:WaitForChild("Left")

local PlayerScripts = plr:WaitForChild("PlayerScripts")
local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
local ControlModule = PlayerModule:GetControls()

tool.Equipped:Connect(function()
	local char = plr.Character
	local humanoidRootPart:Part = char:FindFirstChild("HumanoidRootPart")
	local hum:Humanoid = char:FindFirstChild("Humanoid")
	
	print("goo")
	
	--tool.VMWings:PivotTo(humanoidRootPart.CFrame)
	--wings()
	
	--tool.VMWings.Torso.Anchored = false 
	
	if hum and char and hum.Health > 0 then
		hum:ChangeState(Enum.HumanoidStateType.PlatformStanding)
		local force = Instance.new("BodyGyro")
		force.Name = "VMforce"
		force.Parent = humanoidRootPart
		force.CFrame = humanoidRootPart.CFrame
		force.P = 10^6
		force.maxTorque = Vector3.new(force.P,force.P,force.P)
		
		local velocity = Instance.new("LinearVelocity")
		velocity.Name = "VMVelocity"
		velocity.Attachment0 = humanoidRootPart.RootAttachment
		velocity.VectorVelocity = Vector3.new(0,0,0)
		velocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
		velocity.MaxForce = 10^6
		velocity.Parent = humanoidRootPart
		
		flyIdle = hum:LoadAnimation(idleAnim)
		flyFront = hum:LoadAnimation(frontAnim)	
		flyBack = hum:LoadAnimation(backAnim)
		flyRight = hum:LoadAnimation(rightAnim)
		flyLeft = hum:LoadAnimation(leftAnim)
		
		Connection = runService.Heartbeat:Connect(function()
			--tool.VMWings:SetPrimaryPartCFrame(char:FindFirstChild("Torso").CFrame)
			local MoveAmount = ControlModule:GetMoveVector() or Vector3.new()
			
			if MoveAmount.Magnitude == 0 then
				flyFront:Stop(0.5)
				flyBack:Stop(0.5)
				flyRight:Stop(0.5)
				flyLeft:Stop(0.5)
				
				if flyIdle.IsPlaying == false then
					flyIdle:Play(0.5)
				end
			else
				flyIdle:Stop(0.5)
				
				if MoveAmount.Z < 0 then
					if flyFront.IsPlaying == false then
						flyBack:Stop(0.5)
						flyFront:Play(0.5, 1)
					end
				elseif MoveAmount.Z > 0 then
					if flyBack.IsPlaying == false then
						flyFront:Stop(0.5)
						flyBack:Play(0.5, 1)
					end
				else
					flyBack:Stop(0.5)
					flyFront:Stop(0.5)
				end
				
				if MoveAmount.X < -0.5 then
					if flyLeft.IsPlaying == false then
						flyRight:Stop(0.5)
						flyLeft:Play(0.5, 1)
					end
				elseif MoveAmount.X > 0.5 then
					if flyRight.IsPlaying == false then
						flyLeft:Stop(0.5)
						flyRight:Play(0.5, 1)
					end
				else
					flyLeft:Stop(0.5)
					flyRight:Stop(0.5)
				end
				
				if flyFront.IsPlaying == false and flyBack.IsPlaying == false and flyLeft.IsPlaying == false and flyRight.IsPlaying == false then
					flyFront:Stop(0.5)
				end
			end
			
			force.CFrame = workspace.Camera.CFrame
			TweenService:Create(velocity, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {VectorVelocity = MoveAmount * 60}):Play()
		end)	
	end
end)

tool.Unequipped:Connect(function()
	local force = plr.Character.HumanoidRootPart:FindFirstChild("VMforce")
	local velocity = plr.Character.HumanoidRootPart:FindFirstChild("VMVelocity")
	
	if force then
		force:Destroy()
	end
	if velocity then
		velocity:Destroy()
	end
	if Connection then
		Connection:Disconnect()
		Connection = nil
	end
	if flyIdle ~= nil then
		flyIdle:Stop()
	end
	if flyFront ~= nil then
		flyFront:Stop()
	end
	if flyBack ~= nil then
		flyBack:Stop()
	end
	if flyRight ~= nil then
		flyRight:Stop()
	end
	if flyLeft ~= nil then
		flyLeft:Stop()
	end
end)
