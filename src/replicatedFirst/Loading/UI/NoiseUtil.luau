--!strict

local Theme = require(script.Parent.Theme)

local NoiseUtil = {}

local function hash2i(x: number, y: number): number
  local n = bit32.bxor(x + 12345, bit32.lshift(y + 54321, 16))
  n = bit32.bxor(n, bit32.rshift(n, 13))
  n = (n * 0x45D9F3B) % 0x10000000
  n = bit32.bxor(n, bit32.rshift(n, 13))
  n = (n * 0x45D9F3B) % 0x10000000
  n = bit32.bxor(n, bit32.rshift(n, 16))
  return n
end

function NoiseUtil.unloadedColor(col: number, row: number): Color3
  local theme = Theme.get()
  local n = hash2i(col, row)
  local t = (n % 9973) / 9973 -- 0..1 pseudo random
  -- Slight bias to keep readable contrast
  local blend = 0.3 + t * 0.5 -- 0.3..0.8
  return theme.unloadedA:lerp(theme.unloadedB, blend)
end

return NoiseUtil
