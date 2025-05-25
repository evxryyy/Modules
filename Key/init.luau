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

function Key:Fire(...)
	if(not self.__InputActionInstance or not self) then return end
	self.__InputActionInstance.InputAction:Fire(...)
end

function Key:ConnectPressedEvent(T : () -> ())
	if(not self.__InputActionInstance or not self) then return end
	if(not T) then return end
	self.__InputPressedSignalConnected = self.__InputActionInstance.InputAction.Pressed:Connect(T)
end

function Key:ConnectReleasedEvent(T : () -> ())
	if(not self.__InputActionInstance or not self) then return end
	if(not T) then return end
	self.__InputReleasedSignalConnected = self.__InputActionInstance.InputAction.Released:Connect(T)
end

function Key:ActionState() : any
	if(not self.__InputActionInstance or not self) then return end
	return self.__InputActionInstance.InputAction:GetState()
end

function Key:DisconnectPressedEvent()
	if(not self.__InputActionInstance or not self) then return end
	if(not self.__InputPressedSignalConnected) then return end
	self.__InputPressedSignalConnected:Disconnect()
	self.__InputPressedSignalConnected = false
end

function Key:DisconnectReleasedEvent()
	if(not self.__InputActionInstance or not self) then return end
	if(not self.__InputReleasedSignalConnected) then return end
	self.__InputReleasedSignalConnected:Disconnect()
	self.__InputReleasedSignalConnected = false
end

function Key:DisconnectEvents()
	if(not self.__InputActionInstance or not self) then return end
	self:DisconnectPressedEvent()
	self:DisconnectReleasedEvent()
end

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

function Key:Destroy()
	if(not self.__InputActionInstance or not self) then return end
	self:DisconnectEvents()
	self.__InputActionInstance:Destroy()
	table.clear(self)
	setmetatable(self,nil)
end

return Key
