local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldNetwork = require(ReplicatedStorage.Networks.WorldNetwork)

WorldNetwork.SendChunk.listen(function(data: {
	chunk: buffer,
	cx: number,
	cy: number,
	tileEntities: { { Facing: number, Position: { number } } },
})
	print(data)
end)

WorldNetwork.SendRangeOfChunks.listen(function(data: {
	{
		chunk: buffer,
		cx: number,
		cy: number,
		tileEntities: { { Facing: number, Position: { number } } },
	}
})
	print(unpack(data))
end)

WorldNetwork.SendBlockMasks.listen(function(data)
	print(data.create)
	print(data.remove)
end)

task.wait(5)

--WorldNetwork.RequestChunk.send({ cx = 0, cy = 0 })

task.wait(5)

--WorldNetwork.RequestChunk.send({ cx = 0, cy = 0, range = 5 })
