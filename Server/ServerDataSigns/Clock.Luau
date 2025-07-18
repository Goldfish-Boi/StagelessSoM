local TweenService = game:GetService("TweenService")

local frame = script.Parent.Timer

Sec = 0
TSec = 0
Min = 0
TMin = 0
Hr = 0
THr = 0
HHr = 0

local tween = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local r = Color3.fromRGB(255, 0, 0)
local w = Color3.fromRGB(255, 255, 255)

while task.wait(1) do
	Sec += 1
	
	frame.OneSec.UIStroke.Color = r
	
	TweenService:Create(frame.OneSec.UIStroke, tween, {Color = w}):Play()
	
	if Sec == 10 then
		Sec = 0
		TSec += 1
		
		frame.TenSecs.UIStroke.Color = r
		
		TweenService:Create(frame.TenSecs.UIStroke, tween, {Color = w}):Play()
		
		if TSec == 6 then
			TSec = 0
			Min += 1
			
			frame.OneMin.UIStroke.Color = r

			TweenService:Create(frame.OneMin.UIStroke, tween, {Color = w}):Play()
			
			if frame.ColonMinSec.UIStroke.Color ~= w then
				frame.ColonMinSec.UIStroke.Color = r

				TweenService:Create(frame.ColonMinSec.UIStroke, tween, {Color = w}):Play()
			end
			
			if Min == 10 then
				Min = 0
				TMin += 1
				
				frame.TenMins.UIStroke.Color = r

				TweenService:Create(frame.TenMins.UIStroke, tween, {Color = w}):Play()
				
				if TMin == 6 then
					TMin = 0
					Hr += 1
					
					frame.OneHr.UIStroke.Color = r

					TweenService:Create(frame.OneHr.UIStroke, tween, {Color = w}):Play()
					
					if frame.ColonHrMin.UIStroke.Color ~= w then
						frame.ColonHrMin.UIStroke.Color = r

						TweenService:Create(frame.ColonHrMin.UIStroke, tween, {Color = w}):Play()
					end
					
					if Hr == 10 then
						Hr = 0
						THr += 1
						
						frame.TenHrs.UIStroke.Color = r

						TweenService:Create(frame.TenHrs.UIStroke, tween, {Color = w}):Play()
						
						if THr == 10 then
							THr = 0
							HHr += 1
							
							frame.HundredHrs.UIStroke.Color = r

							TweenService:Create(frame.HundredHrs.UIStroke, tween, {Color = w}):Play()
						end
					end
				end
			end
		end
	end
	
	frame.OneSec.Text = Sec
	frame.TenSecs.Text = TSec
	
	frame.OneMin.Text = Min
	frame.TenMins.Text = TMin
	
	frame.OneHr.Text = Hr
	frame.TenHrs.Text = THr
	frame.HundredHrs.Text = HHr
end
