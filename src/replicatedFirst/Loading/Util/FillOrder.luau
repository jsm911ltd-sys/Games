--!strict

-- Blue-noise-ish stable ordering to avoid visible banding.

local cache: { [string]: { number } } = {}

local function key(cols: number, rows: number): string
  return tostring(cols) .. "x" .. tostring(rows)
end

local function build(cols: number, rows: number): { number }
  local total = cols * rows
  local pairsArr = table.create(total)
  local idx = 1
  for r = 1, rows do
    for c = 1, cols do
      local x = c + 12345
      local y = r + 54321
      local n = bit32.bxor(x, bit32.lshift(y, 16))
      n = bit32.bxor(n, bit32.rshift(n, 13))
      n = (n * 0x45D9F3B) % 0x10000000
      n = bit32.bxor(n, bit32.rshift(n, 13))
      n = (n * 0x45D9F3B) % 0x10000000
      n = bit32.bxor(n, bit32.rshift(n, 16))
      local k = (n % 1000003) / 1000003
      pairsArr[idx] = { key = k, i = ((r - 1) * cols + c) }
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

return {
  get = function(cols: number, rows: number): { number }
    local k = key(cols, rows)
    local o = cache[k]
    if not o then
      o = build(cols, rows)
      cache[k] = o
    end
    return o
  end,
}
