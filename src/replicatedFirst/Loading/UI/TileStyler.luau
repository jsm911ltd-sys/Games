--!strict

local Theme = require(script.Parent.Theme)
local GradientUtil = require(script.Parent.GradientUtil)
local NoiseUtil = require(script.Parent.NoiseUtil)

export type Tile = {
  frame: Frame,
  stroke: UIStroke,
  corner: UICorner,
  col: number,
  row: number,
}

local Styler = {}

function Styler.setUnloaded(tile: Tile, _idx: number)
  tile.stroke.Transparency = Theme.get().strokeTransparency
  tile.corner.CornerRadius = UDim.new(Theme.get().cornerRadius, 0)
  tile.frame.BackgroundTransparency = 0
  tile.frame.BackgroundColor3 = NoiseUtil.unloadedColor(tile.col, tile.row)
end

function Styler.setLoaded(tile: Tile, gridFrame: Frame)
  tile.stroke.Transparency = 1
  tile.corner.CornerRadius = UDim.new(0, 0)
  tile.frame.BackgroundTransparency = 0
  local absPos = gridFrame.AbsolutePosition
  local absSize = gridFrame.AbsoluteSize
  local center = tile.frame.AbsolutePosition + tile.frame.AbsoluteSize * 0.5
  local norm = Vector2.new(
    if absSize.X > 0 then (center.X - absPos.X) / absSize.X else 0.5,
    if absSize.Y > 0 then (center.Y - absPos.Y) / absSize.Y else 0.5
  )
  tile.frame.BackgroundColor3 = GradientUtil.sample(norm)
end

return Styler
