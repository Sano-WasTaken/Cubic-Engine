local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local function GetServices()
	local Item = require(ServerStorage.Classes.Item)

	return Item
end

local function assertContext()
	assert(RunService:IsServer(), "You should do this in server side .")
end

export type CanvasItem = {
	Mesh: BasePart?,
	Id: number?,
	MaxStackSize: number?,
	ClassName: string?,
}

local ItemContent = {
	Mesh = Instance.new("MeshPart"),
	Id = 0,
	MaxStackSize = 64,
	ClassName = "Item",
}

export type ItemContent = typeof(ItemContent)

function ItemContent:GetClonedMesh(): BasePart
	return self.Mesh:Clone()
end

function ItemContent:GetServices()
	local a, b = pcall(GetServices)

	return a, b
end

function ItemContent:IsUsable()
	return self.Use ~= nil
end

function ItemContent:IsA(className: string)
	return self.ClassName == className
end

function ItemContent:GetID()
	return self.Id
end

function ItemContent:CreateItem(amount: number?)
	assertContext()

	local _, Item = self:GetServices()

	amount = amount or 1

	return Item.new(self.Id):SetAmount(amount)
end

function ItemContent:extends(class: {})
	return setmetatable(class, { __index = self }) :: typeof(self) & typeof(class)
end

return {
	assertContext = assertContext,
	Class = ItemContent,
}
