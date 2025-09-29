local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plr = Players.LocalPlayer
local hum = plr.Character:WaitForChild("Humanoid")

local colourCorrection:ColorCorrectionEffect = game.Lighting:WaitForChild("MTKColorCorrectionEffect")
local gui = script.Parent
local white = gui.White
local black = gui.Black
local portal = gui.PortalWipe
local death = gui.Death
local fixed = death.Fixed
local broken = death.Broken
local currentTower = ""

local musicModule = require(game.ReplicatedStorage:WaitForChild("Background Music"):WaitForChild("MusicSystemManager"))
local randomizedText = require(script.RandomizedTexts)
local cameraShake = require(script.CameraShaker)

local debounce = false
local db = false
local dead = false

local playerData = nil

local camShake = cameraShake.new(Enum.RenderPriority.Camera.Value, function(shakeCf) workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * shakeCf end)
camShake:Start()

local normalDif = {
	Easy = Color3.fromRGB(119, 243, 71),
	Medium = Color3.fromRGB(255, 255, 0),
	Hard = Color3.fromRGB(255, 124, 0),
	Difficult = Color3.fromRGB(255, 0, 0),
	Challenging = Color3.fromRGB(194, 0, 0),
	Intense = Color3.fromRGB(25, 34, 45),
	Remorseless = Color3.fromRGB(200, 0, 200),
}

local soulCrushingDif = {
	Insane = Color3.fromRGB(0, 0, 255),
	Extreme = Color3.fromRGB(2, 128, 255),
	Terrifying = Color3.fromRGB(0, 255, 255), 
	Catastrophic = Color3.fromRGB(255, 255, 255),
	Horrific = Color3.fromRGB(150, 150, 255),
	Unreal = Color3.fromRGB(75, 0, 255),
	TowerRush = Color3.fromRGB(255, 255, 255),
}

local RemotesFolder:Folder = ReplicatedStorage.Communicators

local RemoteEvents:{[string]:RemoteEvent} = {}
local BindableEvents:{[string]:BindableEvent} = {}

local RemoteFunctions:{[string]:RemoteFunction} = {}

do 
	for k:number, v:Instance in RemotesFolder:GetDescendants() do
		if v:IsA("RemoteEvent") then
			RemoteEvents[v.Name] = v
		elseif v:IsA("BindableEvent") then
			BindableEvents[v.Name] = v
		elseif v:IsA("RemoteFunction") then
			RemoteFunctions[v.Name] = v
		end
	end
end

BindableEvents.DataUpdate.Event:Connect(function(Type, data)
	if Type == "SettingsClient" then
		playerData = data
	end
end)

function typeCheck(triggerPart, cutsceneType, additionalInfo)
	print(cutsceneType)
	
	if cutsceneType == "Advance" then
		textEffect(triggerPart, workspace.Towers:FindFirstChild(triggerPart).Difficulty.Value, false, additionalInfo, cutsceneType)
		return
	elseif cutsceneType == "Portal" then
		task.spawn(function()
			cutscene(triggerPart, cutsceneType, additionalInfo)
		end)
		
		task.spawn(function()
			portalTransition(triggerPart, cutsceneType, additionalInfo)
		end)
	elseif cutsceneType == "TowerRush" then
		cutscene(triggerPart, cutsceneType, additionalInfo)
	elseif cutsceneType == "Win" then
		win()
	end
end

function cutscene(triggerPart, cutsceneType, additionalInfo)
	if db == true or playerData == nil or playerData["DisplayPortalTransitions"] == false then return end
	
	local sc = nil
	
	db = true

	if normalDif[triggerPart.Name] then
		sc = false
	elseif soulCrushingDif[triggerPart.Name] then
		sc = true
	end

	local towerName:string

	if cutsceneType == "Portal" then
		towerName = workspace.Towers:FindFirstChild(triggerPart.TowerPortal.Value).ProperName.Value
	elseif cutsceneType == "TowerRush" then
		towerName = additionalInfo
	end

	workspace.Camera.CameraType = Enum.CameraType.Scriptable

	TweenService:Create(workspace.Camera, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = triggerPart.Centre.WorldCFrame}):Play()

	task.wait(1)

	textEffect(towerName, triggerPart.Name, sc)
	
	workspace.Camera.CameraType = Enum.CameraType.Custom
	workspace.Camera.CameraSubject = plr.Character:WaitForChild("Humanoid")
end

function win()
	if playerData == nil or playerData["FadeToWhiteOnWin"] == false then return end

	script.RisingChimes:Play()

	camShake:Shake(cameraShake.Presets.Win)

	TweenService:Create(colourCorrection, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Brightness = 1}):Play()
end

function textEffect(towerName, dif, sc, additionalInfo1, additionalInfo2)
	if playerData == nil or playerData["DisplayTowerTitles"] == false then return end
	
	if additionalInfo2 == "Advance" then
		towerName = additionalInfo1
	end
	
	for count = 1, towerName:len(), 1 do
		--print(towerName:sub(count, count))

		local labelFrame:Frame = gui.Holder.Template:Clone()
		labelFrame.Parent = gui.Holder
		labelFrame.Label.Text = towerName:sub(count, count)
		labelFrame.Label.TextTransparency = 1
		labelFrame.Visible = true
		labelFrame.LayoutOrder = count
		labelFrame.Name = "Letter"
		labelFrame.Label.UIStroke.Transparency = 1

		if sc == false then
			local h, s, v = normalDif[dif]:ToHSV()

			labelFrame.Label.TextColor3 = normalDif[dif]
			
			if v ~= 0 then
				labelFrame.Label.UIStroke.Color = Color3.fromHSV(h, s, v / 2)
			else
				labelFrame.Label.UIStroke.Color = Color3.fromHSV(h, s, v)
			end
		elseif sc == true then
			local h, s, v = soulCrushingDif[dif]:ToHSV()

			labelFrame.Label.Font = Enum.Font.Bodoni
			
			if dif ~= "Horrific" and dif ~= "Unreal" then
				labelFrame.Label.TextColor3 = soulCrushingDif[dif]
				
				if v ~= 0 then
					labelFrame.Label.UIStroke.Color = Color3.fromHSV(h, s, v / 2)
				else
					labelFrame.Label.UIStroke.Color = Color3.fromHSV(h, s, v)
				end
			else
				labelFrame.Label.UIStroke.Color = Color3.fromHSV(h, s, v)
				labelFrame.Label.TextColor3 = Color3.new(0, 0, 0)
			end
		end

		task.spawn(function()
			if dif == "TowerRush" then
				local hue = 0
				
				labelFrame.Label.TextColor3 = Color3.fromHSV(0, 1, 1)
				
				for count2 = 1, count do
					task.wait()
				end
				
				while task.wait() do
					if not labelFrame and not labelFrame:FindFirstChild("Label") then
						return
					else
						if hue >= 360 then hue = 0 end
						hue += 3
						
						if labelFrame and labelFrame:FindFirstChild("Label") then
							labelFrame.Label.TextColor3 = Color3.fromHSV(0 + (1 * (hue / 360)), 1, 1)
							labelFrame.Label.UIStroke.Color = Color3.fromHSV(0 + (1 * (hue / 360)), 1, 0.5)
						end
					end
				end
			end
		end)

		TweenService:Create(labelFrame.Label, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
		TweenService:Create(labelFrame.Label.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0}):Play()

		task.spawn(function()
			if sc == true then
				for count = 1, 100 do
					if labelFrame and labelFrame:FindFirstChild("Label") then
						TweenService:Create(labelFrame.Label, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(math.random(42, 58) / 100, 0, math.random(42, 58) / 100, 0)}):Play()
						--labelFrame.Label.Position = UDim2.new(math.random(42, 58) / 100, 0, math.random(42, 58) / 100, 0)
						task.wait(0.05)
					end
				end
			end
		end)

		task.spawn(function()
			task.wait(4)

			TweenService:Create(labelFrame.Label, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
			TweenService:Create(labelFrame.Label.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 1}):Play()

			db = false

			task.wait(1)

			labelFrame:Destroy()

			gui.Holder.UIListLayout.Padding = UDim.new(-0.03, 0)
		end)
	end

	local tween = TweenService:Create(gui.Holder.UIListLayout, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Padding = UDim.new(0, 0)})
	tween:Play()

	task.spawn(function()
		repeat
			if gui.Holder.UIListLayout.AbsoluteContentSize.X > workspace.Camera.ViewportSize.X * 0.95 then
				tween:Cancel()
				break
			end
			task.wait()
		until tween.PlaybackState == Enum.PlaybackState.Completed
	end)
end

function portalTransition(portalPart, cutsceneType, additonalInfo)
	if db == true or playerData == nil or playerData["DisplayPortalTransitions"] == false then return end

	local sc = nil

	debounce = true

	if normalDif[portalPart.Name] then
		sc = false
	elseif soulCrushingDif[portalPart.Name] then
		sc = true
	end

	task.wait(0.5)
	
	for count = 1, 10 do
		local left:Frame = portal:FindFirstChild("Left" .. count)
		local right:Frame = portal:FindFirstChild("Right" .. count)

		TweenService:Create(left, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(-0.5, left.Position.Y.Scale)}):Play()

		TweenService:Create(right, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, right.Position.Y.Scale)}):Play()
	end

	task.wait(2)

	for count = 1, 10 do
		local left:Frame = portal:FindFirstChild("Left" .. count)
		local right:Frame = portal:FindFirstChild("Right" .. count)

		TweenService:Create(left, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(-1.1, left.Position.Y.Scale)}):Play()

		task.wait(0.04)

		TweenService:Create(right, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(1.1, right.Position.Y.Scale)}):Play()

		task.wait(0.04)
	end

	debounce = false
	
	task.wait(1)
end

function transition()
	if debounce == true then return end

	debounce = true

	local Goal = {}
	Goal.Position = UDim2.new(0, 0, 0, 0)

	local TweenInfIn = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local TweenInfOut = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	local whiteMoveIn = TweenService:Create(white, TweenInfIn, Goal)
	local blackMoveIn = TweenService:Create(black, TweenInfIn, Goal)

	whiteMoveIn:Play()

	task.wait(0.25)

	blackMoveIn:Play()

	blackMoveIn.Completed:Connect(function()
		TweenService:Create(black.Logo, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0.65, 0, 0.5, 0), Rotation = -7}):Play()

		task.wait(0.5)

		local Goal2 = {}
		Goal2.Position = UDim2.new(1.5, 0, 0, 0)

		local whiteMoveOut = TweenService:Create(white, TweenInfOut, Goal2)
		local blackMoveOut = TweenService:Create(black, TweenInfOut, Goal2)

		blackMoveOut:Play()

		task.wait(0.25)

		whiteMoveOut:Play()

		whiteMoveOut.Completed:Connect(function()
			black.Position = UDim2.new(-1.5, 0, 0, 0)
			black.Logo.Position = UDim2.new(0.5, 0, 0.5, 0)
			black.Logo.Rotation = 0
			white.Position = UDim2.new(-1.5, 0, 0, 0)

			debounce = false
		end)
	end)
end

function onPlayerDied()
	dead = true
	
	print(playerData["DisplayDeathScreen"])
	
	if playerData["DisplayDeathScreen"] == false then
		task.wait(3)
		
		RemoteEvents.RespawnPlayer:FireServer()
		
		dead = false
	else
		local previousSong = nil
		local tween

		currentTower = RemoteFunctions.RequestCurrentTower:InvokeServer(plr.Name)

		script.Stop:Play()

		local colorCorrection:ColorCorrectionEffect = game.Lighting:FindFirstChild("MTKColorCorrectionEffect")
		colorCorrection.Saturation = -1

		fixed.ImageTransparency = 0
		fixed.Position = UDim2.fromScale(0.5, 1.2)
		fixed.Size = UDim2.fromScale(0.1, 0.1)

		TweenService:Create(fixed, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.4)}):Play()

		task.wait(1)

		tween = TweenService:Create(fixed, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Size = UDim2.fromScale(0.2, 0.2)})
		tween:Play()

		tween.Completed:Connect(function()
			script.Bass:Play()


			task.spawn(function()
				while task.wait() do
					if dead == true then
						if previousSong == nil then
							previousSong = musicModule.CurrentSong.song

							if not previousSong:FindFirstChild("PitchShiftSoundEffect") then
								local pitchShift:PitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")

								pitchShift.Octave = 0.5
								pitchShift.Parent = previousSong
								pitchShift.Name = "PitchShiftSoundEffect"
							end

							previousSong.PlaybackSpeed *= 0.75
						elseif previousSong ~= nil then
							if musicModule.CurrentSong.song ~= previousSong then
								previousSong.PlaybackSpeed /= 0.75

								if previousSong:FindFirstChild("PitchShiftSoundEffect") then
									previousSong.PitchShiftSoundEffect:Destroy()
								end

								previousSong = musicModule.CurrentSong.song

								if not previousSong:FindFirstChild("PitchShiftSoundEffect") then
									local pitchShift:PitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")

									pitchShift.Octave = 0.5
									pitchShift.Parent = previousSong
									pitchShift.Name = "PitchShiftSoundEffect"
								end

								previousSong.PlaybackSpeed *= 0.75
							end
						end
					else
						previousSong.PlaybackSpeed /= 0.75

						if previousSong:FindFirstChild("PitchShiftSoundEffect") then
							previousSong.PitchShiftSoundEffect:Destroy()
						end

						break
					end
				end
			end)


			fixed.ImageTransparency = 1
			broken.ImageTransparency = 0
			death.Flash.BackgroundTransparency = 0
			death.BackgroundTransparency = 0
			death.Respawn.Lobby.Visible = true

			death.TextLabel.Text = randomizedText.returnDeathText(currentTower)

			if currentTower ~= "" then
				death.Respawn.Tower.Visible = true
			end

			fixed.Size = UDim2.fromScale(0.5, 0.4)
			broken.Size = UDim2.fromScale(0.5, 0.4)
			broken.Rotation = math.random(-180, 180)

			TweenService:Create(broken, TweenInfo.new(0.45, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.fromScale(0.5, 0.4)}):Play()
			TweenService:Create(death.Flash, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 1}):Play()
		end)
	end
end

function respawn(location)
	script.Reverse:Play()
	
	death.TextLabel.Text = randomizedText.returnReviveText(currentTower, location)
	death.TextLabel.Position = UDim2.fromScale(0.5, 0.175)
	TweenService:Create(death.TextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.15)}):Play()
	
	death.Respawn.Lobby.Visible = false
	death.Respawn.Tower.Visible = false
	
	local ogPos = broken.Position
	
	for count = 1, 60 do
		local BobbleX = (math.cos(os.clock() * 30) * (count / 2400)) -- Increase 20 for an intense shake. Increase decimal number for how far it goes.
		local BobbleY = math.abs(math.sin(os.clock() * 30) * (count / 2400)) -- Increase 30 for an intense shake. Increase decimal number for how it goes.
		broken.Position = ogPos + UDim2.new(BobbleX,0,BobbleY,0) -- Adding pos to the elements, so we can keep the UDIM2 relative to its original position.
		
		task.wait(1 / 60)
	end
	
	broken.Position = ogPos
	death.Flash.BackgroundTransparency = 0
	
	TweenService:Create(death.Flash, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
	
	fixed.ImageTransparency = 0
	broken.ImageTransparency = 1
	
	task.wait(1)
	
	TweenService:Create(fixed, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Size = UDim2.fromScale(0.9, 0.9)}):Play()
	
	task.wait(0.5)
	
	death.Flash.BackgroundTransparency = 0
	
	TweenService:Create(death.Flash, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
	
	script.Bass:Play()
	
	dead = false
	return true
end

function flash()
	if playerData == nil then return end
	if debounce == true or playerData["DisplayFlashEffect"] == false then return end

	debounce = true

	if playerData["DarkFlashes"] == true then colourCorrection.Brightness = -1 else colourCorrection.Brightness = 1 end
	
	script.Flash:Play()

	task.wait(0.25)

	TweenService:Create(colourCorrection, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Brightness = 0}):Play()

	task.wait(0.25)

	debounce = false
end

for i, part in ipairs(workspace.Markers:GetChildren())  do
	if part:IsA("Part") and part.Name == "LobbyTP" then
		part.Touched:Connect(function(otherPart)
			if otherPart.Parent:FindFirstChild("Humanoid") then
				if Players:GetPlayerFromCharacter(otherPart.Parent) == plr or Players:GetPlayerFromCharacter(otherPart.Parent.Parent) == plr then
					flash()
				end
			end
		end)
	end
end

for i, part in ipairs(workspace.Portals:GetChildren()) do
	if part:IsA("Part") and part.Name == "ViewingArea" then
		part.Touched:Connect(function(otherPart)
			if otherPart.Parent:FindFirstChild("Humanoid") then
				if Players:GetPlayerFromCharacter(otherPart.Parent) == plr or Players:GetPlayerFromCharacter(otherPart.Parent.Parent) == plr then
					flash()
				end
			end
		end)
	end
end

death.Respawn.Lobby.MouseButton1Click:Connect(function()
	local respawn = respawn("Lobby")
	
	if respawn == true then RemoteEvents.RespawnPlayer:FireServer() end
end)

death.Respawn.Tower.MouseButton1Click:Connect(function()
	local respawn = respawn("Tower")

	if respawn == true then RemoteEvents.RestartRequested:FireServer("Death") end
end)

BindableEvents.GuiTransition.Event:Connect(transition)
RemoteEvents.Effect.OnClientEvent:Connect(typeCheck)

plr.CharacterAdded:Connect(function()
	fixed.Size = UDim2.fromScale(0.2, 0.2)
	fixed.ImageTransparency = 1
	broken.ImageTransparency = 1
	death.BackgroundTransparency = 1
	death.Respawn.Lobby.Visible = false
	death.Respawn.Tower.Visible = false
	death.TextLabel.Text = ""
	game.Lighting:WaitForChild("MTKColorCorrectionEffect").Brightness = 0
	
	hum = plr.Character:WaitForChild("Humanoid")
	hum.Died:Connect(onPlayerDied)
end)

plr.Character:WaitForChild("Humanoid").Died:Connect(onPlayerDied)
