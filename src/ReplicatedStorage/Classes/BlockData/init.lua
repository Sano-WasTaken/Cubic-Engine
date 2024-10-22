local Variant = require(script.Variant)

local BlockData = {}

local PALLETTE_PATTERN = "%s:%s"

export type BlockData = typeof(BlockData) & { id: number, sid: string, variants: { Variant.Variant } }

--[[
Palettes are important, you can have like 4096 (12bits) variant in a palette, how it works:

- in the chunk buffer data (12bits buffer) you can store an id from a palette (like stone:nid=1)
- in the variant buffer data (same as the chunk buffer data in 12bits) you can store the variant in the palette (like sandstone:vnid=15)

CREATE A NEW PALETTE.
- nid: Numerical Identifier
- sid: String Indentifier
]]
local function newBlockData(nid: number, sid: string): BlockData
	return setmetatable({ id = nid, sid = sid, variants = {} }, { __index = BlockData }) :: any
end

function BlockData.CreateVariant(self: BlockData, variant: Variant.Variant): BlockData
	local index = #self.variants + 1

	assert(index < 4096, "variant out of bounds")

	variant.id = index
	self.variants[index] = variant

	return self
end

function BlockData.GetPSID(self: BlockData): string
	return self.sid
end

function BlockData.GetPNID(self: BlockData): number
	return self.id
end

--[[
GET THE VARIANT STRING ID.
- vnid: Variant Numerical Identifier
- vsid: Variant String Indentifier

**EXEMPLE:**
```lua
Palette:GetPSIDFromVNID(15): "stone:sandstone"
```
]]
function BlockData.GetPSIDFromVNID(self: BlockData, vnid: number): string
	local variant = self.variants[vnid]

	return PALLETTE_PATTERN:format(self.sid, variant.sid)
end

--[[
GET ALL VARIANTS STRING ID FROM A PALETTE ().
- psid: Palette String Indentifier

**EXEMPLE:**
```lua
Palette:GetAllVSID(): { "stone:andesite", "stone:diorite", ... }
```
]]
function BlockData.GetAllPSID(self: BlockData): { string }
	local sids = {}

	for vid, variant in self.variants do
		local svid = PALLETTE_PATTERN:format(self.sid, variant.sid)

		sids[vid] = svid
	end

	return sids
end

--[[
GET VARIANT NUMERICAL ID FROM HIS PALETTE STRING ID.
- psid: Palette String Indentifier
- vnid: Variant Numerical Indentifier

**EXEMPLE:**
```lua
Palette:GetVNIDFromPSID("stone:sandstone"): 15
```
]]
function BlockData.GetVNIDFromPSID(self: BlockData, psid: string): number
	local vsid = psid:match(":(w+)$") :: string

	local vid = 0

	for vnid, variant in self.variants do
		if variant.sid == vsid then
			vid = vnid
			break
		end
	end

	return vid
end

--[[
GET VARIANT NUMERICAL ID FROM HIS STRING ID.
- vsid: Variant String Indentifier
- vsid: Variant Numerical Indentifier

**EXEMPLE:**
```lua
Palette:GetVNIDFromVSID("sandstone"): 15
```
]]
function BlockData.GetVNIDFromVSID(self: BlockData, vsid: string): number
	local vid = 0

	for vnid, variant in self.variants do
		if variant.sid == vsid then
			vid = vnid
			break
		end
	end

	return vid
end

--[[
GET VARIANT SID AND PALETTE SID.

**EXEMPLE:**
```lua
GET_VSID_PSID_FROM_SID("stone:sandstone"): ("stone", "sandstone")
```
]]
local function GET_VSID_PSID_FROM_SID(sid: string)
	local psid, vsid = sid:match("(%w+):(%w+)")

	if psid == nil or vsid == nil then
		error("Error: the sid is not valid.")
	end

	return psid, vsid
end

return {
	newBlockData = newBlockData,
	newVariant = Variant,
	GET_VSID_PSID_FROM_SID = GET_VSID_PSID_FROM_SID,
}
