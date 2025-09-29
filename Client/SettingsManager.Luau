local TweenService = game:GetService("TweenService")

local plrSettings = game.ReplicatedStorage.Communicators.Remotes.Functions.RequestData:InvokeServer("Settings")

local settingsTable = {}
local connection

function update()
	task.spawn(function()
		game.ReplicatedStorage.Communicators.Remotes.Events.UpdatePlayerDataClient:FireServer("Settings", settingsTable)
	end)

	task.spawn(function()
		game.ReplicatedStorage.Communicators.Bindables.Events.DataUpdate:Fire("SettingsClient", settingsTable)
	end)
end

for i, object in ipairs(script.Parent:GetDescendants()) do
	if object:IsA("ModuleScript") and object.Parent:IsA("Frame") and object.Parent.Visible == true then
		--table.insert(settingsTable, require(object))
		local module = require(object)
		
		module.setValue(plrSettings)
		
		settingsTable[object.Parent.Name] = module.ReturnData()
		
		script.Parent.Parent.Parent.Changed:Connect(function()
			if script.Parent.Parent.Parent.Visible == false then
				settingsTable[object.Parent.Name] = module.ReturnData()
			end
		end)
		
		script.InstantUpdate.Event:Connect(function()
			settingsTable[object.Parent.Name] = module.ReturnData()
		end)
	end
	
	update()
end

script.Parent.Parent.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Parent.Parent.Visible == true then
		return
	end
	
	task.wait()
	
	update()
end)

script.InstantUpdate.Event:Connect(function()
	task.wait()
	
	update()
end)
