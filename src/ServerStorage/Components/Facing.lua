local ServerStorage = game:GetService("ServerStorage")
local Component = require(ServerStorage.Classes.Component)

local FacingComponent = {}

setmetatable(FacingComponent, { __index = Component })

export type Facing = "NORTH" | "SOUTH" | "EAST" | "WEST"

local Facings = {
	"NORTH", -- Basic facing
	"SOUTH",
	"EAST",
	"WEST",
}

function FacingComponent:new()
	return 1
end

function FacingComponent:GetFacing(): Facing
	return Facings[self.Container]
end

function FacingComponent:SetFacing(facing: Facing)
	self.Container = table.find(Facings, facing)
end

function FacingComponent:getFacingID(facing: Facing)
	return table.find(Facings, facing)
end

export type FacingComponent = typeof(FacingComponent)

return FacingComponent
