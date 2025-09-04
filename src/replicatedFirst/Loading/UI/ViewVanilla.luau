--!strict

-- Vanilla UI view for the grid-based loader.
-- Step 1: build responsive grid and map progress to loaded tiles.

local Config = require(script.Parent.Parent.Core.Config)
local Theme = require(script.Parent.Theme)

export type View = {
  mount: (self: View, parent: Instance) -> (),
  setProgress: (self: View, p: number) -> (),
  setStatus: (self: View, status: string) -> (),
  onSkip: (self: View, cb: () -> ()) -> (),
  destroy: (self: View) -> (),
}

type Tile = {
  frame: Frame,
  stroke: UIStroke,
}

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

local function computeGrid(containerSize: Vector2)
  local gridCfg = Config.grid
  local minPx = math.max(6, gridCfg.minCellPx)
  local gutter = gridCfg.gutterPx
  local cols = math.floor(containerSize.X / (minPx + gutter))
  local rows = math.floor(containerSize.Y / (minPx + gutter))
  cols = math.clamp(cols, 12, gridCfg.maxCols)
  rows = math.clamp(rows, 8, gridCfg.maxRows)

  local maxTiles = gridCfg.maxTiles or (gridCfg.maxCols * gridCfg.maxRows)
  local total = cols * rows
  if total > maxTiles then
    local scale = math.sqrt(total / maxTiles)
    cols = math.max(1, math.floor(cols / scale))
    rows = math.max(1, math.floor(rows / scale))
  end

  return cols, rows
end

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
      ColorSequenceKeypoint.new(0, theme.unloadedB),
      ColorSequenceKeypoint.new(0.5, theme.bgColor:lerp(theme.unloadedA, 0.5)),
      ColorSequenceKeypoint.new(1, theme.unloadedB),
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

  local gridFrame = createInstance("Frame", {
    Name = "Grid",
    BackgroundTransparency = 1,
    ZIndex = 1,
    Size = UDim2.fromScale(1, 1),
  }) :: Frame
  gridFrame.Parent = root

  local status = createInstance("TextLabel", {
    Name = "Status",
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = theme.text,
    TextTransparency = 0.15,
    Font = Enum.Font.Gotham,
    TextSize = 14,
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.fromScale(0.5, 0.96),
    Size = UDim2.fromOffset(400, 20),
    ZIndex = 3,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
  }) :: TextLabel
  status.Parent = overlay

  local skipBtn = createInstance("TextButton", {
    Name = "Skip",
    BackgroundColor3 = theme.unloadedA,
    BorderSizePixel = 0,
    AutoButtonColor = true,
    Text = "Skip (at your own peril)",
    TextColor3 = theme.text,
    TextTransparency = 0.25,
    Font = Enum.Font.GothamMedium,
    TextSize = 14,
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.fromScale(0.5, 0.98),
    Size = UDim2.fromOffset(300, 40),
    Visible = false,
    ZIndex = 4,
  }) :: TextButton
  skipBtn.Parent = overlay
  do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = skipBtn
  end

  gui.Parent = parent

  -- Build initial grid based on size
  self:_rebuildGrid(gridFrame)

  -- Delayed show skip
  if Config.skip.enabled then
    local s = self :: any
    task.delay(Config.skip.delayMs / 1000, function()
      if not s._gui then
        return
      end
      skipBtn.Visible = true
      s._skipShown = true
    end)
  end

  skipBtn.Activated:Connect(function()
    local cb = (self :: any)._skipCb
    if cb then
      cb()
    end
    self:_fadeOutAndDestroy()
  end)

  -- Handle resize: rebuild grid if dimensions change significantly
  local conn
  conn = gridFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    self:_rebuildGrid(gridFrame)
    local s2 = self :: any
    self:setProgress(s2._progress)
  end)

  local s = self :: any
  s._gui = gui
  s._root = root
  s._grid = gridFrame
  s._statusLabel = status
  s._skipBtn = skipBtn
end

function ViewImpl:_clearTiles()
  local s = self :: any
  local grid = s._grid
  if not grid then
    return
  end
  for _, child in ipairs(grid:GetChildren()) do
    child:Destroy()
  end
  s._tiles = {}
end

local function buildFillOrder(cols: number, rows: number): { number }
  local total = cols * rows
  local order = table.create(total)
  for i = 1, total do
    order[i] = i
  end
  -- Fisher-Yates shuffle with deterministic seed for stable visuals
  local rng = Random.new(314159)
  for i = total, 2, -1 do
    local j = rng:NextInteger(1, i)
    order[i], order[j] = order[j], order[i]
  end
  return order
end

function ViewImpl:_rebuildGrid(gridFrame: Frame)
  self:_clearTiles()
  local theme = Theme.get()
  local cols, rows = computeGrid(gridFrame.AbsoluteSize)
  local s = self :: any
  s._cols = cols
  s._rows = rows
  s._order = buildFillOrder(cols, rows)

  -- Pre-create tiles row-major for deterministic mapping
  local tiles = {} :: { Tile }
  local total = cols * rows
  tiles[total] = nil -- pre-size

  -- Compute cell size and gutter as scale by using UIGridLayout with px cell sizes via UISizeConstraint trick
  local layout = Instance.new("UIGridLayout")
  layout.CellPadding = UDim2.fromOffset(Config.grid.gutterPx, Config.grid.gutterPx)
  layout.FillDirectionMaxCells = cols
  layout.FillDirection = Enum.FillDirection.Horizontal
  layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
  layout.VerticalAlignment = Enum.VerticalAlignment.Center
  layout.SortOrder = Enum.SortOrder.LayoutOrder
  layout.Parent = gridFrame

  local cellSizePxX =
    math.floor((gridFrame.AbsoluteSize.X - math.max(0, cols - 1) * Config.grid.gutterPx) / math.max(1, cols))
  local cellSizePxY =
    math.floor((gridFrame.AbsoluteSize.Y - math.max(0, rows - 1) * Config.grid.gutterPx) / math.max(1, rows))
  local cellPx = math.max(4, math.floor(math.min(cellSizePxX, cellSizePxY)))
  layout.CellSize = UDim2.fromOffset(cellPx, cellPx)

  for i = 1, total do
    local f = Instance.new("Frame")
    f.ZIndex = 1
    f.BackgroundColor3 = if i % 2 == 0 then theme.unloadedA else theme.unloadedB
    f.BorderSizePixel = 0
    f.Name = string.format("Tile_%d", i)
    f.LayoutOrder = i

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(Theme.get().cornerRadius, 0)
    corner.Parent = f

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = Theme.get().strokeTransparency
    stroke.Color = theme.unloadedA:lerp(theme.bgColor, 0.5)
    stroke.Parent = f

    f.Parent = gridFrame
    tiles[i] = { frame = f, stroke = stroke }
  end

  s._tiles = tiles
end

function ViewImpl:setProgress(p: number)
  local s = self :: any
  s._progress = math.clamp(p, 0, 1)
  local tiles = s._tiles
  if not tiles then
    return
  end
  local theme = Theme.get()
  local total = #tiles
  if total == 0 then
    return
  end
  local loaded = math.floor(s._progress * total)
  local order = s._order :: { number }?
  if not order or #order ~= total then
    order = nil
  end
  -- Optimize: only update the delta since last call
  local last = s._lastLoaded or 0
  if last < 0 or last > total then
    last = 0
  end
  if not order then
    -- Fallback linear mapping
    -- Reset previous loaded range if progress decreased (unlikely)
    if loaded < last then
      for i = loaded + 1, last do
        local t = tiles[i]
        t.frame.BackgroundTransparency = 0
        t.frame.BackgroundColor3 = if i % 2 == 0 then theme.unloadedA else theme.unloadedB
        t.stroke.Transparency = Theme.get().strokeTransparency
      end
    end
    for i = last + 1, loaded do
      local t = tiles[i]
      t.frame.BackgroundTransparency = 1 -- reveal gradient behind; merges with neighbors
      t.stroke.Transparency = 1
    end
  else
    -- Shuffled order mapping
    if loaded < last then
      for k = loaded + 1, last do
        local idx = (order :: any)[k]
        local t = tiles[idx]
        t.frame.BackgroundTransparency = 0
        t.frame.BackgroundColor3 = if idx % 2 == 0 then theme.unloadedA else theme.unloadedB
        t.stroke.Transparency = Theme.get().strokeTransparency
      end
    end
    for k = last + 1, loaded do
      local idx = (order :: any)[k]
      local t = tiles[idx]
      t.frame.BackgroundTransparency = 1
      t.stroke.Transparency = 1
    end
  end
  s._lastLoaded = loaded
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
