local function UseTool(id: number)
	return function()
		print(id)
	end
end

return {
	UseTool = UseTool,
}
