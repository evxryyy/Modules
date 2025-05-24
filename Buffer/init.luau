--!strict

local Types = require(script.Types)

--//Buffer definitions
local offset

local MAXUINT8 = 255
local MAXUINT16 = 65535
local MAXUINT32 = 4294967295
local MAXUINT64 = 18014398509481984

local MININT8 = -128
local MAXINT8 = 127
local MININT16 = -32768
local MAXINT16 = 32767
local MININT32 = -2147483648
local MAXINT32 = 2147483647
local MININT64 = -9007199254740992
local MAXINT64 = 9007199254740992

--//

export type Buffer = {
    buffer : buffer,
    offset : number,
    allocate : (size : number) -> (),
    clean : (self : Buffer) -> nil,
    WriteU8 : (self : Buffer,value : Types.UnsignedInt8) -> nil,
    WriteI8 : (self : Buffer,value : Types.Int8) -> nil,
    WriteU16 : (self : Buffer,value : Types.UnsignedInt16) -> nil,
    WriteI16 : (self : Buffer,value : Types.Int16) -> nil,
    WriteU32 : (self : Buffer,value : Types.UnsignedInt32) -> nil,
    WriteI32 : (self : Buffer,value : Types.Int32) -> nil,
    WriteU64 : (self : Buffer,value : Types.UnsignedInt64) -> nil,
    WriteI64 : (self : Buffer,value : Types.Int64) -> nil,
    WriteF32 : (self : Buffer, value : Types.Float32) -> nil,
    WriteF64 : (self : Buffer, value : Types.Float64) -> nil,
    WriteString : (self : Buffer,value : Types.String,lenght : number) -> nil,
    WriteArray : (self : Buffer,value : Types.Array<{any}>,types : Types.Array<string>) -> nil,
    WriteBool1 : (self : Buffer,value : Types.Bool1<{any}>) -> nil,
    ReadU8 : (self : Buffer,offset : number | nil) -> number,
    ReadI8 : (self : Buffer,offset : number | nil) -> number,
    ReadU16 : (self : Buffer,offset : number | nil) -> number,
    ReadI16 : (self : Buffer,offset : number | nil) -> number,
    ReadU32 : (self : Buffer,offset : number | nil) -> number,
    ReadI32 : (self : Buffer,offset : number | nil) -> number,
    ReadU64 : (self : Buffer,offset : number | nil) -> number,
    ReadI64 : (self : Buffer,offset : number | nil) -> number,
    ReadString : (self : Buffer,offset : number | nil,lenght : number) -> string,
    ReadBool1 : (self : Buffer,offset : number | nil) -> {boolean},
}

local function allocate(b : buffer,size : number) : any
    if(not size) then return end
    if(not b) then return end
    local targetSize = buffer.len(b)+size
    local new_buffer = buffer.create(targetSize)
    buffer.copy(new_buffer,0,b,0,buffer.len(b))
    return new_buffer
end

local function WriteU8(b : buffer,offset : number,value : number) : any
    if(not b or not value) then return end
    value = math.clamp(value,0,MAXUINT8)
    buffer.writeu8(b,offset,value)
    return b
end

local function WriteU16(b : buffer,offset : number,value : number) : any
    if(not b or not value) then return end
    value = math.clamp(value,0,MAXUINT16)
    buffer.writeu16(b,offset,value)
    return b
end

local function WriteU32(b : buffer,offset : number,value : number) : any
    if(not b or not value) then return end
    value = math.clamp(value,0,MAXUINT32)
    buffer.writeu32(b,offset,value)
    return b
end

local function WriteU64(b : buffer,offset : number,value : number) : any
    if(not b or not value) then return end
    value = math.clamp(value,0,MAXUINT64)
    buffer.writef64(b,offset,value)
    return b
end

local function WriteI8(b : buffer,offset : number,value : number) : any
    if(not b or not value) then return end
    value = if(value < MININT8) then 0 elseif(value > MAXINT8) then 0 else value
    buffer.writei8(b,offset,value)
    return b
end

local function WriteI16(b : buffer,offset : number,value : number) : any
    if(not b or not value) then return end
    value = if(value < MININT16) then 0 elseif(value > MAXINT16) then 0 else value
    buffer.writei16(b,offset,value)
    return b
end

local function WriteI32(b : buffer,offset : number,value : number) : any
    if(not b or not value) then return end
    value = if(value < MININT32) then 0 elseif(value > MAXINT32) then 0 else value
    buffer.writei32(b,offset,value)
    return b
end

local function WriteI64(b : buffer,offset : number,value : number) : any
    if(not b or not value) then return end
    value = if(value < MININT64) then 0 elseif(value > MAXINT64) then 0 else value
    buffer.writef64(b,offset,value)
    return b
end

local function WriteF32(b : buffer,offset : number,value : number) : any
    if(not b or not value) then return end
    buffer.writef32(b,offset,value)
    return b
end

local function WriteF64(b : buffer,offset : number,value : number) : any
    if(not b or not value) then return end
    buffer.writef64(b,offset,value)
    return b
end

local function WriteString(b : buffer,offset : number, value : string,lenght : number) : any
    if(not b or not value) then return end
    if(not lenght) then lenght = #value end
    buffer.writestring(b,offset,value,lenght)
    return b
end

local function WriteBool(b : buffer,offset : number,value : any)
    if(not b) then return end
    buffer.writei8(b,offset,if(value) then 1 else 0)
    return b
end


local BufferModule = {}
local BufferPrototype = {}
BufferPrototype.__index = BufferPrototype
BufferPrototype.__newindex = function(t,k,v)
    warn(("Buffer ::%s is not a valid member"):format(k))
end

function BufferModule.new(size : number)
    if(not size) then size = 0 end
    local self = {
        buffer = buffer.create(size),
        offset = 0
    } :: Buffer
    setmetatable(self,BufferPrototype)
    return self
end

function BufferPrototype.allocate(self : Buffer,size : number)
    if(not self) then return end
    self.buffer = allocate(self.buffer,size)
    return self :: Buffer
end

--//Writers

BufferPrototype.WriteU8 = function(self : Buffer,value : number)
    if(not self or not self.buffer) then return end
    if(self.offset+1 >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,1) end
    self.buffer = WriteU8(self.buffer,self.offset,value)
    self.offset += 1
end

BufferPrototype.WriteU16 = function(self : Buffer,value : number)
    if(not self or not self.buffer) then return end
    if(self.offset+2 >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,2) end
    self.buffer = WriteU16(self.buffer,self.offset,value)
    self.offset += 2
end

BufferPrototype.WriteU32 = function(self : Buffer,value : number)
    if(not self or not self.buffer) then return end
    if(self.offset+4 >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,4) end
    self.buffer = WriteU32(self.buffer,self.offset,value)
    self.offset += 4
end

BufferPrototype.WriteU64 = function(self : Buffer,value : number)
    if(not self or not self.buffer) then return end
    if(self.offset+8 >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,8) end
    self.buffer = WriteU64(self.buffer,self.offset,value)
    self.offset += 8
end

BufferPrototype.WriteI8 = function(self : Buffer,value : number)
    if(not self or not self.buffer) then return end
    if(self.offset+1 >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,1) end
    self.buffer = WriteI8(self.buffer,self.offset,value)
    self.offset += 1
end

BufferPrototype.WriteI16 = function(self : Buffer,value : number)
    if(not self or not self.buffer) then return end
    if(self.offset+2 >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,2) end
    self.buffer = WriteI16(self.buffer,self.offset,value)
    self.offset += 2
end

BufferPrototype.WriteI32 = function(self : Buffer,value : number)
    if(not self or not self.buffer) then return end
    if(self.offset+4 >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,4) end
    self.buffer = WriteI32(self.buffer,self.offset,value)
    self.offset += 4
end

BufferPrototype.WriteI64 = function(self : Buffer,value : number)
    if(not self or not self.buffer) then return end
    if(self.offset+8 >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,8) end
    self.buffer = WriteI64(self.buffer,self.offset,value)
    self.offset += 8
end

BufferPrototype.WriteF32 = function(self : Buffer,value : number)
    if(not self or not self.buffer) then return end
    if(self.offset+4 >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,4) end
    self.buffer = WriteF32(self.buffer,self.offset,value)
    self.offset += 4
end

BufferPrototype.WriteF64 = function(self : Buffer,value : number)
    if(not self or not self.buffer) then return end
    if(self.offset+8 >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,8) end
    self.buffer = WriteF64(self.buffer,self.offset,value)
    self.offset += 8
end

BufferPrototype.WriteString = function(self : Buffer,value : string,lenght : number)
    if(not self or not self.buffer) then return end
    if(self.offset+lenght or #value >= buffer.len(self.buffer) or lenght >= buffer.len(self.buffer)) then self.buffer = allocate(self.buffer,lenght or #value) end
    self.buffer = WriteString(self.buffer,self.offset,value,lenght)
    self.offset += lenght or #value
end

BufferPrototype.WriteArray = function(self : Buffer,v : Types.Array<{any}>,t : Types.Array<string>)
    if(not self or not self.buffer) then return end
    local values,types = v,t
    if(not values or not types) then
        return self
    end
    if(type(values) ~= "table" or type(types) ~= "table") then warn("v and t must be table") end
    if(type(values) == "table") then
        for i,value in pairs(values) do
            if(type(value) == "table") then 
                local format_message = `Buffer.WriteArray :: values({(value)}) can't write array in a array`
                warn(format_message)
                continue
            end
            local vtype = types[i] :: string
            if(BufferPrototype["Write"..vtype]) then
                if(type(values[i]) == "string") then
                    BufferPrototype["Write"..vtype](self,values[i],if(type(values[i]) == "string") then #values[i] else 0)
                else
                    BufferPrototype["Write"..vtype](self,values[i])
                end
            else
                if(type(value) == "table") then
                    warn("overwrite array detected skiping this array")
                else
                    warn(("type ::%s doesn't exist skiping this value"):format(vtype))
                end
            end
        end
    end
    return self
end

BufferPrototype.WriteBool1 = function(self : Buffer, values : Types.Bool1<{any}>)
    if(not self or not self.buffer) then return end
    for i = 1,8 do buffer.writebits(self.buffer,self.offset+i-1,1,if(values[i]) then 1 else 0) end
    self.offset += 8
end

--//Readers:

BufferPrototype.ReadU8 = function(self : Buffer,offset : number | nil) : number | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        return buffer.readu8(self.buffer,self.offset-1)
    else
        return buffer.readu8(self.buffer,offset)
    end
end

BufferPrototype.ReadI8 = function(self : Buffer,offset : number | nil) : number | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        return buffer.readi8(self.buffer,self.offset-1)
    else
        return buffer.readi8(self.buffer,offset)
    end
end

BufferPrototype.ReadU16 = function(self : Buffer,offset : number | nil) : number | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        return buffer.readu16(self.buffer,self.offset-1)
    else
        return buffer.readu16(self.buffer,offset)
    end
end

BufferPrototype.ReadI16 = function(self : Buffer,offset : number | nil) : number | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        return buffer.readi16(self.buffer,self.offset-1)
    else
        return buffer.readi16(self.buffer,offset)
    end
end

BufferPrototype.ReadU32 = function(self : Buffer,offset : number | nil) : number | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        return buffer.readu32(self.buffer,self.offset-1)
    else
        return buffer.readu32(self.buffer,offset)
    end
end

BufferPrototype.ReadI32 = function(self : Buffer,offset : number | nil) : number | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        return buffer.readi32(self.buffer,self.offset-1)
    else
        return buffer.readi32(self.buffer,offset)
    end
end

BufferPrototype.ReadU64 = function(self : Buffer,offset : number | nil) : number | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        return buffer.readf64(self.buffer,self.offset-1)
    else
        return buffer.readf64(self.buffer,offset)
    end
end

BufferPrototype.ReadI64 = function(self : Buffer,offset : number | nil) : number | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        return buffer.readf64(self.buffer,self.offset-1)
    else
        return buffer.readf64(self.buffer,offset)
    end
end

BufferPrototype.ReadF32 = function(self : Buffer,offset : number | nil) : number | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        return buffer.readf32(self.buffer,self.offset-1)
    else
        return buffer.readf32(self.buffer,offset)
    end
end

BufferPrototype.ReadF64 = function(self : Buffer,offset : number | nil) : number | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        return buffer.readf64(self.buffer,self.offset-1)
    else
        return buffer.readf64(self.buffer,offset)
    end
end

BufferPrototype.ReadString = function(self : Buffer,offset : number | nil,lenght : number) : string | nil
    if(not self or not self.buffer) then return end
    if(not lenght) then return end
    if(not offset) then
        return buffer.readstring(self.buffer,(self.offset-(lenght)),lenght)
    else
        return buffer.readstring(self.buffer,offset,lenght)
    end
end

BufferPrototype.ReadBool1 = function(self : Buffer,offset : number | nil) : {boolean} | nil
    if(not self or not self.buffer) then return end
    if(not offset) then
        local bools = {}
        local targetOffset = self.offset - 8
        for i = 0,7 do bools[i+1] = (buffer.readbits(self.buffer,targetOffset+i,1) == 1) end
        return bools
    else
        local bools = {}
        local targetOffset = offset - 8
        for i = 0,7 do bools[i+1] = (buffer.readbits(self.buffer,targetOffset+i,1) == 1) end
        return bools
    end
end

return BufferModule
