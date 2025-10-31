local PS = game:GetService("PhysicsService")
local Players = game:GetService("Players")

PS:RegisterCollisionGroup("Player")
PS:CollisionGroupSetCollidable("Player", "Player", false)

local function assignPlayerCollisionGroup(char)
	char:WaitForChild("HumanoidRootPart")
	char:WaitForChild("Head")
	char:WaitForChild("Humanoid")

	for i, v:Instance in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CollisionGroup = "Player"
		end
	end
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAppearanceLoaded :Connect(function(char)
		assignPlayerCollisionGroup(char)
	end)
end)

for i, plr:Player in ipairs(Players:GetChildren()) do
	repeat wait() until plr.Character
	assignPlayerCollisionGroup(plr.Character)
end