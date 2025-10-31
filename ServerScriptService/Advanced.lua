local module = {}
module.Complex = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local t = {}
	for i=1,2 do
		local rand
		repeat
			rand = math.random(2,5)
		until
		table.find(t,rand) == nil
		table.insert(t,rand)
	end
	local r,i = table.unpack(t)
	local start = r + require(game.ReplicatedStorage.MathAddons).Complex.i*i
	local n = start^2
	n = math.round(n[1])+require(game.ReplicatedStorage.MathAddons).Complex.i*math.round(n[2])
	return {Question1 = 'z = ' .. tostring(n),Question2 = '|z| = ?'},"Complex" ,require(game.ReplicatedStorage.MathAddons).Complex.abs(n)
end
module.Factorial = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local n = math.random(20,80)
	return {Factorial = 'How many trailing zeros does <b>' .. n .. '</b>! have?'},"Factorial" ,math.floor(n/5) + math.floor(n/25)
end
module.Factorial2 = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local n = math.random(7,11)
	local fact = 1
	for i=1,n do
		fact *= i    
	end
	return {Factorial = 'How many positive integer divisors does <b>' .. n .. '</b>! have?'},"Factorial2" ,#require(game.ReplicatedStorage.MathAddons).factors(fact)
end
module.Logarithm = function(seedd)
	local seed = math.randomseed(seedd or (os.time() / 86400))

	local ta = {1}
	local tb = {-5, -4, -3, -2, -1, 1, 2, 3, 4, 5}
	local a = ta[math.random(#ta)]
	local b = tb[math.random(#tb)]
	local c = ta[math.random(#ta)]
	local d = tb[math.random(#tb)]
	local ans = math.random(math.ceil(math.max(-b / a, -d / c)), 20)
	local f = a * c * ans^2 + (a * d + b * c) * ans + b * d
	while f == 0 do
		a = ta[math.random(#ta)]
		b = tb[math.random(#tb)]
		c = ta[math.random(#ta)]
		d = tb[math.random(#tb)]
		ans = math.random(math.ceil(math.max(-b / a, -d / c)), 20)
		f = a * c * ans^2 + (a * d + b * c) * ans + b * d
	end

	local realA = a * c
	local realB = a * d + b * c
	local realC = b * d - f
	local ans1 = (-(realB) - ((realB)^2 - 4 * realA * realC)^0.5) / (2 * realA)
	local ans2 = (-(realB) + ((realB)^2 - 4 * realA * realC)^0.5) / (2 * realA)

	return {
		Question1 = 'log₂(' .. (a < 0 and '-' or '') .. 'x' .. (b < 0 and b or '+' .. b) .. ') + log₂(' .. (c < 0 and '-' or '') .. 'x' .. (d < 0 and d or '+' .. d) .. ') = log₂(' .. f .. ')'
	}, "Logarithm", ans
end
module.Quadratic = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local tb = {-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,1,2,3,4,5,6,7,8,9,10}
	local p,q = tb[math.random(#tb)],tb[math.random(#tb)]
	local b = -(p+q)
	local c = p*q
	local ans1 = (-(b)-((b)^2-4*c)^.5)/2
	local ans2 = (-(b)+((b)^2-4*c)^.5)/2
	return {Question1 = 'x²'.. (b<0 and b or '+'..b )..'x'.. (c<0 and c or '+'..c) },"Quadratic" ,ans1 .. ',' .. ans2
end

module.Sum = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local func = math.random(1,3)
	local exp = {[0]='⁰','¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹'}
	local n = math.random(2,5)
	if func == 1 then
		local upper = math.random(8,12)
		local lower = math.random(2,7)
		local ans = require(game.ReplicatedStorage.MathAddons).summation(lower,upper,function(x) return x^n end)
		return {Function = 'n' .. exp[n],UpperBound = upper,LowerBound = "n="..lower},'Sum',ans
	elseif func == 2 then
		local upper = math.random(5,7)
		local lower = math.random(2,4)
		local exp = math.random(2,4)
		local ans = require(game.ReplicatedStorage.MathAddons).summation(lower,upper,function(x) return exp^x end)
		return {Function = exp..'ⁿ',UpperBound = upper,LowerBound = "n="..lower},'Sum',ans
	else
		local a = math.random(2,8)
		local upper = math.random(8,10)
		local lower = math.random(2,7)
		local ans = a*require(game.ReplicatedStorage.MathAddons).summation(lower,upper,function(x) return x end)
		return {Function = a..'n',UpperBound = upper,LowerBound = "n="..lower},'Sum',ans
	end
end
local matt = require(game.ReplicatedStorage.MathAddons).toBase
module.Base = function(seedd)
	local t = {[0]='₀','₁','₂','₃','₄','₅','₆','₇','₈','₉','₁₀','₁₁','₁₂','₁₃','₁₄','₁₅','₁₆'}

	local seed = math.randomseed(seedd or (os.time()/86400))
	local from = math.random(2,16)
	local to = math.random(2,16)
	local rand = tostring(math.random(10,100))
	local fromNum = matt(rand,from,10)
	local ans = matt(rand,to,10)
	return {Question1 = "Convert this number to base".. to,Question2 = fromNum .. t[from]},'Base',ans
end


module.Coeff = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local exp = {[0]='⁰','¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹'}
	local a = math.random(2,5)
	local b = math.random(2,5)
	local n = math.random(4,6)
	local r = math.random(1,n-1)
	return {Question = "Find the coefficient of the x" .. exp[r] .. " term in the binomial expansion of ("..a.."x+"..b..")" .. exp[n] .. "."},"Coeff",require(game.ReplicatedStorage.MathAddons).nCr(n,r)*a^r*b^(n-r)
end

module.Pythag = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local m = math.random(3,7)
	local n = math.random(1,m-1)
	local a = m^2-n^2
	local b = 2*m*n
	local c = m^2+n^2
	local rand = math.random(1,3)
	if rand == 1 then
		return {Question = "If one leg of a right triangle has length ".. b .. " and its hypotenuse has length "..c..", what is the length of its other leg?"},"Pythag",a
	elseif rand == 2 then
		return {Question = "If one leg of a right triangle has length ".. a .. " and its hypotenuse has length "..c..", what is the length of its other leg?"},"Pythag",b
	elseif rand == 3 then
		return {Question = "If the legs of a right triangle have length" .. a .. ' and '.. b .. " what is the length of the triangle's hypotenuse"},"Pythag",c
	end
end

module.Dist = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local t = {-5,-4,-3,-2,-1,1,2,3,4,5}
	local ind1 = math.random(#t)
	local m = t[ind1]
	table.remove(t,ind1)
	table.remove(t,table.find(t,-m))
	local n = t[math.random(#t)]
	local a = m^2-n^2
	local b = 2*m*n
	local c = m^2+n^2
	local p,q = math.random(-10,10),math.random(-10,10)
	return {Question = "What is the distance between the points (" .. p .. ","..q..") and ("..p+a..","..q+b..")?"},"Dist",c
end



return module
