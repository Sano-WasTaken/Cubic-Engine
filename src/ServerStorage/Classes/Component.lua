local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Object = require(ReplicatedStorage.Classes.Object)
local Component = {
	ClassName = "BaseComponent",
}

setmetatable(Component, { __index = Object })

--[[
Objects have container data, do not forget to create.
]]

export type Component = typeof(Component) & typeof(Object) & {
	Container: any,
}

--export type IComponent = {} -- make you sure if you want a fully autocompletion from your component object.

-- OVERRIDDEN IT!
function Component:new(): { any }
	error("Please, do not use the BaseComponent Class to create a component.")

	return {}
end

function Component:create(data: any?) -- you can use this as Component.create(self, data)
	assert(self.ClassName == "BaseComponent", "Please, do not use the BaseComponent Class to create a component.")

	return setmetatable({
		Container = data or self:new(),
	}, { __index = self })
end

function Component:GetContainerData()
	return self.Container
end

return Component
