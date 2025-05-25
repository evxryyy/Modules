--[[
		Key Module - A more advanced way to handle user inputs
		
		Version: 1.0.0
		Author: evxry_ll
		Documentation: https://evxryyy.github.io/UtilsSite/
]]

local RunService = game:GetService("RunService")

if(not RunService:IsClient()) then error(`{script.Name} can't be required in a server script.`) end

local function formatErrorMessage(call,message,level)
	return call(message,level)
end

local Types = require(script.Types)

export type Constructor<T...> = Types.Constructor<T...>

local Key = {}
Key.__index = Key
Key.__newindex = function(t,k,v)
	warn(`Can't set Key::{tostring(k)}`)
end

--[[
	Return a Key Class that can manipulate the action inputAction
	
	Exemples : 
	
	```lua
		local ReplicatedStorage = game:GetService("ReplicatedStorage")

		local Key = require(ReplicatedStorage.Key)

		local PrintAction = Key.ConstructInput({
			InputContextName = "PrintAction", -- Name of the InputContext;
			Sink = false,
			Priority = 1000, -- Priority level
			AttachedGuiButton = {}; -- Gui button to bind with
			Enabled = true,
			Parent = nil, -- Nil = parented to key module
			Keybinds = {Enum.KeyCode.E},
			InputType = Enum.InputActionType.Bool -- input type
		})
	```
]]
function Key.ConstructInput<T...>(Configuration : Types.KeyConfiguration) : Constructor<T...>
	if(not Configuration or type(Configuration) ~= "table") then
		formatErrorMessage(error,`Configuration not valid`,2)
	end
	local InputContext = Instance.new("InputContext",Configuration.Parent or script)
	InputContext.Name = Configuration.InputContextName
	InputContext.Enabled = Configuration.Enabled or true
	InputContext.Priority = Configuration.Priority or 1000
	InputContext.Sink = Configuration.Sink or false
	local InputAction = Instance.new("InputAction",InputContext)
	InputAction.Enabled = Configuration.Enabled or false
	InputAction.Type = Configuration.InputType or Enum.InputActionType.Bool
	for i,keycode in next,Configuration.Keybinds do
		local InputBinding = Instance.new("InputBinding",InputAction)
		InputBinding.KeyCode = keycode
		InputBinding.Name = keycode.Name
		if(Configuration.AttachedGuiButton[i]) then
			local gui = Configuration.AttachedGuiButton[i]
			InputBinding.UIButton = gui
		end
	end
	local self = setmetatable({
		__InputActionInstance = InputContext,
		__InputPressedSignalConnected = false,
		__InputReleasedSignalConnected = false,
		AttachedGuiButton = Configuration.AttachedGuiButton,
	},Key)
	return self
end

--[[
	Fire: only accept a boolean value
	Ex:
	PrintAction:Fire(true)
]]
function Key:Fire(T : boolean)
	if(not self.__InputActionInstance or not self) then return end
	self.__InputActionInstance.InputAction:Fire(T)
end

--[[
	Connect the callback to .Pressed event
]]
function Key:ConnectPressedEvent(T : () -> ())
	if(not self.__InputActionInstance or not self) then return end
	if(not T) then return end
	self.__InputPressedSignalConnected = self.__InputActionInstance.InputAction.Pressed:Connect(T)
end

--[[
	Connect the callback to .Released event
]]
function Key:ConnectReleasedEvent(T : () -> ())
	if(not self.__InputActionInstance or not self) then return end
	if(not T) then return end
	self.__InputReleasedSignalConnected = self.__InputActionInstance.InputAction.Released:Connect(T)
end

--[[
	Return the current input state
]]
function Key:ActionState() : any
	if(not self.__InputActionInstance or not self) then return end
	return self.__InputActionInstance.InputAction:GetState()
end

--[[
	Disconnect the .Pressed event
]]
function Key:DisconnectPressedEvent()
	if(not self.__InputActionInstance or not self) then return end
	if(not self.__InputPressedSignalConnected) then return end
	self.__InputPressedSignalConnected:Disconnect()
	self.__InputPressedSignalConnected = false
end

--[[
	Disconnect the .Released event
]]
function Key:DisconnectReleasedEvent()
	if(not self.__InputActionInstance or not self) then return end
	if(not self.__InputReleasedSignalConnected) then return end
	self.__InputReleasedSignalConnected:Disconnect()
	self.__InputReleasedSignalConnected = false
end

--[[
	Disconnect all events
]]
function Key:DisconnectEvents()
	if(not self.__InputActionInstance or not self) then return end
	self:DisconnectPressedEvent()
	self:DisconnectReleasedEvent()
end

--[[
	This Will replace the button A to the Button B and same for the key
	if not GuiButton is passed it will automaticly connect the Button.A (first attached button to the action)
	
	```lua
		PrintAction:ChangeKeys({Enum.KeyCode.P}) -- Button.A wil be connected to the keycode P
		PrintAction:ChangeKeys({Enum.KeyCode.P},{Buttons.B}) -- Button A will be disconnected and Button.B will be connected to the keycode P
	```
]]
function Key:ChangeKeys(T : {Enum.KeyCode},G : {GuiButton})
	if(not self.__InputActionInstance or not self) then return end
	if(not T or #T <= 0) then return end
	local bindingsInstance = self.__InputActionInstance.InputAction:GetChildren()
	for i,keycode in next,T do
		local targetInstance = bindingsInstance[i]
		if(not targetInstance) then
			local InputBinding = Instance.new("InputBinding",self.__InputActionInstance.InputAction)
			InputBinding.KeyCode = keycode
			InputBinding.Name = keycode.Name
			if(G) then
				InputBinding.UIButton = G[i]
			else
				if(self.AttachedGuiButton[i]) then
					local gui = self.AttachedGuiButton[i]
					InputBinding.UIButton = gui
				end
			end
		else
			targetInstance.KeyCode = keycode
			targetInstance.Name = keycode.Name
			if(G) then
				targetInstance.UIButton = G[i]
			else
				if(self.AttachedGuiButton[i]) then
					local gui = self.AttachedGuiButton[i]
					targetInstance.UIButton = gui
				end
			end
		end
	end
end

--[[
	Add new keys to the action and GuiButton
	```lua
		local PrintAction = Key.ConstructInput({
			InputContextName = "PrintAction", -- Name of the InputContext;
			Sink = false,
			Priority = 1000, -- Priority level
			AttachedGuiButton = {Buttons.A}; -- Gui button to bind with
			Enabled = true,
			Parent = nil, -- Nil = parented to key module
			Keybinds = {Enum.KeyCode.E},
			InputType = Enum.InputActionType.Bool -- input type
		})
		PrintAction:AddKeys({Enum.KeyCode.P},{Buttons.B}) -- Button.B will be connected to the keycode P
	```
	Same case with ChangesKeys if not GuiButtons is passed the default AttachedGuiButton will be connected to the new key
	e.g button A will get the E and P key code connection
]]
function Key:AddKeys(T : {Enum.KeyCode},G : {GuiButton}) 
	if(not self.__InputActionInstance or not self) then return end
	if(not T or #T <= 0) then return end
	for i,keycode in next,T do
		local added = true
		for i,bindingInstance in pairs(self.__InputActionInstance.InputAction:GetChildren()) do
			if(bindingInstance.KeyCode == keycode) then
				added = false
				break
			end
		end
		if(not added) then
			formatErrorMessage(warn,`{keycode} is already added`,"")
			continue
		end
		local InputBinding = Instance.new("InputBinding",self.__InputActionInstance.InputAction)
		InputBinding.KeyCode = keycode
		InputBinding.Name = keycode.Name 
		if(G) then
			InputBinding.UIButton = G[i]
		else
			if(self.AttachedGuiButton[i]) then
				local gui = self.AttachedGuiButton[i]
				InputBinding.UIButton = gui
			end
		end
	end
end

--[[
	Remove a key from the current action
]]
function Key:RemoveKeys(T : {Enum.KeyCode})
	if(not self.__InputActionInstance or not self) then return end
	if(not T or #T <= 0) then return end
	for _,keycode in next,T do
		local remove : Instance | boolean = false
		for i,bindingInstance : InputBinding in pairs(self.__InputActionInstance.InputAction:GetChildren()) do
			if(bindingInstance.KeyCode == keycode) then
				remove = bindingInstance
				break
			end
		end
		if(remove and typeof(remove) == "Instance") then remove:Destroy() end
		if(not remove) then
			formatErrorMessage(warn,`{keycode} is not found`,"")
			continue
		end
	end
end

--[[
	Destroy the Action.
]]
function Key:Destroy()
	if(not self.__InputActionInstance or not self) then return end
	self:DisconnectEvents()
	self.__InputActionInstance:Destroy()
	table.clear(self)
	setmetatable(self,nil)
end

return Key
