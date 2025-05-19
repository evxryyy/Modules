return function()
	local Task = require(script.Parent)
	it("Should return a task",function() 
		local _task = Task.new()
		expect(_task).to.be.a("table")
		expect(_task.__connected_task).to.be.a("table")
		expect(_task.__ID).to.be.ok()
		expect(_task.new).to.be.a(nil)
		return _task
	end)
	it("Return a connected event to from the task",function() 
		local _task = Task.new()
		expect(_task).to.be.a("table")
		expect(_task.__connected_task).to.be.a("table")
		expect(_task.__ID).to.be.ok()
		expect(_task.new).to.be.a(nil)
		_task:Add(workspace.ChildAdded:Connect(function()
		end))
		local get_added_rbx_connection = _task:GetTaskAtIndex(1)
		expect(get_added_rbx_connection).to.be.a("RBXScriptConnection")
		expect(get_added_rbx_connection.Disconnect).to.be.ok()
		return get_added_rbx_connection
	end)
	it("Add a class and call the clean up function",function() 
		local _task = Task.new()
		expect(_task).to.be.a("table")
		expect(_task.__connected_task).to.be.a("table")
		expect(_task.__ID).to.be.ok()
		expect(_task.new).to.be.a(nil)
		local class = {Destroy = function() print("cleaning") end}
		setmetatable(class,{
			__index = function(t,k)
				error(`Can't get Class::{k}`)
			end,
			__newindex = function(t,k,v)
				error(`Can't set Class::{type(k)}`)
			end,
		})
		_task:Add(class)
		local get_class = _task:GetTaskAtIndex(1)
		expect(get_class).to.be.a("table")
		expect(_task:clean()).to.be.ok()
	end)
	it("Clean a task and all added events/instances",function() 
		local _task = Task.new()
		expect(_task).to.be.a("table")
		expect(_task.__connected_task).to.be.a("table")
		expect(_task.__ID).to.be.ok()
		expect(_task.new).to.be.a(nil)
		local class = {Destroy = function() print("cleaning") end}
		setmetatable(class,{
			__index = function(t,k)
				error(`Can't get Class::{k}`)
			end,
			__newindex = function(t,k,v)
				error(`Can't set Class::{type(k)}`)
			end,
		})
		_task:Add(class)
		_task:Add(workspace.ChildAdded:Connect(function()
		end))
		local instance = Instance.new("BoolValue")
		instance.Name = "random_tesez_object"
		instance.Parent = script
		_task:Add(instance)
		_task:clean()
		expect(_task[1]).to.be.a(nil)
	end)
end
