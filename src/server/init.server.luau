--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Require Loader from shared Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
-- Wally wrapper names match the key in wally.toml (case-sensitive).
-- Your dependency key is "loader", so the wrapper is likely "loader" not "Loader".
local loaderModule = Packages:FindFirstChild("Loader") or Packages:FindFirstChild("loader")
if not loaderModule then
    error("Loader package not found under ReplicatedStorage.Packages (expected 'Loader' or 'loader'). Did you run 'wally install' and connect Rojo?")
end
local Loader = require(loaderModule)

-- Load your server ModuleScripts
-- Prefer a Services folder if present, else load everything under this folder
local root = script.Parent
local services = root:FindFirstChild("Services")
if services then
    Loader.LoadDescendants(services)
else
    Loader.LoadDescendants(root)
end
