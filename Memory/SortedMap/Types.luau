export type SortedMap = {
	--//Properties
	__SortedMapData : MemoryStoreSortedMap,
	__Size : number,
	--//Writers
	Set : (self : SortedMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	Add : (self : SortedMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	SetItem : (self : SortedMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	AddItem : (self : SortedMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	SetAsync : (self : SortedMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	SetTemp : (self : SortedMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	AddTemp : (self : SortedMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	AddAsync : (self : SortedMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	--//Gets
	Get : (self : SortedMap,key : string | number) -> {ValidItem} | unknown,
	GetAsync : (self : SortedMap,key : string | number) -> {ValidItem} | unknown,
	get : (self : SortedMap,key : string | number) -> {ValidItem} | unknown,
	getAsync : (self : SortedMap,key : string | number) -> {ValidItem} | unknown,
	--//Updates
	Update : (self : SortedMap, key : string | number, callback : () -> (),expiration : number) -> {ValidItem} | unknown,
	UpdateAsync : (self : SortedMap, key : string | number, callback : () -> (),expiration : number) -> {ValidItem} | unknown,
	Async : (self : SortedMap, key : string | number, callback : () -> (),expiration : number) -> {ValidItem} | unknown,
	--//Listeds
	RequestList : (self : SortedMap,ReadCount : number) -> {any} | unknown,
	RequestListedRange : (self : SortedMap,Direction : Enum.SortDirection,ReadCount : number,exclusiveLowerBound : Bound,exclusiveUpperBound : Bound) -> {any} | unknown,
	--//Removes
	Remove : (self : SortedMap,key : string | number) -> (),
	RemoveAsync : (self : SortedMap,key : string | number) -> (),
	remove : (self : SortedMap,key : string | number) -> (),
	--//Destroys
	Destroy : (self : SortedMap) -> (),
	DestroyAsync : (self : SortedMap) -> (),
	DestroySortedMap : (self : SortedMap) -> (),
	RemoveSortedMap : (self : SortedMap) -> (),
}

export type Bound = {
	key : string | number,
	sortKey : string | number
} | unknown

export type ValidItem = 
	{string & number} 
	| string 
	| number
	| {string}
	| {number}
	| boolean
	| {boolean}

return nil
