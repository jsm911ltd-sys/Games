--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Require Loader from shared Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Loader = require(Packages:WaitForChild("Loader"))

-- Load your server ModuleScripts
-- Prefer a Services folder if present, else load everything under this folder
local root = script.Parent
local services = root:FindFirstChild("Services")
if services then
    Loader.LoadDescendants(services)
else
    Loader.LoadDescendants(root)
end
