local RunService = game:GetService("RunService")
if(RunService:IsClient()) then error("Memory should only be required from a server script") end

return table.freeze({
	Queue = require(script.Queue);
	SortedMap = require(script.SortedMap);
	HashMap = require(script.HashMap);
})
