--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages:WaitForChild("Fusion"))

-- Create and export a Fusion 0.3 scope
local scope = Fusion.scoped(Fusion)
return scope

