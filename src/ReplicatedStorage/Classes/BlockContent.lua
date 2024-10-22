local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local LootTable = require(script.Parent.LootTable)
local Object = require(script.Parent.Object)

-- To prevents server features are using in client context

-- Common Block Contents
export type Textures = string | { Top: string, Bottom: string, Right: string, Left: string, Front: string, Back: string }
export type CanvasBlock = {
	Id: number?,
	Textures: Textures?,
	Mesh: BasePart?,
	Unbreakable: boolean?,
	Transparency: number?,
	BlockType: number?,
	Color: Color3?,
	ClassName: string?,
	Material: Enum.Material?,
	Culled: boolean?,

	Faced: boolean?,
	Inverted: boolean?,
}

local baseMesh = Instance.new("Part")
baseMesh.Anchored = true

local BlockContent = {
	Id = 0,
	Textures = "rbxassetid://18945254631",
	Mesh = baseMesh,
	Unbreakable = false,
	Culled = true,
	Faced = false,
	Inverted = false,
	Transparency = 0,
	Material = Enum.Material.Plastic,
	ClassName = "Block",
	Color = Color3.new(1, 1, 1),
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

	mesh.Size = Vector3.one * 3
	mesh.Anchored = true
	mesh.Material = self.Material
	mesh.Transparency = self.Transparency
	mesh.Color = self.Color
	mesh.Name = tostring(self.Id)

	return mesh
end

function BlockContent:IsCulled(): boolean
	return self.Culled
end

function BlockContent:IsUnbreakable()
	return self.Unbreakable
end

function BlockContent:GetLootTable(): { { ID: number, Amount: number } }
	local lootTable = self.LootTable or LootTable.new():SetItem({ id = ItemEnum[BlockEnum[self:GetID()]] })

	return lootTable:CalculateItems()
end

--function BlockContent:SetLootTable() end

function BlockContent:extends(class: CanvasBlock)
	return setmetatable(class, { __index = self })
end

return {
	Class = BlockContent,
	assertContext = assertContext,
}
