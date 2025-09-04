--!strict

local RunService = game:GetService("RunService")

local GuiUtil = {}

function GuiUtil.awaitNonZeroSize(inst: GuiObject, timeoutSec: number?): boolean
  local deadline = os.clock() + (timeoutSec or 1)
  while (inst.AbsoluteSize.X < 2 or inst.AbsoluteSize.Y < 2) and os.clock() < deadline do
    RunService.Heartbeat:Wait()
  end
  return inst.AbsoluteSize.X >= 2 and inst.AbsoluteSize.Y >= 2
end

return GuiUtil
