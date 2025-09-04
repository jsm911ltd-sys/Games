--!strict

-- Entry point for the loading screen. Step 1 mounts UI, drives simple demo progress in Studio.

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

local Config = require(script.Parent.Core.Config)
local Aggregator = require(script.Parent.Core.ProgressAggregator)
local ViewVanilla = require(script.Parent.UI.ViewVanilla)

-- Mount our UI first, then remove the default loader so there is no flash.
local view = ViewVanilla.new()
-- Mount to PlayerGui for compatibility in live games
local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")
view:mount(playerGui)
pcall(function()
  ReplicatedFirst:RemoveDefaultLoadingScreen()
end)

-- Hook skip (visual-only skip for now; preloading continues once we wire it)
view:onSkip(function()
  -- In a future step, mark a telemetry flag / notify aggregator
end)

-- Wire the aggregator to the view
local agg = Aggregator.new()
agg:subscribe(function(p)
  view:setProgress(p)
end)

-- Expose a minimal global for future wiring (safe, namespaced)
-- game:GetService("ReplicatedStorage") will exist, but avoid cross-deps here.
-- Developers can later set progress via _G if needed during bring-up.
_G.__GamesLoader = {
  setProgress = function(p: number)
    agg:setProgress(p)
  end,
}

-- Demo driver in Studio only, if enabled
if Config.demo.enabled and RunService:IsStudio() then
  local duration = math.max(0.1, Config.demo.durationSec)
  local start = os.clock()
  while true do
    local t = os.clock() - start
    local p = math.clamp(t / duration, 0, 1)
    agg:setProgress(p)
    if p >= 1 then
      break
    end
    task.wait(0.016)
  end
  -- For step 1, simple fade-out; flip-wave will be added next step
  task.delay(0.1, function()
    view:destroy()
  end)
end
