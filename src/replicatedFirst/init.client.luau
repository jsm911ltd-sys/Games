--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

-- Remove Roblox's default loading screen; we will show our own.
pcall(function()
  ReplicatedFirst:RemoveDefaultLoadingScreen()
end)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Loading = script:WaitForChild("Loading")
local State = require(Loading:WaitForChild("State"))
local View = require(Loading:WaitForChild("View"))

local state = State.create()
local screenGui = View.create(state)
screenGui.Parent = playerGui

-- Track ContentProvider request queue as a rough progress signal.
local initialQueue = ContentProvider.RequestQueueSize

local function updateProgress()
  local q = ContentProvider.RequestQueueSize
  local p = 0
  if initialQueue > 0 then
    p = math.clamp(1 - (q / initialQueue), 0, 0.98)
  else
    p = game:IsLoaded() and 0.98 or 0
  end
  state.progress:set(p)
  state.statusText:set("Loading assets...")
end

updateProgress()
local conn = ContentProvider:GetPropertyChangedSignal("RequestQueueSize"):Connect(updateProgress)

task.spawn(function()
  -- Wait for the game to fully load
  game.Loaded:Wait()

  -- Give the request queue a short grace period to drain
  local t0 = os.clock()
  while ContentProvider.RequestQueueSize > 0 and os.clock() - t0 < 5 do
    updateProgress()
    RunService.RenderStepped:Wait()
  end

  if conn.Connected then
    conn:Disconnect()
  end

  state.progress:set(1)
  state.statusText:set("Ready!")

  -- Smooth fade-out
  local duration = 0.35
  local start = os.clock()
  while true do
    local t = (os.clock() - start) / duration
    if t >= 1 then
      break
    end
    state.opacity:set(1 - t)
    RunService.RenderStepped:Wait()
  end
  state.opacity:set(0)
  screenGui:Destroy()
end)

