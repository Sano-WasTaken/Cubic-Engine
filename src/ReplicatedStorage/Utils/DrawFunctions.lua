export type Point = { x: number, y: number, z: number }

local function DrawCircle(r: number, xo: number, yo: number, callback: (x: number, y: number) -> nil, empty: boolean)
	for i = -r, r do
		for j = -r, r do
			if
				(not empty and math.round(math.sqrt(i * i + j * j)) <= r)
				or math.round(math.sqrt(i * i + j * j)) == r
			then
				callback(i + xo, j + yo)
			end
		end
	end
end

local function DrawRectangle(
	l: number,
	w: number,
	xo: number,
	yo: number,
	callback: (x: number, y: number) -> nil,
	empty: boolean
)
	for i = 1, l do
		for j = 1, w do
			if not empty or not ((i > 1 and i < l) and (j > 1 and j < w)) then
				callback(i + xo, j + yo)
			end
		end
	end
end

local function DrawLine(pointA: Point, pointB: Point, callback: (x: number, y: number, z: number) -> nil)
	local magnitude =
		math.round(math.sqrt((pointB.x - pointA.x) ^ 2 + (pointB.y - pointA.y) ^ 2 + (pointB.z - pointA.z) ^ 2))

	for i = 1, magnitude do
		local x = math.round(pointA.x + (pointB.x - pointA.x) * (i / magnitude))
		local y = math.round(pointA.y + (pointB.y - pointA.y) * (i / magnitude))
		local z = math.round(pointA.z + (pointB.z - pointA.z) * (i / magnitude))

		callback(x, y, z)
	end
end

-- REDO: Polygon algorithm is totaly unoptimized ! (and it's pretty bad)
local function DrawPolygon(
	segments: number,
	r: number,
	xo: number,
	yo: number,
	angleOffset: number,
	callback: (x: number, y: number) -> nil
)
	assert(segments > 2, "a polygon must have 3 or + segments !")

	local angle = 360 / segments

	for i = 1, segments do
		local a = (i - 1) * angle + angleOffset
		local b = i * angle + angleOffset

		local x1 = xo + math.cos(math.rad(a)) * r
		local y1 = yo + math.sin(math.rad(a)) * r

		local x2 = xo + math.cos(math.rad(b)) * r
		local y2 = yo + math.sin(math.rad(b)) * r

		DrawLine({ x = x1, y = 0, z = y1 }, { x = x2, y = 0, z = y2 }, function(x: number, _, z: number)
			callback(x + xo, z + yo)
		end)
	end
end

local function DrawCuboid(
	l: number,
	h: number,
	w: number,
	offset: Point,
	callback: (x: number, y: number, z: number) -> nil,
	empty: boolean
)
	for i = 1, l do
		for j = 1, h do
			for k = 1, w do
				if (not empty) or not ((i > 1 and i < l) and (j > 1 and j < h) and (k > 1 and k < w)) then
					callback(i + offset.x, j + offset.y, k + offset.z)
				end
			end
		end
	end
end

function DrawSphere(r: number, offset: Vector3, callback: (x: number, y: number, z: number) -> nil, empty: boolean)
	for x = -r, r do
		for y = -r, r do
			for z = -r, r do
				local unit = math.floor(math.sqrt(x * x + y * y + z * z))
				if (not empty and unit <= r) or unit == r then
					callback(x + offset.X, y + offset.Y, z + offset.Z)
				end
			end
		end
	end
end

function DrawEllipsoid(
	axis: Vector3,
	offset: Vector3,
	callback: (x: number, y: number, z: number) -> nil,
	empty: boolean
)
	local thickness = 2

	local a, b, c = axis.X, axis.Y, axis.Z
	local inner_a, inner_b, inner_c = a - thickness, b - thickness, c - thickness

	for x = -axis.X, axis.X do
		for y = -axis.Y, axis.Y do
			for z = -axis.Z, axis.Z do
				local unit = ((x * x) / (a * a) + (y * y) / (b * b) + (z * z) / (c * c))
				local innerUnit = (
					(x * x) / (inner_a * inner_a)
					+ (y * y) / (inner_b * inner_b)
					+ (z * z) / (inner_c * inner_c)
				)

				if (not empty and unit <= 1) or (unit <= 1 and innerUnit >= 1) then
					callback(x + offset.X, y + offset.Y, z + offset.Z)
				end
			end
		end
	end
end

return {
	DrawCircle = DrawCircle,
	DrawRectangle = DrawRectangle,
	DrawLine = DrawLine,
	DrawPolygon = DrawPolygon,
	DrawCuboid = DrawCuboid,
	DrawSphere = DrawSphere,
	DrawEllipsoid = DrawEllipsoid,
}
