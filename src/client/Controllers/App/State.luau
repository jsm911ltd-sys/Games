--!strict

local scope = require(script.Parent.Parent:WaitForChild("FusionScope"))

export type State = {
  count: any,
  showButtons: any,
  inc: () -> (),
  reset: () -> (),
  toggleButtons: () -> (),
  showResetConfirm: any,
  openResetConfirm: () -> (),
  cancelResetConfirm: () -> (),
  confirmReset: () -> (),
}

local function create(): State
  local count = scope:Value(0)
  local showButtons = scope:Value(true)
  local showResetConfirm = scope:Value(false)

  return {
    count = count,
    showButtons = showButtons,
    showResetConfirm = showResetConfirm,
    inc = function()
      count:set(scope.peek(count) + 1)
    end,
    reset = function()
      count:set(0)
    end,
    toggleButtons = function()
      showButtons:set(not scope.peek(showButtons))
    end,
    openResetConfirm = function()
      showResetConfirm:set(true)
    end,
    cancelResetConfirm = function()
      showResetConfirm:set(false)
    end,
    confirmReset = function()
      count:set(0)
      showResetConfirm:set(false)
    end,
  }
end

return {
  create = create,
}
