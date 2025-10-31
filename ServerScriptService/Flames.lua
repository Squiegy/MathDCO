local ds = game:GetService('DataStoreService'):GetDataStore('Flames')
local ticketsLb = game:GetService('DataStoreService'):GetOrderedDataStore('Tickets')
local template = {
	
}

function giveFlame(player,flame,value)
	local t = ds:GetAsync('Player_'.. player.UserId)
	t[flame] = value
	ds:SetAsync('Player_'.. player.UserId,t)
	game.ReplicatedStorage.Flame:FireClient(player,ds:GetAsync('Player_'.. player.UserId))
end

function equipFlame(player,name)
	for i,v in pairs(player.Character:GetChildren()) do
		if string.find(v.Name,'Flame') then v:Destroy() end
	end	
	if game.ReplicatedStorage.Fire:FindFirstChild(name) == nil then return end
	local char = player.Character
	local head = char:WaitForChild("Head") --You can change this to another body part
	game.ReplicatedStorage.FlameCheck:FireClient(player,player.stats.CurrentFlame.Value,true)
	game.ReplicatedStorage.Flame:FireClient(player,ds:GetAsync('Player_'.. player.UserId))
	local newPart = game.ReplicatedStorage.Fire:FindFirstChild(name):Clone()
	newPart.Transparency = 1
	newPart.Anchored = false
	newPart.CanCollide = false
	newPart.Massless = true
	newPart.Parent = char

	local weld = Instance.new("Weld", head) --Could also use a Motor6D, or likewise
	weld.C0 = CFrame.new(0,-3.5,0)*CFrame.Angles(0, 0, math.rad(180)) --Both C0 and C1 are, by default, set to a blank CFrame
	weld.C1 = CFrame.new()
	weld.Part0 = head
	weld.Part1 = newPart 
end

for i,v in pairs(game.ReplicatedStorage.Fire:GetChildren()) do
	template[v.Name] = false
end

game.Players.PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(char)
		if not ds:GetAsync('Player_'.. player.UserId) then
			ds:SetAsync('Player_'.. player.UserId,template)
		end
		local t = {}
		for i,v in pairs(template) do
			if ds:GetAsync('Player_'.. player.UserId)[i] == nil then
				t[i] = false
			else
				t[i] = ds:GetAsync('Player_'.. player.UserId)[i]
			end
		end
		ds:SetAsync('Player_'.. player.UserId,t)
		game.ReplicatedStorage.Flame:FireClient(player,ds:GetAsync('Player_'.. player.UserId))
		
		equipFlame(player,player:WaitForChild('stats'):WaitForChild('CurrentFlame').Value)
		
	end)
end)


game.ReplicatedStorage.FlameToggle.OnServerInvoke = function(p,name)
	if ds:GetAsync('Player_'.. p.UserId)[name] == false then return false end
	if name == p.stats.CurrentFlame.Value then
		
		p.stats.CurrentFlame.Value = ''
		equipFlame(p,'')
		return false
	else
		p.stats.CurrentFlame.Value = name
		equipFlame(p,name)
		return true
	end 
end