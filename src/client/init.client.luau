local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Require Loader from shared Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
-- Wrapper name matches the dependency key in wally.toml (case-sensitive).
local loaderModule = Packages:FindFirstChild("Loader") or Packages:FindFirstChild("loader")
if not loaderModule then
  error(
    "Loader package not found under ReplicatedStorage.Packages (expected 'Loader' or 'loader'). Did you run 'wally install' and connect Rojo?"
  )
end
local Loader = require(loaderModule)

-- Load your client ModuleScripts
-- Prefer a Controllers folder if present, else load everything under this folder
local root = script.Parent
local controllers = root:FindFirstChild("Controllers")
if controllers then
  Loader.LoadDescendants(controllers)
else
  Loader.LoadDescendants(root)
end
