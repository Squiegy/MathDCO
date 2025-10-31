local m = require(game.ReplicatedStorage.MathAddons)
function dollar(x)
	return string.format("$%.2f", x)
end
function extract(str)
	local nums = {}
	for num in str:gmatch("-?%d+%.?%d*") do
		table.insert(nums, tonumber(num))
	end
	return nums
end
function round(x,d)
	local digit = math.floor(math.log10(x))+1
	return tonumber(tostring(math.round(x*10^d)/10^d):sub(1,digit+1+d))

end
function format(a,b,c)
	local equation = (a == 1 and "x") or (a == -1 and "-x") or (a .. "x")
	equation = equation .. ((b >= 0 and '+') or '') .. ((b == 1 and '') or (b == -1 and '-') or b) .. "y"
	equation = equation .. '='..c

	return equation
end
function extract2(equation)
	local a, b, c = equation:match("([%+%-]?%d*)x([%+%-]?%d*)y%s*=%s*([%+%-]?%d*)")

	-- Convert empty strings to 1 or 0
	a = (a == "" or a == "+" or a == "-") and (a .. "1") or a
	b = (b == "" or b == "+" or b == "-") and (b .. "1") or b
	c = c == "" and "0" or c

	return tonumber(a), tonumber(b), tonumber(c)
end

local function choose(n, k)
	if k > n or k < 0 then
		return 0 -- Invalid case
	end
	local result = 1
	for i = 1, k do
		result = result * (n - i + 1) / i
	end
	return math.floor(result + 0.5) -- Handle floating-point precision
end

function simplify_sqrt(n)
	local factor = math.floor(math.sqrt(n))

	while factor > 1 do
		if n % (factor * factor) == 0 then
			local outside = factor
			local inside = n / (factor * factor)
			if inside == 1 then
				return tostring(outside)
			else
				return tostring(outside) .. "√" .. tostring(inside) .. ""
			end
		end
		factor = factor - 1
	end

	return "√" .. tostring(n) .. ""
end

function generateQuadraticString(...)
	local coefficients = table.pack(...) local superscripts = {
		[0] = "⁰", [1] = "¹", [2] = "²", [3] = "³", [4] = "⁴", [5] = "⁵",
		[6] = "⁶", [7] = "⁷", [8] = "⁸", [9] = "⁹"
	}

	local function toSuperscript(number)
		local superscriptStr = ""
		local numStr = tostring(math.abs(number))

		for i = 1, #numStr do
			local digit = tonumber(numStr:sub(i, i))
			superscriptStr = superscriptStr .. superscripts[digit]
		end

		return superscriptStr
	end

	local result = ""
	local degree = #coefficients - 1

	for i, coeff in ipairs(coefficients) do
		local exponent = degree - (i - 1)

		if coeff ~= 0 then
			if result ~= "" and coeff > 0 then
				result = result .. "+"
			end

			if math.abs(coeff) == 1 and exponent > 0 then
				if coeff == -1 then
					result = result .. "-"
				end
			else
				result = result .. coeff
			end

			if exponent > 0 then
				result = result .. "x"
				if exponent > 1 then
					result = result .. toSuperscript(exponent)
				end
			end
		end
	end

	return result
end

function getPolynomial(str)
	local superscripts = {
		["⁰"] = 0, ["¹"] = 1, ["²"] = 2, ["³"] = 3, ["⁴"] = 4, 
		["⁵"] = 5, ["⁶"] = 6, ["⁷"] = 7, ["⁸"] = 8, ["⁹"] = 9
	}

	local function replaceSuperscripts(s)
		for sup, num in pairs(superscripts) do
			s = string.gsub(s, sup, "^" .. num)
		end
		return s
	end

	str = replaceSuperscripts(str)

	local terms = {}
	for term in string.gmatch(str, "([+-]?[^+-]+)") do
		table.insert(terms, term)
	end

	local coefficients = {}
	local maxExponent = 0

	for _, term in ipairs(terms) do
		local coeff, exponent = term:match("([+-]?%d*)x%^?(%d*)")

		if coeff == "" or coeff == "+" then
			coeff = 1
		elseif coeff == "-" then
			coeff = -1
		end

		if exponent == "" then
			exponent = 1
		elseif exponent == nil then
			exponent = 0
		end

		exponent = tonumber(exponent)
		coeff = tonumber(coeff)

		coefficients[exponent] = coeff

		if exponent > maxExponent then
			maxExponent = exponent
		end
	end

	for i = 0, maxExponent do
		if coefficients[i] == nil then
			coefficients[i] = 0
		end
	end

	local unpackedCoefficients = {}
	for i = maxExponent, 0, -1 do
		table.insert(unpackedCoefficients, coefficients[i])
	end

	return table.unpack(unpackedCoefficients)
end

function getQuad(str)
	local superscripts = {
		["⁰"] = 0, ["¹"] = 1, ["²"] = 2, ["³"] = 3, ["⁴"] = 4, 
		["⁵"] = 5, ["⁶"] = 6, ["⁷"] = 7, ["⁸"] = 8, ["⁹"] = 9
	}

	local function replaceSuperscripts(s)
		for sup, num in pairs(superscripts) do
			s = string.gsub(s, sup, "^" .. num)
		end
		return s
	end

	str = replaceSuperscripts(str)

	local terms = {}
	for term in string.gmatch(str, "([+-]?[^+-]+)") do
		table.insert(terms, term)
	end

	local coefficients = {}
	local maxExponent = 0

	for _, term in ipairs(terms) do
		-- Check if the term is a constant (no 'x' in it)
		local coeff, exponent = term:match("([+-]?%d*)x%^?(%d*)")

		if not coeff then
			-- Term is a constant
			coeff = term
			exponent = 0
		end

		-- Handle coefficient defaults
		if coeff == "" or coeff == "+" then
			coeff = 1
		elseif coeff == "-" then
			coeff = -1
		end

		-- Handle exponent defaults
		if exponent == "" then
			exponent = 1
		elseif exponent == nil then
			exponent = 0
		end

		exponent = tonumber(exponent)
		coeff = tonumber(coeff)

		coefficients[exponent] = coeff

		if exponent > maxExponent then
			maxExponent = exponent
		end
	end

	-- Fill missing exponents with 0 coefficients
	for i = 0, maxExponent do
		if coefficients[i] == nil then
			coefficients[i] = 0
		end
	end

	-- Unpack coefficients in descending exponent order
	local unpackedCoefficients = {}
	for i = maxExponent, 0, -1 do
		table.insert(unpackedCoefficients, coefficients[i])
	end

	return table.unpack(unpackedCoefficients)
end

local m = require(game.ReplicatedStorage.MathAddons)
local questions = {
	[1] = {
		['Image'] = false,
		['Written'] = false, 
		['Question'] = '%d + %d', 
		['Numbers'] = {
			[1] = function() return math.random(1,5) end,
			[2] = function() return math.random(1,5) end
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return math.abs(t[1] - t[2])
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[math.random(1,2)]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1] + t[2]
			end,true},
		},
		['ImageLabel'] = ''
	},
	[2] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = '%d - %d', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(5,9) end,
			[2] = function() return math.random(1,5) end
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return math.abs(t[1] + t[2])
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local random = math.random(1,2)
				return math.abs(t[random] - 2* t[random == 1 and 2 or 1])
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1] - t[2]
			end,true},
		},
		['ImageLabel'] = '',
	},
	[3] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'Provide a number that is greater than %d and less than %d', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(1,4) end,
			[2] = function() return math.random(6,11) end
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return math.random(t[2]+1,13)
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local random = math.random(1,2)
				return math.random(0,t[1]-1)
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[math.random(1,2)]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return math.random(t[1]+1,t[2]-1)
			end,true},
		},
		['ImageLabel'] = '',
	},
	[4] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = '%d - %d', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(5,9) end,
			[2] = function() return math.random(1,5) end
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return math.abs(t[1] + t[2])
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local random = math.random(1,2)
				return math.abs(t[random] - 2* t[random == 1 and 2 or 1])
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return math.random(t[2],t[1])
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1] - t[2]
			end,true},
		},
		['ImageLabel'] = '',
	},
	[5] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'You have %d apples in a basket. You put %d more apples in. How many apples do you have now?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(1,5) end,
			[2] = function() return math.random(5,9) end
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[2]
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[2] - t[1]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[2] + t[1]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = ''
	},
	[6] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'There are %d marbles in a box. %d are red and the rest are blue. How many are blue?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(11,21)
			end,
			[2] = function()
				return math.random(1,9)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				return math.abs(t[2]-2*t[1])

			end,false},
			[2] = {function(...)
				local t = table.pack(...)

				return t[1]+t[2]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)

				return t[1]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)

				return t[1]-t[2]
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://1137365473',

		['Hint'] = 'What number do you subtract from ${1} to obtain {2}?'
	},
	[7] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = '%d - %d', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(5,9) end,
			[2] = function() return math.random(1,5) end
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return math.abs(t[1] + t[2])
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local random = math.random(1,2)
				return math.abs(t[random] - 2* t[random == 1 and 2 or 1])
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1] - t[2]
			end,true},
		},
		['ImageLabel'] = '',
	},
	[8] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'What day of the work week is %s?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() 
				local t = {"Monday","Tuesday","Wednesday","Thursday","Friday",}
				return t[math.random(#t)]
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local tab = table.find({"Monday","Tuesday","Wednesday","Thursday","Friday",},t[1])
				local r = math.random(1,2)
				while wait() do
					r = math.random(1,2)
					if r ~= tab then break end
				end
				return r
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local tab = table.find({"Monday","Tuesday","Wednesday","Thursday","Friday",},t[1])
				local r = math.random(3,5)
				while wait() do
					r = math.random(3,5)
					if r ~= tab then break end
				end
				return r
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local tab = table.find({"Monday","Tuesday","Wednesday","Thursday","Friday",},t[1])
				local r = math.random(6,7)
				while wait() do
					r = math.random(6,7)
					if r ~= tab then break end
				end
				return r
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local tab = {"Monday","Tuesday","Wednesday","Thursday","Friday",}
				return table.find(tab,t[1])
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = '',

		['Hint'] = 'Monday would be the first, Tuesday would be second continue this process until {1}.',
		['FreeHint'] = 'The work week starts on Monday.'
	},
	[9] = {
		['Image'] = true, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'What shape has 1 less side than a pentagon?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
		},['Answers'] = {
			[1] = {function(...)

				return 'A Pentagon'
			end,false},
			[2] = {function(...)
				return 'A Hexagon'
			end,false},
			[3] = {function(...)
				return 'A Triangle'
			end,false},
			[4] = {function(...)
				return 'A Square'
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10747361156'
	},
	[10] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'One pile has %d presents. The other pile has %d presents. How many in presents are there in total?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(10,20) end,
			[2] = function() return math.random(10,20) end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				return math.abs(t[2]-2*t[1])

			end,false},
			[2] = {function(...)
				local t = table.pack(...)

				return math.abs(t[1]-t[2])
			end,false},
			[3] = {function(...)
				local t = table.pack(...)

				return t[1]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)

				return t[1]+t[2]
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = ''
	},
	[11] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'There are %d items in a box. %d more were added, and later %d were taken out. How many are left?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(6,10) end,
			[2] = function() return math.random(1,5) end,
			[3] = function() return math.random(1,5) end
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				if t[2] ~= t[3] then
					return t[1]-t[2]+t[3]
				else
					return math.abs(t[1]-t[2]-t[3])
				end

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+t[3]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]-t[3]
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = ''
	},
	[12] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'What number is created when you combine %s 10s and %s 1s?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local t = {"one","two","three","four","five","six","seven","eight"}
				return t[math.random(#t)]
			end,
			[2] = function()
				local t = {"one","two","three","four","five","six","seven","eight"}
				return t[math.random(#t)]
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local nums = {"one","two","three","four","five","six","seven","eight"}
				local num1 = table.find(nums,t[1])
				local num2 = table.find(nums,t[2])
				return num1 + num2 * 10

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local nums = {"one","two","three","four","five","six","seven","eight"}
				local num1 = table.find(nums,t[1])
				local num2 = table.find(nums,t[2])
				return num1 + num2 + 10 + 1
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local nums = {"one","two","three","four","five","six","seven","eight"}
				local num1 = table.find(nums,t[1])
				local num2 = table.find(nums,t[2])
				return num1 +num2
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local nums = {"one","two","three","four","five","six","seven","eight"}
				local num1 = table.find(nums,t[1])
				local num2 = table.find(nums,t[2])
				return num1 * 10 + num2
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = ''
	},
	[13] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'A student started writing a paper at 12:%d0 PM and finishes at 12:%d0 PM. How long did it take the student to finish?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1,3)
			end,
			[2] = function()
				return math.random(4,5)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return math.abs((t[1]-t[2]-1)*10)

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return (t[2]-t[1]+1)*10
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return (t[2]-t[1]-1)*10
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return (t[2]-t[1])*10
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10749940320',

		['Hint'] = 'Adding and subtracting time is the same as adding and subtracting numbers. Think how you can subtract 12:{1}0 from 12:{2}0'
	},
	[14] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'Is addition commutative?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {

		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				return 'False'
			end,false},
			[2] = {function(...)
				local t = table.pack(...)

				return 'True'
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://1137365473',
		['FreeHint'] = 'In other words, does the order of the numbers NOT matter when adding?',
	},
	[15] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = '%d in word form is:', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,9)*10+math.random(1,9)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local tens = {"Twenty","Thirty","Forty","Fifty","Sixty","Seventy","Eighty","Ninety"}
				local ones = {[0]="Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"}
				local fractions = {[0]="Zeros","Ones","Halfs","Thirds","Fourth","Fifths","Sixths","Sevenths","Eighths","Ninths"}
				local ten = tens[math.floor(t[1]/10)-1]
				local one = fractions[math.floor(t[1])-math.floor(t[1]/10)*10]
				return ten .. '-' .. one

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local tens = {"Twenty","Thirty","Forty","Fifty","Sixty","Seventy","Eighty","Ninety"}
				local ones = {[0]="Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"}
				local fractions = {[0]="Zeros","Ones","Halfs","Thirds","Fourth","Fifths","Sixths","Sevenths","Eighths","Ninths"}
				local ten = ones[math.floor(t[1]/10)]
				local one = ones[math.floor(t[1])-math.floor(t[1]/10)*10]
				return ten .. '-' .. one
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local tens = {"Twenty","Thirty","Forty","Fifty","Sixty","Seventy","Eighty","Ninety"}
				local ones = {[0]="Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"}
				local fractions = {[0]="Zeros","Ones","Halfs","Thirds","Fourth","Fifths","Sixths","Sevenths","Eighths","Ninths"}
				local ten = ones[math.floor(t[1]/10)]
				local one = fractions[math.floor(t[1])-math.floor(t[1]/10)*10]
				return ten .. '-' .. one
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local tens = {"Twenty","Thirty","Forty","Fifty","Sixty","Seventy","Eighty","Ninety"}
				local ones = {[0]="Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"}
				local fractions = {[0]="Zeros","Ones","Halfs","Thirds","Fourth","Fifths","Sixths","Sevenths","Eighths","Ninths"}
				local ten = tens[math.floor(t[1]/10)-1]

				local one = ones[math.floor(t[1])-math.floor(t[1]/10)*10]
				if one == 'Zero' then one = '' end
				return ten .. '-' .. one
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://1137365473',

		['Hint'] = 'Try and say the word aloud.'
	},
	[16] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = '%d Hundreds, %d Tens and %d Ones, forms what number?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(1,9) end,
			[2] = function() return math.random(0,9) end,
			[3] = function() return math.random(0,9) end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				return t[3] *100 + t[2] * 10 + t[1] 
			end,false},
			[2] = {function(...)
				local t = table.pack(...)

				return t[2] *100 + t[3] * 10 + t[1] 
			end,false},
			[3] = {function(...)
				local t = table.pack(...)

				return t[1] *100 + t[3] * 10 + t[2] 
			end,false},
			[4] = {function(...)
				local t = table.pack(...)

				return t[1] *100 + t[2] * 10 + t[3] 
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://1137365473',

		['Hint'] = 'If you put {1} in the hundreds place, {2} in the tens place. And {3} in the ones place. What number do you have?'
	},
	[17] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'Which expression is equal to %d + %d?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(5,10) end,
			[2] = function() return math.random(5,10) end
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a = math.random(1,2)
				local rand1 = t[1]-a
				local rand2 = t[2]-a
				return rand1 .. ' + '.. rand2
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local a = math.random(1,2)
				local rand1 = t[1]+a
				local rand2 = t[2]+a
				return rand1 .. ' + '.. rand2
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local a = math.random(1,2)
				local rand1 = t[1]-a
				local rand2 = t[2]+3*a
				return rand1 .. ' + '.. rand2
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local random = math.random(1,5)
				local random2 = math.random(1,2)
				return t[random2] + random .. ' + '.. t[random2 == 1 and 2 or 1] - random
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = ''
	},
	[18] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = '%d + %d - %d', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(11,21)
			end,
			[2] = function()
				return math.random(11,15)
			end,
			[3] = function()
				return math.random(11,15)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				return math.abs(t[2]-t[3]-t[1]-1)

			end,false},
			[2] = {function(...)
				local t = table.pack(...)

				return math.abs(t[2]+t[3]-t[1]+1)
			end,false},
			[3] = {function(...)
				local t = table.pack(...)

				return math.abs(t[2]+t[3]+t[1]-1)
			end,false},
			[4] = {function(...)
				local t = table.pack(...)

				return t[1]+t[2]-t[3]
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://1137365473'
	},
	[19] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'In the pattern %s... How much do you add to get to the next number?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local slope = math.random(2,5)
				local yint = math.random(1,9)
				local t = {}
				for i=0,4 do
					table.insert(t,slope*i+yint)
				end
				return table.concat(t,', ')
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local split = string.split(t[1],', ')
				return (split[5]+split[1])%10

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local split = string.split(t[1],', ')
				return (split[5]-split[1])%10
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local split = string.split(t[1],', ')
				return split[5]%10
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local split = string.split(t[1],', ')
				return split[2]-split[1]
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://1137365473',

		['Hint'] = 'By how much does each number in the sequence go up by?'
	},
	[20] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "%d + %d + %d", -- what is the question (rich text syntax allowed)
		['Numbers'] = {

			[1] = function()
				return math.random(5,7)
			end,
			[2] = function()
				return math.random(7,9)
			end,
			[3] = function()
				return math.random(9,11)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+t[3]-math.random(-6,-3)
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+t[3]-math.random(-2,1)
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+t[3]+math.random(2,7)
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+t[3]
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752'
	},
	[21] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'How many cents does %d nickels, %d dimes and %d pennies make?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(1,2) end,
			[2] = function() return math.random(1,2) end,
			[3] = function() return math.random(1,5) end
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[2]*5+t[3]*10+t[1]
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[3]*5+t[2]*10+t[1]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]*5+t[3]*10+t[2]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]*5+t[2]*10+t[3]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = '',
		['FreeHint'] = '1 nickel is worth 5 cents, 1 dime is worth 10 cents, and 1 penny is worth 1 cent.',

		['Hint'] = '1 nickel is worth 5 cents, 1 dime is worth 10 cents, and 1 penny is worth 1 cent.'
	},
	[22] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'A train was scheduled to arrive at 7:%d, but arrived at 8:%s. In minutes, How long was the delay?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(9,11)*5 end,
			[2] = function() local a = math.random(1,4)*5 return a == 5 and '05' or a end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return math.abs(t[1]-t[2])
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return 60-t[1]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return math.abs(t[1]+t[2])
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return 60-t[1]+t[2]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://1137365473',
	},
	[23] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'Your ceiling is %d inches high, you want the tree to have %d inches of space with the ceiling. How tall must the tree be? <u>(in inches)</u>', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(5,8)*12 end,
			[2] = function() return math.random(5,12) end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]+2*t[2]
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]-2*t[2]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]-t[2]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://1137365473',

		['Hint'] = '{1}-{2}'
	},
	[24] = {
		['Image'] = true, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'What fraction does the image represent?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return "3/3"

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return "3/5"
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return "4/3"
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return "3/4"
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752'
	},
	[25] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'A farmer grows %d watermelons and %d apples. How many pieces of fruit did the farmer grow altogether?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(100,199) end,
			[2] = function() return math.random(50,99) end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*2

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]-t[2]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752'
	},
	[26] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "A book you are reading has %d pages. If you are almost done with the book. What is a reasonable number of pages to be left to read", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return math.random(200,500) end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return math.floor((t[1]+math.random(-25,25))*.75)
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return math.floor((t[1]+math.random(-25,25))*.1)
			end,true}
		}, -- if written is true, this is what will be used
		['FreeHint'] = 'Which answer seems the most right.',
		['ImageLabel'] = 'rbxassetid://10761505752'
	},
	--[[[27] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "You go on vacation on a %s, and return 1 week later. What day of the week did you return?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local t = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"}
				return t[math.random(#t)]
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]
			end,true}
		}, -- If written is false, this is what will be used -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752',

		['Hint'] = 'There are 7 days in a week, every 7 days the day of the week goes back to what it was 7 days prior.'
	},]]
	[27] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "You go on vacation on the %dth of %s, and return a week later. On what day did you return?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(4,20)
			end,
			[2] = function()
				local t = {"January", "February", "March", "April", "May", "June", "July" ,"August", "September", "October", "November", "December"}
				return t[math.random(#t)]
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]-7
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]+1
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return (t[1]+15)%28+1
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]+7
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752'
	},
	[28] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "%d + %d", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(20,100)*5
			end,
			[2] = function()
				return math.random(20,100)*5
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]-math.random(1,5)*10
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+math.random(1,5)*10
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return math.floor((t[1]+t[2])*(math.random()+.5))
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752'
	},
	[29] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "%d + %d", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(100,699)
			end,
			[2] = function()
				return math.random(100,699)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+math.random(1,5)*10
			end,false},

			[2] = {function(...)
				local t = table.pack(...)
				return math.floor((t[1]+t[2])*(math.random()+.5))
			end,false},

			[3] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]-math.random(1,5)*10
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752'
	},

	[30] = {

		['Image'] = false, 
		['Written'] = false, 
		['Question'] = "The length of a rectangle is %d, and its width is %d. What is its area?", -- what is the question (rich text syntax allowed)

		['Numbers'] = {
			[1] = function()
				return math.random(2,5)
			end,
			[2] = function()
				return math.random(2,5)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]+2*t[2]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[2]+1
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752',
	},
	[31] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'You have %s, you spend %d dimes and %d nickels. How much money do you have now?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() return dollar(math.random(1,100)*.05):sub(1,5) end,
			[2] = function() return math.random(1,3) end,
			[3] = function() return math.random(1,3) end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				t[1] = string.gsub(t[1]:sub(1,5),'%$','')
				return dollar(t[1]-t[2]*.05-t[3]*.1):sub(1,5)
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				t[1] = string.gsub(t[1]:sub(1,5),'%$','')
				return dollar(t[1]+t[2]*.05-t[3]*.1):sub(1,5)
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				t[1] = string.gsub((t[1]):sub(1,5),'%$','')
				return dollar(t[1]-t[3]*.05-t[2]*.1-.05):sub(1,5)
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				t[1] = string.gsub(t[1]:sub(1,5),'%$','')
				return dollar(t[1]-t[3]*.05-t[2]*.1):sub(1,5)
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://1137365473',

		['FreeHint'] = '1 nickel is worth 5 cents, 1 dime is worth 10 cents, and 1 penny is worth 1 cent. $1.20 = 120 cents.',
		['Hint'] = 'The period in money splits dollars with cents (dollars left of the period, cents right), only focus on the cent portion when subtracting coin amounts.'
	},
	[32] = {
		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = 'How many sides does a <u>%s</u>gon have?', -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local t = {[5]='penta',[6]='hexa',[8]='octa',[10]='deca'}
				local tt = {5,6,8}
				local r = tt[math.random(#tt)]
				return t[r]
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local tab = {'penta','hexa','octa','deca'}
				if table.find(tab,t[1]) == 1 then return 6 elseif table.find(tab,t[1]) == 2 then return 8 elseif table.find(tab,t[1]) == 3 then return 10 elseif table.find(tab,t[1]) == 4 then return 5 end
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local tab = {'penta','hexa','octa','deca'}
				if table.find(tab,t[1]) == 1 then return 8 elseif table.find(tab,t[1]) == 2 then return 10 elseif table.find(tab,t[1]) == 3 then return 5 elseif table.find(tab,t[1]) == 4 then return 6 end
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local tab = {'penta','hexa','octa','deca'}
				if table.find(tab,t[1]) == 1 then return 10 elseif table.find(tab,t[1]) == 2 then return 5 elseif table.find(tab,t[1]) == 3 then return 6 elseif table.find(tab,t[1]) == 4 then return 8 end
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local tab = {'penta','hexa','octa','deca'}
				if table.find(tab,t[1]) == 1 then return 5 elseif table.find(tab,t[1]) == 2 then return 6 elseif table.find(tab,t[1]) == 3 then return 8 elseif table.find(tab,t[1]) == 4 then return 10 end
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://1137365473',
		['Hint'] = 'A stop sign is an octagon. A honeycomb is a hexagon. A pentalathon has 5 events. A decade has 10 years.'
	},
	[33] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "You ordered %d pizzas for a party which cost $%d each. You also gave a $%d tip to the delivery person. How much did you spend", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,4)
			end,
			[2] = function()
				return math.random(7,12)
			end,
			[3] = function()
				return math.random(3,7)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+t[3]
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]*t[3]+t[2]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]*t[3]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]+t[3]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752',

		['Hint'] = 'Multiply the cost of 1 pizza by the quantity of them, which is {1}×{2}. Adding ${3} to that gives the total cost.'
	},

	[34] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "2 apples cost %s. How much does 1 apple cost", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return dollar(math.random(5,10)*2)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				local a,_ = string.gsub(t[1],"%$","")
				return dollar(a/2-2)
			end,false},
			[2] = {function(...)
				local t = table.pack(...)

				local a,_ = string.gsub(t[1],"%$","")
				return dollar(a/2-4)
			end,false},
			[3] = {function(...)
				local t = table.pack(...)

				local a,_ = string.gsub(t[1],"%$","")
				return dollar(a/2-3)
			end,false},
			[4] = {function(...)
				local t = table.pack(...)

				local a,_ = string.gsub(t[1],"%$","")
				return dollar(a/2)
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752',

		['Hint'] = 'Think about what number added to itself gives you the cost of the 2 apples`'
	},
	[35] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "%d×%d", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(11,15)
			end,
			[2] = function()
				return math.random(7,15)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*(t[2]-1)
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2] - math.random(1,10)*3
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2] + math.random(1,10)*5
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542'
	},
	[36] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "You have %d chocolates. You share half with your friend. Then you eat the half of the remaining chocolates you have left. How many chocolates do you have now?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1,5)*4
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*3/4
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]/2
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]-4
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]/4
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = '{1}/4 = ?'
	},
	[37] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Right now, the time is 2:%s PM. What is the time in %d hours.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local r = math.random(1,59)
				return r < 10 and '0'.. r or r
			end,
			[2] = function()
				return math.random(24,30)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return 2+t[1]%12 .. ':'.. t[2] .. ' PM'
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return 2+t[1]%12 .. ':'.. math.max(math.random(10,23),(t[1]+t[2])%60) .. ' PM'
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return 2+t[2]%12 .. ':'.. math.max(math.random(10,23),(t[1]+t[2])%60) .. ' PM'
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return 2+t[2]%12 .. ':'.. t[1] .. ' PM'
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = 'Every 24 hours the time of day is the same.'
	},
	[38] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "A town has %d grown-ups and %d children. How many people live in the town?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1000,1999)
			end,
			[2] = function()
				return math.random(1000,1999)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+10+math.random(1,8)*10
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]-110-math.random(1,8)*10
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+100+math.random(1,5)*10
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542'
	},
	[39] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "There were %d mugs in the pantry. You broke %d mugs and bought some more to replace them. You buy double the mugs as you broke, how many whole mugs do you have?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(11,21)
			end,
			[2] = function()
				return math.random(2,5)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return -t[2]+t[2]*2
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]-t[2]-t[2]*2
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]*2
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]-t[2]+t[2]*2
			end,true},
		},-- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = 'There are {1}-{2} whole mugs after you broke them'
	},
	[40] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Brand A sells their product for %s pounds. Brand B sells their product for %s pounds. Which brand is cheaper, and by how much per pound?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local gcf = math.random(2,6)
				local n1 = math.random(2,6)*gcf
				local n2 = gcf
				return '$'..n1 ..' per '.. gcf
			end,
			[2] = function()
				local gcf = math.random(2,6)
				local n1 = math.random(2,6)*gcf
				local n2 = gcf
				return '$'..n1 ..' per '.. gcf
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local AP = string.split(string.gsub(t[1], "%$", ""),' per ')[1]
				local AK = string.split(string.gsub(t[1], "%$", ""),' per ')[2]
				local BP = string.split(string.gsub(t[2], "%$", ""),' per ')[1]
				local BK = string.split(string.gsub(t[2], "%$", ""),' per ')[2]
				local rightBrand = AP/AK > BP/BK and 'Brand A | $' or 'Brand B | $'
				if AP/AK == BP/BK then return rightBrand.. math.random(1,4) end
				return rightBrand.. math.abs(AP/AK-BP/BK)
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local AP = string.split(string.gsub(t[1], "%$", ""),' per ')[1]
				local AK = string.split(string.gsub(t[1], "%$", ""),' per ')[2]
				local BP = string.split(string.gsub(t[2], "%$", ""),' per ')[1]
				local BK = string.split(string.gsub(t[2], "%$", ""),' per ')[2]
				local rightBrand = AP/AK > BP/BK and 'Brand A | $' or 'Brand B | $'
				if math.random(1,2) == 1 and AP/AK ~= BP/BK then return "Same Deal" end
				return rightBrand.. math.abs(AK-BK)
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local AP = string.split(string.gsub(t[1], "%$", ""),' per ')[1]
				local AK = string.split(string.gsub(t[1], "%$", ""),' per ')[2]
				local BP = string.split(string.gsub(t[2], "%$", ""),' per ')[1]
				local BK = string.split(string.gsub(t[2], "%$", ""),' per ')[2]
				local rightBrand = AP/AK < BP/BK and 'Brand A | $' or 'Brand B | $'
				return rightBrand.. math.abs(AK-BK)+math.random(2,4)
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local AP = string.split(string.gsub(t[1], "%$", ""),' per ')[1]
				local AK = string.split(string.gsub(t[1], "%$", ""),' per ')[2]
				local BP = string.split(string.gsub(t[2], "%$", ""),' per ')[1]
				local BK = string.split(string.gsub(t[2], "%$", ""),' per ')[2]
				local rightBrand = AP/AK < BP/BK and 'Brand A | $' or 'Brand B | $'
				if AP/AK == BP/BK then return "Same Deal" end
				return rightBrand.. math.abs(AP/AK-BP/BK)
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752',

		['Hint'] = 'Dividing the price by the amount will give the unit price. Find out which unit price is cheaper, and by what amount.'
	},
	[41] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "%s = ?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local a = math.random(4,6)
				local s = ''
				local n
				if a > 3 then n = 2 else n = 3 end
				for i=1,a do
					if i == a then
						s ..= n
					else
						s ..= n .. '×'
					end
				end
				return s
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return tonumber(string.split(t[1],'×')[1])^(#string.split(t[1],'×')-1)
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return tonumber(string.split(t[1],'×')[1])^(#string.split(t[1],'×')+1)
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return tonumber(string.split(t[1],'×')[1])*(#string.split(t[1],'×')+1)
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return tonumber(string.split(t[1],'×')[1])^#string.split(t[1],'×')
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['Hint'] = 'Think of some number, then multiply it by 2 {1} times. How many times larger is the new number than the previous one?'
	},
	[42] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "%d×(%d+%d)", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()

				return math.random(5,9)
			end,
			[2] = function()

				return math.random(5,9)
			end,
			[3] = function()

				return math.random(5,9)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*(t[2]+t[3])
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = 'Your first written question! Type the answer into the box below!',
	},
	[43] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "At a school, each class ordered %d pizza pies. If there are %d classes, how many pizza pies did the school order", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1,2)*8
			end,
			[2] = function()
				return math.random(1,15)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return math.abs(20*(t[2]-5)-math.random(1,10))
			end,true},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]+math.random(1,10)
			end,true},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['Hint'] = 'Round {1} to the nearest 10th. Multiply that by {2}',
	},
	[44] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "You and your friends watched the latest movie at the movie theater. The movie was %d hours and %d minutes long. You all left the movie theater at %d:30 PM .At what time did the movie start?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,3)
			end,
			[2] = function()
				return math.random(1,30)
			end,
			[3] = function()
				return math.random(5,11)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a = math.abs(30+t[2])%50 < 10 and ':0' or ':'
				return t[3]-t[1] - (30-t[2] > 0 and 1 or 0).. a.. math.abs(30+t[2])%50 ..' PM'
			end,true},
			[2] = {function(...)
				local t = table.pack(...)
				local a = math.abs(30+t[2])%50 < 10 and ':0' or ':'
				return t[3]-t[1] - (30-t[2] < 0 and 1 or 2).. a.. math.abs(30+t[2])%50 ..' PM'
			end,true},
			[3] = {function(...)
				local t = table.pack(...)
				local a = math.abs(30-t[2]) < 10 and ':0' or ':'
				return t[3]-t[1] + (30-t[2] and 1 or 0).. a.. math.abs(30-t[2])..' PM'
			end,true},
			[4] = {function(...)
				local t = table.pack(...)
				local a = (30-t[2] < 0 and 90-t[2] or 30-t[2]) < 10 and ':0' or ':'
				return t[3]-t[1] - (30-t[2] < 0 and 1 or 0).. a.. (30-t[2] < 0 and 90-t[2] or 30-t[2])..' PM'
			end,true},
		},  -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[Imagine if the colon is the decimal point, and you have to carry the hour to make 60 minutes. imagine 9:15 as 9.15, carry one from 9 to get 8:75. Use this information to solve the problem.]]
	},
	[45] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "A list of numbers contains the numbers %s. What would the %dth number be?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local slope = math.random(2,5)
				local yint = math.random(1,9)
				local t = {}
				for i=0,4 do
					table.insert(t,slope*i+yint)
				end
				return table.concat(t,', ')
			end,
			[2] = function()
				return math.random(6,9)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local nums = string.split(t[1],', ')
				local commond = nums[2]-nums[1]
				return nums[#nums] + 2*(t[2]-#nums)*commond
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local nums = string.split(t[1],', ')
				local commond = nums[2]-nums[1]
				return nums[#nums] + commond+1
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local nums = string.split(t[1],', ')
				local commond = nums[2]-nums[1]
				return nums[#nums]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local nums = string.split(t[1],', ')
				local commond = nums[2]-nums[1]
				return nums[#nums] + (t[2]-#nums)*commond
			end,true},
		}, -- If written is false, this is what will be used
		['Function'] = function(input)
			local a = string.gsub(input,'[^%d]+','')
			return tonumber(a) == 12

		end, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[The sequence goes up by some number each time. Try finding the 5th number in the list, that might help you to get to the 6th.]]
	},
	[46] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "If a magician has %d doves, how many rabbits would they have if they pulled out twice as many rabbits as doves?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,3)
			end
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return 2*t[1]
			end,true},
		},-- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[{1} + 2×{1} + (2×{1})×{2}]]
	},
	[47] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "A square has an area of %d, what is its side length?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(3,5)^2
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return math.floor(t[1]^.5)
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = [[Find a number where when multiplied to itself, equals the area]]
	},

	[48] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "A farmer planted %d rows of carrots in her garden. Each row had %d carrots. The rabbit ate a third of her carrots. How many carrots did the <u>rabbit</u> eat?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(3,9)
			end,
			[2] = function()
				return math.random(2,5)*30
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]/6
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]*4/3
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]*2/3
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]/3
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[There were {1}×{2} carrots before the rabits ate.]]
	},
	[49] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "You finished a fourth of your homework in %d minutes. How many <u>hours</u> did it take you to finish all of it?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()

				return math.random(1,4)*15
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]/15
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[A fourth of the homework takes {1} minutes. Finishing half of the homework will take {1}×2 minutes.]]
	},
	[50] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "You're reading a book and you know you can read %s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local n1 = math.random(2,6)
				local n2 = math.random(2,4)
				local n3 = n2*math.random(2,5)
				return string.format("%d pages in %d minutes. How many pages would you have read in %d minutes?",n1,n2,n3)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local tt = extract(t[1])
				return tt[1]/tt[2]*tt[3]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = 'Divide {2} by the amount of patients waiting. Your answer at the moment is in hours. Turn it into minutes'
	},
	[51] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "How many zeros does 10^%d have?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()

				return math.random(1,8)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = '^ means exponent. Eg: 2^3 = 8 because 2×2×2 = 8',
		['Hint'] = [[Is the number too large? Scale the problem down! How many zeros does 10^2 have? 10^3? 10^4? Do you find a pattern?]]
	},
	[52] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "The price of a shirt is %s. If you get a 25%% discount, how much will the shirt cost?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return dollar(math.random(2,6)*4)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,_ = string.gsub(t[1],"%$","")
				return .75*a
			end,true},

			[2] = {function(...)
				local t = table.pack(...)
				local a,_ = string.gsub(t[1],"%$","")
				return dollar(.75*a)
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = [[A 25% discount means 25% is taken <b>off</b> the original price.]]
	},
	[53] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "You have %d cards, and your friend has %d cards. If someone offers to double this total and give it to the next pair of friends, how many cards will the next pair of friends receive?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()

				return math.random(5,9)
			end,
			[2] = function()

				return math.random(5,9)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return 2*(t[1]+t[2])
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[Add {1} and {2}. Double that number.]]
	},
	[54] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "If the price of a gallon of gas is %s and you have %s, how many <u>whole</u> gallons of gas can you buy?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return dollar(math.random(100)/10)
			end,
			[2] = function()
				return dollar(math.random(6)*5)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,_ = string.gsub(t[1],"%$","")
				local b,_ = string.gsub(t[2],"%$","")
				return math.floor(b/a)
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[55] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "You were assigned to make souvenirs. You have %d feet of ribbon which you plan to use. You want to cut the ribbon equally into 4 inch long pieces. How many smaller ribbons can you make?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,7)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*3
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = 'Try converting measurements into fully inches'
	},

	[56] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "A box has a length of %d, a width of %d, and a depth of %d. What is its volume?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()

				return math.random(2,5)
			end,
			[2] = function()

				return math.random(2,5)
			end,
			[3] = function()

				return math.random(2,5)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]*t[3]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[Formula for Volume is length×width×depth]]
	},
	[57] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "A triangle which has %s equal sides is called what?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local m = math.random(1,3)
				if m == 1 then return 'no' else return tostring(m) end
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a = 1
				if t[1] == '3' then a = 'scalene' elseif t[1] == 'no' then a = 'isosceles' else  a = 'equilateral' end
				return a
			end,true},
			[2] = {function(...)
				local t = table.pack(...)
				local a = 1
				if t[1] == '2' then a = 'scalene' elseif t[1] == '3' then a = 'isosceles' else  a = 'equilateral' end
				return a
			end,true},
			[3] = {function(...)
				local t = table.pack(...)
				local a = 1
				if t[1] == 'no' then a = 'scalene' elseif t[1] == '2' then a = 'isosceles' else  a = 'equilateral' end
				return a
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[58] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "How many seconds are in %d minutes?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(5,15)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*60
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[59] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "For every %s bananas. How many bananas are there if you have %d apples.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local r = math.random(1,3)
				local b = r*math.random(2,4)
				return string.format('%d apples you have %d',r,b)
			end,
			[2] = function()
				return math.random(2,5)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local newt = {}
				local s = string.split(t[1],' ')
				for i,v in pairs(s) do
					if tonumber(v) ~= nil then
						table.insert(newt,tonumber(v))
					end
				end
				return (t[2]*newt[2])/newt[1]
			end,true},
		},-- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[60] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "%d is a %s of what number", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(5,15)
			end,
			[2] = function()
				local t = {'half','third','fourth','fifth'}
				return t[math.random(#t)]
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local ta = {'half','third','fourth','fifth'}
				local i = table.find(ta,t[2])+1
				return t[1]*i
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[The same question is "what number is some amount times {1}", some amount being the third, fourth or fifth. (eg, that number may be 3 if the problem contained a third)]]
	},
	[61] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "In track, one runner ran %d laps. Another runner ran %d more laps than the first. Each lap is a quarter of a mile. How many miles did the second runner run?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()

				return math.random(3,6)*4
			end,
			[2] = function()

				return math.random(1,2)*4
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return (t[1]+t[2])/4
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[The second runner ran 20 laps.]]
	},
	[62] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Convert the fraction %d/8 to a decimal.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1,7)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]/8
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[63] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "The perimeter of a rectangle is %d. If the length is %d, what is the width of the rectangle?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(6,20)*4
			end,
			[2] = function()
				return math.random(5,10)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[2]
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]-2*t[2]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]-t[2]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]/2-t[2]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[The formula for perimeter is 2(L+W), where L and W are length and width. S you have the equation {1} = 2({2}+W)]]
	},
	[64] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "There are %d chickens and %d cows on a farm. How many legs are there in total?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(5,10)
			end,
			[2] = function()
				return math.random(8,20)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*2+t[2]*4
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = 'Chickens have 2 legs',

		['Hint'] = [[2*{1}+4*{2}]]
	},
	[65] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Find the mean (average) of the following set of numbers: %s.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local total = math.random(4,6)
				local s = ''
				for i=1,total-1 do
					if i == total-1 then
						s ..= math.random(2,8)
					else
						s ..= math.random(2,8) .. ', '
					end


				end
				local function avg(x)
					local s = 0
					for i,v in pairs(x) do
						s += v
					end
					return s/#x,s
				end
				local newt = string.split(s,', ')
				local mean,sum = avg(newt)
				local goal = math.ceil(mean)
				s ..= ', '..goal*(#newt+1)-sum
				return s
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local function avg(x)
					local s = 0
					for i,v in pairs(x) do
						s += v
					end
					return s/#x
				end
				local newt = string.split(t[1],', ')

				return avg(newt)
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['Hint'] = "The mean of a set is defined as adding up all the numbers and dividing that sum by how many there are."

	},
	[66] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "%d/%d + %d/%d", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()

				return math.random(1,4)
			end,
			[2] = function()

				return math.random(5,9)
			end,
			[3] = function()

				return math.random(1,4)
			end,
			[4] = function()

				return math.random(5,9)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				if t[2]+t[3] == t[1] +t[4] then

					return t[2]+t[3] .. '/' .. t[1] +t[4]+1
				end
				return t[2]+t[3] .. '/' .. t[1] +t[4]
			end,true},
			[2] = {function(...)
				local t = table.pack(...)
				if t[1]+t[3] == t[2] +t[4] then

					return t[1]+t[3] .. '/' .. t[2] +t[4]+1
				end
				return t[1]+t[3] .. '/' .. t[2] +t[4]
			end,true},
			[3] = {function(...)
				local t = table.pack(...)
				if t[1]+t[2] == t[3] +t[4] then

					return t[1]+t[2] .. '/' .. t[3] +t[4]+1
				end
				return t[1]+t[2] .. '/' .. t[3] +t[4]
			end,true},
			[4] = {function(...)
				local t = table.pack(...)
				local lcm = m.lcm(t[2],t[4])
				local top1 = t[1]*(lcm/t[2])
				local top2 = t[3]*(lcm/t[4])
				local bottoms = lcm
				local toptotal = top1+top2
				local gcd = m.gcd(toptotal,bottoms)
				local finaltop = toptotal/gcd
				local finalbottom = bottoms/gcd
				return finaltop .. '/' .. finalbottom
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[The denominator of the final answer will equal the greatest common divisor of {2} and {4}]]
	},
	[67] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "You saved %s from your school allowance. You buy %d superhero action figures which cost %s each and a toy robot for %s. How many coins do you have left?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function() 
				return dollar(math.random(400,1000)*.1)
			end,
			[2] = function() 
				return math.random(1,3)
			end,
			[3] = function() 
				return dollar(math.random(10,100)*.1)
			end,
			[4] = function() 
				return dollar(math.random(10,99)*.1)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				local t1 = string.gsub(t[1],"%$","")
				local t3 = string.gsub(t[3],"%$","")
				local t4 = string.gsub(t[4],"%$","")
				return round(t1-t3*t[2]-t4,2)
			end,true},--[[

			[2] = {function(...)
				local t = table.pack(...)

				local t1 = string.gsub(t[1],"%$","")
				local t3 = string.gsub(t[3],"%$","")
				local t4 = string.gsub(t[4],"%$","")
				
				return dollar(round(t1-t3*t[2]-t4,2))
			end,true},]]
		}
	},
	[68] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Theres a square with a side length of %d. A chunk with an area of %d is removed from the square. What is the area of the new shape?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(6,9)
			end,
			[2] = function()
				return math.random(1,5)^2
			end,
		},
		['Answers'] = {

			[1] = {function(...)
				local t = table.pack(...)
				return t[1]^2-t[2]^.5
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return math.abs(t[1]-t[2])
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]^2-t[2]
			end,true}
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[Area = {1}² - {2}]]
	},
	[69] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "%s + %s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return tostring(tonumber(string.format('%.3f',math.random(1000,5000)/1000)))
			end,
			[2] = function()
				return tostring(tonumber(string.format('%.3f',math.random(1000,4999)/1000)))
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				return tonumber(string.format('%.3f',t[1]+t[2]))
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[70] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "%s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local b = math.random(2,6)
				local exp
				if b == 2 then
					exp = math.random(2,6)
				elseif b == 3 then
					exp = math.random(2,4)
				elseif b == 4 then
					exp = math.random(2,3)
				elseif b == 5 then
					exp = math.random(2,3)
				elseif b == 6 then
					exp = 2

				end
				return b ..'^'.. exp
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return string.split(t[1],'^')[1]^string.split(t[1],'^')[2]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = '^ means exponents. Eg: 10^3 = 1000 becuase 10×10×10 = 1000',
	},
	[71] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "%s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local d = math.random(3,7)
				local n = d*math.random(3,7)
				return n..'÷(-'..d .. ')'
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local n,d = extract(t[1])[1],extract(t[1])[2]
				return n/-d
			end,true},
			[2] = {function(...)
				local t = table.pack(...)
				local n,d = extract(t[1])[1],extract(t[1])[2]
				return n/d-math.random(1,3)
			end,true},
			[3] = {function(...)
				local t = table.pack(...)
				local n,d = extract(t[1])[1],extract(t[1])[2]
				return n/d+math.random(1,3)
			end,true},
			[4] = {function(...)
				local t = table.pack(...)
				local n,d = extract(t[1])[1],extract(t[1])[2]
				return n/d
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[72] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "You had %s left over. How many friends do you have?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local ans = math.random(3,9)
				local s = '%d cherries. You gave %d to each of your friends. You still have %d'
				local num2 = math.random(3,10)
				local num3 = math.random(1,num2-1)
				local num1 = ans*num2+num3

				return string.format(s,num1,num2,num3)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local s = t[1]
				local news = string.split(s,' ')
				local new = {}
				for i,v in pairs(news) do if tonumber(v) == nil then table.remove(news,i) end end
				for i,v in pairs(news) do
					table.insert(new,tonumber(v))
				end
				return (new[1]-new[3])/new[2]
			end,true},
		},-- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',

		['Hint'] = [[You gave {1}-{3} cherries away.]]
	},
	[73] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "You have %d pieces of candy and you want to split it among your %d friends. How many pieces of candy will be left over?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(11,99)
			end,
			[2] = function()
				return math.random(2,9)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]%(t[2]+1)+1
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]%(t[2]+1)+2
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[2]-1
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]%t[2]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10761505752',

		['Hint'] = "You and your friends make up {2}+1 people. What is the greatest number of candy that can be given out in total where everyone has an equal amount. Then subtract that from {1}."
	},
	[74] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "The ratio of red apples to green apples in a basket is %s apples in the basket, how many of them are red?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local snd = math.random(4,8)
				local first = math.random(1,snd)
				local count = math.random(2,5)*(first+snd)
				return first..':'..snd .. ' if there are ' .. count
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local ratio,apples = table.unpack(string.split(t[1],' if there are '))
				local red,green = table.unpack(string.split(ratio,':'))

				return apples*red/(red+green)
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['Hint'] = "Add the two numbers in the ratio together, then divide it by the total amount of apples, then multiply it by the first number in the ratio."
	},	
	[75] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "A car salesperson sells %d cars on a Monday, and %d cars on a Tuesday. This was only 25%% of the sales in that week. How many cars did the salesperson sell that week?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(5,15)
			end,
			[2] = function()
				return math.random(5,15)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				return (t[2]+t[1])*4
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['Hint'] = "Add up the total amount of cars sold on monday and tuesday, then multiply that by 4"
	},
	[76] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "A student earned a grade of %s questions, how many questions did the student miss?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local score = math.random(6,9)*10
				local questions = math.random(1,5)*10
				return string.format('%d%% on a test. If the test had %d',score,questions)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local percent,question = table.unpack(string.split(t[1],' on a test. If the test had '))
				percent = string.gsub(percent,'%%','')/100
				return question-percent*question
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[77] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "%s; Solve for x.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local s = math.random(2,7)
				local y = math.random(-10,10)
				y = y == 0 and math.random(1,2)*2-3 or y
				local set = y%s + s*math.random(-5,5)
				if y > 0 then y = '+' .. y else y = '-' .. -y end
				return s .. 'x' .. y .. ' = ' .. set
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local t = extract(t[1])
				return (t[3]-t[2])/t[1]-1
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local t = extract(t[1])
				return (t[3]-t[2])/t[1]+2
			end,false},  
			[3] = {function(...)
				local t = table.pack(...)
				local t = extract(t[1])
				return (t[3]-t[2])/t[1]+1
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local t = extract(t[1])
				return (t[3]-t[2])/t[1]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = 'x is a variable',
	},
	[78] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "There is a circle with area %dπ. What is its radius?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(3,7)^2
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]^0.5-2
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]^0.5-1
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]^0.5+1
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]^0.5
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[79] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "You split a right angle into two angles. One angle has a measure of %d°. What is the measure of the second angle.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(20,70)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return 45+t[1]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return 180-t[1]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return 90-t[1]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[80] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "What is the lcm (least common multiple) of %s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local r = math.random(0,1)
				if r == 0 then
					local lcm = math.random(2,7)
					local n1 = lcm*math.random(1,25)
					local n2 = lcm*math.random(1,25)
					return n1 .. ' and ' .. n2
				else
					local n1 = math.random(1,12)
					local n2 = math.random(1,12)
					return n1 .. ' and ' .. n2
				end
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return extract(t[1])[1]+extract(t[1])[2]
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return extract(t[1])[1]*extract(t[1])[2]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return m.gcd(extract(t[1])[1],extract(t[1])[2])
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return m.lcm(extract(t[1])[1],extract(t[1])[2])
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[81] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Which expression is equivalent to %s?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local b = math.random(2,20)
				local m = math.random(-20,20)
				local n = math.random(-20,20)
				if m == -n then
					m += 1
				end
				return '('..b .. '^'..m .. ')('..b .. '^'..n .. ')'
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local b, m, n = t[1]:match("%((%d+)%^(%-?%d+)%)%(%d+%^(%-?%d+)%)")
				return '-'..b .. '^'.. -(m+n)

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local b, m, n = t[1]:match("%((%d+)%^(%-?%d+)%)%(%d+%^(%-?%d+)%)")
				return b .. '^'.. m*n
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local b, m, n = t[1]:match("%((%d+)%^(%-?%d+)%)%(%d+%^(%-?%d+)%)")
				local rand = math.random(0,1)
				if rand == 0 then
					return b .. '^'.. -(m+n)
				else
					return '1/' .. b .. '^'.. (m+n)
				end
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local b, m, n = t[1]:match("%((%d+)%^(%-?%d+)%)%(%d+%^(%-?%d+)%)")
				local rand = math.random(0,1)
				if rand == 0 then
					return b .. '^'.. (m+n)
				else
					return '1/' .. b .. '^'.. -(m+n)
				end
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[82] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "%s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				if math.random(1,2) == 1 then
					local m = math.random(3,7)
					local n = math.random(1,m-1)
					local hyp = m^2+n^2
					local leg = math.random(1,2) == 1 and 2*m*n or m^2-n^2
					return string.format("A right triangle has a hypotenuse with length %d cm. One of its legs have a length of %d. What is the length of its other leg.",hyp,leg)
				else
					local m = math.random(3,7)
					local n = math.random(1,m)
					local leg1 = 2*m*n
					local leg2 = m^2-n^2
					return string.format("A right triangle has two legs with length %d cm and %d cm. What is the length of its hypotenuse?",leg1,leg2)

				end
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				if math.floor(#t[1]/10)*10 == 90 then
					local nums = extract(t[1])
					return math.round(math.sqrt(nums[1]^2+nums[2]^2))
				else
					local nums = extract(t[1])
					return math.round(math.sqrt(nums[1]^2-nums[2]^2))
				end
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[83] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "You draw a triangle with one interior angle measuring %d°. Which angle measures could be the measures of the other two interior angles in the triangle?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(30,150)
			end,
		}, -- t[]
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				local a2 = math.random(1,180-t[1]-1)
				return a2 .. '° & '.. 180-a2 .. '°'

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local a2 = math.random(10,180-t[1]-1)
				return a2-math.random(1,10)*(2*math.random(0,1)-1) .. '° & '.. 180-t[1]-a2 .. '°'
			end,false},
			[3] = {function(...)
				local t = table.pack(...)

				local a2 = math.random(30,150)
				return a2 .. '° & '.. 180-a2 .. '°'
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local a2 = math.random(1,180-t[1]-1)
				return a2 .. '° & '.. 180-t[1]-a2 .. '°'
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[84] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "A cylindrical container has a height of %d feet and a <u>diameter</u> of %d feet. What is the volume, in cubic feet, of the container in terms of π?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(3,10)
			end,
			[2] = function()
				return math.random(2,5)*2
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				local a2 = math.random(1,180-t[1])
				return t[1]/2*t[2]^2/4 .. 'π'

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local a2 = math.random(10,180-t[1])
				return t[1]/2*t[2]^2 .. 'π'
			end,false},
			[3] = {function(...)
				local t = table.pack(...)

				local a2 = math.random(30,150)
				return t[1]*t[2]^2 .. 'π'
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1]*t[2]^2/4 .. 'π'
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[85] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Solve for x; x^3 = %d", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,8)^3
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return math.round(t[1]^(1/3))
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[86] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Which equation represents a function that is <b> not </b> linear.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,8)^3
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local r1,r2 = math.random(2,9),math.random(2,9)
				return r1 .. '(x + ' .. r2 .. ')'

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local r1,r2 = math.random(2,9),math.random(2,9)
				return r1  .. '^2 + ' .. r2 .. 'x'
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local r1,r2 = math.random(2,9),math.random(2,9)
				return '(' .. r1 .. ' + x)/' .. r2 
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local r1,r2 = math.random(2,9),math.random(2,9)
				return r1 .. 'x + ' .. r2 .. 'x^2'
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[87] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Point (%d,%d) is rotated %d° %s about the origin. Where does it's image lie?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(-10,10)
			end,
			[2] = function()
				return math.random(-10,10)
			end,
			[3] = function()
				return math.random(1,3)*90
			end,
			[4] = function()
				local t = {"clockwise","counterclockwise"}
				return t[math.random(2)]
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local x,y = t[1],t[2]
				local rot = t[3]
				local dir = t[4]
				if dir == "counterclockwise" then
					rot = 360-rot
				end
				if rot == 90 then
					return string.format("(%d,%d)",-x,y)
				elseif rot == 180 then
					return string.format("(%d,%d)",x,y)

				elseif rot == 270 then
					return string.format("(%d,%d)",y,x)
				end
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local x,y = t[1],t[2]
				local rot = t[3]
				local dir = t[4]
				if dir == "clockwise" then
					rot = 360-rot
				end
				if rot == 90 then
					return string.format("(%d,%d)",-x,y)
				elseif rot == 180 then
					return string.format("(%d,%d)",-y,x)

				elseif rot == 270 then
					return string.format("(%d,%d)",y,x)
				end
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local x,y = t[1],t[2]
				local rot = t[3]
				local dir = t[4]
				if dir == "counterclockwise" then
					rot = 360-rot
				end
				if rot == 90 then
					return string.format("(%d,%d)",-y,x)
				elseif rot == 180 then
					return string.format("(%d,%d)",-x, y)

				elseif rot == 270 then
					return string.format("(%d,%d)",x,-y)
				end
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local x,y = t[1],t[2]
				local rot = t[3]
				local dir = t[4]
				if dir == "clockwise" then
					rot = 360-rot
				end
				if rot == 90 then
					return string.format("(%d,%d)",-y,x)
				elseif rot == 180 then
					return string.format("(%d,%d)",-x,-y)

				elseif rot == 270 then
					return string.format("(%d,%d)",y,-x)
				end
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[88] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Solve the system:\n%s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local x,y = math.random(-10,10),math.random(-10,10)
				local xT = {-1,1} 
				local a = math.random(1,5)*xT[math.random(#xT)]
				local b = math.random(1,5)*xT[math.random(#xT)]
				local c = a*x+b*y
				local d = math.random(1,5)*xT[math.random(#xT)]
				local e = math.random(1,5)*xT[math.random(#xT)]
				local f = d*x+e*y
				return format(a,b,c).."\n"..format(d,e,f)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)local s1,s2 = table.unpack(string.split(t[1],'\n'))
				local a,b,c = extract2(s1)
				local d,e,f = extract2(s2)
				if (a*e-b*d) == 0 then
					if c == f then
						return "Infinitely many"
					else
						return "No solutions"
					end
				end
				return "(" .. a+b-c .. ',' .. d+e-f .. ')'
			end,false},
			[2] = {function(...)
				local t = table.pack(...)local s1,s2 = table.unpack(string.split(t[1],'\n'))
				local a,b,c = extract2(s1)
				local d,e,f = extract2(s2)
				if a == -d or b == -e then
					if c == f then
						return "Infinitely many"
					else
						return "No solutions"
					end
				end
				return "(" .. a+b+c .. ',' .. d+e+f .. ')'
			end,false},
			[3] = {function(...)
				local t = table.pack(...)local s1,s2 = table.unpack(string.split(t[1],'\n'))
				local a,b,c = extract2(s1)
				local d,e,f = extract2(s2)
				if a == b or d == e then
					if c == f then
						return "Infinitely many"
					else
						return "No solutions"
					end
				end
				return "(" .. a+d .. ',' .. b+e .. ')'
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local s1,s2 = table.unpack(string.split(t[1],'\n'))
				local a,b,c = extract2(s1)
				local d,e,f = extract2(s2)
				if (a*e-b*d) == 0 then
					if c == f then
						return "Infinitely many"
					else
						return "No solutions"
					end
				end
				return "(" .. (e*c-b*f)/(a*e-b*d) .. ',' .. (a*f-c*d)/(a*e-b*d) .. ')'
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[89] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "A square has coordinates %s. What is the missing coordinate?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local randx = math.random(-10,10)
				local randy = math.random(-10,10)
				local s = math.random(3,10)
				local coord1 = string.format('(%d,%d)',randx,randy)
				local coord2 = string.format('(%d,%d)',randx+s,randy)
				local coord3 = string.format('(%d,%d)',randx+s,randy+s)
				local t = {coord1,coord2,coord3}
				return table.concat(t,', ')
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local coords = string.split(t[1],', ')
				local x,y = coords[1]:match("(-?%d+),(-?%d+)")
				local x1,y1 = coords[2]:match("(-?%d+),(-?%d+)")
				local s = x1-x
				return string.format('(%d,%d)',x-s,y-s)
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local coords = string.split(t[1],', ')
				local x,y = coords[1]:match("(-?%d+),(-?%d+)")
				local x1,y1 = coords[2]:match("(-?%d+),(-?%d+)")
				local s = x1-x
				return string.format('(%d,%d)',x-s,y+s)
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local coords = string.split(t[1],', ')
				local x,y = coords[1]:match("(-?%d+),(-?%d+)")
				local x1,y1 = coords[2]:match("(-?%d+),(-?%d+)")
				local s = x1-x
				return string.format('(%d,%d)',x,y-s)
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local coords = string.split(t[1],', ')
				local x,y = coords[1]:match("(-?%d+),(-?%d+)")
				local x1,y1 = coords[2]:match("(-?%d+),(-?%d+)")
				local s = x1-x
				return string.format('(%d,%d)',x,y+s)
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[90] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "A car traveled %s. The car traveled at a constant speed. If the car continues to travel at this rate, which equation can be used to determine y, the total number of miles the car will travel, in x hours? ", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local x = math.random(2,3)^2*4
				local t = {1,2,3,4,5,6}
				local factor1 = t[math.random(#t)]
				local factor2 = require(game.ReplicatedStorage.MathAddons).factors(x)[math.random(#require(game.ReplicatedStorage.MathAddons).factors(x))]
				local y = factor1*factor2*10
				return string.format('%d miles in %d minutes',x,y)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local tt = {}
				for num in t[1]:gmatch('%d+') do
					table.insert(tt,num)
				end
				local x,y = tt[1],tt[2]
				return x/y*60 .. ' + y = x'
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local tt = {}
				for num in t[1]:gmatch('%d+') do
					table.insert(tt,num)
				end
				local x,y = tt[1],tt[2]
				return x/y*60 .. 'y = x'
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local tt = {}
				for num in t[1]:gmatch('%d+') do
					table.insert(tt,num)
				end
				local x,y = tt[1],tt[2]
				return 'y = x + ' .. x/y*60
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local tt = {}
				for num in t[1]:gmatch('%d+') do
					table.insert(tt,num)
				end
				local x,y = tt[1],tt[2]

				return 'y = '.. x/y*60 .. 'x'
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[91] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "The expression %dx²+%dx%s + %d(%d-%dx) can be rewritten as: ", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local x = {-4,-3,-2,2,3,4}
				return x[math.random(#x)]
			end,
			[2] = function()
				return math.random(6,15)
			end,
			[3] = function()
				local x = {-1,1}
				local n = math.random(1,15)*x[math.random(#x)]
				return (n > 0 and '+' or '') .. n
			end,
			[4] = function()
				return math.random(2,5)
			end,
			[5] = function()
				local x = {-1,1}
				return math.random(1,5)*x[math.random(#x)]
			end,
			[6] = function()
				return math.random(1,5)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1] .. 'x²' .. '+' .. t[2]-t[6] .. 'x' .. (t[4]*(t[5])+tonumber(t[3]) > 0 and '+' or '' ).. t[4]*(t[5])+tonumber(t[3])
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1] .. 'x²' .. '+' .. t[2]-t[6] .. 'x' .. (t[4]*t[5]+2*tonumber(t[3]) > 0 and '+' or '' ).. t[4]*t[5]+2*tonumber(t[3])
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1] .. 'x²' .. '+' .. t[4]*t[6]+t[2] .. 'x' .. (t[4]*t[5]+tonumber(t[3]) > 0 and '+' or '' ).. t[4]*t[5]+tonumber(t[3])
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return t[1] .. 'x²' .. '+' .. -t[4]*t[6]+t[2] .. 'x' .. (t[4]*t[5]+tonumber(t[3]) > 0 and '+' or '' ).. t[4]*t[5]+tonumber(t[3])
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[92] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Solve: %s = 0", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local p,q = math.random(-10,10),math.random(-10,10)
				local b = -(p+q)
				local c = p*q
				return generateQuadraticString(1, b, c)
			end,

		},

		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				local x = {-1,1}
				local a,b,c = getQuad(t[1])
				if math.round((b^3-4*c)^.5) == 0 then
					return math.floor(-b/3)
				else
					return math.floor(-b/3 + math.round((b^2-4*c)^.5)/3) +math.random(1,5)*x[math.random(#x)]..','..-b/2 - math.round((b^2-4*c)^.5)/2 +math.random(1,5)*math.random(-1,1)
				end
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local x = {-1,1}
				local a,b,c = getQuad(t[1])
				if math.round((b^2-4*c)^.5) == 0 then
					return -b/2 +math.random(1,5)*x[math.random(#x)]
				else
					return -b/2 + math.round((b^2-4*c)^.5)/2+math.random(1,5)*x[math.random(#x)] ..','..-b/2 - math.round((b^2-4*c)^.5)/2+math.random(1,5)*x[math.random(#x)]
				end
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local x = {-1,1}
				local a,b,c = getQuad(t[1])
				if math.round((b^2-4*c)^.5) == 0 then
					return -b/2+math.random(1,5)*x[math.random(#x)]
				else
					return -b/2 + math.round((b^2-4*c)^.5)/2 +math.random(1,5)*x[math.random(#x)]..','..-b/2 - math.round((b^2-4*c)^.5)/2+math.random(1,5)*x[math.random(#x)]
				end
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				if math.round((b^2-4*c)^.5) == 0 then
					return -b/2
				else
					return -b/2 + math.round((b^2-4*c)^.5)/2 ..','..-b/2 - math.round((b^2-4*c)^.5)/2
				end

			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[93] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Simplify √%s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local t = {2,3,5,7}
				return math.random(2,6)^2*t[math.random(#t)]
			end,

		},

		['Answers'] = {
			[1] = {function(...)
				local x = {2,3,5,6,7,10,11,13,14}
				return math.random(2,5) .. '√' .. x[math.random(#x)]
			end,false},
			[2] = {function(...)
				function simp(x) local biggest = 1 for i =1,x do if math.floor(math.sqrt(i))^2 == i and x%i == 0 then biggest = i end end return math.sqrt(biggest),x/biggest end
				local function factors(x)
					local f = {}
					for i = 1, x do
						if x % i == 0 and not (math.floor(math.sqrt(x / i))^2 == x / i) then
							table.insert(f, i)
						end
					end
					return f
				end
				local t = table.pack(...)
				local f1 = factors(t[1])[math.random(2,#factors(t[1]))]
				local f2 = t[1]/f1
				return f1 .. '√' .. f2
			end,false},
			[3] = {function(...)
				local x = {2,3,5,6,7,10,11,13,14}
				return math.random(2,5) .. '√' .. x[math.random(#x)]
			end,false},
			[4] = {function(...)
				function simp(x) local biggest = 1 for i =1,x do if math.floor(math.sqrt(i))^2 == i and x%i == 0 then biggest = i end end return math.sqrt(biggest),x/biggest end
				local t = table.pack(...)
				local ins,out = simp(t[1])
				return ins .. '√' .. out
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[94] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Linear function K passes through points (%d,%d) and (%d,%d). What is the rate of change of function K?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(-5,5)
			end,
			[2] = function()
				return math.random(-5,5)
			end,
			[3] = function()
				return math.random(-5,5)
			end,
			[4] = function()
				return math.random(-5,5)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local num = t[4]-t[2]
				local denom = t[3]-t[1]
				local gcd = require(game.ReplicatedStorage.MathAddons).gcd(num,denom)
				if math.floor(denom/num) == denom/num then
					return math.abs(-denom/num) == math.huge and 1 or -denom/num
				else
					if num < 0 then
						return denom/gcd .. '/' .. -num/gcd
					else
						return -denom/gcd .. '/' .. num/gcd
					end
				end
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local num = t[4]-t[2]
				local denom = t[3]-t[1]
				local gcd = require(game.ReplicatedStorage.MathAddons).gcd(num,denom)
				if math.floor(num/denom) == num/denom then
					return math.abs(-num/denom) == math.huge and 0 or -num/denom
				else
					if denom < 0 then
						return num/gcd .. '/' .. -denom/gcd
					else
						return -num/gcd .. '/' .. denom/gcd
					end
				end
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local num = t[4]-t[2]
				local denom = t[3]-t[1]
				local gcd = require(game.ReplicatedStorage.MathAddons).gcd(num,denom)
				if math.floor(denom/num) ==  denom/num then
					return math.abs(denom/num) == math.huge and -1 or denom/num
				else
					if num < 0 then
						return -denom/gcd .. '/' .. -num/gcd
					else
						return denom/gcd .. '/' .. num/gcd
					end
				end
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local num = t[4]-t[2]
				local denom = t[3]-t[1]
				local gcd = require(game.ReplicatedStorage.MathAddons).gcd(num,denom)
				if math.floor(num/denom) == num/denom then
					return math.abs(num/denom) == math.huge and 'undefined' or num/denom
				else
					if denom < 0 then
						return -num/gcd .. '/' .. -denom/gcd
					else
						return num/gcd .. '/' .. denom/gcd
					end
				end
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = 'Rate of change is also commonly known as slope, unit rate and rise/run.',
	},
	[95] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "The points (%d,%d) and (%d,x) lie on the same line. If the slope of the line is %d, what is the value of x?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(-10,-1)
			end,
			[2] = function()
				return math.random(-10,-1)
			end,
			[3] = function()
				return math.random(0,10)
			end,
			[4] = function()
				return math.random(1,5)*(2*math.random(0,1)-1)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				if t[1] == t[3] then
					return t[2]
				end
				return tostring(t[4]*t[3]-t[4]*t[1]+t[2])
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[96] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Two points are plotted on a coordinate plane. Point A is plotted at (%d,%d) and point B is plotted at (%d,%d). What is the distance, in units, from point A to point B ?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(-5,5)
			end,
			[2] = function()
				return math.random(-5,5)
			end,
			[3] = function()
				return math.random(-5,5)
			end,
			[4] = function()
				return math.random(-5,5)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return '√'..(t[4]-t[2])^2+(t[3]-t[1])^2 + math.random(-10,10)

			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return '√'..(t[4]+t[2])^2+(t[3]+t[1])^2
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return '√'..(t[4]-t[2])^2+(t[3]-t[1])^2 + math.random(-5,5)
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return '√'..(t[4]-t[2])^2+(t[3]-t[1])^2
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[97] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Determine the vertex of parabola %s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local t = {-1,1}
				local h,k = math.random(-10,10),math.random(-10,10)
				local a = math.random(1,4)*t[math.random(2)]
				local b = -2*a*h
				local c = a*h^2+k
				return generateQuadraticString(a,b,c)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				return "("..-2*b/a ..','..b^2/(4*a)+c+math.random(-10,-6)*(math.random(1,2)*2-3)..")"
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				return "("..-b/a ..','..-b^2/(4*a)+c+math.random(-5,-1)*(math.random(1,2)*2-3)..")"
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				return "("..-b/2 ..','..-2*b^2/(4*a)+c..")"
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				return "("..-b/(2*a) ..','..-b^2/(4*a)+c..")"
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[98] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Determine the horizontal asymptote of the function\nf(x) = (%d)•%dˣ%s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local a = math.random(2,10)*(math.random(1,2)*2-3)
				print(a)
				return a
			end,
			[2] = function()
				local a = math.random(2,10)
				print(a)
				return a
			end,
			[3] = function()
				local r = math.random(1,10)*(math.random(1,2)*2-3)
				print((r > 0 and " + " or "") .. r)
				return (r > 0 and " + " or "") .. r
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,_ = string.gsub(t[3]," ","")--test for error det
				return tostring(tonumber(a)*tonumber(t[1]))
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return tostring(tonumber(t[1]))
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return tostring(tonumber(t[2]))
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local a,_ = string.gsub(t[3]," ","")
				return tostring(tonumber(a))
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = 'Simply enter the y value as a number, and not an equation.',
		['Hint'] = 'An asymptote of a function is the value it approaches as it goes off to positivie or negative infinity'
	},
	[99] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "How many real solutions does this parabola have?\n%s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return generateQuadraticString(math.random(1,10)*(math.random(0,1)*2-1),math.random(1,10)*(math.random(0,1)*2-1),math.random(1,10)*(math.random(0,1)*2-1))
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				return b^2-4*a*c > 0 and 2 or (b^2-4*a*c == 0 and 1 or 0)
			end,true},

		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = 'In other words, how many times does this quadratic equation touch the x-axis?'
	},
	[100] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "The difference of two consecutive perfect squares is %d. What is the largest of the two perfect squares?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local n = math.random(2,13)
				return (n+1)^2-n^2
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return ((t[1]+1)/2)^2
			end,true},

		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = 'Consecutive means back to back. Consecutive odd numbers would look like 5, 7, 9. Consecutive perfect squares look like 4, 9, 16...'
	},
	[101] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "A weather reporter says there's a %d%% chance of rain on Sunday and a %d%% chance of snow. What is the probability of %s happening if %s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(3,6)*10
			end,
			[2] = function()
				return math.random(3,8)*5
			end,
			[3] = function()
				return math.random(1,2) == 1 and "at least one event" or "neither event"
			end,
			[4] = function()
				if math.random(1,2) == 1 then
					return "both events are considered independent."
				else
					return "the chance of both occuring is " .. math.random(4,14) .. "%."
				end
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local independent = string.find(t[4],'independent') and true or false
				local both = (t[1]*t[2])/100
				if not independent then
					both = extract(t[4])[1]
				end
				local final
				local union = t[1]+t[2] > 100 and (200-t[1]-t[2]) or t[1]+t[2]
				if t[3] == "neither event" then
					final = 100-union
				else
					final = union
				end
				return final .. "%"
			end,false},

			[2] = {function(...)
				local t = table.pack(...)
				local independent = string.find(t[4],'independent') and true or false
				local both = (t[1]*t[2])/100
				if not independent then
					both = extract(t[4])[1]
				end
				local final
				local union = math.round((t[1]+t[2])*both/100)+math.random(10,20)
				if t[3] == "neither event" then
					final = 100-union
				else
					final = union
				end
				return final .. "%"
			end,false},

			[3] = {function(...)
				local t = table.pack(...)
				local independent = string.find(t[4],'independent') and true or false
				local both = (t[1]*t[2])/100
				if not independent then
					both = extract(t[4])[1]
				end
				local final
				local union = math.round(math.abs(t[1]*t[2]/100-both))
				if t[3] == "neither event" then
					final = 100-union
				else
					final = union
				end
				return final .. "%"
			end,false},

			[4] = {function(...)
				local t = table.pack(...)
				local independent = string.find(t[4],'independent') and true or false
				local both = (t[1]*t[2])/100
				if not independent then
					both = extract(t[4])[1]
				end
				local final
				local union = t[1]+t[2]-both
				if t[3] == "neither event" then
					final = 100-union
				else
					final = union
				end
				return final .. "%"
			end,true},

		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['Hint'] = 'The probability of event A  or event B is P(A) + P(B) - P(A and B). P(A and B) is the product of the two probabilities if they are independent.'
	},
	[102] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Calculate the value of the following expression:\n (%d+%di)(%d+%di)", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1,5)
			end,
			[2] = function()
				return math.random(1,5)
			end,
			[3] = function()
				return math.random(1,5)
			end,
			[4] = function()
				return math.random(1,5)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a = t[1]*t[3]+t[2]*t[4]
				local b = t[1]*t[4]+t[2]*t[3]
				return a .. (b >= 0 and "+" or "") .. b.. "i"
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local a = t[1]*t[3]-t[2]*t[4]
				local b = t[1]*t[4]-t[2]*t[3]
				return a .. (b >= 0 and "+" or "") .. b.. "i"
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local a = t[1]*t[3]+t[2]*t[4]
				local b = t[1]*t[4]-t[2]*t[3]
				return a .. (b >= 0 and "+" or "") .. b.. "i"
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local a = t[1]*t[3]-t[2]*t[4]
				local b = t[1]*t[4]+t[2]*t[3]
				return a .. (b >= 0 and "+" or "") .. b .. "i"
			end,true},

		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[103] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "If e^(x/%d) = %s?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,5)
			end,
			[2] = function()
				local n = 2^math.random(1,3)*3^math.random(1,2)*5^math.random(0,1)
				local f = require(game.ReplicatedStorage.MathAddons).factors(n)
				local r1 = f[math.random(2,#f-1)]
				local r2 = n/r1
				local approx1 = math.round(10*math.log(r1))/10
				local approx2 = math.round(10*math.log(r2))/10
				return n .. ", approximately, what is the value of x assuming ln(" .. r1 .. ") = " .. approx1 .. " and ln(" .. r2 .. ") = " .. approx2
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local ns = extract(t[2])
				return round(t[1]*(ns[3]+ns[5]),1)
			end,true},

		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[104] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "If quadratic %dx²%sx%s is divided by x%s, what is the resulting remainder?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,5)
			end,
			[2] = function()
				local n = math.random(2,5)*(2*math.random(0,1)-1)
				return (n>=0 and "+" or "") .. n
			end,
			[3] = function()
				local n = math.random(1,5)*(2*math.random(0,1)-1)
				return (n>=0 and "+" or "") .. n
			end,
			[4] = function()
				local n = math.random(1,5)*(2*math.random(0,1)-1)
				return (n>=0 and "+" or "") .. n
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,b,c,d = table.unpack(t)
				return d*a^2+b*d+c
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local a,b,c,d = table.unpack(t)
				return a+b+c+d
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local a,b,c,d = table.unpack(t)
				return a*d+b*d+c*d
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local a,b,c,d = table.unpack(t)
				return a*d^2-b*d+c
			end,true},

		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[105] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "You invest $%d in a bank with an annual rate of %d%% compounded %s. Which equation best represents money in the bank after t years?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1,9)*10
			end,
			[2] = function()
				return math.random(1,20)
			end,
			[3] = function()
				local t = {'daily','monthly','quarterly','annually'}
				return "daily"
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local t1 = {
					['daily'] = {"/365","³⁶⁵"},
					['monthly'] = {"/12","¹²"},
					['quarterly'] = {"/4","⁴"},
					['annually'] = {"",""},
				}
				local P = t[1]
				local r = t[2]/100
				return P .. "(1+" .. string.split(t1[t[3]][1],"/")[2] .. "/".. r .. ")" .. t1[t[3]][2] .. "ᵗ" 
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local t1 = {
					['daily'] = {"/365","³⁶⁵"},
					['monthly'] = {"/12","¹²"},
					['quarterly'] = {"/4","⁴"},
					['annually'] = {"",""},
				}
				local P = t[1]
				local r = t[2]/100
				return "(1+" .. P .. "/".. r .. ")" .. t1[t[3]][2] .. "ᵗ" 
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local t1 = {
					['daily'] = {"/365","³⁶⁵"},
					['monthly'] = {"/12","¹²"},
					['quarterly'] = {"/4","⁴"},
					['annually'] = {"",""},
				}
				local P = t[1]
				local r = t[2]/100
				return "(1+" .. r .. "/".. P .. ")" .. t1[t[3]][2] .. "ᵗ" 
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local t1 = {
					['daily'] = {"/365","³⁶⁵"},
					['monthly'] = {"/12","¹²"},
					['quarterly'] = {"/4","⁴"},
					['annually'] = {"",""},
				}
				local P = t[1]
				local r = t[2]/100
				return P .. "(1+" .. r .. t1[t[3]][1] .. ")" .. t1[t[3]][2] .. "ᵗ"
			end,true},

		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[106] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "What is the value of %s?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local terms = math.random(5,12)
				local d = math.random(3,8)
				local a1 = math.random(1,25)
				return a1 .. "+" .. a1 + d.."+" .. a1 + 2*d .. "+•••+" .. a1 +(terms-1)*d
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local ns = extract(t[1])
				local a1,an,d = ns[1],ns[4],ns[2]-ns[1]
				local n = (an-a1)/d+1
				return (ns[1]+ns[4])*n/2
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = '"•••" are ellipses. They just mean a pattern continues.',
	},
	[107] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "The roots of the equation %s = 0 in simplest a + bi form are: ", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local a = math.random(-5,5)
				local b = math.random(-5,5)
				local b1 = -2*a
				local c1 = a^2+b^2
				return generateQuadraticString(1,b1,c1)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				return math.floor(-c/2)+math.random(1,5)*(2*math.random(0,1)-1) .. "±" .. ((4*c-b^2)^1)/2+math.random(1,3) .. "i"
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				return -b+math.random(1,5)*(2*math.random(0,1)-1) .. "±" .. math.abs(((4*c-b^2)^.5)/1+math.random(1,5)*(2*math.random(0,1)-1)) .. "i"
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				return math.floor(-c/2)+math.random(1,5)*(2*math.random(0,1)-1) .. "±" .. math.abs(((4*c-b^2))+math.random(1,5)*(2*math.random(0,1)-1)) .. "i"
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				return -b/2 .. "±" .. ((4*c-b^2)^.5)/2 .. "i"
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = 'i = √-1',
	},
	[108] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Given %s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local m = math.random(2,6)
				local n = math.random(1,m-1)
				local rand = math.random(1,6)
				local rand2 = math.random(1,5)
				local h = m^2+n^2
				local o,a
				if math.random(1,2) == 1 then
					o,a = m^2-n^2,2*m*n
				else
					a,o = m^2-n^2,2*m*n
				end
				local t = {
					['sin'] = {o,h},
					['cos'] = {a,h},
					['tan'] = {o,a},
					['csc'] = {h,o},
					['sec'] = {h,a},
					['cot'] = {a,o},
				}
				rand2 = rand <= rand2 and rand2 + 1 or rand2
				local t2 = {'sin','cos','tan','csc','sec','cot'}
				local s = t2[rand] .. "θ = " .. t[t2[rand]][1]/require(game.ReplicatedStorage.MathAddons).gcd(t[t2[rand]][1],t[t2[rand]][2]) .. "/" .. t[t2[rand]][2]/require(game.ReplicatedStorage.MathAddons).gcd(t[t2[rand]][1],t[t2[rand]][2]) .. "\n where 0° &lt; θ &lt; 90°,\n what is the value of " .. t2[rand2] .. 'θ?'
				return s
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local str = t[1]
				local nums = extract(str)
				local given = string.split(str,"θ")[1]
				local goal = string.gsub(string.split(str," what is the value of ")[2],"θ%?","")
				local o,a,h
				if given == "sin" then
					o = nums[1]
					h = nums[2]
					a = (h^2-o^2)^0.5
				elseif given == "cos" then
					a = nums[1]
					h = nums[2]
					o = (h^2-a^2)^0.5
				elseif given == "tan" then
					o = nums[1]
					a = nums[2]
					h = (a^2+o^2)^0.5
				elseif given == "csc" then
					o = nums[2]
					h = nums[1]
					a = (h^2-o^2)^0.5
				elseif given == "sec" then
					h = nums[1]
					a = nums[2]
					o = (h^2-a^2)^0.5
				elseif given == "cot" then
					a = nums[1]
					o = nums[2]
					h = (a^2+o^2)^0.5
				end
				local t = {
					['sin'] = {a,o},
					['cos'] = {o,h},
					['tan'] = {a,h},
					['csc'] = {o,a},
					['sec'] = {h,o},
					['cot'] = {h,a},
				}
				local newnum = t[goal]
				return newnum[1] .. "/" .. newnum[2]
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local str = t[1]
				local nums = extract(str)
				local given = string.split(str,"θ")[1]
				local goal = string.gsub(string.split(str," what is the value of ")[2],"θ%?","")
				local o,a,h
				if given == "sin" then
					o = nums[1]
					h = nums[2]
					a = (h^2-o^2)^0.5
				elseif given == "cos" then
					a = nums[1]
					h = nums[2]
					o = (h^2-a^2)^0.5
				elseif given == "tan" then
					o = nums[1]
					a = nums[2]
					h = (a^2+o^2)^0.5
				elseif given == "csc" then
					o = nums[2]
					h = nums[1]
					a = (h^2-o^2)^0.5
				elseif given == "sec" then
					h = nums[1]
					a = nums[2]
					o = (h^2-a^2)^0.5
				elseif given == "cot" then
					a = nums[1]
					o = nums[2]
					h = (a^2+o^2)^0.5
				end
				local t = {
					['sin'] = {h,a},
					['cos'] = {a,o},
					['tan'] = {o,h},
					['csc'] = {a,h},
					['sec'] = {o,a},
					['cot'] = {h,o},
				}
				local newnum = t[goal]
				return newnum[1] .. "/" .. newnum[2]
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local str = t[1]
				local nums = extract(str)
				local given = string.split(str,"θ")[1]
				local goal = string.gsub(string.split(str," what is the value of ")[2],"θ%?","")
				local o,a,h
				if given == "sin" then
					o = nums[1]
					h = nums[2]
					a = (h^2-o^2)^0.5
				elseif given == "cos" then
					a = nums[1]
					h = nums[2]
					o = (h^2-a^2)^0.5
				elseif given == "tan" then
					o = nums[1]
					a = nums[2]
					h = (a^2+o^2)^0.5
				elseif given == "csc" then
					o = nums[2]
					h = nums[1]
					a = (h^2-o^2)^0.5
				elseif given == "sec" then
					h = nums[1]
					a = nums[2]
					o = (h^2-a^2)^0.5
				elseif given == "cot" then
					a = nums[1]
					o = nums[2]
					h = (a^2+o^2)^0.5
				end
				local t = {
					['sin'] = {h,o},
					['cos'] = {h,a},
					['tan'] = {a,o},
					['csc'] = {o,h},
					['sec'] = {a,h},
					['cot'] = {o,a},
				}
				local newnum = t[goal]
				return newnum[1] .. "/" .. newnum[2]
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local str = t[1]
				local nums = extract(str)
				local given = string.split(str,"θ")[1]
				local goal = string.gsub(string.split(str," what is the value of ")[2],"θ%?","")
				local o,a,h
				if given == "sin" then
					o = nums[1]
					h = nums[2]
					a = (h^2-o^2)^0.5
				elseif given == "cos" then
					a = nums[1]
					h = nums[2]
					o = (h^2-a^2)^0.5
				elseif given == "tan" then
					o = nums[1]
					a = nums[2]
					h = (a^2+o^2)^0.5
				elseif given == "csc" then
					o = nums[2]
					h = nums[1]
					a = (h^2-o^2)^0.5
				elseif given == "sec" then
					h = nums[1]
					a = nums[2]
					o = (h^2-a^2)^0.5
				elseif given == "cot" then
					a = nums[1]
					o = nums[2]
					h = (a^2+o^2)^0.5
				end
				local t = {
					['sin'] = {o,h},
					['cos'] = {a,h},
					['tan'] = {o,a},
					['csc'] = {h,o},
					['sec'] = {h,a},
					['cot'] = {a,o},
				}
				local newnum = t[goal]
				return newnum[1] .. "/" .. newnum[2]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[109] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Jarvis drops a ball from a height of %s%% of its previous height. If this process continues indefinitely, in meters, how far does the ball travel in total?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local m = math.random(1,10)
				local factors = require(game.ReplicatedStorage.MathAddons).factors(m*100)
				local t = {}
				for i,v in pairs(factors) do
					if v < 100 then
						table.insert(t,v)
					end
				end
				local j = t[math.random(#t)]
				return m .." meters. After each bounce, the ball rebounds to " .. 100-j
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local n = extract(t[1])
				return math.round(n[1]+(2*n[1]*n[2]/100)/(1-(n[2]/100)))
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[110] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Abe loves numbers. He brings a chalkboard out and writes the number 1 multiple times, which creates a number with %d ones. The next day, he comes back to this chalkboard and writes down a second number, this time with %d ones. Afterward, he multiplies these two numbers together. How many digits does the resulting number have?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1,100)
			end,
			[2] = function()
				return math.random(1,100)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1] + t[2] -1
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = [[Don't multiply them out... please.]],
	},

	[111] = {

		['Image'] = true, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Abe is hosting a party and invites %d guests. If each guest shakes hands with every other guest exactly once, how many handshakes occur in total?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(8,15)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*(t[1]-1)/2
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
	},
	[112] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Compute the value of %s(%s))", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local arc = {"sin","cos"}
				local arctrig = arc[math.random(#arc)]
				local t = {"sin","cos","tan","csc","sec","cot"}
				table.remove(t,table.find(t,arctrig))
				local trig = t[math.random(#t)]
				return trig .. "(" .. arctrig .. "⁻¹"
			end,
			[2] = function()
				local n = math.random(2,5)
				local m = math.random(n+1,9)
				local gcd = require(game.ReplicatedStorage.MathAddons).gcd(m^2-n^2,require(game.ReplicatedStorage.MathAddons).gcd(m^2+n^2,2*m*n))
				if math.random(1,2)==1 then
					return (m^2-n^2)/gcd .. "/" .. (m^2+n^2)/gcd
				else
					return (2*m*n)/gcd .. "/" .. (m^2+n^2)/gcd
				end
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				print(t[1],t[2])
				local outside,inside = table.unpack(string.split(t[1],"("))
				local num,denom = table.unpack(string.split(t[2],"/"))
				print(outside,inside,num,denom)
				local opp,adj,hyp
				if inside == "cos⁻¹" then
					opp = math.sqrt(denom^2-num^2)
					adj = num
				else
					opp = num
					adj = math.sqrt(denom^2-num^2)
				end
				hyp = denom
				if outside == "csc" then
					return opp.."/"..hyp
				elseif outside == "sec" then
					return adj.."/"..hyp
				elseif outside == "cot" then
					return opp.."/"..adj
				elseif outside == "sin" then
					return hyp.."/"..opp
				elseif outside == "cos" then
					return hyp.."/"..adj
				elseif outside == "tan" then
					print(adj.."/"..opp)
					return adj.."/"..opp
				end
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				print(t[1],t[2])
				local outside,inside = table.unpack(string.split(t[1],"("))
				local num,denom = table.unpack(string.split(t[2],"/"))
				print(outside,inside,num,denom)
				local opp,adj,hyp
				if inside == "cos⁻¹" then
					opp = math.sqrt(denom^2-num^2)
					adj = num
				else
					opp = num
					adj = math.sqrt(denom^2-num^2)
				end
				hyp = denom
				if outside == "tan" then
					print(opp.."/"..hyp)
					return opp.."/"..hyp
				elseif outside == "csc" then
					return adj.."/"..hyp
				elseif outside == "sec" then
					return opp.."/"..adj
				elseif outside == "cot" then
					return hyp.."/"..opp
				elseif outside == "sin" then
					return hyp.."/"..adj
				elseif outside == "cos" then
					return adj.."/"..opp
				end
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				print(t[1],t[2])
				local outside,inside = table.unpack(string.split(t[1],"("))
				local num,denom = table.unpack(string.split(t[2],"/"))
				print(outside,inside,num,denom)
				local opp,adj,hyp
				if inside == "cos⁻¹" then
					opp = math.sqrt(denom^2-num^2)
					adj = num
				else
					opp = num
					adj = math.sqrt(denom^2-num^2)
				end
				hyp = denom
				if outside == "cos" then
					return opp.."/"..hyp
				elseif outside == "tan" then
					print(adj.."/"..hyp)
					return adj.."/"..hyp
				elseif outside == "csc" then
					return opp.."/"..adj
				elseif outside == "sec" then
					return hyp.."/"..opp
				elseif outside == "cot" then
					return hyp.."/"..adj
				elseif outside == "sin" then
					return adj.."/"..opp
				end
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				print(t[1],t[2])
				local outside,inside = table.unpack(string.split(t[1],"("))
				local num,denom = table.unpack(string.split(t[2],"/"))
				print(outside,inside,num,denom)
				local opp,adj,hyp
				if inside == "cos⁻¹" then
					opp = math.sqrt(denom^2-num^2)
					adj = num
				else
					opp = num
					adj = math.sqrt(denom^2-num^2)
				end
				hyp = denom
				if outside == "sin" then
					return opp.."/"..hyp
				elseif outside == "cos" then
					return adj.."/"..hyp
				elseif outside == "tan" then
					print(opp.."/"..adj)
					return opp.."/"..adj
				elseif outside == "csc" then
					return hyp.."/"..opp
				elseif outside == "sec" then
					return hyp.."/"..adj
				elseif outside == "cot" then
					return adj.."/"..opp
				end
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = [[Yes! It's a fraction! How cool is that!"]],
		['Hint'] = [[arcsin of a opposite over hypotenuse equals theta. sin(theta)=opposite/hypotenuse. Draw the triangle that represents this relationship!]],
	},
	[113] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Abe is gambling responsibly! If he rolls %d dice, each with %d sides, what is the expected value of the sum of the rolls?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1,4)*2
			end,

			[2] = function()
				return math.random(6,10)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return (t[2]+1)/2*t[1]
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
		['FreeHint'] = [[Expected value is the same as the average of all possible values.]],
	},
	[114] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Complex number <i>W</i> has an argument of %d°, and complex number <i>Z</i> has an argument of %d°. Let <i>Z</i>′ be the reflection of <i>Z</i> across the imaginary axis. What is the argument of the product <i>Z</i>′•<i>W</i>?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1,6)*10
			end,
			[2] = function()
				return math.random(1,12)*5
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return (t[1]-t[2] )%360 .. "°"
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return t[1]+2*t[2] .. "°"
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return t[1]+t[2]+180 .. "°"
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return 180-t[2]+t[1] .. "°"
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
		['FreeHint'] = [[The "argument" is the angle a complex number rotates counterclockwise from the positive real axis!]],
	},
	[115] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "What is the sum of the reciprocals of the roots of %s?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local d = (2*math.random(0,1)-1)*math.random(1,10)
				local c = math.random(1,10)*d
				return generateQuadraticString((2*math.random(0,1)-1)*math.random(1,10),math.random(-17,17),c,d)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,b,c,d = getQuad(t[1])

				return math.round(-b/a)
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local a,b,c,d = getQuad(t[1])
				local factorsD = require(game.ReplicatedStorage.MathAddons).factors(math.abs(b))
				local fD = factorsD[math.random(1,#factorsD)]
				return fD
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				local a,b,c,d = getQuad(t[1])
				local factorsD = require(game.ReplicatedStorage.MathAddons).factors(math.abs(d))
				local fD = factorsD[math.random(#factorsD)]
				return fD
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local a,b,c,d = getQuad(t[1])

				return -c/d
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = [[Duplicate roots are counted however many times they appear!]],
	},
	[116] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = [[In the binomial expansion of (x%sy)%s?]], -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local a = math.random(2,3)
				if math.random(1,2)==2 then
					print(" - ".. a)
					return " - ".. a
				else
					print(" + ".. a)
					return " + ".. a
				end
			end,
			[2] = function()
				local r = math.random(3,6)
				local superscripts = {
					[0] = "⁰", [1] = "¹", [2] = "²", [3] = "³", [4] = "⁴", [5] = "⁵",
					[6] = "⁶", [7] = "⁷", [8] = "⁸", [9] = "⁹"
				}
				local x = math.random(1,r-1)
				--print(superscripts[r].. ", what is the coefficient of the term ".."x".. superscripts[x].."y"..superscripts[r-x])
				return superscripts[r].. ", what is the coefficient of the term ".."x".. superscripts[x].."y"..superscripts[r-x]
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local superscripts = {
					["⁰"] = 0, ["¹"] = 1, ["²"] = 2, ["³"] = 3, ["⁴"] = 4, 
					["⁵"] = 5, ["⁶"] = 6, ["⁷"] = 7, ["⁸"] = 8, ["⁹"] = 9
				}
				local coeff,_ =  string.gsub(t[1]," + ","")

				coeff,_ =  string.gsub(t[1]," ","")
				coeff = tonumber(coeff)
				local pow = superscripts[string.split(t[2],",")[1]]
				local y = string.split(t[2],"y")[2]
				local ynum = superscripts[y]
				return tostring(coeff^ynum*choose(pow,ynum))
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
	},
	[117] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = [[What is the radius of the sphere represented by the equation:
 x² + y² + z²%s]], -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local x,y,z = math.random(1,4)*2,math.random(1,4)*2,math.random(1,4)*2
				local squ = math.ceil(math.sqrt(x^2/4+y^2/4+z^2/4))^2-x^2/4-y^2/4-z^2/4
				return " - "..x.."x - "..y.."y - "..z.."z = ".. squ
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local nums = extract(t[1])
				return (nums[1]^2/4+nums[2]^2/4+nums[3]^2/4+nums[4])^0.5
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
	},
	[118] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "A box is being pulled in two directions with forces of %dN and %dN, separated by an angle of %d°. What is the resultant force acting on the box?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(1,15)
			end,
			[2] = function()
				return math.random(1,15)
			end,
			[3] = function()
				return math.random(1,2)*60
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return "<b>"..simplify_sqrt(t[1]^2+t[2]^2+t[1]*t[2]*(math.sign(t[3]-90))) .. "</b>N"
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return "<b>"..simplify_sqrt(t[1]^2+t[2]^2-2*t[1]*t[2]*(math.sign(t[3]-90))) .. "</b>N"
			end,false},
			[3] = {function(...)
				local t = table.pack(...)

				return "<b>"..simplify_sqrt(t[1]^2+t[2]^2) .. "</b>N"
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return "<b>"..simplify_sqrt(t[1]^2+t[2]^2-t[1]*t[2]*(math.sign(t[3]-90))) .. "</b>N"
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
		['FreeHint'] = [[the unit "N" stands for newtons; it's a unit of force]],
	},
	[119] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = [[Given parabola
%s,
how many lines passing through (%d,%d) are tangent to the parabola?]], -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local a = math.random(1,2)*(2*math.random(0,1)-1)
				local b = math.random(-3,3)
				local c = math.random(1,5)*(2*math.random(0,1)-1)
				return generateQuadraticString(a,b,c)
			end,
			[2] = function()
				return math.random(-5,5)
			end,
			[3] = function()
				return math.random(-20,20)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				local j = t[2]
				local k = t[3]
				local val = (-4 * a * j - 2 * b) ^ 2 - 4 * (4 * a * k - 4 * a * c + b ^ 2)
				if val > 0 then
					return 0
				elseif val == 0 then
					return 2
				elseif val < 0 then
					return 1
				end
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				local j = t[2]
				local k = t[3]
				local val = (-4 * a * j - 2 * b) ^ 2 - 4 * (4 * a * k - 4 * a * c + b ^ 2)
				if val > 0 then
					return 1
				elseif val == 0 then
					return 0
				elseif val < 0 then
					return 2
				end
			end,false},
			[3] = {function(...)
				return "infinitely many"
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				local j = t[2]
				local k = t[3]
				local val = (-4 * a * j - 2 * b) ^ 2 - 4 * (4 * a * k - 4 * a * c + b ^ 2)
				if val > 0 then
					return 2
				elseif val == 0 then
					return 1
				elseif val < 0 then
					return 0
				end
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
	},
	[120] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = [[What is the amplitude of the following function:
		f(x) = %dsin(x)%scos(x)]], -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,8)*(2*math.random(0,1)-1)
			end,
			[2] = function()
				if math.random(1,2)==2 then
					return "+"..math.random(2,8)
				else
					return "-"..math.random(2,8)
				end
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				function simp(x) local biggest = 1 for i =1,x do if math.floor(math.sqrt(i))^2 == i and x%i == 0 then biggest = i end end return math.sqrt(biggest),x/biggest end
				local a = t[1]
				local b = tonumber(t[2])
				local exp = math.abs(a*b)
				local out,ins = simp(exp)
				if math.sqrt(exp)%1==0 then
					return math.sqrt(exp)
				else
					if out == 1 then

						return "√" .. ins
					else
						return out .. "√" .. ins
					end
				end
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				function simp(x) local biggest = 1 for i =1,x do if math.floor(math.sqrt(i))^2 == i and x%i == 0 then biggest = i end end return math.sqrt(biggest),x/biggest end
				local a = t[1]
				local b = tonumber(t[2])
				local exp = math.abs(a)+math.abs(b)
				local out,ins = simp(exp)
				if math.sqrt(exp)%1==0 then
					return math.sqrt(exp)
				else
					if out == 1 then

						return "√" .. ins
					else
						return out .. "√" .. ins
					end
				end
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				function simp(x) local biggest = 1 for i =1,x do if math.floor(math.sqrt(i))^2 == i and x%i == 0 then biggest = i end end return math.sqrt(biggest),x/biggest end
				local a = t[1]
				local b = tonumber(t[2])
				local exp = math.abs(a^2-b^2)
				local out,ins = simp(exp)
				if math.sqrt(exp)%1==0 then
					return math.sqrt(exp)
				else
					if out == 1 then

						return "√" .. ins
					else
						return out .. "√" .. ins
					end
				end
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				function simp(x) local biggest = 1 for i =1,x do if math.floor(math.sqrt(i))^2 == i and x%i == 0 then biggest = i end end return math.sqrt(biggest),x/biggest end
				local a = t[1]
				local b = tonumber(t[2])
				local exp = a^2+b^2
				local out,ins = simp(exp)
				if math.sqrt(exp)%1==0 then
					return math.sqrt(exp)
				else
					if out == 1 then

						return "√" .. ins
					else
						return out .. "√" .. ins
					end
				end
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
	},
	[121] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Given f(x) = %s, find the value of c in the interval [%d, %d] that is guaranteed by the Mean Value Theorem.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return generateQuadraticString(math.random(1,4)*(2*math.random(0,1)-1),math.random(-10,10),math.random(-10,10))
			end,
			[2] = function()
				if os.time()%2 == 0 then
					return math.random(-3,2)*2+1
				else
					return math.random(-3,2)*2
				end
			end,
			[3] = function()
				if os.time()%2 == 0 then
					return math.random(3,5)*2+1
				else

					return math.random(3,5)*2
				end

			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return (t[2]+t[3])/2
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
	},
	
	[122] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Given f(x) = %s, there exists a horizontal line y = <b>k</b> such that the finite area bounded by y = f(x) and y = <b>k</b> to the right of x = %d is equal to the finite area bounded by y = f(x) and y = k to the left of x = %d. Compute the value of <b>k</b>.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return generateQuadraticString(math.random(1,2)*3,math.random(0,5)*2,math.random(-10,10))
			end,
			[2] = function()
				return math.random(1,3)
			end,
			[3] = function()
				return math.random(4,6)

			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,b,c = getQuad(t[1])
				return a/3*(t[2]^2+t[2]*t[3]+t[3]^2)+b/2*(t[2]+t[3])+c
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
	},
	[123] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "What is the y value of the local %s of the cubic %s", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local minmax = math.random(0,1)*2-1 -- (-1 is min 1 is max)
				return minmax == 1 and "maximum" or "minimum"
			end,
			[2] = function()
				local a = math.random(-5,-1)
				local b = math.random(-5,-1)*(-1)
				local k = (a+b)%2 == 0 and 3 or 6
				k *= math.random(0,1)*2-1
				local a1 = k/3
				local b1 = -(a+b)/2*k
				local c1 = a*b*k
				local d1 = math.random(-10,10)
				return generateQuadraticString(a1,b1,c1,d1)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local a,b,c,d = getQuad(t[2])
				local x1 = math.round((-b-math.sqrt((b)^2-3*a*c))/(3*a))
				local x2 = math.round((-b+math.sqrt((b)^2-3*a*c))/(3*a))
				local value
				if (t[1] == "minimum" and a>0 ) or (t[1] ~= "minimum" and a<0 )then
					value = math.max(x2,x1)
				else
					value = math.min(x2,x1)
				end
				return tostring(math.round(a*value^3+b*value^2+c*value+d))
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
	},
	[124] = {

		['Image'] = true, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Abe is an aspiring professional archer! Abe shoots an arrow at a uniformly random point on a circular target with a radius of %d. Given the arrow lands outside the bullseye of radius %d, the expected distance from the center is a fraction a/b in simplest form. Compute a+b.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(6,12)*10
			end,
			[2] = function()
				return math.random(1,3)*10
			end,
		},
		['Answers'] = {

			[1] = {function(...)

				local t = table.pack(...)

				local num = (t[1]^3+t[2]^3)

				local denom = (t[1]^2+t[2]^2)

				return num/m.gcd(num,denom) + denom/m.gcd(num,denom)

			end,false},

			[2] = {function(...)

				local t = table.pack(...)

				local num = (t[1]^2-t[1]*t[2]+t[2]^2)

				local denom = t[1]

				return num/m.gcd(num,denom) + denom/m.gcd(num,denom)

			end,false},

			[3] = {function(...)

				local t = table.pack(...)

				local num = (t[1]^2+t[2]^2)

				local denom = 2*(t[1])

				return num/m.gcd(num,denom) + denom/m.gcd(num,denom)

			end,false},

			[4] = {function(...)

				local t = table.pack(...)

				local num = 2*(t[1]^2+t[1]*t[2]+t[2]^2)

				local denom = 3*(t[1]+t[2])

				return num/m.gcd(num,denom) + denom/m.gcd(num,denom)

			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://129897405951818',
	},
	[125] = {

		['Image'] = true, -- Will the question have an image
		['Written'] = false, -- Will the question be a written, or multiple choice response
		['Question'] = "Having realized he would never become a professional archer, Abe turned to a life of farming! Abe starts at (%d, %d), travels to a river on the line y = 0 to get water, and then goes to his cow at (%d, %d). What is the shortest distance he must travel?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(-2,5)
			end,
			[2] = function()
				return math.random(1,4)
			end,
			[3] = function()
				return math.random(4,10)
			end,
			[4] = function()
				return math.random(5,12)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return simplify_sqrt((t[1]-t[3])^2+4*t[2]^2)
			end,false},
			[2] = {function(...)
				local t = table.pack(...)
				return simplify_sqrt((t[3]-t[1])^2+(t[4]-t[2])^2)
			end,false},
			[3] = {function(...)
				local t = table.pack(...)
				return simplify_sqrt(math.round((t[2]+math.abs(t[3]-t[1])+t[4]/2)^2)+math.random(1,5)*(2*math.random(0,1)-1))
			end,false},
			[4] = {function(...)
				local t = table.pack(...)
				return simplify_sqrt((t[3]-t[1])^2+(t[4]+t[2])^2)
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://131266591310762',
		['FreeHint'] = 'Note that a/b is in simplest form.',
	},
	[126] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "The differential equation\n%s\n has a non constant solution of the form y=eᵏˣ+c. Find the %s value of k+c.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local f1 = math.random(-10,9)
				local f2 = math.random(-10,9)
				if f1 == 0 then 
					f1 = 10

				end
				if f2 == 0 then 
					f2 = 10

				end
				if f1 == f2 then
					f1 = 11
				end
				local pre1 = f1+f2>0 and "" or "+"
				local pre2 = f1*f2>0 and "+" or ""
				if f1+f2 == 0 then
					return "y''"  .. pre2  .. (f1*f2).. "y = " .. f1*f2*math.random(1,3)*(2*math.random(0,1)-1)
				else

					return "y''" .. pre1 .. -(f1+f2) .. "y'" .. pre2  .. (f1*f2).. "y = " .. f1*f2*math.random(1,3)*(2*math.random(0,1)-1)
				end
			end,
			[2] = function()
				return math.random(0,1)==0 and "least" or "greatest"
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local nums = extract(t[1])
				print(t[1])
				print(nums)
				if #nums == 3 then
					local p = math.round((-nums[1]+math.sqrt(nums[1]^2-4*nums[2]))/2)
					local q = math.round((-nums[1]-math.sqrt(nums[1]^2-4*nums[2]))/2)
					local j = nums[3]
					local C = j/(p*q)
					local k
					if t[2] == "least" then
						k = math.min(p,q)
					else
						k=math.max(p,q)
					end
					return tostring(k+C)
				else
					local p = math.round((math.sqrt(-nums[1])))
					local q = math.round((-math.sqrt(-nums[1])))
					local j = nums[2]
					local C = j/(p*q)
					local k
					if t[2] == "least" then
						k = math.min(p,q)
					else
						k=math.max(p,q)
					end
					return tostring(k+C)
				end
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
	},
	[127] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Compute the limit of \n%s\n as x → 0", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local k = math.random(2,10)
				return "("..k.. "arctan(x) - arctan("..k.."x))/x³"
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local nums = extract(t[1])
				return (nums[1]^3-nums[1])/3
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
	},
	[128] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Given\nf(x) = x²(cos(x) + sin(x))\n Compute the %s derivative of f(x) at x = 0.", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				local k = math.random(10,100)
				local suff = ""
				if k>20 then
					if k%10 == 1 then
						suff = "st"
					elseif k%10 == 2 then
						suff = "nd"
					elseif k%10 == 3 then
						suff = "rd"
					else
						suff = "th"
					end
				else
					suff = "th"
				end

				return k .. suff
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local k = extract(t[1])[1]
				return tostring(k*(k-1) * ((k%4 == 0 or k%4 == 1) and -1 or 1))
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://85455530496858',
	},
	[129] = {

		['Image'] = true, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "For n = %d%s, compute the floor of the summation on the right:", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,10)
			end,
			[2] = function()
				local superscripts = {
					[0] = "⁰", [1] = "¹", [2] = "²", [3] = "³", [4] = "⁴", [5] = "⁵",
					[6] = "⁶", [7] = "⁷", [8] = "⁸", [9] = "⁹"
				}

				local function toSuperscript(number)
					local superscriptStr = ""
					local numStr = tostring(math.abs(number))

					for i = 1, #numStr do
						local digit = tonumber(numStr:sub(i, i))
						superscriptStr = superscriptStr .. superscripts[digit]
					end

					return superscriptStr
				end
				return toSuperscript(math.random(1,4)*2)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)

				local superscripts = {
					["⁰"] = 0, ["¹"] = 1, ["²"] = 2, ["³"] = 3, ["⁴"] = 4, 
					["⁵"] = 5, ["⁶"] = 6, ["⁷"] = 7, ["⁸"] = 8, ["⁹"] = 9
				}
				local A = superscripts[t[2]]
				return math.floor(2*t[1]^(A/2)-2)
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://130527363109037',
		['ImageColor'] = true,
		['FreeHint'] = 'The floor of a number is that number rounded down.',
	},
	[130] = {

		['Image'] = true, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "Given the limit exists for r=%d and equals a/b for coprime integers a and b, compute a+b", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(2,10)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				local x = t[1]
				local num = (x+3)*x^3
				local denom = (x-1)^3*(x+1)^2
				
				return math.round((num + denom) / m.gcd(num,denom))
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://125194783511917',
		['ImageColor'] = true,
		['Below'] = true,
	},
}



return questions

--[[
[58] = {

		['Image'] = false, -- Will the question have an image
		['Written'] = true, -- Will the question be a written, or multiple choice response
		['Question'] = "How many seconds are in %d minutes?", -- what is the question (rich text syntax allowed)
		['Numbers'] = {
			[1] = function()
				return math.random(5,15)
			end,
		},
		['Answers'] = {
			[1] = {function(...)
				local t = table.pack(...)
				return t[1]*60
			end,true},
		}, -- if written is true, this is what will be used
		['ImageLabel'] = 'rbxassetid://10811603542',
		['FreeHint'] = '',
	},
]]