--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlacementSolver = require(game:GetService("ReplicatedStorage").Shared:WaitForChild("PlacementSolver"))

export type StepPose = {
	CFrame: CFrame,
	IsLeftFoot: boolean,
}

local StepPlanner = {}

local lastWasLeft: boolean = false

function StepPlanner.GetNextFootPose(): boolean
	lastWasLeft = not lastWasLeft
	return lastWasLeft
end

function StepPlanner.PlanNext(character: Model, speed: number): StepPose?
	if not character then return nil end
	local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return nil end
	local moveDir = humanoid.MoveDirection
	if moveDir.Magnitude < 0.05 then return nil end
	local pose = PlacementSolver.ComputeSimplePose(hrp.CFrame, moveDir, speed)
	return { CFrame = pose.CFrame, IsLeftFoot = StepPlanner.GetNextFootPose() }
end

return StepPlanner

