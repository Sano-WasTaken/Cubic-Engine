local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

local stone = Block:declareNewBlockClass({ ClassName = "Stone" })

local andesite = stone:newVariant({ ClassName = "Andesite", SavedProperties = { facing = true } })

local b = andesite:declareNewBlockFromClass()

b:SetFacing("SOUTH")

print(b:GetFacing(), b)
