--!strict

-- Attempts to force the mouse cursor to refresh by nudging it ~1px.
-- Strategies (in order):
-- 1) VirtualInputManager:SendMouseMove (Studio/dev only, safest visual result)
-- 2) Toggle MouseBehavior quickly (can also refresh hover state)
-- 3) Fallback: Toggle MouseIconEnabled briefly

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function nudgeWithVIM(): boolean
  -- Use GetService so the internal service is returned in Studio
  local ok, vimService = pcall(function()
    return game:GetService("VirtualInputManager")
  end)
  if not ok or vimService == nil then
    return false
  end

  -- Some environments restrict these methods; keep under pcall
  local pos = UserInputService:GetMouseLocation()
  local x, y = pos.X, pos.Y
  local okMove1 = pcall(function()
    (vimService :: any):SendMouseMove(x + 1, y)
  end)
  if not okMove1 then
    return false
  end
  RunService.RenderStepped:Wait()
  local _ = pcall(function()
    (vimService :: any):SendMouseMove(x, y)
  end)
  return true
end

local function nudgeWithBehavior(): boolean
  local old = UserInputService.MouseBehavior
  local ok = pcall(function()
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    RunService.RenderStepped:Wait()
    RunService.RenderStepped:Wait()
    UserInputService.MouseBehavior = old
  end)
  return ok
end

local function nudgeWithOverrideIcon(): boolean
  local old = UserInputService.OverrideMouseIconBehavior
  local ok = pcall(function()
    UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceHide
    RunService.RenderStepped:Wait()
    RunService.RenderStepped:Wait()
    UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
    if old ~= nil then
      UserInputService.OverrideMouseIconBehavior = old
    end
  end)
  return ok
end

local function nudgeWithIconToggle(): boolean
  local old = UserInputService.MouseIconEnabled
  local ok = pcall(function()
    UserInputService.MouseIconEnabled = not old
    RunService.RenderStepped:Wait()
    RunService.RenderStepped:Wait()
    UserInputService.MouseIconEnabled = old
  end)
  return ok
end

local function nudgeWithGuiJiggle(gui: GuiObject?): boolean
  if gui == nil or not gui:IsA("GuiObject") then
    return false
  end
  local old = gui.Position
  local function addY1(p: UDim2): UDim2
    return UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + 1)
  end
  local ok = pcall(function()
    gui.Position = addY1(old)
    RunService.RenderStepped:Wait()
    gui.Position = old
    RunService.RenderStepped:Wait()
  end)
  return ok
end

local function nudgeWithTextbox(container: Instance?): boolean
  local screenGui: ScreenGui? = nil
  if container ~= nil then
    if container:IsA("ScreenGui") then
      screenGui = container
    elseif container:IsA("GuiObject") then
      local anc = (container :: GuiObject):FindFirstAncestorOfClass("ScreenGui")
      if anc and anc:IsA("ScreenGui") then
        screenGui = anc
      end
    end
  end
  if screenGui == nil then
    return false
  end

  local box = Instance.new("TextBox")
  box.Name = "_MouseRefreshTextBox"
  box.Size = UDim2.fromOffset(0, 0)
  box.Position = UDim2.fromOffset(-10000, -10000)
  box.TextTransparency = 1
  box.BackgroundTransparency = 1
  box.ClearTextOnFocus = false
  box.Visible = true
  box.Parent = screenGui

  local ok = pcall(function()
    -- Ensure it is mounted before focusing
    RunService.RenderStepped:Wait()
    box:CaptureFocus()
    -- Give time for cursor/hover to flip to caret, then release
    RunService.RenderStepped:Wait()
    RunService.RenderStepped:Wait()
    box:ReleaseFocus()
  end)
  box:Destroy()
  return ok
end

local function nudge(gui: GuiObject?): string
  if nudgeWithVIM() then
    return "vim"
  end
  if nudgeWithTextbox(gui) then
    return "textbox"
  end
  if nudgeWithGuiJiggle(gui) then
    return "gui-jiggle"
  end
  -- Prefer behavior + override icon before simple icon toggle
  if nudgeWithBehavior() then
    return "behavior"
  end
  if nudgeWithOverrideIcon() then
    return "override-icon"
  end
  if nudgeWithIconToggle() then
    return "icon"
  end
  return "none"
end

local function nudgeAfterFrames(gui: GuiObject?, frames: number?): string
  local n = typeof(frames) == "number" and (frames :: number) or 1
  for _ = 1, n do
    RunService.RenderStepped:Wait()
  end
  -- Ensure a heartbeat passes as well in case updates are deferred
  RunService.Heartbeat:Wait()
  return nudge(gui)
end

local function nudgeTextboxAfterFrames(container: Instance?, frames: number?): string
  local n = typeof(frames) == "number" and (frames :: number) or 1
  for _ = 1, n do
    RunService.RenderStepped:Wait()
  end
  RunService.Heartbeat:Wait()
  if nudgeWithTextbox(container) then
    return "textbox"
  end
  -- Soft fallback to GUI jiggle using a GuiObject container if provided
  if container and container:IsA("GuiObject") then
    if nudgeWithGuiJiggle(container :: GuiObject) then
      return "gui-jiggle"
    end
  end
  return "none"
end

return {
  nudge = nudge,
  nudgeAfterFrames = nudgeAfterFrames,
  nudgeTextboxAfterFrames = nudgeTextboxAfterFrames,
}
