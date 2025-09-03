--!strict

local scope = require(script.Parent:WaitForChild("FusionScope"))

export type State = {
  progress: any,
  statusText: any,
  opacity: any,
}

local function create(): State
  local progress = scope:Value(0)
  local statusText = scope:Value("Loading...")
  local opacity = scope:Value(1)

  return {
    progress = progress,
    statusText = statusText,
    opacity = opacity,
  }
end

return {
  create = create,
}

