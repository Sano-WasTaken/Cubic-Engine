local DataProvider = {}

export type DataProvider<T> = {
    InsertData: (self: DataProvider<T>, id: number, data: T) -> DataProvider<T>,
    GetData: (self: DataProvider<T>, id: number) -> T
}

local function new(enumerator: {})
    local self = setmetatable(
        {
            enumerator = enumerator,
            container = {}
        },
        {
            __index = DataProvider
        }
    )

    return self
end

function DataProvider:InsertData(id: number, data)
    self.container[id] = data
    return self
end

function DataProvider:GetData(id: number)
    return self.container[id]
end

return {
    new = new
}