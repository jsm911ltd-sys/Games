--!strict

local StepConfig = require(game:GetService("ReplicatedStorage").Shared:WaitForChild("StepConfig"))

local StepValidation = {}

function StepValidation.WithinBounds(rootPos: Vector3, targetPos: Vector3): boolean
	local horiz = Vector3.new(targetPos.X, rootPos.Y, targetPos.Z)
	local dist = (horiz - rootPos).Magnitude
	if dist > StepConfig.Validation.MaxDistance then return false end
	local dy = math.abs(targetPos.Y - rootPos.Y)
	if dy > StepConfig.Validation.MaxHeightDelta then return false end
	return true
end

return StepValidation

