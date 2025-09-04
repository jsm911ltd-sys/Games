--!strict

-- Minimal progress aggregator for step 1.
-- Provides subscribe + setProgress, ready to be extended later.

export type Subscription = { disconnect: () -> () }
export type ProgressEvent = (progress: number) -> ()

export type Aggregator = {
  subscribe: (self: Aggregator, fn: ProgressEvent) -> Subscription,
  setProgress: (self: Aggregator, progress: number) -> (),
  getProgress: (self: Aggregator) -> number,
}

local AggregatorImpl = {}
AggregatorImpl.__index = AggregatorImpl

function AggregatorImpl.new(): Aggregator
  local self = setmetatable({}, AggregatorImpl) :: any
  local s = self :: any
  s._subs = {} :: { [number]: ProgressEvent }
  s._nextId = 1
  s._progress = 0
  return s
end

function AggregatorImpl:subscribe(fn: ProgressEvent): Subscription
  local s = self :: any
  local id = s._nextId
  s._nextId = s._nextId + 1
  s._subs[id] = fn
  -- prime with current value
  task.defer(fn, s._progress)
  return {
    disconnect = function()
      s._subs[id] = nil
    end,
  }
end

function AggregatorImpl:setProgress(progress: number)
  local p = math.clamp(progress, 0, 1)
  local s = self :: any
  if p == s._progress then
    return
  end
  s._progress = p
  for _, fn in pairs(s._subs) do
    task.defer(fn, p)
  end
end

function AggregatorImpl:getProgress(): number
  local s = self :: any
  return s._progress
end

return AggregatorImpl
