--!strict

local scope = require(script.Parent.Parent:WaitForChild("FusionScope"))

export type State = {
  count: any,
  showButtons: any,
  inc: () -> (),
  reset: () -> (),
  toggleButtons: () -> (),
}

local function create(): State
  local count = scope:Value(0)
  local showButtons = scope:Value(true)

  return {
    count = count,
    showButtons = showButtons,
    inc = function()
      count:set(scope.peek(count) + 1)
    end,
    reset = function()
      count:set(0)
    end,
    toggleButtons = function()
      showButtons:set(not scope.peek(showButtons))
    end,
  }
end

return {
  create = create,
}

