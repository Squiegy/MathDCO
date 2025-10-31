local checkpoints = workspace.Checkpoints
local maxStage = 0
local sounds = workspace.GameSounds
local currentlyInQuestion = {}
local msgs = require(game.ReplicatedStorage.RandomAbe)
local accuracyDs = game:GetService('DataStoreService'):GetDataStore('Accuracy')
local donationsLb = game:GetService('DataStoreService'):GetOrderedDataStore('Robux')
local ticketsLb = game:GetService('DataStoreService'):GetOrderedDataStore('Tickets')
local streakLb = game:GetService('DataStoreService'):GetOrderedDataStore('Streak')
local restartsLb = game:GetService('DataStoreService'):GetOrderedDataStore('Restarts')
local gamebeaten = game:GetService('DataStoreService'):GetDataStore('BeatGame')
local streakQueue = {}
local stageBadges = {
	[1] = 2128622607,
	[2] = 2128622630,
	[3] = 2128622641,
	[4] = 2128622674,
	[5] = 2128622691,
	[6] = 2129148835,
	[7] = 2130095319,
	[8] = 2143843383,
	[9] = 2148132793,
	[10] = 900954375823114,
	[11] = 162285234164762,
	[12] = 1457434316453020,
	[13] = 2347169537580524,
}
local streakBadges = {
	[10] = 2129388338,
	[25] = 2129388341,
	[50] = 2129388345,
	[100] = 2129388347,
	[0] = 2129388353,
}
local palet = {
	[0] = Color3.fromRGB(255,255,255),
	Color3.fromRGB(105, 255, 102),
	Color3.fromRGB(255, 255, 102),
	Color3.fromRGB(255, 166, 102),
	Color3.fromRGB(255, 102, 102),
	Color3.fromRGB(255, 102, 179),
	Color3.fromRGB(153, 102, 255),
	Color3.fromRGB(102, 179, 255),
	Color3.fromRGB(102, 255, 255),
	Color3.fromRGB(255,255,255),
	Color3.fromRGB(105, 255, 102),
	Color3.fromRGB(255, 255, 102),
	Color3.fromRGB(211, 58, 140),--grade12
	Color3.fromRGB(205, 230, 255),
	Color3.fromRGB(255, 102, 179),
	Color3.fromRGB(153, 102, 255),
	Color3.fromRGB(102, 179, 255),
	Color3.fromRGB(102, 255, 255),
	Color3.fromRGB(255,255,255),
	Color3.fromRGB(105, 255, 102)
}
for i,v in pairs(checkpoints:GetChildren()) do
	v.SurfaceGui.TextLabel.FontFace.Weight = Enum.FontWeight.Medium
	if math.floor(tonumber(v.Name)) > maxStage then
		maxStage = math.floor(tonumber(v.Name))
	end
end
function wordToNumber(word)
	local wordToNumberMapping = {
		one = 1,
		two = 2,
		three = 3,
		four = 4,
		five = 5,
		six = 6,
		seven = 7,
		eight = 8,
		nine = 9,
		ten = 10,
		eleven = 10,
		twelve = 11,
		thirteen = 12,
		fourteen = 13,
		fifteen = 14,
		sixteen = 15,
		seventeen = 16,
		eighteen = 17,
		nineteen = 18
	}

	return wordToNumberMapping[word] or nil
end
function comma(x)
	if math.floor(x) == x then return x end
	local whole,dec = math.modf(x)
	return whole .. ','.. dec
end

function dec(x)
	if tonumber(x) == x then return x end
	local a = string.split(x,',')
	return tostring(a[1] .. '.'.. a[2])
end
local runTime = game.ReplicatedStorage.ServerStats.RunTime
local runtimmy = 0
local lastUpdate = 0
coroutine.wrap(function()
	game:GetService('RunService').Heartbeat:Connect(function(delta)
		runtimmy += delta
		if runtimmy - lastUpdate >= 1 then
			runTime.Value = math.floor(runtimmy)
			lastUpdate = runtimmy
		end
	end)

	game:GetService('MessagingService'):SubscribeAsync('GlobalMessages', function(msg)
		game.ReplicatedStorage.ChatMessageRemote:FireAllClients("<b>[Dev]: </b> <i>"..msg.Data..'</i>', Color3.fromRGB(141, 141, 141))
	end)

	while wait(2) do
		game.ReplicatedStorage.ServerStats.LastUpdated.Value = DateTime.fromIsoDate(game:GetService('MarketplaceService'):GetProductInfo(10725387031).Updated).UnixTimestampMillis/1000
	end
end)()
local first = true
game.ReplicatedStorage.ServerStats.LastUpdated:GetPropertyChangedSignal('Value'):Connect(function()
	if first then first = false return end
	game.ReplicatedStorage.ChatMessageRemote:FireAllClients("<b>[System]: </b> "..'A new version is available',Color3.fromRGB(255, 55, 55))
end)
game.ReplicatedStorage.ServerStats.MaxStage.Value = maxStage


for i,v in pairs(workspace:GetDescendants()) do
	if v:IsA('TrussPart') then
		v.Size = Vector3.new(math.floor(v.Size.X/2)*2,math.floor(v.Size.Y/2)*2,math.floor(v.Size.Z/2)*2)
		local p = Instance.new('Part')
		p.Size = v.Size - Vector3.new(.45,.45,.45)
		p.Position = v.Position
		p.Orientation = v.Orientation
		if v:GetAttribute("Material") then
			p.Material = Enum.Material[v:GetAttribute("Material")]
		else
			p.Material = Enum.Material.Neon
		end
		p.Anchored = true
		p.Transparency = v.Transparency
		p.CanCollide = false
		p.Parent = workspace.TrussParts
		local h,s,vv = Color3.toHSV(v.Color)
		p.Color = Color3.fromHSV(h,s,1)
	end
end
local questions = require(game.ServerScriptService.QuestionsModule)
local questionsGlobal = require(game.ServerScriptService.QuestionsModule.InternationalQuestions)
local lbTags = {
	{
		['Text'] = "#1 Donations",
		['Color'] = Color3.fromRGB(39, 189, 64)
	},
	{
		['Text'] = "#1 Streak",
		['Color'] = Color3.fromRGB(255, 255, 53)
	},
	{
		['Text'] = "#1 Tickets",
		['Color'] = Color3.fromRGB(255, 255, 255)
	},
	{
		['Text'] = "#1 Restarts",
		['Color'] = Color3.fromRGB(69, 134, 255)
	},
	{
		['Text'] = "#1 Speedrun",
		['Color'] = Color3.fromRGB(255, 46, 49)
	},
}
coroutine.wrap(function()
	while wait(600) do
		local ti,ro,re,st,sp = game:GetService('DataStoreService'):GetOrderedDataStore('Tickets'):GetSortedAsync(false,10,1):GetCurrentPage(),game:GetService('DataStoreService'):GetOrderedDataStore('Robux'):GetSortedAsync(false,10,1):GetCurrentPage(),game:GetService('DataStoreService'):GetOrderedDataStore('Restarts'):GetSortedAsync(false,10,1):GetCurrentPage(),game:GetService('DataStoreService'):GetOrderedDataStore('Streak'):GetSortedAsync(false,10,1):GetCurrentPage(),game:GetService('DataStoreService'):GetOrderedDataStore('Speedrun12'):GetSortedAsync(false,10,1):GetCurrentPage()
		local t = table.pack(ti,ro,re,st,sp)
		local tt = {}
		for i,v in pairs(t) do
			if i ~= 'n' then 
				for i = 1,math.huge do
					if not workspace.Leaderboard.LeaderboardGui.SurfaceGui.Script.Blacklist:FindFirstChild(v[i].key) then
						table.insert(tt,v[i].key)
						break
					end
				end

			end

		end
		workspace.Leaderboard.Top.Tickets.Value = tt[1]
		workspace.Leaderboard.Top.Robux.Value = tt[2]
		workspace.Leaderboard.Top.Restarts.Value = tt[3]
		workspace.Leaderboard.Top.Streak.Value = tt[4]
		workspace.Leaderboard.Top.Speedrun12.Value = tt[5]
		workspace.Leaderboard.Top.Loaded.Value = true
	end
end)()
game.ReplicatedStorage.GetTop.OnServerInvoke = function(p)
	local key = "Player_"..p.UserId
	if p.Name == "PerfectlySquared" then return nil end
	for i,v in pairs(workspace.Leaderboard.Top:GetChildren()) do
		if v.Value == key then
			return lbTags[i]
		end
	end
	return nil
end
game.ReplicatedStorage.GetTopBindable.OnInvoke = function(p)
	local key = "Player_"..p.UserId
	if p.Name == "PerfectlySquared" then return nil end
	for i,v in pairs(workspace.Leaderboard.Top:GetChildren()) do
		if v.Value == key then
			return lbTags[i]
		end
	end
	return nil
end
local badgesNames = {}
local badgesLoaded = false
local restrictedBadges = {2128622025,2142410273,2143214321,2128607144,3785851401812808}
local hasBadgeT = {}
local procT = {}
for i,v in pairs(stageBadges) do
	table.insert(restrictedBadges,v)
end
for i,v in pairs(streakBadges) do
	table.insert(restrictedBadges,v)
end
table.find(restrictedBadges,2129388353)
restrictedBadges[table.find(restrictedBadges,2129388353)] = nil
coroutine.wrap(function()


	for i,v in pairs(require(game.ReplicatedStorage.BadgesModuleScript)) do
		hasBadgeT[v.Id] = {}
	end
	for i,v in pairs(require(game.ReplicatedStorage.BadgesModuleScript)) do
		badgesNames[v.Id] = game:GetService('BadgeService'):GetBadgeInfoAsync(v.Id)['Name']
	end
	badgesLoaded = true
end)()
game.ReplicatedStorage.Badge.OnInvoke = function(userid,badgeid)
	if not game.Players:GetPlayerByUserId(userid):WaitForChild('Loaded').Value then
		game.Players:GetPlayerByUserId(userid).Loaded:GetPropertyChangedSignal('Value'):Wait()
	end
	if game.Players:GetPlayerByUserId(userid).all_badges.FirstAgain.Value then
		game.Players:GetPlayerByUserId(userid).all_badges.FirstAgain:GetPropertyChangedSignal('Value'):Wait()
	end
	if not game.Players:GetPlayerByUserId(userid).all_badges[tostring(badgeid)].Value then
		table.insert(hasBadgeT[badgeid],userid)
		game.ReplicatedStorage.ClientBadge:FireClient(game.Players:GetPlayerByUserId(userid),badgeid)
		if not table.find(restrictedBadges,badgeid) then
			game.ReplicatedStorage.ChatMessageRemote:FireAllClients('<b>'..game.Players:GetPlayerByUserId(userid).DisplayName..'</b>'.. ' has received the <u>'.. badgesNames[badgeid] ..'</u> achievement!',Color3.fromHSV(math.random(), 0.490196, 1))

		end
		game:GetService("BadgeService"):AwardBadge(userid, badgeid)
		game.Players:GetPlayerByUserId(userid).all_badges[tostring(badgeid)].Value = true
		game.Players:FindFirstChild(game.Players:GetNameFromUserIdAsync(userid)).stats.BadgesEarned.Value  += 1

	end
	return
end

game.ReplicatedStorage.HasBadgeBind.OnInvoke = function(userid,badgeid)
	return table.find(hasBadgeT[badgeid],userid) ~= nil
end

game.ReplicatedStorage.HasBadge.OnServerInvoke = function(p,id)
	if not p:WaitForChild('Loaded').Value then
		p.Loaded:GetPropertyChangedSignal('Value'):Wait()
	end
	return p.all_badges[tostring(id)].Value--game:GetService('BadgeService'):UserHasBadgeAsync(p.UserId, id)
end
game.ReplicatedStorage.Teleporting.OnServerInvoke = function(p,yes)
	p.Teleporting.Value = yes
	return true
end
local storage = {}
game.ReplicatedStorage.CurrentStageEvent.OnServerEvent:Connect(function(p,val,guh)
	storage[p] = os.clock()+1
	if not guh then guh = "" end

	p.stats.CurrentStage.Value = math.clamp(p.stats.CurrentStage.Value+val,0,p.leaderstats.Stage.Value)
	p.stats.Sunsetter.Value = p.stats.CurrentStage.Value == 130
	print("Click received! Changed from " .. guh .. " to " .. p.stats.CurrentStage.Value)

	-- Check if character exists before teleporting (Good Practice)
	if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
		local checkpointName
		if p.stats.CurrentStage.Value/10 == math.floor(p.stats.CurrentStage.Value/10) and p.stats.CurrentStage.Value ~= 0 then
			checkpointName = p.stats.CurrentStage.Value..".5"
		else
			checkpointName = tostring(p.stats.CurrentStage.Value)
		end

		local checkpointPart = checkpoints:FindFirstChild(checkpointName)
		if checkpointPart then
			p.Character.HumanoidRootPart.CFrame = checkpointPart.CFrame * CFrame.new(0,3.25,0)
		end
	end

	-- THE FIX: Wait for a moment to create a true grace period.
	coroutine.wrap(function()
		task.wait(1.1)
		if storage[p] <= os.clock() then
			p.Teleporting.Value = false
			storage[p] = nil
		end

	end)()
end)

for i,v in pairs(checkpoints:GetChildren()) do
	if string.gsub(string.gsub(string.gsub(string.gsub(math.floor(tonumber(v.Name)),'8',''),'0',''),'9',''),'6','') == '' then
		v.SurfaceGui.TextLabel.Text = "<u>"..math.floor(tonumber(v.Name)).."</u>"
	else
		v.SurfaceGui.TextLabel.Text = math.floor(tonumber(v.Name))
	end

end
local doingStageTable = {}
local dev = false

function tickets(stage,resets)
	return math.ceil(stage/10)*(.1*(resets)+1)
end

for i,v in pairs(workspace.FirstFall:GetChildren()) do
	if v:IsA("Part") then
		v.Transparency = 1
		v.Touched:Connect(function(hit)
			if game.Players:GetPlayerFromCharacter(hit.Parent) then
				local p = game.Players:GetPlayerFromCharacter(hit.Parent)
				if p.stats.FirstFall.Value then
					p.stats.FirstFall.Value = false
					game.ReplicatedStorage.FirstFall:FireClient(p)
				end
			end
		end)
	end
end

game.Players.PlayerAdded:Connect(function(p)
	coroutine.wrap(function()
		coroutine.wrap(function()
			p:WaitForChild('Loaded'):GetPropertyChangedSignal('Value'):Wait()
			if p.leaderstats.Stage.Value == maxStage then
				game.ReplicatedStorage.Badge:Invoke(p.UserId, 2128607305)
			end
			if p:IsInGroup(17190781) then
				if not p.stats.FreeHint.Value then
					p.stats.FreeHint.Value = true
					p.stats.Hints.Value += 2
				end
				game.ReplicatedStorage.Badge:Invoke(p.UserId, 2142296843)
			end
		end)()
		if game.ReplicatedStorage.AprilFoolsBool.Value then
			game.ReplicatedStorage.Badge:Invoke(p.UserId, 2143214321)
		end
		local targ = 1720630800
		if os.time()-targ>=0 and os.time()-targ<86400 then
			game.ReplicatedStorage.Badge:Invoke(p.UserId, 3785851401812808)
		else
			
			game.ReplicatedStorage.Badge:Invoke(p.UserId, 2128622025)
		end 
		game.ReplicatedStorage.Badge:Invoke(p.UserId, 2128622025)
		if (os.date("*t",os.time()).month == 3 and (os.date("*t",os.time()).day == 15 or os.date("*t",os.time()).day == 16)) then
			game.ReplicatedStorage.Badge:Invoke(p.UserId, 3028835696845716)
			game.ReplicatedStorage.AdminPanel:Fire({'halo',p.Name,'PiHalo'})
		end
	end)()
	coroutine.wrap(function()
		if not donationsLb:GetAsync('Player_'..p.UserId) then
			donationsLb:SetAsync('Player_'..p.UserId,0)
		end
	end)()

	p.CharacterAdded:Connect(function(c)
		c:WaitForChild('Humanoid').DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		pcall(function()
			table.remove(doingStageTable,table.find(doingStageTable,p))
		end)
		coroutine.wrap(function()
			repeat task.wait() until p:WaitForChild('Loaded').Value == true
			if p.towers.InTower.Value then
				c.HumanoidRootPart.CFrame = workspace:FindFirstChild("TowerTP").CFrame * CFrame.new(0,3.25,0)
				return
			end
			if p:WaitForChild('stats'):WaitForChild('CurrentStage').Value/10 == math.floor(p.stats.CurrentStage.Value/10) and p.stats.CurrentStage.Value ~= 0 then
				c.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value+.5).CFrame * CFrame.new(0,3.25,0)
			else
				c.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value).CFrame * CFrame.new(0,3.25,0)
			end

		end)()

	end)
	
	if dev then
		pcall(function()
			game.ReplicatedStorage.Badge:Invoke(p.UserId, 2128607144)
		end)
	end

	pcall(function()
		if p.Name == 'PerfectlySquared' then 
			dev = true
			for i,v in pairs(game.Players:GetPlayers()) do 
				game.ReplicatedStorage.Badge:Invoke(v.UserId, 2128607144)
			end 
		end
	end)
	repeat wait() until p:WaitForChild('Loaded')
	coroutine.wrap(function()
		for i,v in pairs(game.Players:GetPlayers()) do
			repeat wait() until v:WaitForChild('Loaded').Value 
			v.stats.Multiplier.Value = 1
		end

		for i1,p1 in pairs(game.Players:GetPlayers()) do
			for i2,p2 in pairs(game.Players:GetPlayers()) do
				if p1:IsFriendsWith(p2.UserId) then
					p1.stats.Multiplier.Value += .2
				end
			end
		end
		for i,v in pairs(game.Players:GetPlayers()) do
			if game:GetService('MarketplaceService'):UserOwnsGamePassAsync(p.UserId, 96946478) then
				v.stats.Multiplier.Value *= 2
			end
		end

	end)()
	
end)

game.ReplicatedStorage.PiDigit.OnServerEvent:Connect(function(p,digit,max,review)
	p.piday.Digit.Value = digit
	p.piday.MaxDigit.Value = max
	p.piday.Review.Value = review
end)

game.ReplicatedStorage.GamepassCheck.OnServerInvoke = function(p,userid,gamepassid)
	return game:GetService('MarketplaceService'):UserOwnsGamePassAsync(userid, gamepassid)
end

game.ReplicatedStorage.GamepassCheckBind.OnInvoke = function(userid,gamepassid)
	return game:GetService('MarketplaceService'):UserOwnsGamePassAsync(userid, gamepassid)
end
game.Players.PlayerRemoving:Connect(function(p)
	table.remove(currentlyInQuestion,table.find(currentlyInQuestion,p))
	if p.Name == 'PerfectlySquared' then
		dev = false
	end
	ticketsLb:SetAsync("Player_"..p.UserId,math.floor(p.stats.Tickets.Value))
	coroutine.wrap(function()
		repeat wait() until p:WaitForChild('Loaded').Value 
		p.stats.Multiplier.Value = 1

		for i1,p1 in pairs(game.Players:GetPlayers()) do
			if p1:IsFriendsWith(p.UserId) then
				if game:GetService('MarketplaceService'):UserOwnsGamePassAsync(p1.UserId, 96946478) then
					p1.stats.Multiplier.Value -= .4
				else
					p1.stats.Multiplier.Value -= .2
				end
			end
		end
	end)()
end)
for ii,vv in pairs(workspace.Killbricks:GetChildren()) do
	for i,v in pairs(vv:GetChildren()) do
		v.Touched:Connect(function(hit)
			if game.ReplicatedStorage.Halos:FindFirstChild(hit.Name) or game.ReplicatedStorage.Fire:FindFirstChild(hit.Name) then return end
			if game.Players:GetPlayerFromCharacter(hit.Parent) then
				local p = game.Players:GetPlayerFromCharacter(hit.Parent)
				p.stats.Deaths.Value += 1
				if p.stats.CurrentStage.Value/10 == math.floor(p.stats.CurrentStage.Value/10) and p.stats.CurrentStage.Value ~= 0 then
					p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value+.5).CFrame * CFrame.new(0,3.25,0)
				else
					p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value).CFrame * CFrame.new(0,3.25,0)
				end


			end
		end)
	end

end

game.ReplicatedStorage.ClientKb.OnServerEvent:Connect(function(p)
	p.stats.Deaths.Value += 1
	if p.stats.CurrentStage.Value/10 == math.floor(p.stats.CurrentStage.Value/10) and p.stats.CurrentStage.Value ~= 0 then
		p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value+.5).CFrame * CFrame.new(0,3.25,0)
	else
		p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value).CFrame * CFrame.new(0,3.25,0)
	end
end)

function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end
function color3ToHex(color3)
	local function getHex(num)
		local chars = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
		local hex = ""
		local x = num / 16
		local y = num % 16

		hex = chars[math.floor(x) + 1] .. chars[math.floor(y) + 1]

		return hex
	end
	if not color3.R then return "#000000" end

	local r, g, b = color3.r * 255, color3.g * 255, color3.b * 255
	return "#" .. getHex(r) .. getHex(g) .. getHex(b)
end

for i,checkpoint in pairs(checkpoints:GetChildren()) do
	checkpoint.Touched:Connect(function(hit)
		if game.Players:GetPlayerFromCharacter(hit.Parent) then
			local p = game.Players:GetPlayerFromCharacter(hit.Parent)
			if p.leaderstats.Stage.Value >= tonumber(checkpoint.Name) and p.stats.CurrentStage.Value == tonumber(checkpoint.Name) - 1 and not p.Teleporting.Value then 
				p.stats.CurrentStage.Value += 1 
				print("hello! im changing stuff!") 
				if tonumber(checkpoint.Name)/10 == math.floor(tonumber(checkpoint.Name)/10) then 
					p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value+.5).CFrame * CFrame.new(0,3.25,0) 
				end 
				return 
			end

			if p.leaderstats.Stage.Value == checkpoint.Name - 1 and not table.find(doingStageTable,p) then
				table.insert(doingStageTable,p)
				p.Character.Humanoid.WalkSpeed = 0

				local questionTable 
				local func
				local finalNumbers = {}

				local pcallFunc = function() -- start
					if p.settings.Region.Value and questionsGlobal[tonumber(checkpoint.Name)] then
						questionTable = shallowCopy(questionsGlobal[tonumber(checkpoint.Name)])
					else
						questionTable = shallowCopy(questions[tonumber(checkpoint.Name)])

					end
					finalNumbers = {}
					local numbers = questionTable['Numbers']
					for i,v in ipairs(numbers) do
						table.insert(finalNumbers,v())
					end
					questionTable['Question'] = string.format(questionTable['Question'],table.unpack(finalNumbers))
					pcall(function()
						questionTable['Hint'] = string.gsub(questionTable['Hint'],'{%d}+',function (n) n = (string.gsub(n,'%D','')) return finalNumbers[tonumber(n)] end)
					end)
					func = function(input,...)
						if p.settings.Region.Value and questionsGlobal[tonumber(checkpoint.Name)] then
							for i,v in pairs(questionsGlobal[tonumber(checkpoint.Name)]['Answers']) do
								if typeof(v[1](...)) == 'number' and typeof(input) ~= typeof(true) then
									input = input:gsub('[^%d%$%.]+', '')
									if string.find(input,'%$') then
										input = string.gsub(input,'%$','')
									end
									if tonumber(input) == v[1](...) then
										return true
									end
								end
								if string.lower(tostring(input)) == string.lower(tostring(questionsGlobal[tonumber(checkpoint.Name)]['Answers'][#questionTable['Answers']][1](...))) then
									return true
								end
							end
							return false,string.lower(tostring(questionsGlobal[tonumber(checkpoint.Name)]['Answers'][#questionTable['Answers']][1](...)))
						else
							for i,v in pairs(questions[tonumber(checkpoint.Name)]['Answers']) do
								if typeof(v[1](...)) == 'number' and typeof(input) ~= typeof(true) then
									input = input:gsub('[^%d%$%.]+', '')
									if string.find(input,'%$') then
										input = string.gsub(input,'%$','')
									end
									if tonumber(input) == v[1](...) then
										return true
									end
								end
								if string.lower(tostring(input)) == string.lower(tostring(questions[tonumber(checkpoint.Name)]['Answers'][#questionTable['Answers']][1](...))) then
									return true
								end
							end

						end

						return false,string.lower(tostring(questions[tonumber(checkpoint.Name)]['Answers'][#questionTable['Answers']][1](...)))
					end
					local newAnswers = {}
					local ansCheck = {}
					for i,v in ipairs(questionTable['Answers']) do
						table.insert(newAnswers,{v[1](table.unpack(finalNumbers)),v[2]})
					end
					questionTable['Answers'] = newAnswers -- answer table now has valid

					local correctAns = newAnswers[#newAnswers]
					correctAns[2] = false
					for i,v in pairs(newAnswers) do
						if not table.find(ansCheck,v[1]) then
							table.insert(ansCheck,v[1])
						end
					end
					local newnewanswers = {}
					for i,v in pairs(ansCheck) do
						if v == correctAns[1] then
							table.insert(newnewanswers,{v,true})
						else
							table.insert(newnewanswers,{v,false})
						end
					end
					for i,v in pairs(numbers) do
					end
					questionTable['Answers'] = newnewanswers
					table.insert(currentlyInQuestion,p)
				end
				local s,e = pcall(pcallFunc)
				local successFunc = function()
					if p.leaderstats.Stage.Value == tonumber(checkpoint.Name) then return true end
					local result,ans = game.ReplicatedStorage.QuestionPrompt:InvokeClient(p,questionTable,checkpoint.Name)
					
					pcall(function()
						if checkpoint.Name == '72' and tonumber(result) <= 0 then
							game.ReplicatedStorage.Badge:Invoke(p.UserId,2148132771)
						end
					end)
					p.Character.Humanoid.WalkSpeed = 16

					if result == true then
						table.remove(currentlyInQuestion,table.find(currentlyInQuestion,p))
						table.remove(doingStageTable,table.find(doingStageTable,p))
						--game.ReplicatedStorage.ResetBack:FireClient(p)
						print("hewo!")
						return
					end
					if result == 'Speedrun' then
						return
					end
					local correct,ans
					table.remove(currentlyInQuestion,table.find(currentlyInQuestion,p))
					table.remove(doingStageTable,table.find(doingStageTable,p))
					if questionTable['Written'] == true then
						local s,e = pcall(function()
							local abc = dec(result)
						end)
						if  typeof(result) ~= "boolean" and wordToNumber(string.lower(result)) ~= nil then
							result = tostring(wordToNumber(string.lower(result)) )
						end
						if tonumber(result) then
							correct,ans = func(result,table.unpack(finalNumbers))
						elseif s then
							correct,ans = func(dec(result),table.unpack(finalNumbers))
						else
							correct,ans = func(result,table.unpack(finalNumbers))
						end
					else
						for i,answer in pairs(questionTable['Answers']) do
							if tostring(answer[1]) == tostring(result) then
								correct = answer[2]
							end
							if answer[2] then ans = answer[1] end
						end
					end
					if checkpoint.Name == "130" then
						local dd = gamebeaten:GetAsync("Players")
						local d
						local max = 0
						local maxname = "Genesis"

						if not dd then
							d = {["Genesis"] = 0}
						else
							d = game:GetService("HttpService"):JSONDecode(dd)

							for name, ts in pairs(d) do
								-- Check that this isn't the current player and that timestamp is newer
								if name ~= p.Name and ts > max then
									max = ts
									maxname = name
								end
							end
						end

						-- mark end credits
						p:SetAttribute("EndCredits", true)

						-- add player if not in table (or update with latest timestamp if needed)
						if not d[p.Name] then
							d[p.Name] = DateTime.now().UnixTimestamp
							gamebeaten:SetAsync("Players", game:GetService("HttpService"):JSONEncode(d))
						end

						-- send data to client
						local done = game.ReplicatedStorage.EndCredits:InvokeClient(
							p,
							maxname,
							p.stats.TimePlayed.Value,
							p.stats.Deaths.Value,
							correct
						)

						p:SetAttribute("EndCredits", false)
					end
					if not correct and checkpoint.Name ~= "130" then
						if (tonumber(checkpoint.Name)-1)/10 == math.floor((tonumber(checkpoint.Name)-1)/10)  and p.stats.CurrentStage.Value ~= 0 then

							p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value+.5).CFrame * CFrame.new(0,3.25,0)
						else
							p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value).CFrame * CFrame.new(0,3.25,0)

						end
					end
					if (p.stats.Device.Value == "PC" or correct) and checkpoint.Name ~= "130" then
						game.ReplicatedStorage.CorrectEffect:FireClient(p,correct,p.stats.Streak.Value,ans)
					elseif result == false then
						game.ReplicatedStorage.CorrectEffect:FireClient(p,false,"p.stats.Streak.Value","ans","please")
					
					end
					if correct or checkpoint.Name == "130" then
						coroutine.wrap(function()
							local d = accuracyDs:GetAsync('Stage_'..checkpoint.Name)
							if d then
								accuracyDs:SetAsync('Stage_'..checkpoint.Name,{d[1]+1,d[2]})
							else
								accuracyDs:SetAsync('Stage_'..checkpoint.Name,{1,0})
							end
						end)()
						p.stats.CurrentStage.Value = tonumber(checkpoint.Name)
						print("hello! im changing stuff!")
						p.leaderstats.Stage.Value = tonumber(checkpoint.Name)
						table.remove(doingStageTable,table.find(doingStageTable,p))
						if tonumber(checkpoint.Name) == maxStage then
							game.ReplicatedStorage.Badge:Invoke(p.UserId, 2128607305)
							if checkpoint.Name ~= "130" then
								game.ReplicatedStorage.PromptRestart:FireClient(p,p.stats.Restarts.Value,p,2)
							end
						end
						if p.leaderstats.Stage.Value/10 == math.floor(p.leaderstats.Stage.Value/10) then
							game.ReplicatedStorage.ChatMessageRemote:FireAllClients('<b>'..p.DisplayName..'</b>'.. ' has completed Grade '.. p.leaderstats.Stage.Value/10-1 ..'!',palet[p.leaderstats.Stage.Value/10 - 1])
						end
						for i = 10,#stageBadges*10,10 do
							if p.leaderstats.Stage.Value == i then
								game.ReplicatedStorage.Badge:Invoke(p.UserId, stageBadges[i/10])
							end
						end
						if not p.settings.SpeedrunMode.Value then -- speedrun mode enabled, no losing/gaining streaks
							p.stats.Streak.Value += 1
							if p.stats.Streak.Value > p.stats.HighestStreak.Value then
								coroutine.wrap(function()
									streakLb:SetAsync("Player_"..p.UserId,p.stats.Streak.Value)
								end)()
								p.stats.HighestStreak.Value = p.stats.Streak.Value
							end
							if p.leaderstats.Stage.Value > p.stats.HighestStage.Value then

								p.stats.HighestStage.Value = p.leaderstats.Stage.Value
							end
							if streakBadges[p.stats.Streak.Value] then
								game.ReplicatedStorage.Badge:Invoke(p.UserId, streakBadges[p.stats.Streak.Value])
								coroutine.wrap(function()
									if not p.all_badges[streakBadges[p.stats.Streak.Value]].Value  then --game:GetService('BadgeService'):UserHasBadgeAsync(p.UserId,streakBadges[p.stats.Streak.Value])
										game.ReplicatedStorage.ChatMessageRemote:FireAllClients('<b>'..p.DisplayName..'</b>'.. ' has reached a streak of <u>'.. p.stats.Streak.Value ..'</u> for the first time!',Color3.fromHSV(0.611111, p.stats.Streak.Value/100, 1))

									end
								end)()
							end

						end
						if tonumber(checkpoint.Name)/10 == math.floor(tonumber(checkpoint.Name)/10) then
							for i,emitter in pairs(script.Confetti:GetChildren()) do
								local c = emitter:Clone()
								c.Parent = checkpoints:FindFirstChild(p.stats.CurrentStage.Value+.5)
								coroutine.wrap(function()
									wait(.5)
									c.Enabled = false
									wait(1)
									c:Destroy()
								end)()
							end
							p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value+.5).CFrame * CFrame.new(0,3.25,0)
							if p.settings.SpeedrunMode.Value then
								local timeTook, totalTime, secondsBetter = game.ReplicatedStorage.SpeedrunBack:Invoke(p,p.stats.CurrentStage.Value/10)
								game.ReplicatedStorage.SpeedrunBackToClient:FireClient(p,p.stats.CurrentStage.Value/10,timeTook,totalTime,secondsBetter)
							end
						end
						for i,emitter in pairs(script.Confetti:GetChildren()) do
							local c = emitter:Clone()
							c.Parent = checkpoint
							coroutine.wrap(function()
								wait(.5)
								c.Enabled = false
								wait(2)
								c:Destroy()
							end)()
						end
						local a = tickets(tonumber(checkpoint.Name),p.stats.Restarts.Value)*p.stats.Multiplier.Value*game.ReplicatedStorage.ServerStats.ServerMultiplier.Value
						if not p.settings.SpeedrunMode.Value then
							p.stats.Tickets.Value += a
							game.ReplicatedStorage.TicketFallRemote:FireClient(p,a)
						end
						if p.settings.StreakNotif.Value and not p.settings.SpeedrunMode.Value and p.stats.Device.Value == "PC" and checkpoint.Name ~= "130" then
							game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Correct',[[Nice! You have a streak of <i><b>]]..p.stats.Streak.Value ..[[</b></i>!]],'rbxassetid://10116606885',Color3.fromRGB(105, 255, 105),sounds.Confetti.SoundId)
						end
						game.ReplicatedStorage.PlaySoundRemote:FireClient(p,workspace.GameSounds.Firework.SoundId)
					else
						if result ~= false then
							coroutine.wrap(function()
								local d = accuracyDs:GetAsync('Stage_'..checkpoint.Name)
								if d then
									accuracyDs:SetAsync('Stage_'..checkpoint.Name,{d[1],d[2]+1})
								else
									accuracyDs:SetAsync('Stage_'..checkpoint.Name,{0,1})
								end
							end)()
							game.ReplicatedStorage.QuestionWrong:FireClient(p)
							if not p.settings.SpeedrunMode.Value then
								local streak = p.stats.Streak.Value
								streakQueue[p] = streak
								p.stats.Streak.Value = 0
								if streakQueue[p] >= p.settings.PromptStreakSave.Value then
									p.Character.Humanoid.WalkSpeed = 0
									game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Hold on..',[[That is incorrect! Would you like to save your streak?]],'rbxassetid://13594032231',Color3.fromRGB(55, 188, 255),sounds.Error.SoundId)
									local reply = game.ReplicatedStorage.PromptSaveStreak:InvokeClient(p,streak)
									p.Character.Humanoid.WalkSpeed = 16
									if reply == true then
										if p.stats.Savers.Value > 0 then
											p.stats.Savers.Value -= 1

											if p.stats.Device.Value == "Mobile" then
												game.ReplicatedStorage.CorrectEffect:FireClient(p,"correct","","ans",true)
											end
											game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Streak Saved!', 'You keep your streak of <b>'..streakQueue[p] .. '</b>. You now have <b>'.. p.stats.Savers.Value .. '</b> streak savers left!','rbxassetid://13594032231',Color3.fromRGB(105, 205, 255),sounds.Purchase.SoundId)
											p.stats.Streak.Value = streakQueue[p]
											streakQueue[p] = nil
											p.Character.Humanoid.WalkSpeed = 16
											game.ReplicatedStorage.Effect:FireClient(p,Color3.fromRGB(105, 205, 255))
										else
											game.ReplicatedStorage.PromptDevProductBindable:Fire(p,1551210853)
											if p.stats.Device.Value == "Mobile" then
												game.ReplicatedStorage.CorrectEffect:FireClient(p,correct,p.stats.Streak.Value,ans,true)
											end
										end
									else
										p.Character.Humanoid.WalkSpeed = 16
										if p.stats.Device.Value == "Mobile" then
											game.ReplicatedStorage.CorrectEffect:FireClient(p,correct,p.stats.Streak.Value,ans)
										end
										if p.settings.StreakNotif.Value then
											if p.stats.Device.Value == "PC" then
												game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Incorrect',[[Ouch! You lost your streak of <i><b>]]..streakQueue[p] ..[[</b></i>!]],'rbxassetid://10737523175',Color3.fromRGB(255, 55, 55),sounds.Error.SoundId)
											end
										end
										if p.settings.CorrectNotif.Value then
											if p.stats.Device.Value == "PC" then
												game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Incorrect',[[The correct answer was <b>]]..ans .. '</b>','rbxassetid://10737523175',Color3.fromRGB(255, 55, 55),sounds.Error.SoundId)
											end
										end
										game.ReplicatedStorage.Badge:Invoke(p.UserId, streakBadges[0])
										streakQueue[p] = nil
									end
								else
									
									if p.stats.Device.Value == "Mobile" then
										game.ReplicatedStorage.CorrectEffect:FireClient(p,correct,p.stats.Streak.Value,ans)
									end
									if p.settings.StreakNotif.Value then
										if p.stats.Device.Value == "PC" then
											game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Incorrect',[[Ouch! You lost your streak of <i><b>]]..streakQueue[p] ..[[</b></i>!]],'rbxassetid://10737523175',Color3.fromRGB(255, 55, 55),sounds.Error.SoundId)
										end
									end
									if p.settings.CorrectNotif.Value then
										if p.stats.Device.Value == "PC" then
											game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Incorrect',[[The correct answer was <b>]]..ans .. '</b>','rbxassetid://10737523175',Color3.fromRGB(255, 55, 55),sounds.Error.SoundId)
										end
									end
									game.ReplicatedStorage.Badge:Invoke(p.UserId, streakBadges[0])
									streakQueue[p] = nil
								end
							end
						end
					end
				end
				if not s then

					local trueS = false
					local ss = 0
					while not trueS do
						local s,e = pcall(pcallFunc)
						trueS = s
						ss+= 1
						if ss > 100 then error(e) end
					end
					successFunc()
				else
					successFunc()
				end
			end

		end
		return	
	end)
end

game.ReplicatedStorage.IsInQuestion.OnInvoke = function(p)
	return table.find(currentlyInQuestion,p) ~= nil
end
game.ReplicatedStorage.IsInQuestionRemote.OnServerInvoke = function(p)
	return table.find(currentlyInQuestion,p) ~= nil
end

local currentlyPractice = {}
-- practice
game.ReplicatedStorage.PracticeRequest.OnServerEvent:Connect(function(p,stage)
	local questionTable 
	if p.settings.Region.Value and questionsGlobal[stage] then
		questionTable = shallowCopy(questionsGlobal[stage])
	else
		questionTable = shallowCopy(questions[stage])

	end
	local func
	local finalNumbers = {}

	local pcallFunc = function() -- start
		finalNumbers = {}
		local numbers = questionTable['Numbers']
		for i,v in ipairs(numbers) do
			table.insert(finalNumbers,v())
		end
		questionTable['Question'] = string.format(questionTable['Question'],table.unpack(finalNumbers))
		pcall(function()
			questionTable['Hint'] = string.gsub(questionTable['Hint'],'{%d}+',function (n) n = (string.gsub(n,'%D','')) return finalNumbers[tonumber(n)] end)
		end)

		local newAnswers = {}
		local ansCheck = {}
		for i,v in ipairs(questionTable['Answers']) do
			table.insert(newAnswers,{v[1](table.unpack(finalNumbers)),v[2]})
		end

		questionTable['Answers'] = newAnswers -- answer table now has valid

		local correctAns = newAnswers[#newAnswers]
		correctAns[2] = false
		for i,v in pairs(newAnswers) do
			if not table.find(ansCheck,v[1]) then
				table.insert(ansCheck,v[1])
			end
		end
		local newnewanswers = {}
		for i,v in pairs(ansCheck) do
			if v == correctAns[1] then
				table.insert(newnewanswers,{v,true})
			else
				table.insert(newnewanswers,{v,false})
			end
		end
		for i,v in pairs(numbers) do
		end
		questionTable['Answers'] = newnewanswers
	end
	local s,e = pcall(pcallFunc)

	local successFunc = function()
		currentlyPractice[p.UserId] = {
			['Stage'] = stage,
			['finalNumbers'] = finalNumbers,
			['questionTable'] = questionTable,
		}

		game.ReplicatedStorage.PracticeSend:FireClient(p,questionTable,stage)

	end
	local s,e = pcall(successFunc)
	if not s then print(e) end
end)

game.ReplicatedStorage.PracticeReset.OnServerEvent:Connect(function(p)
	local stage = currentlyPractice[p.UserId].Stage
	local questionTable 
	if p.settings.Region.Value and questionsGlobal[stage] then
		questionTable = shallowCopy(questionsGlobal[stage])
	else
		questionTable = shallowCopy(questions[stage])

	end
	local func
	local finalNumbers = {}

	local pcallFunc = function() -- start
		finalNumbers = {}
		local numbers = questionTable['Numbers']
		for i,v in ipairs(numbers) do
			table.insert(finalNumbers,v())
		end
		questionTable['Question'] = string.format(questionTable['Question'],table.unpack(finalNumbers))
		pcall(function()
			questionTable['Hint'] = string.gsub(questionTable['Hint'],'{%d}+',function (n) n = (string.gsub(n,'%D','')) return finalNumbers[tonumber(n)] end)
		end)

		local newAnswers = {}
		local ansCheck = {}
		for i,v in ipairs(questionTable['Answers']) do
			table.insert(newAnswers,{v[1](table.unpack(finalNumbers)),v[2]})
		end

		questionTable['Answers'] = newAnswers -- answer table now has valid

		local correctAns = newAnswers[#newAnswers]
		correctAns[2] = false
		for i,v in pairs(newAnswers) do
			if not table.find(ansCheck,v[1]) then
				table.insert(ansCheck,v[1])
			end
		end
		local newnewanswers = {}
		for i,v in pairs(ansCheck) do
			if v == correctAns[1] then
				table.insert(newnewanswers,{v,true})
			else
				table.insert(newnewanswers,{v,false})
			end
		end
		for i,v in pairs(numbers) do
		end
		questionTable['Answers'] = newnewanswers
	end
	local s,e = pcall(pcallFunc)

	local successFunc = function()
		currentlyPractice[p.UserId] = {
			['Stage'] = stage,
			['finalNumbers'] = finalNumbers,
			['questionTable'] = questionTable,
		}

		game.ReplicatedStorage.PracticeResetBack:FireClient(p,questionTable,stage)


	end
	local s,e = pcall(successFunc)
	if not s then print(e) end

end)

game.ReplicatedStorage.PracticeNext.OnServerEvent:Connect(function(p)
	local stage = currentlyPractice[p.UserId].Stage + 1
	local questionTable 
	if p.settings.Region.Value and questionsGlobal[stage] then
		questionTable = shallowCopy(questionsGlobal[stage])
	else
		questionTable = shallowCopy(questions[stage])

	end
	local func
	local finalNumbers = {}

	local pcallFunc = function() -- start
		finalNumbers = {}
		local numbers = questionTable['Numbers']
		for i,v in ipairs(numbers) do
			table.insert(finalNumbers,v())
		end
		questionTable['Question'] = string.format(questionTable['Question'],table.unpack(finalNumbers))
		pcall(function()
			questionTable['Hint'] = string.gsub(questionTable['Hint'],'{%d}+',function (n) n = (string.gsub(n,'%D','')) return finalNumbers[tonumber(n)] end)
		end)

		local newAnswers = {}
		local ansCheck = {}
		for i,v in ipairs(questionTable['Answers']) do
			table.insert(newAnswers,{v[1](table.unpack(finalNumbers)),v[2]})
		end

		questionTable['Answers'] = newAnswers -- answer table now has valid

		local correctAns = newAnswers[#newAnswers]
		correctAns[2] = false
		for i,v in pairs(newAnswers) do
			if not table.find(ansCheck,v[1]) then
				table.insert(ansCheck,v[1])
			end
		end
		local newnewanswers = {}
		for i,v in pairs(ansCheck) do
			if v == correctAns[1] then
				table.insert(newnewanswers,{v,true})
			else
				table.insert(newnewanswers,{v,false})
			end
		end
		for i,v in pairs(numbers) do
		end
		questionTable['Answers'] = newnewanswers
	end
	local s,e = pcall(pcallFunc)

	local successFunc = function()
		currentlyPractice[p.UserId] = {
			['Stage'] = stage,
			['finalNumbers'] = finalNumbers,
			['questionTable'] = questionTable,
		}

		game.ReplicatedStorage.PracticeNextBack:FireClient(p,questionTable,stage)


	end
	local s,e = pcall(successFunc)

end)
game.ReplicatedStorage.PracticeDelete.OnServerEvent:Connect(function(p)
	currentlyPractice[p.UserId] = nil
end)
game.ReplicatedStorage.PracticeAttemptBack.OnServerEvent:Connect(function(p,result)
	local stage = currentlyPractice[p.UserId].Stage
	local finalNumbers = currentlyPractice[p.UserId].finalNumbers
	local questionTable = currentlyPractice[p.UserId].questionTable

	local func = function(input,...)
		if p.settings.Region.Value and questionsGlobal[stage] then
			for i,v in pairs(questionsGlobal[stage]['Answers']) do
				if typeof(v[1](...)) == 'number' and typeof(input) ~= typeof(true) then
					input = input:gsub('[^%d%$%.]+', '')
					if string.find(input,'%$') then
						input = string.gsub(input,'%$','')
					end
					if tonumber(input) == v[1](...) then
						return true
					end
				end
				if string.lower(tostring(input)) == string.lower(tostring(questions[stage]['Answers'][#questionTable['Answers']][1](...))) then
					return true
				end
			end
		else
			for i,v in pairs(questions[stage]['Answers']) do
				if typeof(v[1](...)) == 'number' and typeof(input) ~= typeof(true) then
					input = input:gsub('[^%d%$%.]+', '')
					if string.find(input,'%$') then
						input = string.gsub(input,'%$','')
					end
					if tonumber(input) == v[1](...) then
						return true
					end
				end
				if string.lower(tostring(input)) == string.lower(tostring(questions[stage]['Answers'][#questionTable['Answers']][1](...))) then
					return true
				end
			end
		end

		return false,string.lower(tostring(questions[stage]['Answers'][#questionTable['Answers']][1](...)))
	end
	if result == true then return end
	local correct
	if questionTable['Written'] == true then
		local s,e = pcall(function()
			local abc = dec(result)
		end)
		if wordToNumber(string.lower(result)) ~= nil then
			result = tostring(wordToNumber(string.lower(result)) )
		end
		if tonumber(result) then
			correct = func(result,table.unpack(finalNumbers))
		elseif s then
			correct = func(dec(result),table.unpack(finalNumbers))
		else
			correct = func(result,table.unpack(finalNumbers))
		end


	else
		for i,answer in pairs(questionTable['Answers']) do
			if tostring(answer[1]) == tostring(result) then
				correct = answer[2]
			end
		end
	end
	game.ReplicatedStorage.PracticeCorrectEffect:FireClient(p,correct)
	if correct then
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Correct',[[Nice!]],'rbxassetid://10116606885',Color3.fromRGB(105, 255, 105),sounds.Confetti.SoundId)
		game.ReplicatedStorage.PlaySoundRemote:FireClient(p,workspace.GameSounds.Firework.SoundId)
	else
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Incorrect',[[Yowch!]],'rbxassetid://10737523175',Color3.fromRGB(255, 55, 55),sounds.Error.SoundId)

	end
end)

local t = {
	[1] = 1309638079,
	[5] = 1309638253,
	[10] = 1309638252,
	[25] = 1309638251
}

local gamePassFunctions = {
	[92726733] = function(player)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(player,msgs.Purchased[math.random(#msgs.Purchased)],true)
		game.ReplicatedStorage.NotificationBigRemote:FireClient(player,'Purchase Successful!', 'You now have access to the calculator!','rbxassetid://11215965354',Color3.fromRGB(105, 155, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.GamepassBuy:FireClient(player,92726733)
		donationsLb:SetAsync('Player_'..player.UserId,donationsLb:GetAsync('Player_'..player.UserId) + 35)
	end,
	[96946478] = function(player)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(player,msgs.Purchased[math.random(#msgs.Purchased)],true)
		game.ReplicatedStorage.NotificationBigRemote:FireClient(player,'Purchase Successful!', 'Welcome to the club! (Rejoin for chat tag)','rbxassetid://11344995655',Color3.fromRGB(255, 255, 80),sounds.Purchase.SoundId)
		player.stats.Multiplier.Value = 2
		game.ReplicatedStorage.AdminPanel:Fire({'halo',player.Name,'ShinyHalo'})
		local t = require(game.ReplicatedStorage.Tags)
		coroutine.wrap(function()
			for i,v in pairs(t) do
				if v.Text == '👑 VIP' then

					local data = game:GetService('DataStoreService'):GetDataStore('Tags'):GetAsync('Player_'..player.UserId)
					data[i] = true

					game.ReplicatedStorage.ChatTag:FireClient(player,data,player.stats.CurrentTag.Value)
					game:GetService('DataStoreService'):GetDataStore('Tags'):SetAsync('Player_'..player.UserId,data)
				end
			end
		end)()
		donationsLb:SetAsync('Player_'..player.UserId,donationsLb:GetAsync('Player_'..player.UserId) + 100)
	end,
}
local donations = {
	[5] = "Thanks!",
	[10] = "Thankss!",
	[50] = "Woah, thanks!",
	[100] = "wowza thanks so much",
	[500] = "that is... a lot of money",
	[1000] = "WHAT? TYSM???!!! 🙂🙂🙂",
	[10000] = "WHAT DO I EVEN DO WITH THIS??",
}
local productFunctions = {
	[t[1]] = function(r,p) 
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 5)
		p.stats.Hints.Value += 1	
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'+'..1 .. ' Hints Added!', 'You now have <b>'..p.stats.Hints.Value..'</b> Hints!','rbxassetid://10116606885',Color3.fromRGB(255, 255, 105),sounds.Purchase.SoundId)
		return true
	end,
	[t[5]] = function(r,p) 
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 20)
		p.stats.Hints.Value += 5
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'+'..5 .. ' Hints Added!', 'You now have <b>'..p.stats.Hints.Value..'</b> Hints!','rbxassetid://10116606885',Color3.fromRGB(255, 255, 105),sounds.Purchase.SoundId)
		return true	
	end,
	[t[10]] = function(r,p) 
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 35)
		p.stats.Hints.Value += 10
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'+'..10 .. ' Hints Added!', 'You now have <b>'..p.stats.Hints.Value..'</b> Hints!','rbxassetid://10116606885',Color3.fromRGB(255, 255, 105),sounds.Purchase.SoundId)
		return true	
	end,
	[t[25]] = function(r,p) 
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 75)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		p.stats.Hints.Value += 25
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'+'..25 .. ' Hints Added!', 'You now have <b>'..p.stats.Hints.Value..'</b> Hints!','rbxassetid://10116606885',Color3.fromRGB(255, 255, 105),sounds.Purchase.SoundId)

		return true	
	end,
	[1323311625] = function(r,p) 
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 25)
		p.leaderstats.Stage.Value += 1
		p.stats.CurrentStage.Value = p.leaderstats.Stage.Value
		print("hello! im changing stuff!")
		if (p.leaderstats.Stage.Value)/10 == math.floor(p.leaderstats.Stage.Value/10) then
			p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value+.5).CFrame * CFrame.new(0,3.25,0)
		else
			p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value).CFrame * CFrame.new(0,3.25,0)

		end
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Stage skipped!', 'You are now on stage '..p.leaderstats.Stage.Value,'rbxassetid://10116606885',Color3.fromRGB(105, 255, 180),sounds.Purchase.SoundId)
		game.ReplicatedStorage.Effect:FireClient(p,Color3.fromRGB(105, 255, 180))
		for i = 10,#stageBadges*10,10 do
			if p.leaderstats.Stage.Value == i then
				game.ReplicatedStorage.Badge:Invoke(p.UserId, stageBadges[p.leaderstats.Stage.Value/10])
			end
		end
		return p.leaderstats.Stage.Value	
	end,

	[1841013419] = function(r,p) 
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'5 Robux Donated!', donations[5],'rbxassetid://10116606885',Color3.fromRGB(205, 205, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 5)
	end,
	[1841013587] = function(r,p) 
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'10 Robux Donated!', donations[10],'rbxassetid://10116606885',Color3.fromRGB(180, 180, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 10)
	end,
	[1841013704] = function(r,p) 
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'50 Robux Donated!', donations[50],'rbxassetid://10116606885',Color3.fromRGB(155, 155, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 50)
	end,
	[1323443754] = function(r,p) 
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'100 Robux Donated!', donations[100],'rbxassetid://10116606885',Color3.fromRGB(130, 130, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 100)
	end,
	[1323443932] = function(r,p) 
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'500 Robux Donated!', donations[500],'rbxassetid://10116606885',Color3.fromRGB(105, 105, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 500)
	end,
	[1323444024] = function(r,p) 
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'1,000 Robux Donated!', donations[1000],'rbxassetid://10116606885',Color3.fromRGB(80, 80, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 1000)
	end,
	[1841013889] = function(r,p) 
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'10,000 Robux Donated!', donations[10000],'rbxassetid://10116606885',Color3.fromRGB(55, 55, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 10000)
	end,
	[1338741241] = function(r,p) 
		p.stats.Tickets.Value += 100
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'+100 Tickets', string.format('You now have %d tickets!',p.stats.Tickets.Value),'rbxassetid://10116606885',Color3.fromRGB(205, 255, 205),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 50)
	end,
	[1338741307] = function(r,p) 
		p.stats.Tickets.Value += 500
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'+500 Tickets', string.format('You now have %d tickets!',p.stats.Tickets.Value),'rbxassetid://10116606885',Color3.fromRGB(105, 255, 105),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 200)
	end,
	--Streak Savers
	[1550935223] = function(r,p) 
		p.stats.Savers.Value += 1
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'+1 Streak Save', string.format('You now have %d streak saves!',p.stats.Savers.Value),'rbxassetid://13594032231',Color3.fromRGB(205, 238, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 30)
	end,
	[1550935335] = function(r,p) 
		p.stats.Savers.Value += 5
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'+5 Streak Saves', string.format('You now have %d streak saves!',p.stats.Savers.Value),'rbxassetid://13594032231',Color3.fromRGB(155, 222, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 135)
	end,
	[1550935415] = function(r,p) 
		p.stats.Savers.Value += 10
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'+10 Streak Saves', string.format('You now have %d streak saves!',p.stats.Savers.Value),'rbxassetid://13594032231',Color3.fromRGB(105, 205, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 240)
	end,
	[1550935575] = function(r,p) 
		p.stats.Savers.Value += 25
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'+25 Streak Saves', string.format('You now have %d streak saves!',p.stats.Savers.Value),'rbxassetid://13594032231',Color3.fromRGB(55, 188, 255),sounds.Purchase.SoundId)
		game.ReplicatedStorage.AbeDialogueRemote:FireClient(p,msgs.Purchased[math.random(#msgs.Purchased)],true)
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 525)
	end,
	[1551210853] = function(r,p)
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Streak Saved!', 'You keep your streak of <b>'..streakQueue[p]..'</b>','rbxassetid://13594032231',Color3.fromRGB(105, 205, 255),sounds.Purchase.SoundId)
		p.stats.Streak.Value = streakQueue[p]
		game.ReplicatedStorage.CorrectEffect:FireClient(p,"correct","","ans",true)
		streakQueue[p] = nil

		p.Character.Humanoid.WalkSpeed = 16
		game.ReplicatedStorage.Effect:FireClient(p,Color3.fromRGB(105, 205, 255))
		donationsLb:SetAsync('Player_'..p.UserId,donationsLb:GetAsync('Player_'..p.UserId) + 30)
	end,
}
game.ReplicatedStorage.PromptDevProduct.OnServerEvent:Connect(function(p,id)
	if id == 1323311625 and p.leaderstats.Stage.Value == maxStage then
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,"You've beat the game already", "You can't skip any more stages!",'rbxassetid://10280563829',Color3.fromRGB(255, 80, 80),sounds.Error.SoundId)
	end
	game:GetService('MarketplaceService'):PromptProductPurchase(p, id)
end)

game.ReplicatedStorage.PromptDevProductBindable.Event:Connect(function(p,id)
	if id == 1323311625 and p.leaderstats.Stage.Value == maxStage then
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,"You've beat the game already", "You can't skip any more stages!",'rbxassetid://10280563829',Color3.fromRGB(255, 80, 80),sounds.Error.SoundId)
	end
	game:GetService('MarketplaceService'):PromptProductPurchase(p, id)

end)

game.ReplicatedStorage.Skip.OnServerEvent:Connect(function(p)
	repeat task.wait() until table.find(currentlyInQuestion,p) == nil
	if p.stats.FreeSkips.Value > 0 then
		p.stats.FreeSkips.Value -= 1
		p.leaderstats.Stage.Value += 1
		p.stats.CurrentStage.Value = p.leaderstats.Stage.Value
		print("hello! im changing stuff!")
		if (p.leaderstats.Stage.Value)/10 == math.floor(p.leaderstats.Stage.Value/10) then
			p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value+.5).CFrame * CFrame.new(0,3.25,0)
		else
			p.Character.HumanoidRootPart.CFrame = checkpoints:FindFirstChild(p.stats.CurrentStage.Value).CFrame * CFrame.new(0,3.25,0)

		end
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Stage skipped!', 'You are now on stage '..p.leaderstats.Stage.Value,'rbxassetid://10116606885',Color3.fromRGB(105, 255, 180),sounds.Purchase.SoundId)
		game.ReplicatedStorage.Effect:FireClient(p,Color3.fromRGB(105, 255, 180))
		for i = 10,#stageBadges*10,10 do
			if p.leaderstats.Stage.Value == i then
				game.ReplicatedStorage.Badge:Invoke(p.UserId, stageBadges[p.leaderstats.Stage.Value/10])
			end
		end
		return
	end
	game:GetService('MarketplaceService'):PromptProductPurchase(p,1323311625)
end)

game:GetService('MarketplaceService').ProcessReceipt = function(receiptInfo)
	local handler = productFunctions[receiptInfo.ProductId]
	if not donationsLb:GetAsync('Player_'..receiptInfo.PlayerId) then
		donationsLb:SetAsync('Player_'..receiptInfo.PlayerId,0)
	end
	local h = handler(receiptInfo,game.Players:GetPlayerByUserId(receiptInfo.PlayerId))
	if h == true then
		game.ReplicatedStorage.Badge:Invoke(receiptInfo.PlayerId, 2128622012)
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

game:GetService('MarketplaceService').PromptGamePassPurchaseFinished:Connect(function(player,gamePassId,wasPurchased)
	if wasPurchased then
		if not donationsLb:GetAsync('Player_'..player.UserId) then
			donationsLb:SetAsync('Player_'..player.UserId,0)
		end
		gamePassFunctions[gamePassId](player)
	end
end)

game.ReplicatedStorage.HintCheck.OnServerInvoke = function(p)
	if p.stats.Hints.Value > 0 then
		p.stats.Hints.Value -= 1
		return true
	else
		game:GetService('MarketplaceService'):PromptProductPurchase(p, t[1])
		game.ReplicatedStorage.NotificationBigRemote:FireClient(p,'Insufficient Hint Amount', "Buy them from the shop or buy it here!",'rbxassetid://10280563829',Color3.fromRGB(255, 55, 55),sounds.Error.SoundId)
		return false
	end
end
local m = {
	"Invite your friends to gain tickets 20% faster!",
	"You gain more tickets per grade.",
	"Restart to get more tickets and Halos!",
	"Stuck on a question? Buy a hint!",
	"Shiftlock is key",
	"Value your sleep!",
	"You are enough!",
	"VIP servers are free!!",
	"Thanks for playing!",
	"In active development",
	"Join the Smilish group for a two hints!",
	"Tired of streak notifications? Turn them off in the settings!",
	"If you have any questions, suggestions, or just want to see update progress join <u>.gg/MTFT2TD6yg</u>",
	"Want to change your decimals from periods to commas? Check out the settings menu!",
	"The game has <b>".. maxStage.. '</b> stages!',
	"Not all problems are created equal. Some will be disproportionally harder/easier.",
	"You gain more tickets per grade level.",
	"For every friend you invite, you get 20% more tickets!",
	"Tickets are used to buy accessories like flames in the flame shop!",
	"New flames are in the shop every 24 hours!",
	"Use the practice menu to your advantage!",
	"Math is used in the real world.",
	"Getting #1 on the leaderboard will earn you a chat tag, and my unconditional appreciation.",
	"Question mark badges are secret badges you get for being a little too curious.",
	"The game has " .. #require(game.ReplicatedStorage.BadgesModuleScript) .. ' badges, can you get them all?' ,

}
coroutine.wrap(function()
	while true do
		wait(60*5)
		for i,v in pairs(game.Players:GetPlayers()) do
			if v.settings.TipNotif.Value then
				game.ReplicatedStorage.ChatMessageRemote:FireClient(v,"<b>[Pro Tip]:</b> "..m[math.random(#m)],Color3.fromRGB(255, 255, 255))
			end
		end
	end
end)()