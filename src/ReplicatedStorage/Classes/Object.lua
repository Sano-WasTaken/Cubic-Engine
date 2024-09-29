local Object = {
	ClassName = "BaseObject",
}

function Object:IsA(className: string)
	local function isA(obj: any): boolean
		local meta = getmetatable(obj)
		if meta == nil then
			return obj.ClassName == className
		else
			return (meta.__index.ClassName == className or obj.ClassName == className) and true or isA(meta.__index)
		end
	end

	return isA(self)
end

return Object
