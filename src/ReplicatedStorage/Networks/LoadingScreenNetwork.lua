local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return {
	IncrementLoadingBar = Red.Event("IncrementLoadingBar", function(i: number, max: number)
		assert(max >= i, "there is a problem lolll.")

		return i, max
	end),

	LoadingSucceed = Red.Event("LoadingSucceed", function()
		return
	end),
}
