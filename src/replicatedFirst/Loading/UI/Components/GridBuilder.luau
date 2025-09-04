--!strict

local Theme = require(script.Parent.Parent.Theme)
local GridMath = require(script.Parent.Parent.Parent.Util.GridMath)
local FillOrder = require(script.Parent.Parent.Parent.Util.FillOrder)
local TileStyler = require(script.Parent.Parent.TileStyler)
local GuiUtil = require(script.Parent.Parent.Parent.Util.GuiUtil)

export type Tile = TileStyler.Tile

export type Grid = {
  frame: Frame,
  tiles: { Tile },
  cols: number,
  rows: number,
  build: (self: Grid) -> (),
  styleInitial: (self: Grid) -> (),
  setProgress: (self: Grid, p: number) -> (),
  destroy: (self: Grid) -> (),
}

local GridBuilder = {}
GridBuilder.__index = GridBuilder

function GridBuilder.new(parent: Instance): Grid
  local frame = Instance.new("Frame")
  frame.Name = "Grid"
  frame.BackgroundTransparency = 1
  frame.ZIndex = 1
  frame.Size = UDim2.fromScale(1, 1)
  frame.ClipsDescendants = true
  frame.Visible = false
  frame.Parent = parent

  local self = setmetatable({
    frame = frame,
    tiles = {},
    cols = 0,
    rows = 0,
    _order = nil :: { number }?,
    _lastLoaded = 0,
  }, GridBuilder) :: any

  return self :: any
end

function GridBuilder:build()
  GuiUtil.awaitNonZeroSize(self.frame, 1)
  for _, child in ipairs(self.frame:GetChildren()) do
    child:Destroy()
  end

  local theme = Theme.get()
  local res = GridMath.compute(self.frame.AbsoluteSize)
  self.cols, self.rows = res.cols, res.rows
  self._order = FillOrder.get(self.cols, self.rows)

  local tiles = {} :: { Tile }
  local total = self.cols * self.rows
  tiles[total] = nil

  local abs = self.frame.AbsoluteSize
  local baseW = math.max(1, math.floor(abs.X / math.max(1, self.cols)))
  local baseH = math.max(1, math.floor(abs.Y / math.max(1, self.rows)))
  local extraW = math.max(0, math.floor(abs.X - baseW * self.cols))
  local extraH = math.max(0, math.floor(abs.Y - baseH * self.rows))

  local function colWidth(c: number): number
    return baseW + (if c <= extraW then 1 else 0)
  end
  local function rowHeight(r: number): number
    return baseH + (if r <= extraH then 1 else 0)
  end

  local y = 0
  for r = 1, self.rows do
    local h = rowHeight(r)
    local x = 0
    for c = 1, self.cols do
      local w = colWidth(c)

      local f = Instance.new("Frame")
      f.ZIndex = 1
      f.BackgroundColor3 = theme.unloadedB
      f.BorderSizePixel = 0
      f.Name = string.format("Tile_%d_%d", r, c)
      f.Position = UDim2.fromOffset(x, y)
      f.Size = UDim2.fromOffset(w, h)

      local corner = Instance.new("UICorner")
      corner.CornerRadius = UDim.new(Theme.get().cornerRadius, 0)
      corner.Parent = f

      local stroke = Instance.new("UIStroke")
      stroke.Thickness = 1
      stroke.Transparency = Theme.get().strokeTransparency
      stroke.Color = theme.unloadedA:lerp(theme.bgColor, 0.5)
      stroke.Parent = f

      f.Parent = self.frame
      local i = (r - 1) * self.cols + c
      tiles[i] = { frame = f, stroke = stroke, corner = corner, col = c, row = r }

      x += w
      if i % 1600 == 0 then
        task.wait()
      end
    end
    y += h
  end

  self.tiles = tiles
  self._lastLoaded = 0
end

function GridBuilder:styleInitial()
  for i = 1, #self.tiles do
    TileStyler.setUnloaded(self.tiles[i], i)
  end
  self.frame.Visible = true
end

function GridBuilder:setProgress(p: number)
  local tiles = self.tiles
  if #tiles == 0 then
    return
  end
  local total = #tiles
  local loaded = math.floor(math.clamp(p, 0, 1) * total)
  local order = self._order
  if not order or #order ~= total then
    order = nil
  end
  local function setLoaded(idx: number)
    TileStyler.setLoaded(tiles[idx], self.frame)
  end
  local function setUnloaded(idx: number)
    TileStyler.setUnloaded(tiles[idx], idx)
  end

  local last = self._lastLoaded or 0
  if last < 0 or last > total then
    last = 0
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
  self._lastLoaded = loaded
end

function GridBuilder:destroy()
  self.tiles = {}
  self.frame:Destroy()
end

return GridBuilder
