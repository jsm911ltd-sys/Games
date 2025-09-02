--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages:WaitForChild("Fusion"))

-- Create a Fusion 0.3 scope and export it
local scope = Fusion.scoped(Fusion)
return scope

