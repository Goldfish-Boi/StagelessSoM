local module = {}

local TweenService = game:GetService("TweenService")

local value
local initilized = false

local zones = {}
local plr = game.Players.LocalPlayer
local settingsNotch = script.Parent
local bg = settingsNotch.BG
local switch = bg.Switch

local LDMFolder = Instance.new("Folder",game.ReplicatedStorage)
LDMFolder.Name = "TowerObbys"

local towerFolder,zoneFolder = workspace:FindFirstChild("Towers"),workspace:FindFirstChild("CanisterZones")

local tweenInf = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

function module.setValue(plrSettings)
	value = plrSettings["CanisterMode"]

	if value == nil then value = false end
	
	task.wait(3)
	
	module.apply()
	
	return
end

function module.apply()
	if not zoneFolder then
		return
	end
	
	if initilized == true then
		if value ~= true then TweenService:Create(switch, tweenInf, {Position = UDim2.new(0, 0, 0, 0), AnchorPoint = Vector2.new(0, 0)}):Play() else TweenService:Create(switch, tweenInf, {Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0)}):Play() end
		if value ~= true then TweenService:Create(bg, tweenInf, {BackgroundColor3 = Color3.fromRGB(191, 73, 73)}):Play() else TweenService:Create(bg, tweenInf, {BackgroundColor3 = Color3.fromRGB(73, 191, 73)}):Play() end
		if value ~= true then TweenService:Create(bg.UIStroke, tweenInf, {Color = Color3.fromRGB(124, 50, 50)}):Play() else TweenService:Create(bg.UIStroke, tweenInf, {Color = Color3.fromRGB(50, 124, 50)}):Play() end
	else
		initilized = true
	end
	
	task.spawn(function()
		if value == true then
			for coundown = 4, 1, -1 do
				script.Parent.Description.Text = "Cansiter mode has been activated. Anti-Cheese cooldown ends in " .. coundown .. "s"	
				task.wait(1)
			end
			script.Parent.Description.Text = "Canister mode has been activated"
		else
			for coundown = 4, 1, -1 do
				script.Parent.Description.Text = "Cansiter mode has been deactivated. Anti-Cheese cooldown ends in " .. coundown .. "s"
				task.wait(1)
			end
			script.Parent.Description.Text = "Canister mode has been deactivated"
		end
	end)
end

if zoneFolder == nil then
	if game.ReplicatedStorage:FindFirstChild("CanisterZones") then
		zoneFolder = game.ReplicatedStorage:FindFirstChild("CanisterZones")
	end
end

if towerFolder == nil or zoneFolder == nil then
	module.setValue(false)
	script.Parent.TextColor3 = Color3.fromRGB(222, 64, 64)
	return
end

zoneFolder.Parent = game.ReplicatedStorage

for _,t in pairs(towerFolder:GetChildren()) do
	if (t.Name ~= "ClientObjects" and t.Name ~= "EverpresentCOs") and t:FindFirstChild("Obby") then
		local folder = Instance.new("Folder",LDMFolder)
		folder.Name = t.Name
	end
end

for _,t in pairs(zoneFolder:GetChildren()) do
	if t:IsA("Folder") then
		zones[t]=t
	end
end

local function IsInZone(p,o)
	p = o.CFrame:PointToObjectSpace(p.Position)
	return math.abs(p.X)<=o.Size.X/2 and math.abs(p.Y)<=o.Size.Y/2 and math.abs(p.Z)<=o.Size.Z/2
end

local blackList = {
	"Winpad";
	"WinPad";
	"Frames";
	"LobbyTP";
}
--print(zones)
local function parentChildren(instance,parent)
	for i,v in pairs(instance:GetChildren()) do 
		if not table.find(blackList,v.Name) then
			v.Parent = parent
		end	
	end
end

local db = false

script.Parent.BG.Button.MouseButton1Click:Connect(function()
	print("Guh")
	
	if db == false then
		db = true
		
		if value == true then value = false else value = true end
		module.apply()
		
		wait(4) -- no LHJ for you!
		db = false
	end
end)

game:GetService("RunService").RenderStepped:Connect(function(delta)
	if value == true then
		if plr.Character ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") then
			local bZ
			for _,f in pairs(zones) do
				local active = false		
				for _,z in pairs(f:GetChildren()) do
					if z:IsA("BasePart") and IsInZone(plr.Character.HumanoidRootPart,z) then
						active = true
					end
					if active and (bZ == nil) then
						bZ = f
					end
				end			
			end	
			if bZ == nil then
				for _,t in pairs(towerFolder:GetChildren()) do
					if t:FindFirstChild("Obby") and LDMFolder:FindFirstChild(t.Name) then
						parentChildren(t.Obby,LDMFolder:FindFirstChild(t.Name))			
					end	
				end
			else
				parentChildren(LDMFolder:FindFirstChild(bZ.Name),towerFolder:FindFirstChild(bZ.Name).Obby)
				for _,t in pairs(towerFolder:GetChildren()) do
					if t:FindFirstChild("Obby") and LDMFolder:FindFirstChild(t.Name) and t.Name ~= bZ.Name then
						parentChildren(t.Obby,LDMFolder:FindFirstChild(t.Name))				
					end	
				end
			end
		end	
	else
		for _,t in pairs(LDMFolder:GetChildren()) do
			if towerFolder:FindFirstChild(t.Name) and towerFolder:FindFirstChild(t.Name):FindFirstChild("Obby") then
				parentChildren(t,towerFolder:FindFirstChild(t.Name).Obby)		
			end
		end	
	end
end)

function module.ReturnData()
	return value
end

return module
