local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enumerator = require(ReplicatedStorage.Classes.Enum)

local enum = Enumerator.new({
	Stone = 1,
	Grass = 2,
	Dirt = 3,
	SpawnBlock = 4,
	SandStone = 5,
	Test_Pickaxe = 6,
	God_Pickaxe = 7,
	Coal_Ore = 8,
	Iron_Ore = 9,
	Copper_Ore = 10,
	Gold_Ore = 11,
	Iron_Block = 12,
	Coal_Block = 13,
	Oak_Log = 14,
	Chest = 15,
	Crystal_Pickaxe = 16,
	Glass = 17,
	Stone_Stairs = 18,
})

return enum
