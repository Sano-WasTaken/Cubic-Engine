local TileEntity = {
	ClassName = "TileEntity",
	ExecutionContext = "justinit",
	Id = 0,
}

export type TileEntity = typeof(TileEntity)

export type EntityContent = {}

function TileEntity:extends(class: {})
	return setmetatable(class, { __index = self })
end

function TileEntity:GetID()
	return self.Id
end

function TileEntity:create()
	error("cannot create TileEntity.")
end

-- Abstract Method
function TileEntity:Init()
	error("Abstract component is not overridden.")
end

-- Abstract Method
function TileEntity:Tick(_: number)
	error("Abstract component is not overridden.")
end

return TileEntity
