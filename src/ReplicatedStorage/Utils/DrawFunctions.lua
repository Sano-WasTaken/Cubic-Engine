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

		DrawLine({ x = x1, y = 0, z = y1 }, { x = x2, y = 0, z = y2 }, function(x: number, _, z: number): nil
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

return {
	DrawCircle = DrawCircle,
	DrawRectangle = DrawRectangle,
	DrawLine = DrawLine,
	DrawPolygon = DrawPolygon,
	DrawCuboid = DrawCuboid,
}
