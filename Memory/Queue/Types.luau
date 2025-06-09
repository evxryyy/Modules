export type Queue = {
	--Properties
	__QueueObjectData : MemoryStoreQueue,
	__QueueInvisibleSize : number,
	__QueueSize : number,
	__QueueOffset : number,
	--Size Functions
	ISize : (self : Queue) -> number,
	Size : (self : Queue) -> number,
	Offset : (self : Queue) -> number,
	IncludeInvisibleSize : (self : Queue) -> number,
	ExcludeInvisibleSize : (self : Queue) -> number,
	QueueOffset : (self : Queue) -> number,
	--Add Functions
	Add : (self : Queue,itemToAdd : ValidItem , expiration : number,priority : number) -> WriterReturnedValues,
	AddTemp : (self : Queue,itemToAdd : ValidItem , expiration : number,priority : number) -> WriterReturnedValues,
	AddItem : (self : Queue,itemToAdd : ValidItem , expiration : number,priority : number) -> WriterReturnedValues,
	AddAsync : (self : Queue,itemToAdd : ValidItem , expiration : number,priority : number) -> WriterReturnedValues,
	--Read functions
	Read : (self : Queue,offset : number,readAll : boolean,waitTime : number?) -> ReaderReturnedValues,
	ReadItem : (self : Queue,offset : number,readAll : boolean,waitTime : number?) -> ReaderReturnedValues,
	ReadAsync : (self : Queue,offset : number,readAll : boolean,waitTime : number?) -> ReaderReturnedValues,
	ReadTemp : (self : Queue,offset : number,readAll : boolean,waitTime : number?) -> ReaderReturnedValues,
	--Remove functions
	Remove : (self : Queue,id : string) -> boolean | unknown,
	RemoveAsync : (self : Queue,id : string) -> boolean | unknown,
	RemoveItem : (self : Queue,id : string) -> boolean | unknown,
	RemoveData : (self : Queue,id : string) -> boolean | unknown,
	--Destroy functions
	Destroy : (self : Queue) -> (),
	DestroyQueue : (self : Queue) -> (),
	RemoveQueue : (self : Queue) -> (),
}

export type ReaderReturnedValues = {ValidItem & string} | unknown

export type WriterReturnedValues = {
	AddedObject : ValidItem,
	Expiration : number,
	Priority : number,
	ReadedData : {ValidItem & string},
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
