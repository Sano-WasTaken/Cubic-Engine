local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolEnum = require(ReplicatedStorage.Enums.ToolEnum)
local DataProvider = require(ReplicatedStorage.Classes.DataProvider)

export type ToolTip = "Pickaxe" | "Axe" | "Shovel"
export type ToolData = {
	ToolTip: ToolTip,
	BreakSpeed: number,
	Reach: number,
}

type ToolDataProvider = DataProvider.DataProvider<ToolData>

local ToolDataProvider: ToolDataProvider = DataProvider.new(ToolEnum)

ToolDataProvider:InsertData(ToolEnum["Test_Pickaxe"], {
	ToolTip = "Pickaxe",
	BreakSpeed = 1,
	Reach = 25,
})

return ToolDataProvider
