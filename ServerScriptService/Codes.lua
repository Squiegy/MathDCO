local ds = game:GetService('DataStoreService'):GetDataStore('Codes')
local codes = {
	['educational'] = {
		['stats'] = {'FreeSkips', 1},
		['Function'] = function(p)
			return p.AccountAge > 1
		end,
	}
}

local template = {}

for i,v in pairs(codes) do
	template[i] = false
end

game.Players.PlayerAdded:Connect(function(p)
	if ds:GetAsync('Player_'..p.UserId) == nil then
		ds:SetAsync('Player_'..p.UserId,template)
	else
		for i,v in pairs(template) do
			if ds:GetAsync('Player_'..p.UserId)[i] == nil then
				local t = ds:GetAsync('Player_'..p.UserId)
				t[i] = false
				ds:SetAsync('Player_'..p.UserId,t)
			end
		end
	end
end)

game.ReplicatedStorage.Code.OnServerInvoke = function(p,code)
	code = string.lower(code)
	local seed = math.randomseed(p.UserId^0.69)
	--christmas!!
	local codey = tostring(math.random(100000,999999))
	if code == codey then
		local tt = ds:GetAsync('Player_'..p.UserId)
		if tt[codey] == true then
			return 'Code already redeemed!'
		end
		local reward = 'You have received 1 stage skip + a cool hat! ⛄'
		local t = game:GetService('DataStoreService'):GetDataStore('Halos'):GetAsync('Player_'.. p.UserId)
		t["AbeSnowman"] = true
		game:GetService('DataStoreService'):GetDataStore('Halos'):SetAsync('Player_'.. p.UserId,t)

		game.ReplicatedStorage.Halo:FireClient(p,t)
		
		tt[codey] = true
		ds:SetAsync('Player_'..p.UserId,tt)
		game.ReplicatedStorage.Badge:Invoke(p.UserId,1979765587907179)
		return 'Redeemed!',reward
	end
	-- nvm
	local reward = ''
	if codes[code] ~= nil then
		if codes[code]['Function'] ~= nil then
			if codes[code]['Function'](p) == false then return [[Your account isn't eligible for this code.]] end
		end
	end
	local t = ds:GetAsync('Player_'..p.UserId)
	if t[code] == nil then 
		return 'Code doesnt exist!'
	elseif t[code] == true then
		return 'Code already redeemed!'
	else
		t[code] = true
		ds:SetAsync('Player_'..p.UserId,t)
		if codes[code]['stats'] ~= nil then
			if typeof(codes[code]['stats'][2]) == 'number' then
				reward = string.format('+%d %s',codes[code]['stats'][2],codes[code]['stats'][1])
				p.stats:FindFirstChild(codes[code]['stats'][1]).Value +=codes[code]['stats'][2]
			else
				error('not a number value')
			end
		elseif codes[code]['Halos'] ~= nil then
			
			reward = 'You have received the '..string.sub(string.gsub(codes[code]['Halos'][1], "(%u)", " %1"), 2, -1)
			
			local t = game:GetService('DataStoreService'):GetDataStore('Halos'):GetAsync('Player_'.. p.UserId)
			
			t[codes[code]['Halos'][1]] = true
			
			game:GetService('DataStoreService'):GetDataStore('Halos'):SetAsync('Player_'.. p.UserId,t)
			
			game.ReplicatedStorage.Halo:FireClient(p,t)
		elseif codes[code]['Flames'] ~= nil then
			reward = 'You have received the '..string.sub(string.gsub(codes[code]['Flames'][1], "(%u)", " %1"), 2, -1)
			local t = game:GetService('DataStoreService'):GetDataStore('Flames'):GetAsync('Player_'.. p.UserId)
			t[codes[code]['Flames'][2]] = true
			game:GetService('DataStoreService'):GetDataStore('Flames'):SetAsync('Player_'.. p.UserId,t)
			game.ReplicatedStorage.Flame:FireClient(p,t)
		
		end
		return 'Redeemed!',reward
	end
end