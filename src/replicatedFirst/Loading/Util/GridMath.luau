--!strict

local Config = require(script.Parent.Parent.Core.Config)

export type Result = {
  cols: number,
  rows: number,
}

local GridMath = {}

function GridMath.compute(containerSize: Vector2): Result
  local gridCfg = Config.grid
  local minPx = math.max(2, gridCfg.minCellPx)
  local gutter = gridCfg.gutterPx

  local cols = math.floor(containerSize.X / math.max(1, (minPx + gutter)))
  local rows = math.floor(containerSize.Y / math.max(1, (minPx + gutter)))

  cols = math.clamp(cols, 8, gridCfg.maxCols)
  rows = math.clamp(rows, 6, gridCfg.maxRows)

  local maxTiles = gridCfg.maxTiles or (gridCfg.maxCols * gridCfg.maxRows)
  local total = math.max(1, cols * rows)
  if total > maxTiles then
    local scale = math.sqrt(total / maxTiles)
    cols = math.max(1, math.floor(cols / scale))
    rows = math.max(1, math.floor(rows / scale))
  end

  return { cols = cols, rows = rows }
end

return GridMath
