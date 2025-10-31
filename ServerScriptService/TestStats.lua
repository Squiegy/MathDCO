local dss = game:GetService("DataStoreService")
local pd = dss:GetDataStore(game.ReplicatedStorage.ServerStats.DatastoreVersion.Value)
local accuracyDs = game:GetService('DataStoreService'):GetDataStore('Accuracy')
local donationsLb = game:GetService('DataStoreService'):GetOrderedDataStore('Robux')
local ticketsLb = game:GetService('DataStoreService'):GetOrderedDataStore('Tickets')
local streakLb = game:GetService('DataStoreService'):GetOrderedDataStore('Streak')
local restartsLb = game:GetService('DataStoreService'):GetOrderedDataStore('Restarts')
local speedrunLb = game:GetService('DataStoreService'):GetOrderedDataStore('Speedrun12')
local savedStageT = {}
local startTimes = {}
local palet = {
	[120] = Color3.fromRGB(255, 51, 51),
	[90] = Color3.fromRGB(255, 102, 51),
	[60] = Color3.fromRGB(255, 153, 51),
	[45] = Color3.fromRGB(255, 204, 51),
	[30] = Color3.fromRGB(255, 255, 51),
	[25] = Color3.fromRGB(204, 255, 51),
	[20] = Color3.fromRGB(153, 255, 51),
	[17.5] = Color3.fromRGB(51, 255, 51),
	[15] = Color3.fromRGB(51, 255, 153),
	[12.5] = Color3.fromRGB(51, 255, 204),
	[10] = Color3.fromRGB(51, 255, 255),
	[9] = Color3.fromRGB(51, 187, 255),
	[8] = Color3.fromRGB(51, 119, 255),
	[7] = Color3.fromRGB(51, 51, 255),
	[6] = Color3.fromRGB(119, 51, 255),
	[5] = Color3.fromRGB(187, 51, 255),
	[4] = Color3.fromRGB(255, 51, 255),
	[3] = Color3.fromRGB(255, 51, 187),
	[2] = Color3.fromRGB(255, 51, 119),
	[1] = Color3.fromRGB(255, 255, 255),
	[0] = Color3.fromRGB(0, 0, 0),

}

local paletT = {}

for i,v in pairs(palet) do
	table.insert(paletT,i)
end
table.sort(paletT)

local funcs = {
	['SpeedrunMode'] = function(p,bool)
		if bool then
			game.ReplicatedStorage.Effect:FireClient(p,Color3.fromRGB(255, 255, 255))
			game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'On your marks...',[[Begin whenever you're ready!]],'rbxassetid://13923541792',Color3.fromRGB(255,255,255),workspace.Sounds.Notification.SoundId)
			p.Character.HumanoidRootPart.CFrame = workspace.Checkpoints:FindFirstChild('0').CFrame * CFrame.new(0,3.25,0)
			savedStageT[p] = p.leaderstats.Stage.Value
			p.leaderstats.Stage.Value = 0
			p.stats.Sunsetter.Value = false
			p.stats.CurrentStage.Value = 0
			local bool = game.ReplicatedStorage.IsInQuestion:Invoke(p)
			if bool then
				game.ReplicatedStorage.QuestionReset:FireClient(p)
			end
			if p.Character.Humanoid.MoveDirection.Magnitude == 0 then
				game.ReplicatedStorage.IsRunning:InvokeClient(p)
			end
			if p.settings.SpeedrunMode.Value then
				local t = tick()
				startTimes[p] = {[0] = t}
				game.ReplicatedStorage.Speedrun:FireClient(p,t)
			end
		else
			game.ReplicatedStorage.Effect:FireClient(p,Color3.fromRGB(255, 255, 255))
			game.ReplicatedStorage.NotificationBigRemote:FireClient(p,[[On whose marks?]],[[Speedrun mode was disabled!]],'rbxassetid://13923541792',Color3.fromRGB(255,255,255),workspace.Sounds.Notification.SoundId)
			p.leaderstats.Stage.Value = savedStageT[p]
			p.stats.CurrentStage.Value = savedStageT[p]
			print("hello! im changing stuff!")
			p.Character.HumanoidRootPart.CFrame = workspace.Checkpoints:FindFirstChild((savedStageT[p]/10 == math.floor(savedStageT[p]/10) and savedStageT[p] ~= 0) and savedStageT[p]+.5 or savedStageT[p]).CFrame * CFrame.new(0,3.25,0)
			savedStageT[p] = nil
			local bool = game.ReplicatedStorage.IsInQuestion:Invoke(p)
			if bool then
				game.ReplicatedStorage.QuestionReset:FireClient(p)
			end
		end
	end,
}
game.ReplicatedStorage.SpeedrunReset.OnServerEvent:Connect(function(p) -- start working on this tmr
	game.ReplicatedStorage.Effect:FireClient(p,Color3.fromRGB(255, 255, 255))
	game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'On your marks...',[[Begin whenever you're ready!]],'rbxassetid://13923541792',Color3.fromRGB(255,255,255),workspace.Sounds.Notification.SoundId)
	p.Character.HumanoidRootPart.CFrame = workspace.Checkpoints:FindFirstChild('0').CFrame * CFrame.new(0,3.25,0)
	p.leaderstats.Stage.Value = 0
	p.stats.Sunsetter.Value = false
	p.stats.CurrentStage.Value = 0
	local bool = game.ReplicatedStorage.IsInQuestion:Invoke(p)
	if bool then
		game.ReplicatedStorage.QuestionReset:FireClient(p)
	end
	if p.Character.Humanoid.MoveDirection.Magnitude == 0 then
		game.ReplicatedStorage.IsRunning:InvokeClient(p)
	end

	if p.settings.SpeedrunMode.Value then
		local t = tick()
		startTimes[p] = {[0] = t}
		game.ReplicatedStorage.Speedrun:FireClient(p,t)
	end
end)

function secToFormat(x)
	local h = math.floor((x / 3600) % 24)
	local m = math.floor((x / 60) % 60)
	local s = math.floor(x % 60)
	local ms = math.floor(1000 * (x - math.floor(x)))
	local formatFinal = (x < 3600 and '' or h .. ':') .. (x < 60 and '' or ((m >= 10 or h == 0) and m or '0' .. m) .. ':') .. ((s >= 10 or m == 0) and s or '0' .. s)
	return formatFinal .. '.' .. (ms == 0 and '000' or tonumber(string.format("%.3f", f(ms)))*1000)
end

game.ReplicatedStorage.SpeedrunBack.OnInvoke = function(p,grade)
	startTimes[p][grade] = tick()
	local timeTook = startTimes[p][grade]-startTimes[p][grade-1]
	local secondsBetter = timeTook-p.speedrun['Grade'..grade].Value
	if p.speedrun['Grade'..grade].Value > timeTook then
		p.speedrun['Grade'..grade].Value = timeTook
	end
	local totalTime = startTimes[p][grade]-startTimes[p][0]
	if grade * 10 == game.ReplicatedStorage.ServerStats.MaxStage.Value then
		game.ReplicatedStorage.SpeedrunStop:FireClient(p,totalTime,p.speedrun['BestTime10'].Value)
		if p.speedrun['BestTime10'].Value > totalTime then
			p.speedrun['BestTime10'].Value = totalTime
			local c
			for i,v in ipairs(paletT) do
				if totalTime > v then
					c = palet[v]
					break
				end
			end
			game.ReplicatedStorage.ChatMessageRemote:FireAllClients('<b>'..p.DisplayName..'</b>'.. ' has beat the game in '.. secToFormat(p.speedrun['BestTime10'].Value)  ..'!',c)

			coroutine.wrap(function()
				speedrunLb:SetAsync('Player_'..p.UserId,math.floor(totalTime*1000))
			end)()
		end
	end
	return timeTook,totalTime,secondsBetter
end
game.ReplicatedStorage.Settings.OnServerEvent:Connect(function(p,s,v)
	if s == 'Reset' then
		p.stats.CurrentStage.Value = 0
		p.leaderstats.Stage.Value = 0
		p.stats.Sunsetter.Value = false
		p.Character.HumanoidRootPart.CFrame = workspace.Checkpoints:FindFirstChild(p.stats.CurrentStage.Value).CFrame * CFrame.new(0,3.25,0)
		return
	end
	if not p.settings:FindFirstChild(s) then return end
	p.settings[s].Value = v
	if funcs[s] then
		funcs[s](p,v)
	end
end)
-- PROFILESERIVCE 
local ProfileService = require(game.ServerScriptService.ProfileService)
local SetToDefault = {
	'SpeedrunMode'
}
local ProfileTemplate = require(game.ServerScriptService.ProfileTemplate)

local Profiles = {} -- [player] = profile

local ProfileStore = ProfileService.GetProfileStore(
	'ProfileStore#01',
	ProfileTemplate
)
local timeT = {}
local haloT = {
	"SquaredButAsASackOfRice",
	"BigBossGhost",
	"AbePumpkin"
}
function afterLoaded(player)
	local t = os.clock()
	local tt= Instance.new("BoolValue")
	tt.Name = "Teleporting"
	tt.Parent = player
	timeT[player] = game.Workspace:GetServerTimeNow()
	player.settings.SpeedrunMode.Value = false
	player.stats.Sunsetter.Value = player.stats.CurrentStage.Value == 130
	if player.UserId == game.Players:GetUserIdFromNameAsync('PerfectlySquared') then
		--player.stats.Streak.Value = math.random(50,200)
		game.ReplicatedStorage.NotificationBigRemote:FireClient(player,"This should appear","after the menu closes")
	end
	local s, e = pcall(function()
		local data = player:GetJoinData()
		local friendy
		pcall(function()
			print(game:GetService('HttpService'):JSONEncode(data))
		end)

		-- Iterate over all players to find a mutual friend
		for i, v in pairs(game.Players:GetPlayers()) do
			print(player:IsFriendsWith(v.UserId), v.leaderstats.Stage.Value)
			if player:IsFriendsWith(v.UserId) and v.leaderstats.Stage.Value < 40 then
				friendy = v.UserId
				print(friendy)
				break
			end
		end

		-- Check if the player was invited or has a mutual friend
		if next(data) ~= nil or friendy then
			if next(data) == nil then
				data = "Player_" .. tostring(friendy)
			else
				data = data.LaunchData
			end
			print(game:GetService('HttpService'):JSONEncode(data))

			if data ~= "" then
				print("We're in the clear!", data)
				data = game:GetService('HttpService'):JSONDecode(data)

				-- Check if the player who invited exists in the game
				if game.Players:GetPlayerByUserId(tonumber(data.InvitedBy)) ~= nil then
					local t = game:GetService('HttpService'):JSONDecode(player.stats.Link.Value)
					table.insert(t, tonumber(data.InvitedBy))  -- Ensure InvitedBy is treated as a number
					player.stats.Link.Value = game:GetService('HttpService'):JSONEncode(t)

					local invitedByPlayer = game.Players:GetPlayerByUserId(tonumber(data.InvitedBy)) -- Ensure InvitedBy is treated as a number
					local t2 = game:GetService('HttpService'):JSONDecode(invitedByPlayer.stats.Link.Value)
					table.insert(t2, player.UserId)
					invitedByPlayer.stats.Link.Value = game:GetService('HttpService'):JSONEncode(t2)

					local r = math.random(1, 360)
					game.ReplicatedStorage.Notice:FireClient(player, "Welcome! 👋", [[Hey there! <b>]] .. invitedByPlayer.DisplayName .. [[</b> could use a hand 🤙
When you both hit Stage <b>40</b>, you'll each receive a unique badge and halo 🎁]], "let's go!", r)
					game.ReplicatedStorage.NotificationBigRemote:FireClient(invitedByPlayer, player.DisplayName .. " joined!", "To claim your rewards, both of you need to reach Stage 40!", "rbxassetid://11611441705", Color3.fromHSV(r / 360, .6, 1))

					local con, con2

					-- Function to check if both players reached stage 40
					local function checkStages()
						if invitedByPlayer.leaderstats.Stage.Value >= 40 and player.leaderstats.Stage.Value >= 40 then
							game.ReplicatedStorage.Badge:Invoke(tonumber(data.InvitedBy), 3190538089097832)
							game.ReplicatedStorage.Badge:Invoke(player.UserId, 3190538089097832)
							game.ReplicatedStorage.NotificationBigRemote:FireClient(player, "🎉 Congrats! 🎉", "You and <b>" .. invitedByPlayer.DisplayName .. "</b> have received the friendship halo!", "rbxassetid://17310480163", Color3.fromHSV(r / 360, .6, 1))
							game.ReplicatedStorage.NotificationBigRemote:FireClient(invitedByPlayer, "🎉 Congrats! 🎉", "You and <b>" .. player.DisplayName .. "</b> have received the friendship halo!", "rbxassetid://17310480163", Color3.fromHSV(r / 360, .6, 1))
							game.ReplicatedStorage.AdminPanel:Fire({ 'halo', player.Name, 'MathHalo' })
							game.ReplicatedStorage.AdminPanel:Fire({ 'halo', invitedByPlayer.Name, 'MathHalo' })

							local t = game:GetService('HttpService'):JSONDecode(player.stats.Link.Value)
							table.remove(t, table.find(t, invitedByPlayer.UserId))
							player.stats.Link.Value = game:GetService('HttpService'):JSONEncode(t)

							local t2 = game:GetService('HttpService'):JSONDecode(invitedByPlayer.stats.Link.Value)
							table.remove(t2, table.find(t2, player.UserId))
							invitedByPlayer.stats.Link.Value = game:GetService('HttpService'):JSONEncode(t2)

							con:Disconnect()
							con2:Disconnect()
						end
					end

					con = invitedByPlayer.leaderstats.Stage:GetPropertyChangedSignal("Value"):Connect(checkStages)
					con2 = player.leaderstats.Stage:GetPropertyChangedSignal("Value"):Connect(checkStages)
				end
			end
		end
	end)

	if not s then
		print("Error: " .. tostring(e))
	end
	if player.stats.HighestStage.Value < player.leaderstats.Stage.Value then
		player.stats.HighestStage.Value = player.leaderstats.Stage.Value
	end

	local d = game:GetService('DataStoreService'):GetOrderedDataStore('Streak'):GetAsync('Player_'..player.UserId)
	if not d then
		game:GetService('DataStoreService'):GetOrderedDataStore('Streak'):SetAsync('Player_'..player.UserId,player.stats.HighestStreak.Value)
	else
		if player.stats.HighestStreak.Value > d then
			game:GetService('DataStoreService'):GetOrderedDataStore('Streak'):SetAsync('Player_'..player.UserId,player.stats.HighestStreak.Value)
		end
	end

	player.stats.HighestStage.Value = player.leaderstats.Stage.Value

	if player.speedrun.BestTime10.Value ~= math.huge then
		speedrunLb:SetAsync('Player_'..player.UserId,math.floor(player.speedrun.BestTime10.Value*1000))
	end

	local sum = 0
	for i,v in pairs(player.all_badges:GetChildren()) do
		sum += v.Value and 1 or 0
	end
	if player.challenges.LastDay.Value < math.floor(workspace:GetServerTimeNow()/86400)-1 then
		player.challenges.Streak.Value = 0
	end
	player.stats.BadgesEarned.Value = sum
	player.stats.isVIP.Value = game:GetService('MarketplaceService'):UserOwnsGamePassAsync(player.UserId, 96946478)
	if player.stats.isVIP.Value then
		player.stats.Multiplier.Value = 2
		game.ReplicatedStorage.AdminPanel:Fire({'halo',player.Name,'ShinyHalo'})
		local t = require(game.ReplicatedStorage.Tags)
		for i,v in pairs(t) do
			if v.Text == '👑 VIP' then

				local data = game:GetService('DataStoreService'):GetDataStore('Tags'):GetAsync('Player_'..player.UserId)
				data[i] = true

				game:GetService('DataStoreService'):GetDataStore('Tags'):SetAsync('Player_'..player.UserId,data)
				game.ReplicatedStorage.ChatTag:FireClient(player,data,player.stats.CurrentTag.Value)
			end
		end
	end
	if player.halloween.TaskNum.Value == 1 then
		game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,player.halloween.Task1Count.Value/5,1)
		player.halloween.Task1Count:GetPropertyChangedSignal("Value"):Connect(function()
			if player.halloween.TaskNum.Value ~= 1 then return end
			game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,player.halloween.Task1Count.Value/5,1)
		end)
	elseif player.halloween.TaskNum.Value == 2 then
		game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,(10-(player.halloween.CreditsGoal.Value - player.challenges.Credits.Value))/10,2)
		player.halloween.Done.Value = (10-(player.halloween.CreditsGoal.Value - player.challenges.Credits.Value))/10 >= 1
		player.challenges.Credits:GetPropertyChangedSignal("Value"):Connect(function()
			if player.halloween.TaskNum.Value ~= 2 then return end
			player.halloween.Done.Value = (10-(player.halloween.CreditsGoal.Value - player.challenges.Credits.Value))/10 >= 1
			game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,(10-(player.halloween.CreditsGoal.Value - player.challenges.Credits.Value))/10,2)
		end)
	elseif player.halloween.TaskNum.Value == 3 then
		game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,player.halloween.Task3Done.Value and 1 or 0,3)
		player.halloween.Task3Done:GetPropertyChangedSignal("Value"):Connect(function()
			if player.halloween.TaskNum.Value ~= 3 then return end
			game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,player.halloween.Task3Done.Value and 1 or 0,3)
		end)
	elseif player.halloween.TaskNum.Value == 4 then


		game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,"END")
	end

	player.halloween.TaskNum:GetPropertyChangedSignal("Value"):Connect(function()
		if player.halloween.TaskNum.Value == 1 then return end
		game.ReplicatedStorage.AdminPanel:Fire({'halo',player.Name,haloT[player.halloween.TaskNum.Value-1]})
	end)
	--game.ReplicatedStorage.PlacePumpkins:FireClient(player,player.halloween.TaskNum.Value,player.halloween.Done.Value)
	--[[player.halloween.Done:GetPropertyChangedSignal("Value"):Connect(function()
		game.ReplicatedStorage.PlacePumpkins:FireClient(player,player.halloween.TaskNum.Value,player.halloween.Done.Value)
	end)]]
	player.halloween.TaskNum:GetPropertyChangedSignal("Value"):Connect(function()
		if player.halloween.TaskNum.Value == 1 then

			game.ReplicatedStorage.Badge:Invoke(player.UserId,2152709350)
			game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,player.halloween.Task1Count.Value/5,1)
			player.halloween.Task1Count:GetPropertyChangedSignal("Value"):Connect(function()
				if player.halloween.TaskNum.Value ~= 1 then return end
				game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,player.halloween.Task1Count.Value/5,1)
			end)
		elseif player.halloween.TaskNum.Value == 2 then
			game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,(10-(player.halloween.CreditsGoal.Value - player.challenges.Credits.Value))/10,2)
			player.halloween.Done.Value = (10-(player.halloween.CreditsGoal.Value - player.challenges.Credits.Value))/10 >= 1
			player.challenges.Credits:GetPropertyChangedSignal("Value"):Connect(function()
				if player.halloween.TaskNum.Value ~= 2 then return end
				player.halloween.Done.Value = (10-(player.halloween.CreditsGoal.Value - player.challenges.Credits.Value))/10 >= 1
				game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,(10-(player.halloween.CreditsGoal.Value - player.challenges.Credits.Value))/10,2)
			end)
		elseif player.halloween.TaskNum.Value == 3 then
			game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,player.halloween.Task3Done.Value and 1 or 0,3)
			player.halloween.Task3Done:GetPropertyChangedSignal("Value"):Connect(function()
				if player.halloween.TaskNum.Value ~= 3 then return end
				game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,player.halloween.Task3Done.Value and 1 or 0,3)
			end)

		elseif player.halloween.TaskNum.Value == 4 then
			game.ReplicatedStorage.Badge:Invoke(player.UserId,2141994607)
			game.ReplicatedStorage.HalloweenTaskUpdate:FireClient(player,"END")
		end
	end)
	game:GetService('DataStoreService'):GetOrderedDataStore('DailyStreak'):SetAsync('Player_4516257500',player.challenges.Streak.Value)
	local targ = 1720630800
	if os.time()-targ>=0 and os.time()-targ<86400 and not player.stats.RIAFreeSkip24.Value then
		player.stats.FreeSkips.Value += 1
		player.stats.RIAFreeSkip24.Value = true
	end
	local device = game.ReplicatedStorage.Device:InvokeClient(player)
	if device then
		player.stats.Device.Value = "Mobile"
	else
		player.stats.Device.Value = "PC"
	end
	print('Post-Load thread has successfully run for Player_'.. player.UserId .. ' ('..player.Name..') in '..tostring((os.clock()-t)*1000) .. 'ms')
end
local function PlayerAdded(player)
	local loaded = Instance.new('BoolValue')
	loaded.Name = 'Loaded'
	loaded.Parent = player
	local t = os.clock()
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	print('Retreived Data for Player_'.. player.UserId .. ' ('..player.Name..') in '..tostring((os.clock()-t)*1000) .. 'ms')
	local newtT = os.clock()
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
		end)
		if player:IsDescendantOf(game.Players) == true then
			local oldData = pd:GetAsync('Player_'..player.UserId)
			if oldData then
				for ii1,vv1 in pairs(ProfileTemplate) do
					for i1,v1 in pairs(vv1) do
						profile.Data[ii1][i1] = oldData[i1] or profile.Data[ii1][i1]
					end
				end
				pd:RemoveAsync('Player_'..player.UserId)
			end
			Profiles[player] = profile
			for i,v in pairs(ProfileTemplate) do
				local folder = Instance.new('Folder')
				folder.Name = i
				folder.Parent = player
			end
			for ii,vv in pairs(ProfileTemplate) do
				for i,v in pairs(vv) do
					local d
					if typeof(v) == 'boolean' then
						d = Instance.new('BoolValue')
					elseif typeof(v) == 'number' then
						d = Instance.new('NumberValue')
					elseif typeof(v) == 'string' then
						d = Instance.new('StringValue')
					else
						warn('Data named '.. i .. ' appears to be '.. typeof(v))
					end
					d.Name =  i
					pcall(function()
						if table.find(SetToDefault,i) then
							d.Value = ProfileTemplate[ii][i]
						else
							if ii == "all_badges" then
							end
							d.Value = profile.Data[ii][i]
						end
					end)
					d.Parent = player[ii]
					d:GetPropertyChangedSignal('Value'):Connect(function()
						--warn(player.Name .. [['s ]]..i .. ' changed from '.. tostring(profile.Data[ii][i]) .. ' to '.. tostring(d.Value))
						profile.Data[ii][i] = d.Value
						Profiles[player] = profile
					end)
				end
			end
			if player.all_badges.FirstAgain.Value and not player.stats.FirstJoin.Value then
				for i,v in pairs(player.all_badges:GetChildren()) do
					if tonumber(v.Name) then
						v.Value = game:GetService('BadgeService'):UserHasBadgeAsync(player.UserId, tonumber(v.Name))
					end
				end
				player.all_badges.FirstAgain.Value = false
			elseif player.stats.FirstJoin.Value and player.all_badges.FirstAgain.Value then
				player.all_badges.FirstAgain.Value = false
			end

			loaded.Value = true
			--after loaded
			print('Loaded Data for Player_'.. player.UserId .. ' ('..player.Name..') in '..tostring((os.clock()-newtT)*1000) .. 'ms')
			afterLoaded(player)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick('line 149')

	end
end

for _, player in ipairs(game.Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

game.Players.PlayerAdded:Connect(PlayerAdded)

function PlayerRemoving(player,profile)
	profile.Data.stats.TimePlayed = profile.Data.stats.TimePlayed+game.Workspace:GetServerTimeNow()-timeT[player]
	timeT[player] = nil
	profile.Data.stats.FirstJoin = false
	profile.Data.Teleporting = false
	for i,v in pairs(game:GetService('HttpService'):JSONDecode(profile.Data.stats.Link)) do
		local p2 = game.Players:GetPlayerByUserId(v)
		if p2 then
			local t = game:GetService('HttpService'):JSONDecode(p2.stats.Link.Value)
			table.remove(t,table.find(t,v))
			p2.stats.Link.Value = game:GetService('HttpService'):JSONEncode(t)
		end
	end
	profile.Data.stats.Link = "[]"
	if savedStageT[player] then
		profile.Data.stats.CurrentStage = savedStageT[player] 
		profile.Data.leaderstats.Stage = savedStageT[player] 
		profile.Data.settings.SpeedrunMode = false
		savedStageT[player] = nil
	end
end

game.Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	PlayerRemoving(player,profile)
	if profile ~= nil then
		local t = os.clock()
		profile:Release()

		print('Saved Data for Player_'.. player.UserId .. ' ('..player.Name..') in '..tostring((os.clock()-t)*1000) .. 'ms')
	end
end)


game.ReplicatedStorage.RequestStats.OnServerInvoke = function(p)
	local all = Profiles[p].Data
	local n = #require(game.ReplicatedStorage.BadgesModuleScript)
	local sum = p.stats.BadgesEarned.Value
	return all,sum,n
end

game.ReplicatedStorage.Ping.OnServerInvoke = function(p)
	return 
end

game.ReplicatedStorage.Rejoin.OnServerEvent:Connect(function(p)
	game:GetService('TeleportService'):Teleport(game.PlaceId, p)
end)