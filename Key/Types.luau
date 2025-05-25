export type KeyConfiguration = {
	InputContextName : string,
	Keybinds : {Enum.KeyCode},
	AttachedGuiButton : {GuiButton},
	Sink : boolean,
	Priority : number,
	Enabled : boolean,
	Parent : Instance | nil,
	InputType : Enum.InputActionType
}

export type Constructor<T...> = {
	__InputActionInstance : Instance,
	__InputPressedSignalConnected : boolean | RBXScriptConnection,
	__InputReleasedSignalConnected : boolean | RBXScriptConnection,
	AttachedGuiButton : {GuiButton},
	Fire : (self : Constructor<T...> , T : boolean) -> ();
	ConnectPressedEvent : (self : Constructor<T...>, T : (T...) -> ()) -> ();
	ConnectReleasedEvent : (self : Constructor<T...>, T : (T...) -> ()) -> ();
	ActionState : (self : Constructor<T...>) -> any,
	DisconnectPressedEvent : (self : Constructor<T...>) -> ();
	DisconnectReleasedEvent : (self : Constructor<T...>) -> ();
	DisconnectEvents : (self : Constructor<T...>) -> ();
	ChangeKeys : (self : Constructor<T...>,T : {Enum.KeyCode},T : {GuiButton}) -> ();
	AddKeys : (self : Constructor<T...>,T : {Enum.KeyCode},T : {GuiButton}) -> ();
	RemoveKeys : (self : Constructor<T...>, T : {Enum.KeyCode}) -> ();
	Destroy : (self : Constructor<T...>) -> ();
}

return nil
