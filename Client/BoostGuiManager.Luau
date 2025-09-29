local p=script.Parent
local l=p:WaitForChild'List'
local sbt=p:WaitForChild'SpeedBoostTimer'
local jbt=p:WaitForChild'JumpBoostTimer'
local pl=game.Players.LocalPlayer

function _G:AttachTimer(button,textlabel)
	local txt = Instance.new('TextLabel')
	txt.BackgroundTransparency = 1
	txt.TextScaled = true
	txt.Font = Enum.Font.SourceSansBold
	local c = button.Color
	txt.TextColor3 = c
	txt.TextStrokeColor3 = Color3.new(1-c.r,1-c.g,1-c.b)
	txt.TextStrokeTransparency = 0
	txt.Parent = l
	
	textlabel.Destroying:Connect(function()
		txt:Destroy()
	end)
	textlabel.Changed:Connect(function(p)
		if not textlabel or not textlabel.Parent then 
			txt:Destroy() 
		end
		txt.Text = textlabel.Text
	end)
end

game:GetService('RunService').RenderStepped:Connect(function()
	local c=pl.Character
	if c then
		local h=c:FindFirstChild'Humanoid'
		if h and h:FindFirstChild'SpeedBoost' and h.SpeedBoost.Value>0 and h.SpeedBoost.Value<10^10 then
			local s,ms=math.modf(h.SpeedBoost.Value)
			sbt.Text=string.format('%i.%i',s,math.floor(ms*10))
		else
			sbt.Text=''
		end
		if h and h:FindFirstChild'JumpBoost' and h.JumpBoost.Value>0 and h.JumpBoost.Value<10^10 then
			local s,ms=math.modf(h.JumpBoost.Value)
			jbt.Text=string.format('%i.%i',s,math.floor(ms*10))
			if sbt.Text=='' then
				jbt.Position = sbt.Position
			else
				jbt.Position = UDim2.new(1,0,0.9,-35)
			end
		else
			jbt.Text=''
		end
	end
end)

game.ReplicatedStorage.Communicators.Bindables.Events.ResetEffectGui.Event:Connect(function()
	for k,v in l:GetChildren() do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end
end)
