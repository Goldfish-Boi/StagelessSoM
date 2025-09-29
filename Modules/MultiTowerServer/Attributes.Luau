--!strict
-- Written by fanofpixels

local m = {}

function m:GetNumber(Ins:Instance,Name:string):number?
	local Val:Instance? = Ins:FindFirstChild(Name)
	if Val and Val:IsA("NumberValue") then
		return Val.Value
	end
	return Ins:GetAttribute(Name)::number?
end

function m:GetInt(Ins:Instance,Name:string):number?
	local Val:Instance? = Ins:FindFirstChild(Name)
	if Val and Val:IsA("IntValue") then
		return Val.Value
	end
	return Ins:GetAttribute(Name)::number?
end

function m:GetString(Ins:Instance,Name:string):string?
	local Val:Instance? = Ins:FindFirstChild(Name)
	if Val and Val:IsA("StringValue") then
		return Val.Value
	end
	return Ins:GetAttribute(Name)::string?
end

function m:GetBoolean(Ins:Instance,Name:string):boolean?
	local Val:Instance? = Ins:FindFirstChild(Name)
	if Val and Val:IsA("BoolValue") then
		return Val.Value
	end
	return Ins:GetAttribute(Name)::boolean?
end


return m
