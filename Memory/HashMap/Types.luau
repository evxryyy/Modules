export type HashMap = {
	--//Properties
	__HashMapData : MemoryStoreHashMap,
	__Size : number,
	--//Writers
	Set : (self : HashMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	Add : (self : HashMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	SetItem : (self : HashMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	AddItem : (self : HashMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	SetAsync : (self : HashMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	SetTemp : (self : HashMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	AddTemp : (self : HashMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	AddAsync : (self : HashMap,key : string | number,value : ValidItem,expiration : number,sortKey : any) -> boolean & ValidItem,
	--//Gets
	Get : (self : HashMap,key : string | number) -> {ValidItem} | unknown,
	GetAsync : (self : HashMap,key : string | number) -> {ValidItem} | unknown,
	get : (self : HashMap,key : string | number) -> {ValidItem} | unknown,
	getAsync : (self : HashMap,key : string | number) -> {ValidItem} | unknown,
	--//Updates
	Update : (self : HashMap, key : string | number, callback : () -> (),expiration : number) -> {ValidItem} | unknown,
	UpdateAsync : (self : HashMap, key : string | number, callback : () -> (),expiration : number) -> {ValidItem} | unknown,
	Async : (self : HashMap, key : string | number, callback : () -> (),expiration : number) -> {ValidItem} | unknown,
	--//Removes
	Remove : (self : HashMap,key : string | number) -> (),
	RemoveAsync : (self : HashMap,key : string | number) -> (),
	remove : (self : HashMap,key : string | number) -> (),
	--//Destroys
	Destroy : (self : HashMap) -> (),
	DestroyAsync : (self : HashMap) -> (),
	DestroyHashMap : (self : HashMap) -> (),
	RemoveHashMap : (self : HashMap) -> (),
}

export type ValidItem = 
	{string & number} 
	| string 
	| number
	| {string}
	| {number}
	| boolean
	| {boolean}


return nil
