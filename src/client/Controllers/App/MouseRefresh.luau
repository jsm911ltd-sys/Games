--!strict

-- Attempts to force the mouse cursor to refresh by nudging it ~1px.
-- Strategies (in order):
-- 1) VirtualInputManager:SendMouseMove (Studio/dev only, safest visual result)
-- 2) Toggle MouseBehavior quickly (can also refresh hover state)
-- 3) Fallback: Toggle MouseIconEnabled briefly

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function nudgeWithVIM(): boolean
  local ok, vimService = pcall(function()
    return game:FindService("VirtualInputManager")
  end)
  if not ok or vimService == nil then
    return false
  end

  local sendMove = (vimService :: any).SendMouseMove
  if type(sendMove) ~= "function" then
    return false
  end

  local pos = UserInputService:GetMouseLocation()
  local x, y = pos.X, pos.Y

  -- Nudge right by 1, then back to original
  sendMove(vimService, x + 1, y)
  RunService.Heartbeat:Wait()
  sendMove(vimService, x, y)
  return true
end

local function nudgeWithBehavior(): boolean
  local old = UserInputService.MouseBehavior
  local ok = pcall(function()
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    RunService.Heartbeat:Wait()
    UserInputService.MouseBehavior = old
  end)
  return ok
end

local function nudgeWithIconToggle(): boolean
  local old = UserInputService.MouseIconEnabled
  local ok = pcall(function()
    UserInputService.MouseIconEnabled = not old
    RunService.Heartbeat:Wait()
    UserInputService.MouseIconEnabled = old
  end)
  return ok
end

local function nudge(): string
  if nudgeWithVIM() then
    return "vim"
  end
  if nudgeWithBehavior() then
    return "behavior"
  end
  if nudgeWithIconToggle() then
    return "icon"
  end
  return "none"
end

return {
  nudge = nudge,
}

