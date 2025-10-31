local db = {}

for i,v in pairs(workspace.Badges:GetChildren()) do
	db[v.Id.Value] = {}
	v.Touched:Connect(function(hit)
		print(hit)
		local p = game.Players:GetPlayerFromCharacter(hit:FindFirstAncestorWhichIsA("Model"))
		if db[v.Id.Value][p] then return end
		if p then

			db[v.Id.Value][p] = true
		end
		local a = game.ReplicatedStorage.HasBadgeBind:Invoke(p.UserId,v.Id.Value)
		if p and not a then
			game.ReplicatedStorage.Badge:Invoke(p.UserId, v.Id.Value)
		end
		if p then

			db[v.Id.Value][p] = false
		end
	end)
end