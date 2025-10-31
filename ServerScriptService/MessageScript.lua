
local messages_cache = {}
local check_cache = {}

function getLink(id)
	local url = "https://thumbnails.roproxy.com/v1/users/avatar-headshot?userIds="..id.."&size=720x720&format=Png&isCircular=false"
	local data = game:GetService('HttpService'):GetAsync(url)
	return game:GetService('HttpService'):JSONDecode(data).data[1].imageUrl
end

function toInteger(color)
	return math.floor(color.r*255)*256^2+math.floor(color.g*255)*256+math.floor(color.b*255)
end

function toHex(color)
	local int = toInteger(color)

	local current = int
	local final = ""

	local hexChar = {
		"A", "B", "C", "D", "E", "F"
	}

	repeat local remainder = current % 16
		local char = tostring(remainder)

		if remainder >= 10 then
			char = hexChar[1 + remainder - 10]
		end

		current = math.floor(current/16)
		final = final..char
	until current <= 0

	return "0x"..string.reverse(final)
end
local palet = {
	[0] = Color3.fromRGB(255,255,255),
	Color3.fromRGB(83, 202, 81),
	Color3.fromRGB(255, 255, 102),
	Color3.fromRGB(255, 166, 102),
	Color3.fromRGB(255, 102, 102),
	Color3.fromRGB(255, 102, 179),
	Color3.fromRGB(153, 102, 255),
	Color3.fromRGB(102, 179, 255),
	Color3.fromRGB(102, 255, 255),
	Color3.fromRGB(255,255,255),
	Color3.fromRGB(83, 202, 81),
	Color3.fromRGB(255, 255, 102),
	Color3.fromRGB(211, 58, 140),--grade12
	Color3.fromRGB(205, 230, 255),
	Color3.fromRGB(255, 102, 179),
	Color3.fromRGB(153, 102, 255),
	Color3.fromRGB(102, 179, 255),
	Color3.fromRGB(102, 255, 255),
}
local WebhookURL = "https://discord.com/api/webhooks/1027355863083647038/IxHEVVbWKaHa-qqIvi3Z0rofLGaFc-Q684PmD8PJjuaUvqVzyUPam6Uk0ptDyeRq9wDV"
local function postToDiscord(Player,message)
	local Data =  {
		["content"] = "",
		["embeds"] = {{
			["title"] = 'Stage: '..Player.leaderstats.Stage.Value,
			["description"] = message,
			["type"] = "rich",
			["color"] = tonumber(toHex(palet[math.floor(Player.leaderstats.Stage.Value/10)])),
			['author'] = {
				['name'] = Player.DisplayName.. ' (@'..Player.Name..')',
				['icon_url'] = getLink(Player.UserId),
				['url'] = 'https://www.roblox.com/users/'..Player.UserId..'/profile'
			},
			['thumbnail'] = {
				['url'] = getLink(Player.UserId),
			},
		}}
	}
	Data = game:GetService('HttpService'):JSONEncode(Data)
	game:GetService('HttpService'):PostAsync(WebhookURL, Data)
end
function cutString(str, index)
	return string.sub(str, 1, index)
end
local TextService = game:GetService("TextService")

function filterMessage(message, playerId)
	local success, filteredMessage = pcall(function()
		return TextService:FilterStringAsync(message, playerId)
	end)

	if success then
		return filteredMessage:GetNonChatStringForBroadcastAsync()
	else
		warn("Error filtering message:", filteredMessage)
		-- Handle filter failure
		return ""
	end
end
function add(name,id,message,date,t)
	local temp = script.Template:Clone()
	temp.Header.Thumbnail.Image = 'rbxthumb://type=AvatarHeadShot&id='..id..'&w=180&h=180'
	temp.Header.Username.Text = name
	temp.Header.Time.Text = ("%02d:%02d:%02d"):format((date.hour-1)%12+1, date.min, date.sec) .. (date.hour >= 12 and " PM" or " AM")
	temp.TextFrame.Message.Text = message
	temp.Parent = workspace.MessagingSign.GUIPart.SurfaceGui.Frame
	temp.LayoutOrder = t
	workspace.MessagingSign.GUIPart.SurfaceGui.Frame.CanvasPosition = Vector2.new(0,workspace.MessagingSign.GUIPart.SurfaceGui.Frame.AbsoluteCanvasSize.Y)
end
local proc = {}
game.ReplicatedStorage.MessageSend.OnServerEvent:Connect(function(player, message)
	if table.find(proc,player.UserId) then return end
	table.insert(proc,player.UserId)
	if player.stats.Cooldown.Value > os.time() or string.gsub(message," ","") == "" then table.remove(proc,table.find(proc,player.UserId))return end
	message = cutString(message,100)
	message = filterMessage(message,player.UserId)
	local t = os.time()
	table.insert(messages_cache,{player.Name,player.UserId,message,os.time(),os.date("*t")})
	postToDiscord(player,message)
	add(player.Name,player.UserId,message,os.date("*t"),t)
	player.stats.Cooldown.Value = os.time() + 3600
	table.remove(proc,table.find(proc,player.UserId))
end)
function find(List,search)
	for i,v in pairs(List) do
		if game:GetService('HttpService'):JSONEncode(v) == game:GetService('HttpService'):JSONEncode(search) then
			return true
		end
	end
	return false
end
game:GetService('MessagingService'):SubscribeAsync("Messages",function(messages_t)
	messages_t = game:GetService('HttpService'):JSONDecode(messages_t.Data)
	for i,v in pairs(messages_t) do
		if not find(check_cache,v) then
			add(v[1],v[2],v[3],v[5],v[4])
		end
	end
	check_cache = {}
end)

while true do
	if messages_cache ~= {} then
		check_cache = messages_cache
		game:GetService('MessagingService'):PublishAsync("Messages",game:GetService('HttpService'):JSONEncode(messages_cache))
		messages_cache = {}
	end
	wait(60)
end

