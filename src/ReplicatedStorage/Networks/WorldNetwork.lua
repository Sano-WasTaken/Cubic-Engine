local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KISSNet = require(ReplicatedStorage.Classes.KISSNet)

return KISSNet.defineNamespace("WorldNetwork", {
	RequestForChunk = KISSNet.defineFunction(function()
		return KISSNet.dict({
			cx = KISSNet.number,
			cy = KISSNet.number,

			range = KISSNet.optional(KISSNet.number),
		})
	end, function()
		return KISSNet.array(KISSNet.dict({
			cx = KISSNet.number,
			cy = KISSNet.number,

			chunk = KISSNet.buffer,

			facings = KISSNet.array(KISSNet.dict({
				id = KISSNet.number,
				pos = KISSNet.array(KISSNet.number),
				face = KISSNet.number,
			})),
		}))
	end),

	SendBlockMasks = KISSNet.defineEvent(function()
		return KISSNet.dict({
			create = KISSNet.array(KISSNet.dict({
				id = KISSNet.number,
				pos = KISSNet.array(KISSNet.number),
				face = KISSNet.number,
			})),
			remove = KISSNet.array(KISSNet.array(KISSNet.number)),
		})
	end),
})
