local DataModelPatchService = game:GetService("DataModelPatchService")
local Component = require(script.Parent.Component)

type ComponentF = {
	Name: string,
	Component: Component.Component,
}

local TileEntity = {
	ClassName = "TileEntity",
	ExecutionContext = "justinit",
	ID = 0,
	Components = {} :: { ComponentF },
}

export type TileEntity = typeof(TileEntity)

export type EntityContent = {}

function TileEntity:extends(class: {})
	return setmetatable(class, { __index = self })
end

function TileEntity:setComponent(name: string, component: Component.Component)
	table.insert(self.Components, {
		Name = name,
		Component = component,
	})
end

function TileEntity:GetComponent(name: string): Component.Component -- i'm feeling seriously tired doing this.
	local fComp

	for index, comp: ComponentF in self.Components do
		if comp.Name == name then
			local data: { any } = self.Container.Components[index]

			fComp = Component.create(comp.Component, data)
			break
		end
	end

	return fComp
end

function TileEntity:GetID()
	return self.ID
end

local function createComps(self: TileEntity): { Component.Component }
	local components = {}

	for index, comp in self.Components do
		components[index] = comp.Component:create()
	end

	return components
end

function TileEntity:create(data: { any }?)
	assert(self.ClassName == "TileEntity", "cannot create TileEntity.")

	return setmetatable({
		Container = data or { -- Single value or array !
			ID = self.ID,
			Position = { 0, 0, 0 }, -- Array !
			Components = createComps(self), -- ARRRRRRRRRAAAAAYYYYY !!!!!!
		},
	}, { __index = self })
end

function TileEntity:SetPosition(x: number, y: number, z: number)
	self.Container.Position = { x, y, z }
end

function TileEntity:GetPosition(): (number, number, number)
	return unpack(self.Container.Position)
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
