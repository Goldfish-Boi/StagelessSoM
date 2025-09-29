function CheckColor3(Color)
	return typeof(Color)=="Color3"
end

function GetAllButtons(Color)
	local IsColor3 = CheckColor3(Color)
	local ButtonTable = {}
	for k,v in pairs(workspace:GetDescendants()) do
		if v.Name == "Button" and v:FindFirstChild("ClientObject") and v:FindFirstChild("Pressed") then
			local Insert = false
			if Color and IsColor3 then
				for a,b in pairs(v:GetDescendants()) do
					if b:IsA("BasePart") and b.Color == Color then
						Insert = true
					end
				end
			else
				Insert = true
			end
			if Insert then table.insert(ButtonTable,v) end
		end
	end
	return ButtonTable
end

local ButtonMT = {}
function ButtonMT:__newindex()end
function ButtonMT:__index(Color)
	if Color == "All" then
		return GetAllButtons()
	end
	return GetAllButtons(Color)
end
function ButtonMT:__call(Mode,Value,Color)
	if Mode == "Get" then
		return GetAllButtons()
	elseif Mode == "SetAll" then
		for k,v in pairs(GetAllButtons(Color)) do
			v.Pressed.Value = Value
		end
	end
end

_G.Buttons = setmetatable({},ButtonMT)
