local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Object = require(ReplicatedStorage.Classes.Object)
local Component = {
	ClassName = "BaseComponent",
}

setmetatable(Component, { __index = Object })

--[[
Objects have container data, do not forget to create.
]]

export type Component = typeof(Component) & typeof(Object)

--export type IComponent = {} -- make you sure if you want a fully autocompletion from your component object.

-- OVERRIDDEN IT!
function Component:create(data: {}?) -- you can use this as Component.create(self, data)
	assert(self.ClassName == "BaseComponent", "Please, do not use the BaseComponent Class to create a component.")

	return setmetatable(
		data -- if you want recreate the component.
			or {}, -- this is the container, sure you overriden the method.
		{ __index = self }
	)
end

return Component
