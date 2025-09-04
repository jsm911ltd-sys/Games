--!strict

-- Attempts to locate Fusion in a way that works early in ReplicatedFirst.
-- Returns the Fusion module table, or nil if not currently available.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function findInReplicatedStorage(): any?
  local pkgs = ReplicatedStorage:FindFirstChild("Packages")
  if not pkgs then
    return nil
  end
  local mod = pkgs:FindFirstChild("Fusion") or pkgs:FindFirstChild("fusion")
  if not mod then
    return nil
  end
  local ok, res = pcall(require, mod)
  if ok then
    return res
  end
  return nil
end

return function(): any?
  -- Try ReplicatedStorage packages first
  local fusion = findInReplicatedStorage()
  if fusion then
    return fusion
  end
  -- Could be extended to look in a vendored path under ReplicatedFirst
  return nil
end
