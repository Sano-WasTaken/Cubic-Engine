local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Object = require(script.Parent.Object)

local function assertContext()
	assert(RunService:IsServer(), "You should do this in server side .")
end

export type CanvasItem = {
	Mesh: BasePart?,
	Id: number?,
	MaxStackSize: number?,
	ClassName: string?,
}

local ItemContent = {
	Mesh = Instance.new("MeshPart"),
	Id = 0,
	MaxStackSize = 64,
	ClassName = "Item",
	Speed = 1,
	Animation = 110938750432717,
}

setmetatable(ItemContent, { __index = Object })

export type ItemContent = typeof(ItemContent)

function ItemContent:GetClonedMesh(): BasePart
	return self.Mesh:Clone()
end

function ItemContent:IsUsable()
	return self.Use ~= nil
end

function ItemContent:GetTool(): Tool
	local tool = Instance.new("Tool")

	if self:IsA("BlockItem") then
		local handle: Part = self:GetClonedMesh()

		for _, instance in handle:GetChildren() do
			if instance:IsA("Texture") then
				instance.StudsPerTileU = 1.5
				instance.StudsPerTileV = 1.5
			elseif instance:IsA("BasePart") then
				instance.Size = instance.Size / 2
				instance.Anchored = false
				instance.CanCollide = false
			end
		end

		handle.Size = Vector3.one * 1.5

		handle.Name = "Handle"

		handle.Parent = tool
	elseif self:IsA("Tool") then
		local handle: Part = self:GetClonedMesh()

		handle.Name = "Handle"

		handle.Parent = tool
	end

	tool.CanBeDropped = false

	return tool
end

function ItemContent:Animate(): AnimationTrack?
	assert(RunService:IsClient())

	local player = Players.LocalPlayer

	local character = player.Character or player.CharacterAdded:Wait()

	local animator: Animator = character:FindFirstChildOfClass("Humanoid").Animator

	if animator then
		local animation = Instance.new("Animation")

		animation.AnimationId = `rbxassetid://{self.Animation}`

		local track = animator:LoadAnimation(animation)

		return track
	end

	return
end

function ItemContent:GetID()
	return self.Id
end

function ItemContent:extends(class: {})
	return setmetatable(class, { __index = self }) :: typeof(self) & typeof(class)
end

return {
	assertContext = assertContext,
	Class = ItemContent,
}
