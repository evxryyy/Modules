--[[
	ASCII:
	
	Basic way to convert numbers/string to binary or ASCII Number reprensentation
	
	Example:
	
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local ASCII = require(ReplicatedStorage:WaitForChild("ASCII"))
	print(ASCII.StrASCII("Hello World !")) -- {72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33}
	print(ASCII.ASCIIStr({72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33})) -- Hello World!
	
	Documentation::
		StrASCII : (string) -> 
			return a new table contain all ASCII number of the string 
			e.g (each char is a ASCII Number)
		ASCIIStr : ({number} | number) ->
			if you pass a number only not in a table it will return only the char represented in ASCII Formula
			e.g (72) -> H
			instead if a table is passed it will return a string of all the char represented in ASCII Formula
			e.g ({72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33}) -> Hello World!
			
		BinaryNumber : (number | {number}) ->
			if you pass a number only not in a table it will return the Binary Reprensentation in a single table.
			e.g (10) -> {1,0,1,0}
			instead if a table is passed it will return a table of table containing the Binary Reprensentation of each number
			e.g ({10,15}) -> {{1,0,1,0},{1,1,1,1}}
			
		BinaryToNumber : ({number} | {[number] : {number}}) ->
			if you pass a number only not in a table it will return the Integer Reprensentation of the all binary numbers
			e.g ({1,0,1,0}) -> 10
			Note: if you pass a table like this {[1] = {1,0,1,0},[2] = {1,0,1,0}} it will merge all number and return Integer Reprensentation.
			e.g {
				local t = {[1] = {1,0,1,0},[2] = {1,0,1,0}}
				BinaryToNumber(t) -> 170
			}
	::
]]

export type ASCII = {
	__index : (self : ASCII,k : string | number) -> ();
	StrASCII : (str : string) -> {number};
	ASCIIStr : (num : number | {number}) -> string;
	BinaryNumber : (num : number | {number}) -> buffer | {buffer};
	BinaryToNumber : (bits : buffer | {buffer}) -> number;
}

local function allocate(b : buffer,size : number)
	if(not size) then return end
	if(not b) then return end
	local targetSize = buffer.len(b)+size
	local new_buffer = buffer.create(targetSize)
	buffer.copy(new_buffer,0,b,0,buffer.len(b))
	return new_buffer
end

local function StrToASCIINums(str : string) : {number}
	assert(type(str) == "string","1st argument must be a string value")
	local _len = utf8.len(str)
	if(_len <= 0) then return {} end
	local nums = {}
	for i = 1,_len do
		local ascii_num = string.byte(str,i)
		table.insert(nums,ascii_num)
	end
	return nums
end

local function ASCIIToStr(num : number | {number}) : string
	assert(type(num) == "number" or type(num) == "table","1st argument must be a number or a an array of numbers")
	local str = ""
	if(type(num) == "number") then
		str = str .. string.char(num)
	elseif(type(num) == "table") then
		for i = 1,#num do
			if(type(num[i]) ~= "number") then continue end
			local extractFloat = math.modf(num[i])
			str = str .. string.char(extractFloat)
		end
	end
	return str
end

local function binaryNumber(num : number | {number}) : buffer | {buffer}
	assert(type(num) == "number" or type(num) == "table","1st argument must be a number or a an array of numbers")
	local bits = {}
	if(type(num) == "number") then
		local _bits = buffer.create(0)
		local _bits_offset = 0
		local rest = 0
		local extractFloat = math.modf(num)
		while extractFloat > 0 do
			rest = math.fmod(extractFloat,2)
			bits[#bits+1] = rest
			extractFloat = (extractFloat-rest) / 2
			task.wait()
		end
		local concat = table.concat(bits,"")
		local reverse = string.reverse(concat)
		table.clear(bits)
		for k = 1,#reverse do
			_bits = allocate(_bits,1)
			buffer.writebits(_bits,_bits_offset,1,tonumber(string.sub(reverse,k,k)))
			_bits_offset += 1
		end
		return _bits
	else
		for i = 1,#num do
			if(type(num[i]) ~= "number") then continue end
			local rest = 0
			local extractFloat = math.modf(num[i])
			table.insert(bits,{})
			while extractFloat > 0 do
				rest = math.fmod(extractFloat,2)
				bits[i][#bits[i]+1] = rest
				extractFloat = (extractFloat-rest) / 2
			end
			local concat = table.concat(bits[i],"")
			local reverse = string.reverse(concat)
			table.clear(bits[i])
			local stack = buffer.create(0)
			local stack_offset = 0
			for k = 1,#reverse do
				stack = allocate(stack,1)
				buffer.writebits(stack,stack_offset,1,tonumber(string.sub(reverse,k,k)))
				stack_offset += 1
			end
			bits[i] = stack
			task.wait()
		end
	end
	return bits
	
end

local function binaryToNumber(bits : buffer | {buffer}) : number
	assert(type(bits) == "table" or type(bits) == "buffer","1st argument must be a table")
	local binaryString = ""
	if(type(bits) == "table") then
		for i,binaryBuffer in ipairs(bits) do
			for k = 0,buffer.len(binaryBuffer)-1 do
				local extract_bit = math.modf(buffer.readbits(binaryBuffer,k,1))
				binaryString = binaryString .. tostring(extract_bit)
			end
		end
	elseif(type(bits) == "buffer") then
		for k = 0,buffer.len(bits)-1 do
			local extract_bit = math.modf(buffer.readbits(bits,k,1))
			binaryString = binaryString .. tostring(extract_bit)
		end
	end
	local num = 0
	local sum = 0
	binaryString = string.reverse(binaryString)
	for i = 1,#binaryString do
		num = string.sub(binaryString,i,i) == "1" and 1 or 0
		sum = sum + num * math.pow(2,i-1)
	end
	return sum
end

local module = {}
module.__index = module

module.StrASCII = StrToASCIINums;
module.ASCIIStr = ASCIIToStr;
module.BinaryNumber = binaryNumber;
module.BinaryToNumber = binaryToNumber;

return module :: ASCII
