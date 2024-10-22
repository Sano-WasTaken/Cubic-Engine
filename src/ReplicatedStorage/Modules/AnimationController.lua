local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemContent = require(ReplicatedStorage.Classes.ItemContent)
local Controller = {
	tracks = {},
}

function Controller.Animate(self: AnimationController, name: string, item: ItemContent.ItemContent)
	local track = item:Animate()
	local speed = item.Speed

	if track then
		track.Looped = false
		track:AdjustSpeed(track.Length / speed)

		track:Play()

		self.tracks[name] = track
	end
end

function Controller.Stop(self: AnimationController, name: string)
	self.tracks[name]:Stop()
end

export type AnimationController = typeof(Controller)

return Controller
