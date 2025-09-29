--!strict
-- Written by fanofpixels

local m = {}

-- Find instances of {Time:seconds} in a string and format it
function m:FormatTimeSyntax(Text:string):string
	local NewText:string = Text:gsub("{Time:%d+%.?%d*}",function(Match:string)
		local NumStart:number?, NumEnd:number? = Match:find("%d+%.?%d*")
		if NumStart and NumEnd then
			local TimeText:string = Match:sub(NumStart,NumEnd)
			local Time:number? = tonumber(TimeText)
			return m:FormatTimer(Time or 0)
		else
			return ""
		end
	end)
	
	return NewText
end

function m:FormatTimer(Time:number):string
	local Milliseconds:number = math.floor((Time % 1) * 100)
	local MillisecondsText:string = tostring(Milliseconds)
	if Milliseconds < 10 then 
		MillisecondsText = "0"..MillisecondsText
	end

	local Seconds:number = math.floor(Time % 60)
	local SecondsText:string = tostring(Seconds)
	if Seconds < 10 then 
		SecondsText = "0"..SecondsText
	end

	local Minutes:number = math.floor(Time / 60)
	local MinutesText:string = tostring(Minutes)
	if Minutes < 10 then -- extend the minutes text to double-digits if it's still in the ones place
		MinutesText = "0"..MinutesText
	end
	return MinutesText..":"..SecondsText.."."..MillisecondsText
end

return m
