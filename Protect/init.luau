local debugger_message = [[
Protect detected an error at ::%s
		__LINE__ :: %s
		__SOURCE__ :: %s
		__TRACE__ :: %s
]]

local Types = require(script.Types)

local ProtectPrototype = {}

local Protect = {}
Protect.__index = Protect
Protect.__newindex = function(t,k,v)
	warn(("Protect ::%s is not a valid member"):format(type(k)))
end

local function make_debug(self,err : string)
	if(not self or not err) then return end
	local format_debug = debugger_message:format(
		self._trace(err,2),
		debug.info(2,"l"),
		debug.info(2,"s"),
		self._trace("[DEBUGGER ERROR]",2)
	)
	rawset(self,"State","Debug")
	return format_debug
end

local function __procceedContextExecution(self,err)
	if(not self or not err) then return end
	local prevent_try = 0
	repeat
		prevent_try += 1
		task.wait()
	until self.attach_prevention ~= nil or prevent_try > 10
	if(not self.attach_prevention) then
		return warn(make_debug(self,err))
	else
		self.attach_prevention(make_debug(self,err))
	end
end

local function runContext(self,handler : Types.ConstructorHandler)
	if(not handler) then return end
	return xpcall(function(...)
		rawset(self,"State","Success")
		self._handler(function(reject_message)  
			rawset(self,"State","Rejected")
			self:reject(reject_message)
			error("cancelling_thread")
		end,function(value_to_resolve): any 
			rawset(self,"State","Resolved")
			return self:resolve(value_to_resolve)	
		end,function(fn : nil | () -> ()) : ()
			if(not rawget(self,"target_should_cancel")) then return end
			rawset(self,"State","HandlerCancelled")
			if(fn) then fn() error("cancelling_thread") end
		end)
	end,function(err)
		if(string.match(err,"cancelling_thread")) then return end
		rawset(self,"State","Debug")
		rawset(self,"errorCount",rawget(self,"errorCount")+1)
		task.spawn(__procceedContextExecution,self,err)
	end)
end

function ProtectPrototype.new(handler : Types.ConstructorHandler)
	if(typeof(handler) == "RBXScriptConnection") then return end
	local self = {}
	self._handler = handler
	self._trace = debug.traceback
	self.errorCount = 0
	self.State = "Constructed"
	setmetatable(self,Protect)
	rawset(self,"attachedCompactResult",runContext)
	rawget(self,"attachedCompactResult")(self,handler)
	return self
end

function ProtectPrototype.delay(handler : Types.ConstructorHandler, num :  number)
	if(not handler or not num) then num = 0.01 end
	local self = {}
	self._handler = handler
	self._trace = debug.traceback
	self.errorCount = 0
	self.State = "Constructed"
	setmetatable(self,Protect)
	rawset(self,"attachedCompactResult",runContext)
	task.delay(num,function()
		if(self.cancelled_before_tracked) then
		else
			if(not self) then return end
			if(not rawget(self,"attachedCompactResult")) then return end
			rawget(self,"attachedCompactResult")(self,handler)
		end
	end)
	return self
end

function ProtectPrototype.spawn(handler : Types.ConstructorHandler)
	if(typeof(handler) == "RBXScriptConnection") then return end
	local self = {}
	self._handler = handler
	self._trace = debug.traceback
	self.errorCount = 0
	self.State = "Constructed"
	setmetatable(self,Protect)
	rawset(self,"attachedCompactResult",runContext)
	task.spawn(rawget(self,"attachedCompactResult"),self,handler)
	return self
end

function ProtectPrototype.each(... : {Types.ConstructorHandler})
	local handles = ...
	if(not handles or type(handles) ~= "table") then return end 
	local self = {}
	self._handles = handles
	self._trace = debug.traceback
	self.errorCount = 0
	self.State = "Constructed"
	setmetatable(self,Protect)
	local index = 1
	local handler = self._handles[1]
	while (handler) do
		rawset(self,"_handler",handler)
		rawset(self,"attachedCompactResult" .. index,runContext)
		rawget(self,"attachedCompactResult" .. index)(self,handler)
		index += 1
		handler = self._handles[index]
	end
	if(self.errorCount > 0) then rawset(self,"State","Debug") end
	return self
end

function Protect:prevent(prevent_handler : Types.PreventConstructorHandler)
	if(not prevent_handler) then return end
	if(rawget(self,"attach_prevention")) then return end
	rawset(self,"attach_prevention",prevent_handler)
	return self
end

function Protect:__tostring()
	if(not self) then return end
	return ("Protect(%s)"):format(self.State or "Constructor")
end

function Protect:resolve(value_to_resolve)
	if(not self or not self._handler) then return end
	return self:finally(value_to_resolve)	
end

function Protect:reject(rejectMessage)
	if(not self or not self._handler) then return end
	return warn(rejectMessage)
end

function Protect:cancel(...)
	if(not self or not self._handler) then return end
	if(rawget(self,"target_should_cancel")) then return end
	rawset(self,"target_should_cancel",true)
	return
end

function Protect:finally(value)
	if(not self) then return end
	return value
end

function Protect:StopHandler()
	if(not self) then return end
	if(rawget(self,"cancelled_before_tracked")) then return end
	self:cancel()
	rawset(self,"cancelled_before_tracked",true)
	rawset(self,"State","Cancelled")
	return
end

function Protect:Destroy()
	if(not self) then return end
	self:StopHandler()
	table.clear(self)
	setmetatable(self,nil)
	return nil
end

return ProtectPrototype
