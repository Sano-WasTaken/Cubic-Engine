local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enumerator = require(ReplicatedStorage.Classes.Enum)

local enum = Enumerator.new({
	Stone = 1,
	Grass = 2,
	Dirt = 3,
	SpawnBlock = 4,
	SandStone = 5,
	Coal_Ore = 6,
	Iron_Ore = 7,
	Copper_Ore = 8,
	Gold_Ore = 9,
	Iron_Block = 10,
	Coal_Block = 11,
	Oak_Log = 12,
	Chest = 13,
	Glass = 14,
	Stone_Stairs = 15,
})

return enum
