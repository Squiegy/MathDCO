local ds = game:GetService('DataStoreService'):GetDataStore('Tags')
local t = require(game.ReplicatedStorage.Tags)
local template = table.create(#t,false)
game.Players.PlayerAdded:Connect(function(p)
	ds:SetAsync('Player_'..p.UserId,template)
	local data = ds:GetAsync('Player_'..p.UserId)
	for i,v in pairs(t) do
		if v.Func(p) then 
			data[i] = true
		end
	end
	ds:SetAsync('Player_'..p.UserId,data)
	repeat wait() until p.Loaded.Value
	game.ReplicatedStorage.ChatTag:FireClient(p,data,p.stats.CurrentTag.Value)
end)

game.ReplicatedStorage.TagToggle.OnServerInvoke = function(p,index)
	if ds:GetAsync('Player_'..p.UserId)[index] then
		if p.stats.CurrentTag.Value == t[index].Text then
			p.stats.CurrentTag.Value = ''
		else
			p.stats.CurrentTag.Value = t[index].Text
		end
		return true
	end
	return false
end