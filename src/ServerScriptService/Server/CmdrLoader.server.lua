local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage.Packages.Cmdr)

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterCommandsIn(ReplicatedStorage.Commands)
