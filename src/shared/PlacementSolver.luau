--!strict
-- Computes desired platform pose given character state.

local StepConfig = require(script.Parent:WaitForChild("StepConfig"))

export type PoseResult = {
	CFrame: CFrame,
	Normal: Vector3?,
}

local PlacementSolver = {}

-- Very lightweight first pass: place ahead of root along move direction at clamped step length.
function PlacementSolver.ComputeSimplePose(rootCf: CFrame, moveDir: Vector3, speed: number): PoseResult
	local stepMin = StepConfig.StepLength.Min
	local stepMax = StepConfig.StepLength.Max
	local scaled = math.clamp(speed * 0.25, stepMin, stepMax)
	local dir = moveDir.Magnitude > 0 and moveDir.Unit or Vector3.new(0, 0, -1)
	local targetPos = rootCf.Position + dir * scaled
	local up = Vector3.yAxis
	local look = (dir.Magnitude > 0) and dir or rootCf.LookVector
	local cf = CFrame.lookAt(targetPos, targetPos + look, up)
	return { CFrame = cf, Normal = up }
end

return PlacementSolver

