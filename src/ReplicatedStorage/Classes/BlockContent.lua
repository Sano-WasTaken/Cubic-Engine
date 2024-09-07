local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockTypeEnum = require(ReplicatedStorage.Enums.BlockTypeEnum)
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

-- To prevents server features are using in client context
local function GetServices()
	local Block = require(ServerStorage.Classes.Block)
	local WorldManager = require(ServerStorage.Managers.WorldManager)

	return Block, WorldManager
end

local _, Block, WorldManager = pcall(GetServices)

-- Common Block Contents
export type Textures = string | { Top: string, Bottom: string, Right: string, Left: string, Front: string, Back: string }
export type Block = Block.IBlock
export type CanvasBlock = {
	Id: number?,
	Textures: Textures?,
	Mesh: BasePart?,
	Unbreakable: boolean?,
	BlockType: number?,
	Color: Color3?,
	Size: Vector3?,
	ClassName: string?,
}

local baseMesh = Instance.new("Part")
baseMesh.Anchored = true

local BlockContent = {
	Id = 0,
	Textures = "rbxassetid://18945254631",
	Mesh = baseMesh,
	Unbreakable = false,
	BlockType = BlockTypeEnum.Block,
	ClassName = "Block",
	Size = Vector3.one * 3,
}

export type BlockContent = typeof(BlockContent)

function assertContext()
	assert(RunService:IsServer(), "you should do this server sided")
end

function BlockContent:GetTexture(): Textures
	return self.Textures
end

function BlockContent:IsA(className: string)
	local function isA(obj: BlockContent): boolean
		local meta = getmetatable(obj)
		if meta == nil then
			return obj.ClassName == className
		else
			return (meta.ClassName == className or obj.ClassName == className) and true or isA(meta)
		end
	end

	return isA(self)
end

function BlockContent:GetID()
	return self.Id
end

function BlockContent:GetMeshClone(): BasePart
	local mesh: BasePart = self.Mesh:Clone()

	mesh.Size = self.Size
	mesh.Anchored = true

	return mesh
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

	_, Block, _ = self:GetServices()

	return Block.new(self.Id):SetPosition(x, y, z):SetOrientation(rx, ry, rz)
end

-- Server Only
function BlockContent:AppendBlock(x: number, y: number, z: number, rx: number, ry: number, rz: number)
	local block = self:CreateBlock(x, y, z, rx, ry, rz)

	_, _, WorldManager = self:GetServices()

	WorldManager:Insert(block)
end

-- Server Only
function BlockContent:tick()
	print()
end

function BlockContent:GetLootTable() end

function BlockContent:SetLootTable() end

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
