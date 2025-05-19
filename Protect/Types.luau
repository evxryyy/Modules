export type ConstructorHandler = (
	reject : (reject_message : any) -> (),
	resolve : (value_to_resolve : any) -> any,
	OnCancel : (fn : nil | () -> ()) -> ()
) -> ();

export type  PreventConstructorHandler = (v : any) -> any

return nil
