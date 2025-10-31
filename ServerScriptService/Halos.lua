local ds = game:GetService('DataStoreService'):GetDataStore('Halos')
local restartsLb = game:GetService('DataStoreService'):GetOrderedDataStore('Restarts')
local template = {

}
local resetT = {
	[1] = 'WhiteHalo',
	[3] = 'GreenHalo',
	[5] = 'YellowHalo',
	[7] = 'OrangeHalo',
	[9] = 'RedHalo',
	[11] = 'PinkHalo',
	[13] = 'TealHalo',
	[15] = 'CyanHalo',
	[17] = 'BlueHalo',
	[19] = 'PurpleHalo',
	[25] = 'GlassHalo',
	[50] = 'RainbowHalo',
	[100] = 'FadedWhiteHalo',
	[1000] = 'ImpossibleHalo',
}
local checkpoints = workspace.Checkpoints
local maxStage = 0
maxStage = game.ReplicatedStorage.ServerStats.MaxStage.Value
game.ReplicatedStorage.ServerStats.MaxStage:GetPropertyChangedSignal('Value'):Connect(function()
	maxStage = game.ReplicatedStorage.ServerStats.MaxStage.Value
end)

function giveHalo(player,halo,value)
	local t = ds:GetAsync('Player_'.. player.UserId)
	t[halo] = value
	ds:SetAsync('Player_'.. player.UserId,t)
	game.ReplicatedStorage.Halo:FireClient(player,t)
end
local haloTable = game.ReplicatedStorage.Halos:GetChildren()
function halo(player,name)
	for i,v in pairs(workspace.Halo:GetChildren()) do
		if v.Name == player.Name then
			v:Destroy()
		end
	end	
	if game.ReplicatedStorage.Halos:FindFirstChild(name) == nil then return end
	local char = player.Character
	local head = char:WaitForChild("Head") --You can change this to another body part
	game.ReplicatedStorage.HaloCheck:FireClient(player,player.stats.CurrentHalo.Value,true)
	game.ReplicatedStorage.Halo:FireClient(player,ds:GetAsync('Player_'.. player.UserId))
	local newPart = game.ReplicatedStorage.Halos:FindFirstChild(name):Clone()
	newPart.Name = player.Name
	if newPart:IsA("Model") then
		newPart.PrimaryPart.Anchored = false
		newPart.PrimaryPart.CanCollide = false
		newPart.PrimaryPart.Massless = true
		newPart.Parent = workspace.Halo
		local weld = Instance.new("Weld", char.Head) --Could also use a Motor6D, or likewise
		weld.C0 = CFrame.new(0,1.25,0) --Both C0 and C1 are, by default, set to a blank CFrame
		weld.C1 = CFrame.new()
		weld.Part0 = head
		weld.Part1 = newPart.PrimaryPart 
	else
		if newPart:FindFirstChild('LocalScript') then
			newPart:FindFirstChild('LocalScript').Enabled = false
		end
		newPart.Anchored = false
		newPart.CanCollide = false
		newPart.Massless = true
		newPart.Parent = workspace.Halo
		local weld = Instance.new("Weld", char.Head) --Could also use a Motor6D, or likewise
		weld.C0 = CFrame.new(0,1.25,0) --Both C0 and C1 are, by default, set to a blank CFrame
		weld.C1 = CFrame.new()
		weld.Part0 = head
		weld.Part1 = newPart 
	end
end

for i,v in pairs(game.ReplicatedStorage.Halos:GetChildren()) do
	template[v.Name] = false
end

game.Players.PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(char)
		local d = ds:GetAsync('Player_'.. player.UserId)
		if not d then
			d = template
			ds:SetAsync('Player_'.. player.UserId,template)
		end
		local t = {}
		for i,v in pairs(template) do
			if d[i] == nil then
				t[i] = false
			else
				t[i] = d[i]
			end
		end
		player:WaitForChild('Loaded'):GetPropertyChangedSignal('Value'):Wait()
		halo(player,player:WaitForChild('stats'):WaitForChild("CurrentHalo").Value)
		for i,v in pairs(resetT) do
			if player.stats.Restarts.Value >= i then
				--print(t,v)
				t[v] = true
			end
		end
		game.ReplicatedStorage.Halo:FireClient(player,t)
		ds:SetAsync('Player_'.. player.UserId,t)
	end)
	repeat wait() until player:WaitForChild('Loaded').Value
	if restartsLb:GetAsync('Player_'..player.UserId) ~= player.stats.Restarts.Value then

		restartsLb:SetAsync('Player_'..player.UserId,player.stats.Restarts.Value)
	end
end)


game.ReplicatedStorage.HaloToggle.OnServerInvoke = function(p,name)
	if ds:GetAsync('Player_'.. p.UserId)[name] == false then return false end
	if name == p.stats.CurrentHalo.Value then

		p.stats.CurrentHalo.Value = ''
		halo(p,'')
		return false
	else

		p.stats.CurrentHalo.Value = name
		halo(p,name)
		return true
	end 
end

game.ReplicatedStorage.Restart.OnServerInvoke = function(p,x)
	if p.leaderstats.Stage.Value < (x == 1 and 60 or maxStage) or game.ReplicatedStorage.IsInQuestion:Invoke(p) then return false end
	p.leaderstats.Stage.Value = 0
	p.stats.Sunsetter.Value = false
	p.stats.CurrentStage.Value = 0
	p.stats.Restarts.Value += x
	coroutine.wrap(function()
		restartsLb:SetAsync('Player_'..p.UserId,p.stats.Restarts.Value)
		if resetT[p.stats.Restarts.Value] ~= nil then
			local t = ds:GetAsync('Player_'..p.UserId)
			t[resetT[p.stats.Restarts.Value]] = true
			ds:SetAsync('Player_'..p.UserId,t)
			game.ReplicatedStorage.Halo:FireClient(p,ds:GetAsync('Player_'.. p.UserId))
			local h,s,v = Color3.toHSV(game.ReplicatedStorage.Halos[resetT[p.stats.Restarts.Value]].Color)
			game.ReplicatedStorage.ChatMessageRemote:FireAllClients("<b>"..p.DisplayName..'</b> obtained the '.. string.sub(string.gsub(resetT[p.stats.Restarts.Value], "(%u)", " %1"), 2, -1) ..'!',Color3.fromHSV(h,s,1))
		end
	end)()
	return true,p.stats.Restarts.Value-x
end