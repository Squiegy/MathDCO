local ds = game:GetService('DataStoreService'):GetDataStore('Ratings')
local ds2 = game:GetService('DataStoreService'):GetDataStore('Usernames')
local ds3 = game:GetService('DataStoreService'):GetDataStore('Messages')
local Admins = require(game.ReplicatedStorage.Admins)
game.ReplicatedStorage.RateFire.OnServerInvoke = function(p,text,rating)
	if ds:GetAsync('Player_'..p.UserId) then
		if table.find(Admins,p.Name) or ((ds:GetAsync('Player_'..p.UserId)['Time'] < os.time() or ds:GetAsync('Player_'..p.UserId)['Time'] == math.huge) and p.AccountAge >= 100 and not ds:GetAsync('Player_'..p.UserId)['Locked']) then
			local t = ds:GetAsync('Player_'..p.UserId)
			local insert = {
				['Text'] = text,
				['Rating'] = rating,
				['Time'] = os.time()
			}
			t['Time'] = os.time() + 86400
			local Name = p.Name
			local Display = p.DisplayName
			local UserId = p.UserId
			local Rating = rating
			local suggestion = text
			local date = os.date("%Y-%m-%d %H:%M:%S", os.time())

			game:GetService('HttpService'):PostAsync('https://docs.google.com/forms/d/e/1FAIpQLSf4jGa1aAJgCvOUHAM-H7SAIMV8ba0LdR-gjXaufkidGdu6ig/formResponse'
			,'entry.582326122='..Name..'&entry.1757220096='..Display..'&entry.1125601500='..UserId..'&entry.877004120='..Rating ..'&entry.1971080663='..suggestion..'&entry.816169453=' .. date
			,Enum.HttpContentType.ApplicationUrlEncoded)
			table.insert(t['Suggestions'],insert)
			ds:SetAsync('Player_'..p.UserId,t)
			local newt = ds2:GetAsync('Usernames')
			if not newt then
				ds2:SetAsync('Usernames',{'Player_'..p.UserId})
			end
			if not table.find(newt,'Player_'..p.UserId) then
				table.insert(newt,'Player_'..p.UserId)
			end
			ds2:SetAsync('Usernames',newt)
			return true
		else
			return false
		end
	else
		if p.AccountAge < 2 then return false end
		ds:SetAsync('Player_'..p.UserId,{
			['Suggestions'] = {
				{
					['Text'] = text,
					['Rating'] = rating,
					['Time'] = os.time()
				}
			},
			['Time'] = os.time() + 86400,
			['Locked'] = false
		})
		local Name = p.Name
		local Display = p.DisplayName
		local UserId = p.UserId
		local Rating = rating
		local suggestion = text
		local date = os.date("%Y-%m-%d %H:%M:%S", os.time())

		game:GetService('HttpService'):PostAsync('https://docs.google.com/forms/d/e/1FAIpQLSf4jGa1aAJgCvOUHAM-H7SAIMV8ba0LdR-gjXaufkidGdu6ig/formResponse'
		,'entry.582326122='..Name..'&entry.1757220096='..Display..'&entry.1125601500='..UserId..'&entry.877004120='..Rating ..'&entry.1971080663='..suggestion..'&entry.816169453=' .. date
		,Enum.HttpContentType.ApplicationUrlEncoded)
		local newt = ds2:GetAsync('Usernames')
		if not newt then
			ds2:SetAsync('Usernames',{'Player_'..p.UserId})
		else
			if not table.find(newt,'Player_'..p.UserId) then
				table.insert(newt,'Player_'..p.UserId)
			end
			ds2:SetAsync('Usernames',newt)

		end
		return true
	end
end

game.Players.PlayerAdded:Connect(function(p)
	if table.find(require(game.ReplicatedStorage.Admins),p.Name) then
		local t = {}
		local a = ds2:GetAsync('Usernames')
		if not a then
			ds2:SetAsync('Usernames',{})
			a = {}
		end
		for i,v in pairs(a) do
			local b = ds:GetAsync(v)
			if b['Time'] == math.huge then
				local a,_ = string.gsub(v,'Player_','')
				t[tonumber(a)] = b
			end

		end
		game.ReplicatedStorage.RateFireClient:FireClient(p,t)
	end
end)

game.ReplicatedStorage.RateFireBack.OnServerEvent:Connect(function(p,key,addedTime)
	if not table.find(require(game.ReplicatedStorage.Admins),p.Name) then
		p:Kick('are you happy doing this')
	else
		local t = ds:GetAsync(key)
		if addedTime == true then

			t['Locked'] = true
		else
			t['Time'] = os.time() + addedTime
		end
		ds:SetAsync(key,t)
	end
end)