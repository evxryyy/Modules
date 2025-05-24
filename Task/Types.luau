export type TaskClass = {
	__ID : string,
	__connected_task : {any},
	Add : (self : TaskClass,Target : __Executable) -> (),
	AddPromise : (self : TaskClass,_promise : {any}) -> (),
	Execute : (self : TaskClass,fn : () -> ()) -> ();
	GetTaskAtIndex : (self : TaskClass,targetIndex : number) -> __Executable,
	Destroy : (self : TaskClass) -> (),
	clean : (self : TaskClass) -> (),
	Clean : (self : TaskClass) -> (),
	Disconnect : (self : TaskClass) -> (),
}

export type __Executable = 
	RBXScriptConnection 
	| {any} 
	| () -> () 
	| Instance

export type Task<T> = T

return nil
