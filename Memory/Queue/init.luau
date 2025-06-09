local RunService = game:GetService("RunService")
if(RunService:IsClient()) then error("Queue should only be required from a server script") end

local MemoryStoreService = game:GetService("MemoryStoreService")

local Types = require(script.Types)

local Constructor = {}
Constructor.__index = Constructor

local queue = {}
queue.__index = queue
queue.__newindex = function(t,k,v)
	warn(`Can't set Queue::{k} (not a valid member)`)
end

function Constructor.new<Queue>(NameOfQueue : string,InvisibleTimeOut : number) : Types.Queue
	local __QueueObject = MemoryStoreService:GetQueue(NameOfQueue,InvisibleTimeOut)
	local self = setmetatable({
		__QueueObjectData = __QueueObject,
		__QueueInvisibleSize = __QueueObject:GetSizeAsync(false),	
		__QueueSize = __QueueObject:GetSizeAsync(true),
		__QueueOffset = 0
	},queue)
	return self :: Types.Queue
end

function queue.ISize(self)
	return self.__QueueInvisibleSize
end

function queue.Size(self)
	return self.__QueueSize
end

function queue.Offset(self)
	return self.__QueueOffset
end

function queue.Add(self : Types.Queue,itemToAdd : Types.ValidItem,expiration : number,priority : number) : Types.WriterReturnedValues
	if(not self) then return end
	if(not self.__QueueObjectData) then return end
	self.__QueueObjectData:AddAsync(itemToAdd,expiration,priority)
	self.__QueueOffset += 1
	self.__QueueInvisibleSize = self.__QueueObjectData:GetSizeAsync(false)
	self.__QueueSize = self.__QueueObjectData:GetSizeAsync(true)
	local data , id = self.__QueueObjectData:ReadAsync(self.__QueueOffset,false,-1)
	return {
		AddedObject = itemToAdd,
		Expiration = expiration,
		Priority = priority,
		ReadedData = {table.unpack(data,1,#data),ID = id}
	}
end

function queue.Read(self : Types.Queue,offset : number,readAll : boolean,waitTime : number?) : Types.ReaderReturnedValues
	if(not self) then return end
	if(not self.__QueueObjectData) then return end
	local data , id = self.__QueueObjectData:ReadAsync(self.__QueueOffset,readAll,waitTime)
	return {table.unpack(data,1,#data),Id = id}
end

function queue.Remove(self : Types.Queue,ItemId : string) : boolean | unknown
	if(not self or not ItemId) then return end
	if(not self.__QueueObjectData) then return end
	self.__QueueObjectData:RemoveAsync(ItemId)
	self.__QueueInvisibleSize = self.__QueueObjectData:GetSizeAsync(false)
	self.__QueueSize = self.__QueueObjectData:GetSizeAsync(true)
	return true
end

function queue.Destroy(self : Types.Queue) : ()
	if(not self) then return end
	if(not self.__QueueObjectData) then return end
	self.__QueueObjectData:Destroy()
	table.clear(self)
	setmetatable(self,nil)
end

--//Size/Offset alias
queue.ExcludeInvisibleSize = queue.Size
queue.IncludeInvisibleSize = queue.ISize
queue.QueueOffset = queue.Offset

--//Add alias
queue.AddAsync = queue.Add
queue.AddItem = queue.Add
queue.AddTemp = queue.Add

--//Read alias
queue.ReadAsync = queue.Read
queue.ReadItem = queue.Read
queue.ReadTemp = queue.Read

--//Remove alias
queue.RemoveAsync = queue.Remove
queue.RemoveItem = queue.Remove
queue.RemoveData = queue.Remove

--//Destroy alias
queue.DestroyQueue = queue.Destroy
queue.RemoveQueue = queue.Destroy

return Constructor
