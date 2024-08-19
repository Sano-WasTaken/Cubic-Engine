local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

return function(childs: {Roact.Element})
    local value, update = Roact.createBinding(false)

    return Roact.createElement(
        "ScreenGui",
        {
            IgnoreGuiInset = true, -- default value
            Enabled = value,
            ResetOnSpawn = false,
        },
        childs
    ), update, value
end