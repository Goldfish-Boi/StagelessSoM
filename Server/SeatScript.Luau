local prev = nil

script.Parent.Seat.Changed:Connect(function()
	if script.Parent.Seat.Occupant then
		local sit = script.Parent.Seat.Occupant:LoadAnimation(script.Parent.Sit)
		
		prev = script.Parent.Seat.Occupant
		
		repeat
			sit:Play()
			task.wait()
		until script.Parent.Seat.Occupant == nil
		
		sit:Stop()
	end
end)
