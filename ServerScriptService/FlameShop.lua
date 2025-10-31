local tt = game.ReplicatedStorage.Fire:GetChildren()
for i,v in pairs(tt) do
	if v:FindFirstChild('Blacklist') then
		if v.Blacklist.Value then
			tt[i] = nil
		end
	end
end
local t = {}
for i,v in pairs(tt) do
	table.insert(t,v)
end
local sounds = workspace.GameSounds
local ds = game:GetService('DataStoreService'):GetDataStore('Flames')
local ticketsLb = game:GetService('DataStoreService'):GetOrderedDataStore('Tickets')
local duration = game.ReplicatedStorage.ShopUpdateTime.Value
local tim = math.floor(os.time()/duration)*duration
function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end
local clonedT = shallowCopy(t)

local items = {}
for i = 0,3 do
	local index = Random.new(tim):NextInteger(1,#clonedT)
	table.insert(items,clonedT[index].Name)
	table.remove(clonedT,index)
end
coroutine.wrap(function()
	while task.wait(1) do
		if math.floor(os.time()/duration)*duration ~= tim then
			tim = math.floor(os.time()/duration)*duration
			table.clear(items)
			local clonedT = shallowCopy(t)
			for i = 0,3 do
				local index = Random.new(tim):NextInteger(1,#clonedT)
				table.insert(items,clonedT[index].Name)
				table.remove(clonedT,index)
			end
			for i,p in pairs(game.Players:GetPlayers()) do
				game.ReplicatedStorage.UpdateShop:FireClient(p,items,ds:GetAsync('Player_'..p.UserId))
			end
		end
	end
end)()

game.Players.PlayerAdded:Connect(function(p)
	if not ds:GetAsync('Player_'..p.UserId) then
		local tt = {}
		for i,v in pairs(require(game.ReplicatedStorage.FlamePrices)) do
			tt[i] = false
		end
		ds:SetAsync('Player_'..p.UserId,tt)
	end
	game.ReplicatedStorage.UpdateShop:FireClient(p,items,ds:GetAsync('Player_'..p.UserId))
end)

game.ReplicatedStorage.Purchase.OnServerInvoke = function(p,flame)
	if ds:GetAsync('Player_'..p.UserId)[flame] == false  then
		if p.stats.Tickets.Value > require(game.ReplicatedStorage.FlamePrices)[flame]  then
			if  table.find(items,flame) then
				coroutine.wrap(function()
					local t = ds:GetAsync('Player_'..p.UserId)
					t[flame] = true
					ds:SetAsync('Player_'..p.UserId,t)
					game.ReplicatedStorage.Flame:FireClient(p,ds:GetAsync('Player_'.. p.UserId))
				end)()
				p.stats.Tickets.Value -= require(game.ReplicatedStorage.FlamePrices)[flame]
				game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Purchase Successful!', string.format("You've unlocked the %s",string.sub(string.gsub(flame, "(%u)", " %1"), 2, -1)),"rbxassetid://11618349343",Color3.fromRGB(105, 255, 105),sounds.Purchase.SoundId)
				return true
			else
				game.ReplicatedStorage.NotificationBigRemote:FireClient(p,"This item isnt in the shop",[[Come back tomorrow!]],'rbxassetid://10245962721',Color3.fromRGB(255, 55, 55),sounds.Error.SoundId)


				return false -- item owned
			end
		else
			game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Insufficient Ticket Amount',[[Buy some from the shop or complete more stages!]],'rbxassetid://10245962721',Color3.fromRGB(255, 55, 55),sounds.Error.SoundId)

			return false -- not enough tickets
		end
		
	else
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Item Owned',[[You already own this flame!]],'rbxassetid://10245962721',Color3.fromRGB(255, 55, 55),sounds.Error.SoundId)

		return false -- item is not in rotation
	end
end