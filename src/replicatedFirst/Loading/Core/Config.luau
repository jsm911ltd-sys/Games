--!strict

export type Theme = {
  bgColor: Color3,
  primary: Color3, -- loaded tiles (violet)
  accent: Color3, -- digits / special (orange)
  unloadedA: Color3, -- base for unloaded
  unloadedB: Color3, -- subtle alt
  text: Color3,
  cornerRadius: number,
  strokeTransparency: number,
}

export type GridConfig = {
  minCellPx: number,
  gutterPx: number,
  maxCols: number,
  maxRows: number,
  maxTiles: number?,
}

export type SkipConfig = {
  enabled: boolean,
  delayMs: number,
  confirm: boolean,
}

export type DemoConfig = {
  enabled: boolean,
  durationSec: number,
}

export type Config = {
  theme: Theme,
  grid: GridConfig,
  skip: SkipConfig,
  reducedMotionDefault: boolean,
  useFusionView: boolean,
  demo: DemoConfig,
}

local RunService = game:GetService("RunService")

local function fromHex(hex: string): Color3
  hex = hex:gsub("#", "")
  if #hex == 3 then
    local r = tonumber(hex:sub(1, 1) .. hex:sub(1, 1), 16) or 0
    local g = tonumber(hex:sub(2, 2) .. hex:sub(2, 2), 16) or 0
    local b = tonumber(hex:sub(3, 3) .. hex:sub(3, 3), 16) or 0
    return Color3.fromRGB(r, g, b)
  end
  local r = tonumber(hex:sub(1, 2), 16) or 0
  local g = tonumber(hex:sub(3, 4), 16) or 0
  local b = tonumber(hex:sub(5, 6), 16) or 0
  return Color3.fromRGB(r, g, b)
end

local Config: Config = {
  theme = {
    bgColor = fromHex("0F0A1F"),
    primary = fromHex("8A2BE2"),
    accent = fromHex("FF8A3D"),
    unloadedA = fromHex("3E1466"),
    unloadedB = fromHex("1B0E33"),
    text = fromHex("F8F5FF"),
    cornerRadius = 0.12, -- relative to cell size
    strokeTransparency = 0.7,
  },
  grid = {
    minCellPx = 6, -- much smaller cells to increase density significantly
    gutterPx = 0,
    maxCols = 80,
    maxRows = 48,
    maxTiles = 2400, -- soft cap for performance; scales down if exceeded
  },
  skip = {
    enabled = true,
    delayMs = 2500,
    confirm = false,
  },
  reducedMotionDefault = false,
  useFusionView = true, -- try Fusion view when available; falls back to vanilla
  demo = {
    enabled = RunService:IsStudio(),
    durationSec = 6,
  },
}

return Config
