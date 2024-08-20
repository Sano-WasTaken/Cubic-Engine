return {
	id = 0,
	-- accept position vector, direction vector and normalized vector
	callback = function(position: Vector3, _: Vector3, normal: Vector3): (Vector3, Vector3)
		return (position + normal), Vector3.zero
	end,
}
