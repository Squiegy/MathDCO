local module = {}

module.Addition = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local a = math.random(1,3)
	if a == 1 then
		local n = math.random(2,9)
		local nums = {}
		for i=1,n do
			table.insert(nums,math.random(9,50))
		end
		local ans = 0
		for i,v in pairs(nums) do
			ans += v
		end
		return {Question = table.concat(nums,'+') .. ' = ?'},"Addition",ans
	elseif a == 2 then
		local n = math.random(2,9)
		local nums = {}
		for i=1,n do
			table.insert(nums,math.random(9,50))
		end
		local ans = 0
		for i,v in pairs(nums) do
			ans -= v
		end
		return  {Question = '-'.. table.concat(nums,'-') .. ' = ?'},"Addition",ans
	else
		local n = math.random(2,9)
		local nums = {}
		for i=1,n do
			local nn = math.random(-50,50)
			table.insert(nums,nn)
		end
		local ans = 0
		for i,v in pairs(nums) do
			ans += v
		end
		local str = ''
		for i, num in ipairs(nums) do
			if i > 1 then
				if num >= 0 then
					str ..=  "+"
				end
			end

			str ..= tostring(num)
		end
		return {Question = str .. ' = ?'},"Addition" ,ans
	end
end

module.Multiplication = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local n = math.random(2,9)
	local nums = {}
	local randT = {-5,-4,-3,-2,-1,1,2,3,4,5}
	for i=1,n do
		table.insert(nums,randT[math.random(#randT)])
	end
	local str = ''
	for i, num in ipairs(nums) do
		if i > 1 then
			str ..= "*"
		end

		if num < 0 then
			str ..= "(" .. tostring(num) .. ")"
		else
			str ..= tostring(num)
		end
	end
	local ans = 1
	for i,v in pairs(nums) do
		ans *= v
	end
	return {['Question'] = str .. ' = ?'},'Multiplication' ,ans
end

module.Division = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local numbers = {}
	local factorCount = math.random(3,12)*2
	for i=1,1000 do
		local f = 0
		for ii=1,i^.5 do
			if (i/ii)%1 == 0 then
				f += ii == i^.5 and 1 or 2
			end
		end
		if f == factorCount then
			table.insert(numbers,i)
		end
	end
	local number = numbers[math.random(#numbers)]
	local factors = require(game.ReplicatedStorage.MathAddons).factors(number)
	local divisor = factors[math.random(#factors)]
	return {Question = number .. '÷'..divisor},'Division', number/divisor
end

module.Exponents = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local exp2 = {'⁰','¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹','¹⁰'}
	local number = math.random(2,8)
	local number2 = math.random(3,11-number)
	return {Question = number .. exp2[number2+1]},'Exponents', number^number2
end

module.Remainder = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local b,d = math.random(4,20),math.random(4,20)
	local a,c = math.random(b+1,math.random(2,10)*b),math.random(d+1,math.random(2,10)*d)
	return {Question = "What is the sum of the remainders of " .. a .. "/" .. b .. " and " .. c .. "/" .. d .. "?"},"Remainder",a%b+c%d
end

module.Inequality = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local s = math.random(2,7)
	local y = math.random(-10,10)
	y = y == 0 and math.random(1,2)*2-3 or y
	local set = y%s + s*math.random(-5,5)
	if y > 0 then y = '+' .. y else y = '-' .. -y end
	local rand = math.random(1,3)
	return {Question = [[If ]]..s .. 'x' .. y .. (rand == 1 and ' = ' or (rand == 2 and " > " or " < ")) .. set..[[, what number must x be ]]..(rand == 1 and 'equal to' or (rand == 2 and "greater than" or "less than"))..[[?]]},"Inequality",math.round((set-y)/s)
end

module.Fraction = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local b,d = math.random(3,12),math.random(3,12)
	local a,c = math.random(1,b-1),math.random(1,d-1)
	local rand = math.random(1,2)
	return {Question = "What is the " .. (rand == 2 and "denominator" or "numerator").." of the reduced fraction (" .. a .. "/" .. c .. ")*(" .. b .. "/" .. d .. ")?"},"Fraction",math.round((rand == 1 and a*b or c*d)/require(game.ReplicatedStorage.MathAddons).gcd(a*b,c*d))
end

module.Triangle = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local h,b = math.random(1,10),math.random(1,5)
	local mul = math.random(0,1)
	if mul == 0 then h *= 2 else b *= 2 end
	return {Question = "What is the area of the triangle with a height of length" .. h .. " and base of length " ..  b}, "Triangle",math.round(b*h/2)
end

module.Trapezoid = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local h,b,b2 = math.random(1,10),math.random(1,5),math.random(6,10)
	if (b+b2)%2 ~= 0 and h%2~=0 then b += 1 end
	return {Question = "What is the area of a trapezoid with base lengths of " .. b .. " and " .. b2 .. ", and a height of length " .. h}, "Trapezoid",math.round((b+b2)/2*h)
end

module.WholePart = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local rand = math.random(1,2)
	if rand == 1 then
		local n1,n2,d1,d2 = math.random(10,99),math.random(10,99),math.random(10,99),math.random(10,99)
		return {Question = "Find the decimal part of "..n1 .. "." .. d1 .. " + " .. n2 .. "." .. d2 .. "."}, "WholePart",(d1+d2)%100
	else
		local n1,n2,d1,d2 = math.random(10,99),math.random(10,99),math.random(10,99),math.random(10,99)
		return {Question = "Find the whole part of "..n1 .. "." .. d1 .. " + " .. n2 .. "." .. d2 .. "."}, "WholePart",n1+n2+math.floor((d1+d2)/100)
	end
end

module.Remainder2 = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local a = math.random(200,999)
	local b = math.random(11,31)
	return {Question = "Find the remainder when " .. a .. " is divided by " .. b}, "Remainder2",a%b
end

module.LCM = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local t = {2,3,4,5,6,7,8,9,10}
	local ind1 = math.random(#t)
	local a = t[ind1]
	table.remove(t,ind1)
	local ind2 = math.random(#t)
	local b = t[ind2]
	table.remove(t,ind2)
	local ind3 = math.random(#t)
	local c = t[ind3]
	table.remove(t,ind3)
	return {Question = "Find the smallest positive integer such that it is divisible by " .. a .. ",".. b .. ", and ".. c .. "."}, "LCM",require(game.ReplicatedStorage.MathAddons).lcm(c,require(game.ReplicatedStorage.MathAddons).lcm(a,b))
end

module.Prime = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local t = {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59}
	local rd = {"st","nd","rd","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th"}
	local r = math.random(1,10)
	return {Question = "What is the " ..r .. rd[r] .. " prime number?"},"Prime",t[r]
end

module.Num = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local n = math.random(1,10)
	local n2 = n
	local s = "I have a number. If I "
	for i=1,5 do
		local j = math.random(2,5)
		local r = math.random(1,3)
		if r == 1 then
			s ..= "add " .. j .. " to it, "
			n2 += j
		elseif r == 2 then
			s ..= "subtract " .. j .. " from it, "
			n2 -= j
		elseif r == 3 then
			s ..= "multiply it by " .. j .. ", "
			n2 *= j
		end
	end
	s ..= "I get " .. n2 .. ". What is my number"
	return {Question = s},"Num",n
end


return module
