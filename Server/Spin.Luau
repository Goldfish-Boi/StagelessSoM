local tweenService = game:GetService("TweenService")

for i, mesh in ipairs(script.Parent:GetChildren()) do
	if mesh:IsA("MeshPart") then
		tweenService:Create(mesh, TweenInfo.new(7.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Orientation = Vector3.new(mesh.Orientation.X, mesh.Orientation.Y + 360, mesh.Orientation.Z)}):Play()
	end
end
