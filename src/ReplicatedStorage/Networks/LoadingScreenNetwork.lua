local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KISSNet = require(ReplicatedStorage.Classes.KISSNet)

return KISSNet.defineNamespace("LoadingBar", {
	IncrementLoadingBar = KISSNet.defineEvent(function()
		return KISSNet.dict({
			max = KISSNet.number,
			index = KISSNet.number,
		})
	end),

	LoadingSuccess = KISSNet.defineEvent(function()
		return KISSNet.nothing
	end),
})
