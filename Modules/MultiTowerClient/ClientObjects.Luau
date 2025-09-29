--!strict
-- Written by fanofpixels

type COScriptContext = ModuleScript|StringValue

local m = {}

local HTTPService = game:GetService("HttpService")
local PhysicsService = game:GetService("PhysicsService")

local ClientObjects:Instance?

local ThreadFolder:Folder = script.Parent.ClientObjectThreads
local ThreadTemplate:LocalScript = script.ClientObjectThread
local ScriptRepo:Folder = script.Parent.ScriptRepo

function m:LoadClientObjectScript(Context:COScriptContext, Orphaned:boolean)
	
	-- Clone the thread template and set it up
	local Thread:LocalScript = ThreadTemplate:Clone()
	Thread.Name = HTTPService:GenerateGUID(false)

	local ThreadContext:ObjectValue = Thread:WaitForChild("Context")::ObjectValue
	ThreadContext.Value = Context -- The thread script will automatically figure out if this is a RunRepoScript or a ClientObjectScript
	
	Thread.Parent = Orphaned and script.Parent.EverpresentClientObjectThreads or ThreadFolder
	Thread.Enabled = true
end

function m:LoadClientObjects(COFolder:Instance, Orphaned:boolean)
	-- If "orphaned" do not do anything to the ClientObjects variable
	-- Usually used for loading everpresent COs without touching tower COs
	if not Orphaned then
		-- If there are already client objects present, delete them
		m:UnloadClientObjects()
	end
	
	-- Set the current client objects folder
	COFolder.Name = "ClientSidedObjects"
	COFolder.Parent = workspace
	if not Orphaned then
		ClientObjects = COFolder
	end
	for k:number, v:Instance in COFolder:GetDescendants() do
		
		if v.Name == "ClientObjectScript" and v:IsA("ModuleScript") then
			m:LoadClientObjectScript(v, Orphaned)
		elseif v.Name == "RunRepoScript" and v:IsA("StringValue") then
			m:LoadClientObjectScript(v, Orphaned)
		elseif v.Name == "SetCollisionGroup" and v:IsA("StringValue") then
			if v.Parent and v.Parent:IsA("BasePart") then
				--PhysicsService:SetPartCollisionGroup(v.Parent,v.Value)
				v.Parent.CollisionGroup = v.Value
			end
		elseif v.Name == "Invisible" then
			if v.Parent and v.Parent:IsA("BasePart") then
				v.Parent.Transparency = 1
			end
		elseif v.Name == "LightingChanger" and v:IsA("BasePart") then
			v.Transparency = 1
		elseif v:IsA("BasePart") and v.CollisionGroup == "Default" then
			v.CollisionGroup = "ClientObjects"
		end
	end
end

function m:UnloadClientObjects()
	-- ClientObjects may not exist as it is nilable and this function is called when there likely isn't any COs loaded at all
	-- So we check if its not nil for good measure
	if ClientObjects then
		ClientObjects:Destroy()
	end
	
	-- Kill all threads
	ThreadFolder:ClearAllChildren()
end

do
	(ThreadTemplate:WaitForChild("Repository")::ObjectValue).Value = ScriptRepo
end

return m
