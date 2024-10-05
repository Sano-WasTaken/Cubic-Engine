local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bytenet = require(ReplicatedStorage.Packages.Bytenet)

return Bytenet.defineNamespace("Loading", function()
	return {
		IncrementLoadingBar = Bytenet.definePacket({
			value = Bytenet.struct({
				max = Bytenet.uint32,
				index = Bytenet.uint32,
			}),
		}),

		LoadingSuccess = Bytenet.definePacket({
			value = Bytenet.nothing,
		}),
	}
end)
