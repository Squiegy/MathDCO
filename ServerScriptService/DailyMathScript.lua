 local simple = require(game.ServerScriptService.Simple)
--local advanced = require(game.ServerScriptService.Simple)
--local expert = require(game.ServerScriptService.Simple)
local dailyStreakDS = game:GetService('DataStoreService'):GetOrderedDataStore('DailyStreak')
local creditsDS = game:GetService('DataStoreService'):GetOrderedDataStore('Credits')
local playerT = {}
local msg = {
	['Simple'] = 'Pretty easy huh?',
	['Advanced'] = 'That one was tough!',
	['Expert'] = 'The chosen one!',
}

local strokes = {
	['Simple'] = Color3.fromRGB(105, 255, 105),
	['Advanced'] = Color3.fromRGB(255, 255, 105),
	['Expert'] = Color3.fromRGB(255, 105, 105)
}
game.ReplicatedStorage.Answers.OnInvoke = function(day)
	day = tonumber(day)
	math.randomseed(day+19580)
	local tt = {'Simple','Advanced','Expert'}


	local function toArray(dictionary)
		local result = {}
		
		for _, v in pairs(dictionary) do 
			table.insert(result, v)
		end
		return result 
	end
	local fire = {}
	local answers = {}
	for i,v in pairs(tt) do
		local array = toArray(require(game.ServerScriptService[v])) 

		local index = math.random(1, #array)
		local t,category,ans = array[index](day+19580)
		answers[v] = ans
		fire[v] = {category,t}
	end
	return answers
end
game.Players.PlayerAdded:Connect(function(player)
	math.randomseed(math.floor(workspace:GetServerTimeNow()/86400))
	local tt = {'Simple','Advanced','Expert'}


	local function toArray(dictionary)
		local result = {}
		
		for _, v in pairs(dictionary) do 
			table.insert(result, v)
		end
		return result 
	end
	local fire = {}
	playerT[player] = {}
	for i,v in pairs(tt) do
		local array = toArray(require(game.ServerScriptService[v])) 

		local index = math.random(1, #array)
		local t,category,ans = array[index]()
		playerT[player][v] = ans
		fire[v] = {category,t}
	end
	repeat wait() until player.Loaded.Value
	if game.ReplicatedStorage.ServerStats.Day.Value ~= player.challenges.PlayedToday.Value then
		player.challenges.Hearts.Value = 3
	end
	player.challenges.PlayedToday.Value = game.ReplicatedStorage.ServerStats.Day.Value
	game.ReplicatedStorage.DailyMathProblems:FireClient(player,fire)
	if player.challenges.LastDay.Value < math.floor(workspace:GetServerTimeNow()/86400)-1 then
		player.challenges.Streak.Value = 0
		dailyStreakDS:SetAsync('Player_' .. player.UserId,0)
	end
end)

game.ReplicatedStorage.RefreshDaily.Event:Connect(function()
	playerT = {}
	for i,player in pairs(game.Players:GetPlayers()) do
		math.randomseed(math.floor(workspace:GetServerTimeNow()/86400))
		local tt = {'Simple','Advanced','Expert'}


		local function toArray(dictionary)
			local result = {}
			
			for _, v in pairs(dictionary) do 
				table.insert(result, v)
			end
			return result 
		end
		local fire = {}
		playerT[player] = {}
		for i,v in pairs(tt) do
			local array = toArray(require(game.ServerScriptService[v])) 

			local index = math.random(1, #array)
			local t,category,ans = array[index]()
			playerT[player][v] = ans
			fire[v] = {category,t}
		end
		if not player:WaitForChild('Loaded').Value then
			player.Loaded:GetPropertyChangedSignal('Value'):Wait()
		end
 		player.challenges:WaitForChild("Hearts").Value = 3
		game.ReplicatedStorage.DailyMathProblems:FireClient(player,fire,true)
	end
end)
function commaEqual(x,y)
	local table1 = string.split(string.gsub(x,' ',''),',')
	local table2 = string.split(string.gsub(y,' ',''),',')
	if #table1 ~= #table2 then
		return false
	end

	local sortedTable1 = {}
	for key, value in pairs(table1) do
		table.insert(sortedTable1, value)
	end
	table.sort(sortedTable1)

	local sortedTable2 = {}
	for key, value in pairs(table2) do
		table.insert(sortedTable2, value)
	end
	table.sort(sortedTable2)

	for i = 1, #sortedTable1 do
		if sortedTable1[i] ~= sortedTable2[i] then
			return false
		end
	end

	return true
end
game.ReplicatedStorage.DailyMathCheck.OnServerInvoke = function(player, ans,c)
	if player.challenges['LastDay'..c].Value == math.floor(workspace:GetServerTimeNow()/86400) then return end
	if player.challenges.Hearts.Value == 0 then
		game.ReplicatedStorage.NotificationBig:Fire('Heartless..',[[You have no more hearts left. Come back tommorow and try again!]],'rbxassetid://14366853636',Color3.fromRGB(241, 89, 255),game.Workspace.GameSounds.Error.SoundId)
		return false
	end
	ans = string.gsub(ans,' ','')
	local correct
	if #string.split(playerT[player][c],',') > 1 then
		correct = commaEqual(playerT[player][c],ans)  
	elseif tonumber(playerT[player][c]) == nil then
		correct = string.upper(playerT[player][c]) == tostring(ans)
	else
		correct = tostring(math.round(playerT[player][c])) == tostring(ans)
	end
	if correct then
		game.ReplicatedStorage.ChatMessageRemote:FireAllClients('<b>'..player.DisplayName..'</b>'.. ' has completed todays <b>' .. c .. '</b> Math Challenge!',strokes[c])
		player.challenges['LastDay'..c].Value = math.floor(workspace:GetServerTimeNow()/86400)
		player.challenges.Credits.Value += 1
		creditsDS:SetAsync('Player_' .. player.UserId,player.challenges.Credits.Value)
		player.challenges[c .. 'Completions'].Value += 1
		if player.challenges.LastDay.Value < math.floor(workspace:GetServerTimeNow()/86400) then
			player.challenges.Streak.Value += 1
			dailyStreakDS:SetAsync('Player_' .. player.UserId,player.challenges.Streak.Value)
		end
		player.challenges.LastDay.Value = math.floor(workspace:GetServerTimeNow()/86400)
		game.ReplicatedStorage.NotificationBigRemote:FireClient(player,msg[c],[[Come back tommorow to save your streak of <b>]] .. player.challenges.Streak.Value .. '</b>!','rbxassetid://13306485413',strokes[c],game.Workspace.GameSounds.Confetti.SoundId)
		player.challenges.LastProblem.Value = workspace:GetServerTimeNow()
		player.challenges['LastProblem'..c].Value = workspace:GetServerTimeNow()
		game.ReplicatedStorage.Effect:FireClient(player,Color3.fromRGB(127, 255, 136))
	else
		player.challenges.Hearts.Value -= 1
		game.ReplicatedStorage.Effect:FireClient(player,Color3.fromRGB(255, 80, 80))

		if player.challenges.Hearts.Value == 0 then
			game.ReplicatedStorage.NotificationBig:Fire('Thats all folks!','You have no more hearts left, come back tommorow and try again!','rbxassetid://14366853636',Color3.fromRGB(255, 89, 89),game.Workspace.GameSounds.Error.SoundId)

		else
			game.ReplicatedStorage.NotificationBigRemote:FireClient(player,'Incorrect!',[[Careful, you have <b>]] .. player.challenges.Hearts.Value .. '</b> hearts left!','rbxassetid://14366853636',Color3.fromRGB(255, 89, 89),game.Workspace.GameSounds.Error.SoundId)

		end
	end
	return correct
end

game.ReplicatedStorage.PurchaseReward.OnServerEvent:Connect(function(p,name)
	local m = require(game.ReplicatedStorage.RewardPrices)
	local price = m[name]
	
	if p.challenges.Credits.Value >= price[1] then
		local bool = price[2](p)
		if bool then
			p.challenges.Credits.Value -= price[1]
			creditsDS:SetAsync('Player_' .. p.UserId,p.challenges.Credits.Value)
		end
	else
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,"Broke!",'You need ' .. price[1]-p.challenges.Credits.Value .. ' more credits to buy this.',"rbxassetid://13927274408",Color3.fromRGB(255, 55, 55),game.Workspace.GameSounds.Error.SoundId)
	end
end)

coroutine.wrap(function()
	local a = game.ReplicatedStorage.ServerStats.Time
	local refresh = game.ReplicatedStorage.RefreshDaily
	local day = game.ReplicatedStorage.ServerStats.Day
	local lastUpdate = 0
	
	game:GetService('RunService').Heartbeat:Connect(function(dt)
		-- Update time every second instead of every frame
		lastUpdate += dt
		if lastUpdate >= 1 then
			a.Value = workspace:GetServerTimeNow()
			lastUpdate = 0
			
			if math.floor(workspace:GetServerTimeNow()/86400) ~= day.Value then
				refresh:Fire()
				day.Value = math.floor(workspace:GetServerTimeNow()/86400)
			end
		end
	end)
end)()


game.ReplicatedStorage.ServerStats.Day:GetPropertyChangedSignal('Value'):Connect(function()
	game.ReplicatedStorage.ChatMessageRemote:FireAllClients("<b>[Server]:</b> The Daily Math Challenge has been reset!",Color3.fromRGB(255, 130, 255))

end)