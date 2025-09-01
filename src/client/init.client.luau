--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Require Loader from shared Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Loader = require(Packages:WaitForChild("Loader"))

-- Load your client ModuleScripts
-- Prefer a Controllers folder if present, else load everything under this folder
local root = script.Parent
local controllers = root:FindFirstChild("Controllers")
if controllers then
    Loader.LoadDescendants(controllers)
else
    Loader.LoadDescendants(root)
end
