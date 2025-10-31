local module = {}
module.Derivative = function(seedd)
	local seed = seedd or math.randomseed((os.time()/86400))
	local exp = {[0]='⁰','¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹'}
	local n = math.random(1,2)
	local p = math.random(-10,10)
	local powers = {}
	for i=1,n do
		local rand
		repeat
			rand = math.random(1,4)
		until
		table.find(powers,rand) == nil
		table.insert(powers,rand)
	end
	local coeffs = {}
	for i=1,n do
		table.insert(coeffs,math.random(2,6))
	end
	table.sort(powers,function(a,b)
		return a > b
	end)
	local ans = 0
	local str = ''
	for i,v in pairs(powers) do
		ans += v*coeffs[i]*p^(v-1)
		str ..= coeffs[i] .. 'x' .. exp[v] ..  (i ~= #powers and '+' or '')
	end
	return {Question1 = 'f(x) = ' .. str,Question2 = [[f'(]] .. p .. ') = ?'},'Derivative',ans
end
module.Integral = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local exp = {[0]='⁰','¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹'}
	local n = 1
	local c = math.random(-5,5)
	local powers = {}
	for i=1,n do
		local rand
		repeat
			rand = math.random(1,4)
		until
		table.find(powers,rand) == nil
		table.insert(powers,rand)
	end
	local coeffs = {}
	for i=1,n do
		table.insert(coeffs,math.random(2,6))
	end
	table.sort(powers,function(a,b)
		return a > b
	end)
	local upper = c+powers[1]+1
	local lower = c
	local ans = 0
	local str = ''
	for i,v in pairs(powers) do
		ans += (v+1)^-1*coeffs[i]*upper^(v+1)-(v+1)^-1*coeffs[i]*lower^(v+1)
		str ..= coeffs[i] .. 'x' ..exp[v] .. (i ~= #powers and '+' or '') 
	end
	return {LowerBound = tostring(c),UpperBound = tostring(c+powers[1]+1),Integrand = str .. "dx"},'Integral',ans
end

module.Limit = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local func = math.random(1,4)
	if func == 1 then
		local r = math.random(1,8)
		return {Function = (r == 1 and '' or tostring(r)) .. 'xˣ',LowerBound = 'x → 0⁺'},'Limit',r
	elseif func == 2 then
		return {Function = 'xln(x)',LowerBound = 'x → 0'},'Limit',0
	elseif func == 3 then
		local a = math.random(2,10)
		local b = math.random(2,10)
		return {Function = b .. 'xln(1+'..a..'/x)',LowerBound = 'x → ∞'},'Limit',a*b
	else
		local denom = math.random(1,10)*(2*math.random(0,1)-1)
		local num = math.random(-10,10)
		local numString = 'x²' .. (num+denom > 0 and '+' or '-') .. math.abs(num+denom) .. 'x' .. (num*denom < 0 and '-' or '+') .. math.abs(num*denom)
		local denomString = 'x' .. (denom>0 and '+' or '') .. denom
		return {Function = '('..numString .. ')/('..denomString .. ')' ,LowerBound = 'x → '.. -denom},'Limit',num-denom
	end
end

module.Matrix = function(seedd)
	local seed = math.randomseed(seedd or (os.time()/86400))
	local a,b,c,d = math.random(0,9),math.random(0,9),math.random(0,9),math.random(0,9)
	local de = a*d-b*c
	local r = math.random(1,2)
	if r == 1 then
		return {Question2 = "What is the determinant of the matrix: ",LowerBound = a .. "  ".. b,UpperBound = c .. "  ".. d},"Matrix",de
	else
		local area = math.random(2,5)
		return {Question2 = "An object with area "..area..", in 2D space undergoes a linear transformation shown on the right. What is the <b>positive</b> area of the object after this transformation",LowerBound = a .. "  ".. b,UpperBound = c .. "  ".. d},"Matrix",math.abs(de)*area
	end
end


return module
