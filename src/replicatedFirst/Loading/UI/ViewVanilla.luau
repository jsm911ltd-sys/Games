--!strict

-- Vanilla UI view for the grid-based loader.
-- Step 1: build responsive grid and map progress to loaded tiles.

local Config = require(script.Parent.Parent.Core.Config)
local Theme = require(script.Parent.Theme)
local RunService = game:GetService("RunService")
local GuiUtil = require(script.Parent.Parent.Util.GuiUtil)
local GridBuilder = require(script.Parent.Components.GridBuilder)
local SkipButton = require(script.Parent.Components.SkipButton)
local StatusLabel = require(script.Parent.Components.StatusLabel)

export type View = {
  mount: (self: View, parent: Instance) -> (),
  setProgress: (self: View, p: number) -> (),
  setStatus: (self: View, status: string) -> (),
  onSkip: (self: View, cb: () -> ()) -> (),
  destroy: (self: View) -> (),
}

type Tile = GridBuilder.Tile

local ViewImpl = {}
ViewImpl.__index = ViewImpl

local function createInstance<T>(className: string, props: { [string]: any }, children: { Instance }?): any
  local inst = Instance.new(className)
  for k, v in pairs(props) do
    (inst :: any)[k] = v
  end
  if children then
    for _, child in ipairs(children) do
      child.Parent = inst
    end
  end
  return inst
end

-- Grid math and gradient are provided by Util modules

function ViewImpl.new(): View
  local self = setmetatable({}, ViewImpl) :: any
  local s = self :: any
  s._gui = nil :: ScreenGui?
  s._root = nil :: Frame?
  s._grid = nil :: Frame?
  s._tiles = {} :: { Tile }
  s._cols = 0
  s._rows = 0
  s._skipBtn = nil :: TextButton?
  s._statusLabel = nil :: TextLabel?
  s._progress = 0
  s._skipCb = nil :: (() -> ())?
  s._skipShown = false
  return s
end

function ViewImpl:mount(parent: Instance)
  local theme = Theme.get()

  local gui = createInstance("ScreenGui", {
    Name = "GlitchGridLoader",
    DisplayOrder = 10000,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    Enabled = true,
  }) :: ScreenGui

  local root = createInstance("Frame", {
    Name = "Root",
    BackgroundColor3 = theme.bgColor,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
  }) :: Frame
  root.Parent = gui

  do
    -- subtle diagonal background gradient for synthwave vibe
    local grad = Instance.new("UIGradient")
    grad.Rotation = 45
    grad.Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0, Theme.get().accent),
      ColorSequenceKeypoint.new(0.5, Theme.get().primary),
      ColorSequenceKeypoint.new(1, Theme.get().accent),
    })
    grad.Parent = root
  end

  local overlay = createInstance("Frame", {
    Name = "Overlay",
    BackgroundTransparency = 1,
    ZIndex = 2,
    Size = UDim2.fromScale(1, 1),
  }) :: Frame
  overlay.Parent = root

  -- Grid (modular)
  local grid = require(script.Parent.Components.GridBuilder).new(root)

  require(script.Parent.Parent.Util.GuiUtil).awaitNonZeroSize(root, 1)

  local statusObj = require(script.Parent.Components.StatusLabel).new(overlay)

  local skipBtnObj = require(script.Parent.Components.SkipButton).new(overlay)

  gui.Parent = parent

  grid:build()
  grid:styleInitial()

  -- Delayed show skip
  if Config.skip.enabled then
    local s = self :: any
    task.delay(Config.skip.delayMs / 1000, function()
      if not s._gui then
        return
      end
      skipBtnObj:setVisible(true)
      s._skipShown = true
    end)
  end

  skipBtnObj:onActivated(function()
    local cb = (self :: any)._skipCb
    if cb then
      cb()
    end
    self:_fadeOutAndDestroy()
  end)

  -- Handle resize: rebuild grid if dimensions change significantly
  local conn
  conn = grid.frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    grid:build()
    local s2 = self :: any
    grid:setProgress(s2._progress)
  end)

  local s = self :: any
  s._gui = gui
  s._root = root
  s._grid = grid.frame
  s._statusLabel = statusObj.instance
  s._skipBtn = skipBtnObj.instance
  s._gridObj = grid
end

function ViewImpl:_clearTiles() end -- handled by GridBuilder

-- Fill order provided by Util.FillOrder

function ViewImpl:_rebuildGrid(_gridFrame: Frame) end -- handled by GridBuilder

function ViewImpl:setProgress(p: number)
  local s = self :: any
  s._progress = math.clamp(p, 0, 1)
  local gridObj = s._gridObj
  if gridObj then
    gridObj:setProgress(s._progress)
  end
end

function ViewImpl:setStatus(status: string)
  local s = self :: any
  local label = s._statusLabel
  if label then
    label.Text = status
  end
end

function ViewImpl:onSkip(cb: () -> ())
  local s = self :: any
  s._skipCb = cb
end

function ViewImpl:_fadeOutAndDestroy()
  local s = self :: any
  local gui = s._gui
  local root = s._root
  if not gui or not root then
    self:destroy()
    return
  end
  local tweenService = game:GetService("TweenService")
  local tween = tweenService:Create(
    root,
    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    { BackgroundTransparency = 1 }
  )
  tween:Play()
  task.delay(0.27, function()
    self:destroy()
  end)
end

function ViewImpl:destroy()
  local s = self :: any
  local gui = s._gui
  s._gui = nil
  s._grid = nil
  s._tiles = {}
  if gui then
    gui:Destroy()
  end
end

return ViewImpl
