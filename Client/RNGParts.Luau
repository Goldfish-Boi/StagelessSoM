local TweenService = game:GetService("TweenService")
local BadgeService = game:GetService("BadgeService")
local Debris = game:GetService("Debris")

local checker = workspace.Lobby["Bagger 293"].RarityChecker
local destroyer = workspace.Lobby["Bagger 293"].BaggerPartDestroyer
local moniter = checker.Moniter
local serverRarest = checker.ServerRarest
local sensor = checker.Sensor
local antiFallenPart = workspace.Lobby["Bagger 293"].BaggerAntiFallen
local emit = workspace.Lobby["Bagger 293"].Emitters:GetChildren()

local folder = Instance.new("Folder")
folder.Name = "BaggerParts"
folder.Parent = workspace.Camera

local rarest = 1
local active = true
local previous = nil

local partsActive = true
local dustActive = true

sensor.Touched:Connect(function(part)
	if part:FindFirstChild("Rarity") and part.Name ~= "InceptedPart" then
		moniter.SurfaceGui.Frame.Rarity.Text = "1 / " .. part.Rarity.Value
		
		task.spawn(function()
			sensor.Sound:Play()
		end)
		
		if part.Rarity.Value > rarest then
			rarest = part.Rarity.Value
			
			serverRarest.SurfaceGui.Frame.Rarity.Text = "1 / " .. part.Rarity.Value
		end
	end
end)

antiFallenPart.Touched:Connect(function(part)
	if part.Name == "BaggerPart" or part.Name == "InceptedPart" then
		if active == true then
			part.Position = workspace.Lobby["Bagger 293"].BaggerSpawnPart.Position
		else
			part:Destroy()
		end
	end
end)

destroyer.Touched:Connect(function(part)
	if part.Name == "BaggerPart" or part.Name == "InceptedPart" then
		part:Destroy()
	elseif part.Parent:FindFirstChild("Humanoid") then
		part.Parent.Humanoid.Health = 0
	end
end)

local materials = {
	Enum.Material.Plastic,
	Enum.Material.Rock,
	Enum.Material.Concrete,
	Enum.Material.Glass,
	Enum.Material.Neon,
	Enum.Material.ClayRoofTiles,
	Enum.Material.DiamondPlate,
	Enum.Material.CorrodedMetal,
	Enum.Material.Mud,
	Enum.Material.Rubber,
	Enum.Material.Metal,
	Enum.Material.Foil
}

function applyVariants(part:Part)
	local rarity = Instance.new("NumberValue")
	
	rarity.Name = "Rarity"
	rarity.Parent = part
	rarity.Value = 1
	
	if math.random(1, 20) == 1 then --Spherical
		part.Shape = Enum.PartType.Ball
		
		rarity.Value *= 20
	end
	if math.random(1, 25) == 1 then --Reflective
		part.Reflectance = 1
		part.Material = Enum.Material.Plastic
		
		rarity.Value *= 25
	end
	if math.random(1, 30) == 1 then --BoundingBox
		local boundingBox = Instance.new("SelectionBox")
		boundingBox.Name = "Bounding Box"
		boundingBox.Parent = part
		boundingBox.Color3 = Color3.new(0, 0, 0)
		boundingBox.LineThickness = 0.125
		boundingBox.Adornee = part
		
		rarity.Value *= 30
	end
	if math.random(1, 35) == 1 then --Particle
		local particle = Instance.new("ParticleEmitter")
		
		particle.Name = "Particle"
		particle.Parent = part
		particle.LockedToPart = true
		particle.Shape = Enum.ParticleEmitterShape.Sphere
		particle.Lifetime = NumberRange.new(1)
		particle.Transparency = NumberSequence.new(0, 1)
		particle.Size = NumberSequence.new(1, 0)
		particle.Speed = NumberRange.new(2)
		
		rarity.Value *= 35
	end
	if math.random(1, 40) == 1 then --Glow
		local light = Instance.new("PointLight")
		
		light.Name = "Light"
		light.Parent = part
		light.Color = part.Color
		light.Range = 35
		light.Shadows = true
		
		rarity.Value *= 40
	end
	if math.random(1, 45) == 1 then --Fire
		local fire = Instance.new("Fire")
		
		fire.Name = "Fire"
		fire.Parent = part
		
		rarity.Value *= 45
	end
	if math.random(1, 50) == 1 then
		local a0 = Instance.new("Attachment")
		local a1 = Instance.new("Attachment")
		local trail = Instance.new("Trail")
		
		a0.Name = "A0"
		a1.Name = "A1"
		
		a0.Parent = part
		a1.Parent = part
		
		a0.Position = Vector3.new(-part.Size.X/2, 0, 0)
		a1.Position = Vector3.new(part.Size.X/2, 0, 0)
		
		trail.Parent = part
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		
		trail.Lifetime = 1
		trail.WidthScale = NumberSequence.new(1, 0)
		trail.Transparency = NumberSequence.new(0, 1)
		trail.FaceCamera = true
		
		rarity.Value *= 50
	end
	
	if math.random(1, 100) == 1 then --Rainbow
		task.spawn(function()
			local prevHue, sat, val = part.Color:ToHSV()
			local hue = 0

			while true do
				part.Color = Color3.fromHSV(hue, sat, val)
				
				for i, object in ipairs(part:GetChildren()) do
					if object:IsA("Light") then
						part.Light.Color = Color3.fromHSV(hue, sat, val)
					end
					if object:IsA("Fire") then
						part.Fire.Color = Color3.fromHSV(hue, sat, val)
						part.Fire.SecondaryColor = Color3.fromHSV(hue, sat, val)
					end
					if object:IsA("Trail") then
						object.Color = ColorSequence.new(Color3.fromHSV(hue, sat, val))
					end
					if object.Name == "InceptedPart" then
						object.Color = Color3.fromHSV(hue, sat, val)
					end
				end
				
				hue = (hue + 0.03) % 1
				task.wait(0.05)
			end
		end)
		rarity.Value *= 100
	end
	
	if math.random(1, 5) == 1 then --Clear
		part.Transparency = 0.5

		rarity.Value *= 5

		if math.random(1, 15) == 1 then -- Incepted
			part.Transparency = 0.85
			for count = 1, 5 do
				local clone = part:Clone()
				clone.Parent = part
				clone.Name = "InceptedPart"
				clone.Size = Vector3.new(-(part.Size.X / 5) * count + part.Size.X, -(part.Size.Y / 5) * count + part.Size.Y, -(part.Size.Z / 5) * count + part.Size.Z)
				clone.CanCollide = false

				if clone:FindFirstChild("Particle") then
					clone.Particle:Destroy()
				end
				if clone:FindFirstChild("Light") then
					clone.Light:Destroy()
				end
				if clone:FindFirstChild("Rarity") then
					clone.Rarity:Destroy()
				end
				if clone:FindFirstChild("A0") then
					clone.A0.Position = Vector3.new(-clone.Size.X/2, 0, 0)
				end
				if clone:FindFirstChild("A1") then
					clone.A1.Position = Vector3.new(clone.Size.X/2, 0, 0)
				end

				local weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = clone
				weld.Part1 = part
				
				task.spawn(function()
					while part and task.wait() do
						for i, object in ipairs(part:GetChildren()) do --Corrector
							if object.Name == "InceptedPart" then
								object.Anchored = false
								object.Position = part.Position

								task.spawn(function()
									task.wait()
									object.Position = part.Position
								end)
							end
						end
					end
				end)
			end
			rarity.Value *= 15
		end
	end
	
	--task.wait(0.25)
	
	for i, object in ipairs(part:GetChildren()) do --Corrector
		if object.Name == "InceptedPart" then
			object.Position = part.Position
			
			for i, objectObjects in ipairs(object:GetChildren()) do
				if objectObjects.Name == "InceptedPart" then
					objectObjects:Destroy()
				end
			end
		end
	end
	
	part.Anchored = false
	part.Parent = folder
	
	task.spawn(function()
		while task.wait() do
			if part then
				for i, object in ipairs(part:GetChildren()) do --Corrector
					if object.Name == "InceptedPart" then
						object.Anchored = false
						object.Position = part.Position

						task.spawn(function()
							task.wait()
							object.Position = part.Position
						end)
					end
				end
			else
				break
			end
		end
	end)
	
	if rarity.Value >= 10000 then
		local badgeClick = Instance.new("ClickDetector")
		
		local badgeID = 2768405557715236
		
		badgeClick.Parent = part
		
		badgeClick.MouseClick:Connect(function(plr)
			game.ReplicatedStorage.Communicators.Remotes.Events.AwardBadge:FireServer(badgeID)
			script.BadgeSound:Play()
		end)
	end
end

function waitForWheel()
	task.spawn(function()
		while task.wait(0.1) do
			if workspace:FindFirstChild("ClientParts") then
				if workspace:FindFirstChild("ClientParts"):FindFirstChild("BaggerWheel", true) then
					check(workspace:FindFirstChild("ClientParts"):FindFirstChild("BaggerWheel", true))
					
					break
				end
			end
		end
	end)
end

function check(baggerWheel)
	if not baggerWheel then
		waitForWheel()
		return
	end
	
	task.spawn(function()
		while task.wait(2) do
			--print("Guh")
			--print(baggerWheel.PrimaryPart.Anchored)
			
			if not baggerWheel or not baggerWheel.PrimaryPart then
				waitForWheel()
				break
			end
			
			if baggerWheel.PrimaryPart.Anchored == false then
				if previous == nil or previous == false then
					active = true

					task.spawn(function()
						parts()
					end)

					task.spawn(function()
						dust()
					end)

					previous = true
				end
			else
				if previous == true or previous == nil then
					active = false
					partsActive = false
					dustActive = false
					
					previous = false
				end
			end
		end
	end)
end

waitForWheel()

--sqrt((charPos.X - objectPos.X)^2 + (charPos.Y - objectPos.Y)^2 + (charPos.Z - objectPos.Z)^2)

function parts()
	if partsActive == true then return end
	
	partsActive = true
	
	while task.wait(math.random(2, 3)) do
		if active == true then
			local amount = math.random(1, 4)

			for count = 1, amount do
				local part = workspace.Lobby["Bagger 293"].BaggerSpawnPart:Clone()

				part.Name = "BaggerPart"
				--part.Parent = folder
				part.CanCollide = true
				part.Anchored = true
				part.Material = materials[math.random(1, #materials)]
				part.Transparency = 0
				part.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
				part.Size = Vector3.new(math.random(1, 5), math.random(1, 5), math.random(1, 5))

				applyVariants(part)

				task.spawn(function()
					task.wait(150)

					part:Destroy()
				end)
			end
		else
			break
		end
	end
end

local folder2 = Instance.new("Folder")
folder2.Name = "BaggerDust"
folder2.Parent = workspace.Camera

local dustClouds = game.ReplicatedStorage.RingExclusiveAssets.DustClouds:GetChildren()

function dust()
	if dustActive == true then return end

	dustActive = true
	
	while task.wait(0.025) do
		if active == true then
			local dust:Model = dustClouds[math.random(1, #dustClouds)]:Clone()
			local specEmit:Part = emit[math.random(1, #emit)]
			local GoToPos = specEmit.CFrame * CFrame.new(math.random(-40, 40), 0, math.random(-35, 35))
			local RanOri = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))

			dust.Parent = folder2
			dust:PivotTo(specEmit.CFrame)

			for i, part:Part in ipairs(dust:GetChildren()) do
				part.Size = Vector3.new(part.Size.X / 100, part.Size.Y / 100, part.Size.Z / 100)

				TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {Size = Vector3.new(part.Size.X * 175, part.Size.Y * 175, part.Size.Z * 175)}):Play()
				TweenService:Create(part, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = GoToPos, Orientation = RanOri}):Play()
				Debris:AddItem(part.Parent, 4)
			end
		else
			break
		end
	end
end
