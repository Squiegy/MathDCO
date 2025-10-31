local ds = game:GetService('DataStoreService'):GetDataStore("Matchup")

local N=100

--Datastore format

--ds:whatever() --> [3] = [0,0,0,6,7] (means 3 beat 4 6 times and 3 beat 5 7 times)


function getMin(t)
	local L = {}
	local min = math.huge
	for i,v in pairs(t) do
		for j,vv in pairs(v) do
			if vv + t[j][i] <= min and i ~= j then
				if vv+t[j][i] < min then
					min = vv
					L = {}
				end
				table.insert(L,{i,j})
			end
		end
	end
	print(min)
	return L[math.random(#L)]
end

game.Players.PlayerAdded:Connect(function(p)
	if not ds:GetAsync("Beaten"..N) then
		local t = {}
		for i = 1,N do
			t[i] = table.create(N,0)
		end
		ds:SetAsync("Beaten"..N,t)
	end
	while true do
		local beaten = ds:GetAsync("Beaten"..N)
		local matchup = getMin(beaten)
		local pick = game.ReplicatedStorage.MatchupFunction:InvokeClient(p,matchup)
		ds:UpdateAsync("Beaten"..N,function(old)
			old[matchup[pick]][matchup[3-pick]] += 1
			return old
		end)
		wait(360+60*math.random())
	end
end)