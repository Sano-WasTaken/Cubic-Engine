local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockTypeEnum = require(ReplicatedStorage.Enums.BlockTypeEnum)
local RunService = game:GetService("RunService")
local Object = require(script.Parent.Object)

-- To prevents server features are using in client context

-- Common Block Contents
export type Textures = string | { Top: string, Bottom: string, Right: string, Left: string, Front: string, Back: string }
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

setmetatable(BlockContent, { __index = Object })

export type BlockContent = typeof(BlockContent)

function assertContext()
	assert(RunService:IsServer(), "you should do this server sided")
end

function BlockContent:GetTexture(): Textures
	return self.Textures
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

function BlockContent:GetLootTable() end

function BlockContent:SetLootTable() end

function BlockContent:extends(class: CanvasBlock)
	return setmetatable(class, { __index = self })
end

return {
	Class = BlockContent,
	assertContext = assertContext,
}
