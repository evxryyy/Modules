local RunService = game:GetService("RunService")
if(RunService:IsClient()) then error("HashMap should only be required from a server script") end

local MemoryStoreService = game:GetService("MemoryStoreService")

local Types = require(script.Types)

local Constructor = {}

local hashMap = {}
hashMap.__index = hashMap
hashMap.__newindex = function(t,k,v)
	warn(`Can't set HashMap::{k} (not a valid member)`)
end

function Constructor.new<Hashmap>(NameOfHashmap : string) : Types.HashMap | unknown
	if(not NameOfHashmap) then return end
	local HashmapInstance = MemoryStoreService:GetHashMap(NameOfHashmap)
	local self = setmetatable({
		__HashMapData = HashmapInstance
	},hashMap)
	return self
end

function hashMap.Set(self,key : string | number,value : any,expiration : number,sortKey : any) : boolean & Types.ValidItem
	if(not self or not self.__HashMapData) then return false , false end
	local isSetResult = self.__HashMapData:SetAsync(key,value,expiration,sortKey)
	return isSetResult and if(isSetResult == true) then self.__HashMapData:GetAsync(key)	else nil
end

function hashMap.Get(self,key : string | number) : {any} | unknown
	if(not self or not self.__HashMapData) then return end
	return self.__HashMapData:GetAsync(key)
end

function hashMap.Update(self,key : string | number,callback : () -> (),expiration : number) : Types.ValidItem | unknown
	if(not self or not self.__HashMapData) then return end
	local state,result = pcall(function(...) 
		local updateResult = self.__HashMapData:UpdateAsync(key,callback,expiration)
		if(updateResult) then
			local tbl = {}
			tbl.UpdateResult = updateResult
		end
		return updateResult
	end)
	return state,result
end

function hashMap.RequestList(self,ReadCount : number)
	if(not self or not self.__HashMapData) then return end
	if(not ReadCount) then ReadCount = 200 end
	if(not ReadCount) then ReadCount = 200 end
	if(ReadCount > 200) then ReadCount = 200 elseif(ReadCount <= 0) then ReadCount = 1 end
	local result = {}
	local pages = self.__HashMapData:ListItemsAsync(ReadCount)
	while (pages.IsFinished == false) do
		for _, v in pairs(pages:GetCurrentPage()) do
			table.insert(result,v)
			warn(v)
		end
		pages:AdvanceToNextPageAsync()
	end
	return result
end

function hashMap.Remove(self, key : string | number) : ()
	if(not self or not self.__HashMapData) then return end
	self.__HashMapData:RemoveAsync(key)
end

function hashMap.Destroy(self) : ()
	if(not self or not self.__HashMapData) then return end
	self.__HashMapData:Destroy()
	table.clear(self)
	setmetatable(self,nil)
end

--//Writers alias
hashMap.Add = hashMap.Set
hashMap.SetItem = hashMap.Set
hashMap.AddItem = hashMap.Set
hashMap.SetAsync = hashMap.Set
hashMap.SetTemp = hashMap.Set
hashMap.AddTemp = hashMap.Set
hashMap.AddAsync = hashMap.Set

--//Gets alias
hashMap.GetAsync = hashMap.Get
hashMap.get = hashMap.Get
hashMap.getAsync = hashMap.Get

--//Update alias
hashMap.UpdateAsync = hashMap.Update
hashMap.Async = hashMap.Update

--//Remove alias
hashMap.RemoveAsync = hashMap.Remove
hashMap.remove = hashMap.Remove

--//Destroy alias
hashMap.DestroyAsync = hashMap.Destroy
hashMap.DestroyHashMap = hashMap.Destroy
hashMap.RemoveHashMap = hashMap.Destroy

return Constructor
