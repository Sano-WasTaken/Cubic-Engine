local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient") :: ModuleScript)

CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
