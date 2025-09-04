--!strict

local Theme = require(script.Parent.Theme)

local GradientUtil = {}

function GradientUtil.sample(normPos: Vector2): Color3
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

return GradientUtil
