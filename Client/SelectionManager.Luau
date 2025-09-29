local collectionService = game:GetService("CollectionService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local plr = game.Players.LocalPlayer

local mouse = plr:GetMouse()

local container = script.Selection

local gui = container.BillboardGui
local nameTag = container.NameTag
local towerInfo = container.PortalInfo

for i, object in ipairs(collectionService:GetTagged("Interactable")) do
	if object:FindFirstChild("ClickDetector") then
		local clickDetector:ClickDetector = object.ClickDetector
		local db = false
		
		clickDetector.MouseHoverEnter:Connect(function(plr)
			gui.Enabled = true
			container.Parent = workspace.Camera
			container.Position = mouse.Hit.Position
			userInputService.MouseIconEnabled = false
			
			tweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Position = object.Position}):Play()
			
			clickDetector.MouseClick:Connect(function()
				if db == true then
					return
				end
				
				db = true
				
				print("clicked")
				
				if object:HasTag("NameCheckable") then
					if nameTag.Adornee == object then
						nameTag.Adornee = nil
						nameTag.Enabled = false
					else
						nameTag.Adornee = object
						nameTag.Enabled = true
						nameTag.Frame.TextLabel.Text = object.Name
						nameTag.Frame.TextLabel.MaxVisibleGraphemes = 0
						nameTag.Frame.Position = UDim2.new(0, 0, -0.05, 0)
						nameTag.ImageLabel.Position = UDim2.new(0.5, 0, 0.45, 0)
						
						nameTag.Size = UDim2.new(4 + (0.6 * math.max(0, object.Name:len() - 4)), 0, 2, 0)
						nameTag.StudsOffsetWorldSpace = Vector3.new(0, object.Size.Y / 2, 0)
						
						tweenService:Create(nameTag.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
						tweenService:Create(nameTag.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
						tweenService:Create(nameTag.Frame.TextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {MaxVisibleGraphemes = utf8.len(object.Name)}):Play()
					end
				elseif object:HasTag("Portal") then
					if towerInfo.Adornee == object then
						gui.Enabled = true
						towerInfo.Enabled = false
					else
						local towerData = game.ReplicatedStorage.Communicators.Remotes.Functions.RequestData:InvokeServer("TowerData")
						local towerName = object:FindFirstChild("TowerPortal").Value
						
						gui.Enabled = false
						towerInfo.Enabled = true
						
						towerInfo.Frame.NameTag.Text = towerName
						towerInfo.Frame.Frame.Wins.Text = "Wins: " .. towerData[towerName]["GlobalWins"]
						towerInfo.Frame.Frame.Difficulty.Text = "Difficulty: " .. object.Name
						towerInfo.Frame.Frame.Attempts.Text = "Attempts: " .. towerData[towerName]["GlobalAttempts"]
						towerInfo.Frame.Frame.Time.Text = "Time: " .. math.round(towerData[towerName]["GlobalTimeSpent"] / 3600) .. " Hrs"
						
						--print(towerData)
					end
				end
				
				task.spawn(function()
					task.wait(0.1)
					
					db = false
				end)
			end)
			
			clickDetector.MouseHoverLeave:Connect(function(plr)
				container.Parent = plr.PlayerGui
				gui.Enabled = false
				towerInfo.Enabled = false
				userInputService.MouseIconEnabled = true
				
				nameTag.Adornee = nil
				nameTag.Enabled = false
			end)
		end)
	end
end

plr.CharacterAdded:Connect(function()
	userInputService.MouseIconEnabled = true
end)

game.ReplicatedStorage.Communicators.Remotes.Events.LoadTower.OnClientEvent:Connect(function()
	userInputService.MouseIconEnabled = true
end)
