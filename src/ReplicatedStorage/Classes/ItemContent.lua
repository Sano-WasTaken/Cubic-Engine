local RunService = game:GetService("RunService")

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

function ItemContent:IsUsable()
	return self.Use ~= nil
end

function ItemContent:IsA(className: string)
	local function isA(obj: ItemContent): boolean
		local meta = getmetatable(obj)
		if meta == nil then
			return obj.ClassName == className
		else
			return (meta.ClassName == className or obj.ClassName == className) and true or isA(meta)
		end
	end

	return isA(self)
end

function ItemContent:GetID()
	return self.Id
end

function ItemContent:extends(class: {})
	return setmetatable(class, { __index = self }) :: typeof(self) & typeof(class)
end

return {
	assertContext = assertContext,
	Class = ItemContent,
}
