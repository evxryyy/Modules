local RunService = game:GetService("RunService")
if(RunService:IsClient()) then error("SortedMap should only be required from a server script") end

local MemoryStoreService = game:GetService("MemoryStoreService")

local Types = require(script.Types)
local Hashmap = require(script.Parent.HashMap)

local Constructor = {}

local sortedMap = {}
sortedMap.__index = sortedMap
sortedMap.__newindex = function(t,k,v)
	warn(`Can't set SortedMap::{k} (not a valid member)`)
end

function Constructor.new<SortedMap>(NameOfSortedMap : string) : Types.SortedMap
	local SortedMapObject = MemoryStoreService:GetSortedMap(NameOfSortedMap)
	local self = setmetatable({
		__SortedMapData = SortedMapObject,
		__Size = SortedMapObject:GetSizeAsync(),
		__HashmapClass = Hashmap.new(NameOfSortedMap)
	},sortedMap)
	return self
end

function sortedMap.Set(self,key : string | number,value : any,expiration : number,sortKey : any) : boolean & Types.ValidItem
	if(not self or not self.__SortedMapData) then return false , false end
	local isSetResult = self.__SortedMapData:SetAsync(key,value,expiration,sortKey)
	self.__HashmapClass:Set(key,value,expiration)
	self.__Size = self.__SortedMapData:GetSizeAsync()
	return isSetResult and if(isSetResult == true) then self.__SortedMapData:GetAsync(key)	else nil
end

function sortedMap.Get(self,key : string | number) : {any} | unknown
	if(not self or not self.__SortedMapData) then return end
	return self.__SortedMapData:GetAsync(key)
end

function sortedMap.Update(self,key : string | number,callback : () -> (),expiration : number) : Types.ValidItem | unknown
	if(not self or not self.__SortedMapData) then return end
	local state,result = pcall(function(...) 
		local updateResult = self.__SortedMapData:UpdateAsync(key,callback,expiration)
		self.__HashmapClass:Update(key,callback,expiration)
		if(updateResult) then
			local tbl = {}
			tbl.UpdateResult = updateResult
		end
		self.__Size = self.__SortedMapData:GetSizeAsync()
		return updateResult
	end)
	return state,result
end

function sortedMap.RequestList(self,ReadCount : number)
	if(not self or not self.__SortedMapData) then return end
	if(not ReadCount) then ReadCount = 200 end
	if(not ReadCount) then ReadCount = 200 end
	if(ReadCount > 200) then ReadCount = 200 elseif(ReadCount <= 0) then ReadCount = 1 end
	return self.__HashmapClass:RequestList(ReadCount)
end

function sortedMap.RequestListedRange(self,direction : Enum.SortDirection,count : number,exclusiveLowerBound : Types.Bound,exclusiveUpperBound : Types.Bound)
	if(not self or not self.__SortedMapData) then return end
	if(not direction) then direction = Enum.SortDirection.Ascending end
	if(not count) then count = 200 end
	if(count > 200) then count = 200 elseif(count <= 0) then count = 1 end
	local rangeData = self.__SortedMapData:GetRangeAsync(direction,count,exclusiveLowerBound,exclusiveUpperBound)
	return rangeData
end

function sortedMap.Remove(self, key : string | number) : ()
	if(not self or not self.__SortedMapData) then return end
	self.__HashmapClass:Remove(key)
	self.__SortedMapData:RemoveAsync(key)
end

function sortedMap.Destroy(self) : ()
	if(not self or not self.__SortedMapData) then return end
	self.__HashmapClass:Destroy()
	self.__SortedMapData:Destroy()
	table.clear(self)
	setmetatable(self,nil)
end

--//Writers alias
sortedMap.Add = sortedMap.Set
sortedMap.SetItem = sortedMap.Set
sortedMap.AddItem = sortedMap.Set
sortedMap.SetAsync = sortedMap.Set
sortedMap.SetTemp = sortedMap.Set
sortedMap.AddTemp = sortedMap.Set
sortedMap.AddAsync = sortedMap.Set

--//Gets alias
sortedMap.GetAsync = sortedMap.Get
sortedMap.get = sortedMap.Get
sortedMap.getAsync = sortedMap.Get

--//Update alias
sortedMap.UpdateAsync = sortedMap.Update
sortedMap.Async = sortedMap.Update

--//Remove alias
sortedMap.RemoveAsync = sortedMap.Remove
sortedMap.remove = sortedMap.Remove

--//Destroy alias
sortedMap.DestroyAsync = sortedMap.Destroy
sortedMap.DestroySortedMap = sortedMap.Destroy
sortedMap.RemoveSortedMap = sortedMap.Destroy

return Constructor
