--!strict

-- Fusion-based view, matching the View interface of ViewVanilla.
-- Step 1: build skeleton (root, grid container, overlay, skip), generate tiles via Fusion.New.

local Config = require(script.Parent.Parent.Core.Config)
local Theme = require(script.Parent.Theme)
local getFusion = require(script.Parent.Parent.Vendor.FusionFinder)

export type View = {
  mount: (self: View, parent: Instance) -> (),
  setProgress: (self: View, p: number) -> (),
  setStatus: (self: View, status: string) -> (),
  onSkip: (self: View, cb: () -> ()) -> (),
  destroy: (self: View) -> (),
}

type Tile = { frame: Frame, stroke: UIStroke, corner: UICorner }

local ViewImpl = {}
ViewImpl.__index = ViewImpl

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

local function sampleGradientColor(normPos: Vector2): Color3
  local theme = Theme.get()
  local t = math.clamp((normPos.X + normPos.Y) * 0.5, 0, 1)
  if t <= 0.5 then
    local a = t * 2
    return theme.accent:Lerp(theme.primary, a)
  else
    local a = (t - 0.5) * 2
    return theme.primary:Lerp(theme.accent, a)
  end
end

local function buildFillOrder(cols: number, rows: number): { number }
  local total = cols * rows
  local pairsArr = table.create(total)
  local idx = 1
  local function prng(x: number, y: number): number
    local s = math.sin(x * 12.9898 + y * 78.233) * 43758.5453
    return s - math.floor(s)
  end
  for r = 1, rows do
    for c = 1, cols do
      local key = prng(c, r)
      pairsArr[idx] = { key = key, i = ((r - 1) * cols + c) }
      idx += 1
    end
  end
  table.sort(pairsArr, function(a, b)
    return a.key < b.key
  end)
  local order = table.create(total)
  for i = 1, total do
    order[i] = pairsArr[i].i
  end
  return order
end

function ViewImpl.new(): View
  local self = setmetatable({}, ViewImpl) :: any
  local s = self :: any
  s._F = nil
  s._gui = nil :: ScreenGui?
  s._root = nil :: Frame?
  s._grid = nil :: Frame?
  s._tiles = {} :: { Tile }
  s._cols = 0
  s._rows = 0
  s._order = nil :: { number }?
  s._skipBtn = nil :: TextButton?
  s._statusLabel = nil :: TextLabel?
  s._progress = 0
  s._skipCb = nil :: (() -> ())?
  s._lastLoaded = 0
  return s
end

function ViewImpl:mount(parent: Instance)
  local s = self :: any
  local F = getFusion()
  if not F then
    error("Fusion not available; cannot mount Fusion view")
  end
  s._F = F
  local theme = Theme.get()

  local New = F.New

  local gui = New("ScreenGui")({
    Name = "GlitchGridLoader_Fusion",
    DisplayOrder = 10000,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    Enabled = true,
    Parent = parent,
  })

  local root = New("Frame")({
    Name = "Root",
    BackgroundColor3 = theme.bgColor,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    Parent = gui,
  })

  do
    local grad = Instance.new("UIGradient")
    grad.Rotation = 45
    grad.Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0, Theme.get().accent),
      ColorSequenceKeypoint.new(0.5, Theme.get().primary),
      ColorSequenceKeypoint.new(1, Theme.get().accent),
    })
    grad.Parent = root
  end

  local overlay = New("Frame")({
    Name = "Overlay",
    BackgroundTransparency = 1,
    ZIndex = 2,
    Size = UDim2.fromScale(1, 1),
    Parent = root,
  })

  local gridFrame = New("Frame")({
    Name = "Grid",
    BackgroundTransparency = 1,
    ZIndex = 1,
    Size = UDim2.fromScale(1, 1),
    Parent = root,
  })

  local status = New("TextLabel")({
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
    Parent = overlay,
  })

  local skipBtn = New("TextButton")({
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
    Parent = overlay,
  })
  do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = skipBtn
  end

  -- Build initial grid
  self:_rebuildGridFusion(gridFrame)

  if Config.skip.enabled then
    task.delay(Config.skip.delayMs / 1000, function()
      if not (self :: any)._gui then
        return
      end
      skipBtn.Visible = true
    end)
  end

  skipBtn.Activated:Connect(function()
    local cb = (self :: any)._skipCb
    if cb then
      cb()
    end
    self:destroy()
  end)

  gridFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    self:_rebuildGridFusion(gridFrame)
    local s2 = self :: any
    self:setProgress(s2._progress)
  end)

  s._gui = gui
  s._root = root
  s._grid = gridFrame
  s._statusLabel = status
  s._skipBtn = skipBtn
end

function ViewImpl:_rebuildGridFusion(gridFrame: Frame)
  local s = self :: any
  local theme = Theme.get()
  for _, child in ipairs(gridFrame:GetChildren()) do
    child:Destroy()
  end
  local cols, rows = computeGrid(gridFrame.AbsoluteSize)
  s._cols = cols
  s._rows = rows
  s._order = buildFillOrder(cols, rows)

  local layout = Instance.new("UIGridLayout")
  layout.CellPadding = UDim2.fromOffset(0, 0)
  layout.FillDirectionMaxCells = cols
  layout.FillDirection = Enum.FillDirection.Horizontal
  layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
  layout.VerticalAlignment = Enum.VerticalAlignment.Top
  layout.SortOrder = Enum.SortOrder.LayoutOrder
  layout.CellSize = UDim2.fromScale(1 / cols, 1 / rows)
  layout.Parent = gridFrame

  local tiles = {} :: { Tile }
  local total = cols * rows
  tiles[total] = nil

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
    tiles[i] = { frame = f, stroke = stroke, corner = corner }
  end

  s._tiles = tiles
  s._lastLoaded = 0
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
  local last = s._lastLoaded or 0
  if last < 0 or last > total then
    last = 0
  end
  local gridAbsPos = (s._grid :: Frame).AbsolutePosition
  local gridAbsSize = (s._grid :: Frame).AbsoluteSize
  local function setLoaded(idx: number)
    local t = tiles[idx]
    t.stroke.Transparency = 1
    t.corner.CornerRadius = UDim.new(0, 0)
    t.frame.BackgroundTransparency = 0
    local center = t.frame.AbsolutePosition + t.frame.AbsoluteSize * 0.5
    local norm = Vector2.new(
      if gridAbsSize.X > 0 then (center.X - gridAbsPos.X) / gridAbsSize.X else 0.5,
      if gridAbsSize.Y > 0 then (center.Y - gridAbsPos.Y) / gridAbsSize.Y else 0.5
    )
    t.frame.BackgroundColor3 = sampleGradientColor(norm)
  end
  local function setUnloaded(idx: number)
    local t = tiles[idx]
    t.stroke.Transparency = Theme.get().strokeTransparency
    t.corner.CornerRadius = UDim.new(Theme.get().cornerRadius, 0)
    t.frame.BackgroundTransparency = 0
    t.frame.BackgroundColor3 = if idx % 2 == 0 then theme.unloadedA else theme.unloadedB
  end

  if not order then
    if loaded < last then
      for i = loaded + 1, last do
        setUnloaded(i)
      end
    end
    for i = last + 1, loaded do
      setLoaded(i)
    end
  else
    if loaded < last then
      for k = loaded + 1, last do
        local idx = (order :: any)[k]
        setUnloaded(idx)
      end
    end
    for k = last + 1, loaded do
      local idx = (order :: any)[k]
      setLoaded(idx)
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
