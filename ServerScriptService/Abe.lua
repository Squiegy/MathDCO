local properties = {
	'HeadColor','LeftArmColor','RightArmColor','LeftLegColor','RightLegColor','TorsoColor'
}

game.Players.PlayerAdded:Connect(function(p)
	local t = true
	p.CharacterAppearanceLoaded:Connect(function(ch)
		local tt = true
		for i,v in pairs(properties) do
			if ch:FindFirstChild('Body Colors')[v] ~= script["Body Colors"][v] then
				tt = false
				break
			end
		end
		if ch:FindFirstChild('CoolBoyHair') and tt and ch.Head.face.Texture == 'rbxasset://textures/face.png' then
		else
			tt = false
		end
		if tt then
			game.ReplicatedStorage.Badge:Invoke(p.UserId,2146041554)
		end
		if tt then
			game.ReplicatedStorage.AbeEffect:FireClient(p,t,tt)
		end
		t = false
	end)
end)