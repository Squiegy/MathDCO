local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local messageTimestampsStore = DataStoreService:GetOrderedDataStore("MessageTimestampsStore") -- timestamps
local messagesStore = DataStoreService:GetDataStore("MessagesStore") -- message data
local userMessagesStore = DataStoreService:GetDataStore("UserMessagesStore") -- user history
local lastPostStore = DataStoreService:GetDataStore("LastPostStore") -- cooldowns
local CHARACTER_LIMIT = 125
local COOLDOWN_DAYS = 7
local SECONDS_IN_DAY = 86400
local COOLDOWN_SECONDS = COOLDOWN_DAYS*SECONDS_IN_DAY
local MESSAGES_PER_PAGE = 5

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PostMessageEvent = ReplicatedStorage:WaitForChild("PostMessageEvent")
local GetMessagesFunction = ReplicatedStorage:WaitForChild("GetMessagesFunction")
local SearchMessagesFunction = ReplicatedStorage:WaitForChild("SearchMessagesFunction")
local NewMessageEvent = ReplicatedStorage:WaitForChild("NewMessageEvent")

local function saveMessage(userId, username, message)
	local timestamp = os.time()
	local messageData = {
		UserId = userId,
		Username = username,
		Message = message,
		Timestamp = timestamp
	}


	local key = tostring(timestamp) .. "_" .. tostring(userId)
	messagesStore:SetAsync(key, messageData)


	messageTimestampsStore:SetAsync(key, timestamp)


	local success, userMessages = pcall(function()
		return userMessagesStore:GetAsync(tostring(userId)) or {}
	end)

	if success then
		table.insert(userMessages, 1, messageData) -- newest sort
		if #userMessages > 50 then -- keep last 50
			table.remove(userMessages)
		end
		userMessagesStore:SetAsync(tostring(userId), userMessages)
	end
end

-- cooldown
local function canPost(userId)
	local lastPostTime = lastPostStore:GetAsync(tostring(userId))
	if not lastPostTime then return true end
	return os.time() - lastPostTime >= COOLDOWN_SECONDS
end

PostMessageEvent.OnServerEvent:Connect(function(player, message)
	if not message or #message == 0 or #message > CHARACTER_LIMIT then
		return -- invalid
	end
	if player.stats.HighestStage.Value < 130 then
		return -- invalid
	end

	if not canPost(player.UserId) then
		return
	end

	local messageData = {
		UserId = player.UserId,
		Username = player.Name,
		Message = message,
		Timestamp = os.time()
	}

	saveMessage(player.UserId, player.Name, message)
	lastPostStore:SetAsync(tostring(player.UserId), os.time())


	NewMessageEvent:FireAllClients(messageData)
end)


GetMessagesFunction.OnServerInvoke = function(player, pageNumber)
	local pageSize = MESSAGES_PER_PAGE
	local start = (pageNumber - 1) * pageSize

	local messages = {}

	local success, pages = pcall(function()
		return messageTimestampsStore:GetSortedAsync(false, start + pageSize)
	end)

	if success then
		local data = pages:GetCurrentPage()
		for i = start + 1, start + pageSize do
			if data[i] then
				local key = data[i].key
				local msg = messagesStore:GetAsync(key)
				if msg then
					table.insert(messages, msg)
				end
			end
		end
	end

	return messages
end

SearchMessagesFunction.OnServerInvoke = function(player, searchName, pageNumber)
	local userId
	for _, plr in ipairs(Players:GetPlayers()) do
		if string.lower(plr.Name) == string.lower(searchName) then
			userId = plr.UserId
			break
		end
	end

	if not userId then return {} end

	local success, messages = pcall(function()
		return userMessagesStore:GetAsync(tostring(userId)) or {}
	end)

	if not success or not messages then
		return {}
	end


	local pageSize = MESSAGES_PER_PAGE
	local startIndex = (pageNumber - 1) * pageSize + 1
	local endIndex = math.min(startIndex + pageSize - 1, #messages)

	local pageResults = {}
	for i = startIndex, endIndex do
		table.insert(pageResults, messages[i])
	end

	return pageResults
end
