local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockTypeEnum = require(ReplicatedStorage.Enums.BlockTypeEnum)
local ServerStorage = game:GetService("ServerStorage")

-- To prevents server features are using in client context
local function GetServices()
	local Block = require(ServerStorage.Classes.Block)
	local WorldManager = require(ServerStorage.Managers.WorldManager)

	return Block, WorldManager
end

local isServer, Block, WorldManager = pcall(GetServices)

-- Common Block Contents
export type Textures = string | { Top: string, Bottom: string, Right: string, Left: string, Front: string, Back: string }
export type Block = Block.IBlock
export type CanvasBlock = {
	Id: number?,
	Textures: Textures?,
	Mesh: BasePart?,
	Unbreakable: boolean?,
	BlockType: number?,
}

local BlockContent = {
	Id = 0,
	Textures = "rbxassetid://18945254631",
	Mesh = Instance.new("Part"),
	Unbreakable = false,
	BlockType = BlockTypeEnum.Block,
}

export type BlockContent = typeof(BlockContent)

function assertContext()
	assert(isServer, "you should do this server sided")
end

function BlockContent:GetTexture(): Textures
	return self.Textures
end

function BlockContent:GetID()
	return self.Id
end

function BlockContent:GetMeshClone(): BasePart
	return self.Mesh:Clone()
end

function BlockContent:IsUnbreakable()
	return self.Unbreakable
end

-- Server Only
function BlockContent:GetServices()
	--assertContext()
	local a, b, c = pcall(GetServices)

	return a, b, c
end

-- Server Only
function BlockContent:CreateBlock(x: number, y: number, z: number, rx: number, ry: number, rz: number)
	assertContext()

	return Block.new(self.Id):SetPosition(x, y, z)
end

-- Server Only
function BlockContent:AppendBlock(x: number, y: number, z: number, rx: number, ry: number, rz: number)
	local block = self:CreateBlock(x, y, z, rx, ry, rz)

	WorldManager:Insert(block)
end

function BlockContent:UpdateContent(block: Block.IBlock, content: any)
	warn(block, content, "are using but have no behavior, content should be nil in this case.")
end

function BlockContent:extends(class: CanvasBlock)
	return setmetatable(class, { __index = self })
end

return {
	Class = BlockContent,
	assertContext = assertContext,
}
