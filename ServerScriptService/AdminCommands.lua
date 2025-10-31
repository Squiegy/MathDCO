local Admins = require(game.ReplicatedStorage.Admins)
local Prefix = "/" 
local kicked = {}
local whitelist = {'RedDonutSideView','WhatTheUwuz'}
local shutdown = false
local ds = game:GetService('DataStoreService'):GetDataStore('Lists')
local ms = game:GetService('MessagingService')
local ProfileService = require(game.ServerScriptService.ProfileService)
local ProfileTemplate = require(game.ServerScriptService.ProfileTemplate)
local ProfileStore = ProfileService.GetProfileStore(
	'ProfileStore#01',
	ProfileTemplate
)
coroutine.wrap(function()
	pcall(function()
		for i,v in pairs(ds:GetAsync('Whitelist')) do
			table.insert(whitelist,v)
		end
	end)
	pcall(function()
		ds:SetAsync('Whitelist',whitelist)
	end)
end)()

local function removespaces(str)
	return str:gsub(" ","")
end
game.Players.PlayerAdded:Connect(function(p)
	if table.find(require(game.ReplicatedStorage.Admins),p.Name) then
		p.CharacterAppearanceLoaded:Connect(function(char)
			script.Noclip:Clone().Parent = p.Backpack
		end)
		local t = {}
		pcall(function()
			for i,v in pairs(game:GetService('DataStoreService'):GetDataStore('Accuracy'):GetAsync('Accuracy')) do
				t[i] = v[1]/(v[1]+v[2])
			end
		end)
		game.ReplicatedStorage.AdminStageStats:FireClient(p,t)
	end
end)
local commands = {
	['whitelistremove'] = function(t)
		local newName = game.Players:GetNameFromUserIdAsync(game.Players:GetUserIdFromNameAsync(removespaces(t[2])))
		table.remove(whitelist,table.find(newName))
		pcall(function()
			ds:SetAsync('Whitelist',whitelist)
		end)
	end,
	['whitelist'] = function(t)
		local newName = game.Players:GetNameFromUserIdAsync(game.Players:GetUserIdFromNameAsync(removespaces(t[2])))
		table.insert(whitelist,newName)
		pcall(function()
			ds:SetAsync('Whitelist',whitelist)
		end)
	end,
	
	['lock'] = function(t)
		shutdown = true
	end,
	['unlock'] = function(t)
		shutdown = false
	end,
	['kick'] = function(t)
		local newName = game.Players:GetNameFromUserIdAsync(game.Players:GetUserIdFromNameAsync(removespaces(t[2])))
		local p = game.Players:FindFirstChild(newName)
		local reason = t[3]
		p:Kick(reason)
	end,
	['serverkick'] = function(t)
		local newName = game.Players:GetNameFromUserIdAsync(game.Players:GetUserIdFromNameAsync(removespaces(t[2])))
		local p = game.Players:FindFirstChild(newName)
		local reason = t[3]
		table.insert(kicked,{p.Name,reason})
		p:Kick(reason)
	end,

	['ban'] = function(t)
		local newName = game.Players:GetNameFromUserIdAsync(game.Players:GetUserIdFromNameAsync(removespaces(t[2])))
		local p = game.Players:FindFirstChild(newName)
		local reason = t[3]
		if t[4] == nil then
			t[4] = 'ever'
		end
		local s = 0
		pcall(function()
			ds:SetAsync(newName,{
				['Reason'] = reason,
				['Time'] = removespaces(t[4]),
				['TimeStart'] = os.time()
			})
		end)
		if game.Players:FindFirstChild(newName) then
			p:Kick(reason..', Banned for '..t[4])
		end
	end,
	['unban'] = function(t)
		local p = game.Players:GetNameFromUserIdAsync(game.Players:GetUserIdFromNameAsync(removespaces(t[2])))
		pcall(function()
			ds:GetAsync(p)
			ds:RemoveAsync(p)
		end)

	end,

	['walkspeed'] = function(t)
		local newName = game.Players:GetNameFromUserIdAsync(game.Players:GetUserIdFromNameAsync(removespaces(t[2])))
		local p = game.Players:FindFirstChild(newName)
		local speed = t[3]
		p.Character.Humanoid.WalkSpeed = speed
	end,

	['halo'] = function(t)
		local pName = game.Players:GetNameFromUserIdAsync(game.Players:GetUserIdFromNameAsync(removespaces(t[2])))
		local userId = game.Players:GetUserIdFromNameAsync(pName)
		local tabl = game:GetService('DataStoreService'):GetDataStore('Halos'):GetAsync('Player_'..userId)
		if t[4] == nil then t[4] = '' end
		tabl[t[3]] = string.lower(t[4]) ~= 'remove'
		game:GetService('DataStoreService'):GetDataStore('Halos'):SetAsync('Player_'..userId,tabl)
		if game.Players:FindFirstChild(pName) then
			game.ReplicatedStorage.Halo:FireClient(game.Players:FindFirstChild(pName),game:GetService('DataStoreService'):GetDataStore('Halos'):GetAsync('Player_'.. game.Players:FindFirstChild(pName).UserId))
		end
		warn('Halo Value now' .. tostring(tabl[t[3]]))
	end,
	['setstat'] = function(t)
		local pName = game.Players:GetNameFromUserIdAsync(game.Players:GetUserIdFromNameAsync(removespaces(t[2])))
		local userId = game.Players:GetUserIdFromNameAsync(pName)
		local p = game.Players:FindFirstChild(pName)
		local value = t[4]
		if value == 'false' then
			value = false
		elseif value == 'true' then
			value = true
		end
		if p then
			for i,v in pairs(p:GetDescendants()) do
				if v:IsA('ValueBase') and v.Name == t[3] then
					v.Value = value
				end
			end
		else
			local ta = ProfileStore:LoadProfileAsync("Player_" .. userId)
			for ii,vv in pairs(ta.Data) do
				for i,v in pairs(vv) do
					if i == t[3] then
						ta.Data[ii][i] = value
						warn(pName , i, value)
					end
				end
			end
			ta:Release()
		end
	end,
	['getstat'] = function(t)
		local pName = game.Players:GetNameFromUserIdAsync(game.Players:GetUserIdFromNameAsync(removespaces(t[2])))
		local userId = game.Players:GetUserIdFromNameAsync(pName)
		local p = game.Players:FindFirstChild(pName)
		if p  then
			for i,v in pairs(p:GetDescendants()) do
				if v:IsA('ValueBase') and v.Name == t[3] then
					return v.Value
				end
			end
		else
			local ta = game:GetService('DataStoreService'):GetDataStore('Public#1'):GetAsync('Player_'..userId)
			return ta[t[3]]
		end
	end,
	['shutdown'] = function(t)
		game.ReplicatedStorage.Shutdown:Fire()
	end,
	['globalshutdown'] = function(t)
		ms:PublishAsync('Shutdown',' ')
	end,
	['answers'] = function(t)
		local day = t[2]
		local tt = game.ReplicatedStorage.Answers:Invoke(day)
	end,
} 


game.Players.PlayerAdded:Connect(function(p)
	for _,v in pairs(Admins) do
		if p.Name == v then
			p.Chatted:Connect(function(msg)
				local loweredString = string.lower(msg)
				local args
				pcall(function()
					args = string.split(string.split(loweredString,Prefix)[2],",")
					for i,v in pairs(args) do
					end
					if removespaces(args[2]) == 'me' then
						args[2] = p.Name
						if commands[args[1]] then
							commands[args[1]](args)
						end
					elseif removespaces(args[2]) == 'all' then
						for i,v in pairs(game.Players:GetPlayers()) do
							args[2] = v.Name
							if commands[args[1]] then
								commands[args[1]](args)
							end
						end
					else
						if commands[args[1]] then
							commands[args[1]](args)
						end
					end
				end)




			end)
		end
	end
	if shutdown then
		if not table.find(whitelist,p.Name) and not table.find(Admins,p.Name) and not p:IsFriendsWith(game.Players:GetUserIdFromNameAsync('Squiegy')) then
			p:Kick('Server is currently locked, try joining later.')
		end

	end
	for i,v in pairs(kicked) do
		if v[1] == p.Name then
			p:Kick("You've been blacklisted for "..v[2])
		end
	end
	if ds:GetAsync(p.Name) ~= nil then
		local data = ds:GetAsync(p.Name)

		local letter = string.gsub(data.Time,'%d','')
		local num = 1
		if letter == 's' then
			num = 1
		elseif letter == 'm' then
			num = 60
		elseif letter == 'h' then
			num = 3600
		elseif letter == 'd' then
			num = 86400
		elseif letter == 'w' then
			num = 86400*7




		end
		local number = string.gsub(data.Time,'%a','')
		if number*num+data.TimeStart-os.time() > 0 then

			p:Kick([[ \n You've been banned for "]].. data.Reason .. '"\n Time until unban '.. number*num+data.TimeStart-os.time() ..' seconds')
		else
			ds:RemoveAsync(p.Name)
		end
	end
end)

game.ReplicatedStorage.AdminPanel.Event:Connect(function(args)
	if commands[args[1]] then
		commands[args[1]](args)
	end
end)

game.ReplicatedStorage.AdminPanelRemote.OnServerEvent:Connect(function(p,args)
	if not table.find(Admins,p.Name) then return end
	if commands[args[1]] then
		commands[args[1]](args)
	end
end)

game.ReplicatedStorage.AdminPanelFunction.OnServerInvoke = function(p,args)
	if not table.find(Admins,p.Name) then return end
	if commands[args[1]] then
		return commands[args[1]](args)
	end
end