local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Object = require(ReplicatedStorage.Classes.Object)
local Component = require(script.Parent.Component)

type ComponentF = {
	Name: string,
	Component: Component.Component,
	Args: { any },
}

local TileEntity = {
	ClassName = "TileEntity",
	ExecutionContext = "justinit",
	ID = 0,
	Components = {} :: { ComponentF },
}

setmetatable(TileEntity, { __index = Object })

export type TileEntity = typeof(TileEntity) & typeof(Object)

export type EntityContent = {}

function TileEntity:extends(class: {})
	return setmetatable(class, { __index = self })
end

function TileEntity:setComponent(name: string, component: any, ...: any)
	table.insert(self.Components, {
		Name = name,
		Component = component,
		Args = { ... },
	})
end

function TileEntity:GetComponent(name: string): Component.Component? -- i'm feeling seriously tired doing this.
	local fComp

	for index, comp: ComponentF in self.c do
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
		components[index] = comp.Component:new(unpack(comp.Args))
	end

	return components
end

function TileEntity:create(data: { any }?)
	assert(self.ClassName ~= "TileEntity", "cannot create TileEntity.")

	local c

	if data == nil then
		c = createComps(self)
	end

	return setmetatable({
		Container = data or { -- Single value or array !
			--ID = self.ID,
			p = 0,
			c = #c ~= 0 and c or nil,
		},
	}, { __index = self })
end

function TileEntity:GetContainerData(): {}
	return self.Container
end

function TileEntity:SetPosition(pointer: number)
	self.Container.p = pointer
end

function TileEntity:GetPosition(): number
	return self.Container.p
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
