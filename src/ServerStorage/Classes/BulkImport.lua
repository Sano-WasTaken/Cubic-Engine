local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Block = require(ServerStorage.Classes.Block)
local Queue = require(ReplicatedStorage.Classes.Queue)
local Signal = require(ReplicatedStorage.Packages.Signal)
local BulkImport = {}

local function new(): BulkImport
	return setmetatable({
		queue = Queue.new(),
		Stopped = Signal.new(),
	}, { __index = BulkImport }) :: any
end

function BulkImport.Stop(self: BulkImport)
	self.Stopped:Fire(self.queue)
end

function BulkImport.Insert(self: BulkImport, block: Block.IBlock)
	self.queue:Insert(block)
end

type BlockQueue = Queue.Queue<Block.IBlock>

export type BulkImport = typeof(BulkImport) & {
	queue: BlockQueue,
	Stopped: Signal.Signal<BlockQueue>,
}

return {
	new = new,
}
