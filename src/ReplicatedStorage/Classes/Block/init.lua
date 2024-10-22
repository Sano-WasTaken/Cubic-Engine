local LootTable = require(script.Parent.LootTable)
local Object = require(script.Parent.Object)

-- To prevents server features are using in client context

-- Common Block Contents
export type Textures = string | { Top: string, Bottom: string, Right: string, Left: string, Front: string, Back: string }

local baseMesh = Instance.new("Part")
baseMesh.Anchored = true
baseMesh.Size = Vector3.one * 3

--[[local Block = {
	Id = 0,
	Textures = "rbxassetid://18945254631",
	
	Unbreakable = false,
	Culled = true,
	Faced = false,
	Inverted = false,
	Transparency = 0,
	Material = Enum.Material.Plastic,
	ClassName = "Block",
	Color = Color3.new(1, 1, 1),
}]]

local Block = {}

local BlockClass = {
	ClassName = "Block",

	-- use lower case please.
	SavedProperties = { -- will be managed by the default class
		facing = false,
		invert = false,
		active = false,
	},

	OtherProperties = {
		Unbreakable = false,
		Culled = true,
	},

	InstanceProperties = {
		Textures = "rbxassetid://18945254631" :: Textures,
		Mesh = baseMesh,
		NoTexture = false,
		Color = Color3.new(1, 1, 1),
		Transparency = 0,
		Material = Enum.Material.Plastic,
	},

	BlockObjectClass = Block :: typeof(Block),

	Variant = {} :: { BlockClass },
}

setmetatable(Block, { __index = BlockClass })

export type BlockClass = typeof(BlockClass)
export type ClassProperties = {
	ClassName: string,

	SavedProperties: {
		facing: boolean?,
		invert: boolean?,
		active: boolean?,
	}?,

	OtherProperties: {
		Unbreakable: boolean?,
		Culled: boolean?,
	}?,

	InstanceProperties: {
		Textures: Textures?,
		Mesh: BasePart?,
		NoTexture: boolean?,
		Color: Color3?,
		Transparency: number?,
		Material: Enum.Material?,
	}?,

	Variants: { BlockClass }?,
}

export type Facings = "NORTH" | "SOUTH" | "EAST" | "WEST"

-- Object Elements

export type Block = BlockClass & {
	name: string,
	properties: {
		[string]: any, -- VALID UTF 8
	}?,
} & typeof(Block)

function Block._getProperty(self: Block, state: string): any?
	if self.SavedProperties[state:lower()] then
		if self.properties then
			return self.properties[state:lower()]
		end
	end

	return
end

function Block._setProperty(self: Block, state: string, value: any)
	if self.SavedProperties[state:lower()] then
		self.properties = self.properties or {}

		if self.properties then
			self.properties[state:lower()] = value
		end
	end
end

function Block.GetFacing(self: Block): Facings
	local facing = self:_getProperty("facing") :: string?

	if facing then
		facing = facing:upper()
	else
		facing = "NORTH"
	end

	return facing
end

function Block.SetFacing(self: Block, facing: Facings)
	self._setProperty(self, "facing", facing:lower())
end

-- Static Elements

function BlockClass.getBlockMesh(self: BlockClass): BasePart
	local props = self.InstanceProperties

	local clone = props.Mesh

	if not props.NoTexture then
		for _, normalId: Enum.NormalId in Enum.NormalId:GetEnumItems() do
			local texture = Instance.new("Texture")

			texture.Face = normalId
			texture.Name = normalId.Name

			texture.StudsPerTileU = 3
			texture.StudsPerTileV = 3

			texture.Color3 = props.Color
			texture.Texture = type(props.Textures) == "table" and props.Textures[texture.Name] or props.Textures

			texture.Parent = clone
		end
	end

	clone.Material = props.Material
	clone.Transparency = props.Transparency
	clone.Color = props.Color

	return clone
end

function BlockClass.declareNewBlockClass<T, P>(self: T & BlockClass, properties: P & ClassProperties): BlockClass & T & P
	properties.Variants = {}

	table.insert(properties.Variants :: {}, self)

	return setmetatable(properties :: {}, { __index = self }) :: BlockClass & T & P
end

function BlockClass.newVariant<T, P>(self: T & BlockClass, properties: P & ClassProperties): BlockClass & T & P
	local class = self:declareNewBlockClass(properties)

	self.Variant[#self.Variant + 1] = class

	return class
end

function BlockClass.declareNewBlockFromClass<T>(self: T & BlockClass): Block
	local block = {
		name = self:stringify(),
		--properties = {},
	}

	setmetatable(self.BlockObjectClass, { __index = self })

	return setmetatable(block, { __index = Block }) :: any
end

function BlockClass.getDescendantClassNames(self: BlockClass): { string }
	local className = self.ClassName

	local classNames = {}

	if className ~= BlockClass.ClassName then
		table.insert(classNames, className)

		local subClass = (getmetatable(self :: any).__index :: any) :: BlockClass

		if subClass ~= nil then
			local classNamesFromSubClass = BlockClass.getDescendantClassNames(subClass)

			for _, name in classNamesFromSubClass do
				table.insert(classNames, name)
			end
		end
	else
		return {}
	end

	return classNames
end

function BlockClass.stringify(self: BlockClass): string
	local sid = ""

	local classNames = self:getDescendantClassNames()

	if #classNames == 0 then
		error("Do not use the Block Main Class.")
	end

	for i = #classNames, 1, -1 do
		local str = classNames[i]:lower()

		local space = (i == 1) and "" or ":"

		sid ..= str .. space
	end

	return sid
end

return BlockClass
