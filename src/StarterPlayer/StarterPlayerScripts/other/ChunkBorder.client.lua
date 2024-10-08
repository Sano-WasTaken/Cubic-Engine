local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local InfoController = require(ReplicatedStorage.UI.Controllers.InfoController)

local DEBUG = RunService:IsStudio()

local BLOCK_SIZE = 3

local CHUNK_SIZE = Vector3.new(16, 256, 16)

local RANGE = 20

local borders = {} :: { { Part } }

local function getChunkFromPosition(x: number, y: number): (number, number)
	x, y = x / 3, y / 3

	local cx, cy = (x // CHUNK_SIZE.X), (y // CHUNK_SIZE.Z)

	return cx, cy
end

local function createChunkBorder(cx: number, cy: number)
	local part = Instance.new("Part")

	part.Size = CHUNK_SIZE * BLOCK_SIZE
	part.Position = Vector3.new(
		(cx * CHUNK_SIZE.X * BLOCK_SIZE) - part.Size.X / 2 - BLOCK_SIZE / 2,
		0 + part.Size.Y / 2 - BLOCK_SIZE / 2,
		(cy * CHUNK_SIZE.Z * BLOCK_SIZE) - part.Size.Z / 2 - BLOCK_SIZE / 2
	)

	local highlight = Instance.new("SelectionBox")

	highlight.Adornee = part
	highlight.Parent = part

	part.Transparency = 1 -- 0.95
	part.Anchored = true
	part.Material = Enum.Material.SmoothPlastic
	part.BrickColor = BrickColor.Yellow()
	part.CanCollide = false
	part.CanQuery = false
	part.Name = cx .. " | " .. cy

	--part.Parent = workspace

	borders[cx] = borders[cx] or {}

	borders[cx][cy] = part
end

InfoController:Init()

if DEBUG then
	for i = -RANGE, RANGE do
		for j = -RANGE, RANGE do
			createChunkBorder(i, j)
		end
	end

	local toggle = true

	UserInputService.InputBegan:Connect(function(a0: InputObject, a1: boolean)
		if a0.KeyCode ~= Enum.KeyCode.B then
			return
		end

		for _, rows in borders do
			for _, part in rows do
				part.Parent = toggle and workspace or nil
			end
		end

		InfoController:Toggle()

		toggle = not toggle
	end)
end

RunService.Heartbeat:Connect(function(_: number)
	local character = Players.LocalPlayer.Character

	if character == nil then
		return
	end

	local HumanoidRootPart: Part = character:FindFirstChild("HumanoidRootPart")

	if HumanoidRootPart == nil then
		return
	end

	local posistion = HumanoidRootPart.Position

	local cx, cy = getChunkFromPosition(posistion.X, posistion.Z)

	InfoController:Set(cx, cy)
end)
