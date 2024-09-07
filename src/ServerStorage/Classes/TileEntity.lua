local TileEntity = {
	ClassName = "TileEntity",
	ExecutionContext = "justinit",
	Id = 0,
}

export type TileEntity = typeof(TileEntity)

export type EntityContent = {}

function TileEntity:extends<T>(class: T & TileEntity)
	return setmetatable(class, { __index = self })
end

function TileEntity:IsA(className: string)
	local function isA(obj: TileEntity): boolean
		local meta = getmetatable(obj)
		if meta == nil then
			return obj.ClassName == className
		else
			return (meta.ClassName == className or obj.ClassName == className) and true or isA(meta)
		end
	end

	return isA(self)
end

function TileEntity:GetID()
	return self.Id
end

-- Abstract Method
function TileEntity:Init()
	error("Abstract component is not overridden")
end

-- Abstract Method
function TileEntity:Tick(_: number)
	error("Abstract component is not overridden")
end

return TileEntity
