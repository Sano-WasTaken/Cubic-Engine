local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return {
	MouseRay = Red.Event("MouseRay", function(ray: Ray)
		assert(typeof(ray) == "Ray", "not a Ray")

		return ray
	end),
}
