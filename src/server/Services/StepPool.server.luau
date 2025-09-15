--!strict

-- Server-side object pool for stepping platform Parts.

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local StepConfig = require(game:GetService("ReplicatedStorage").Shared:WaitForChild("StepConfig"))

export type Pool = {
	Get: (self: any) -> Part,
	Release: (self: any, part: Part) -> (),
}

local function ensureFolder(): Folder
	local folder = workspace:FindFirstChild("SteppingPlatforms")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "SteppingPlatforms"
		folder.Parent = workspace
	end
	return folder
end

local function createPart(): Part
	local p = Instance.new("Part")
	p.Name = "StepPlatform"
	p.Anchored = true
	p.CanCollide = true
	p.CanQuery = true
	p.CanTouch = true
	p.CastShadow = false
	p.Size = StepConfig.Platform.Size
	p.Color = StepConfig.Platform.Color
	p.Material = StepConfig.Platform.Material
	p.Transparency = StepConfig.Platform.Transparency
	if StepConfig.Platform.Friction or StepConfig.Platform.Elasticity then
		p.CustomPhysicalProperties = PhysicalProperties.new(
			StepConfig.Platform.Density or 0.7,
			StepConfig.Platform.Friction or 0.2,
			StepConfig.Platform.Elasticity or 0,
			0.5,
			0.5
		)
	end
	return p
end

local Pool = {}

function Pool.new(): Pool
	local folder = ensureFolder()
	local free: { Part } = {}
	for _ = 1, StepConfig.Pool.InitialSize do
		local p = createPart()
		p.Parent = folder
		p.CFrame = CFrame.new(0, -1000, 0)
		table.insert(free, p)
	end

	local self = {}
	function self:Get(): Part
		local part = table.remove(free)
		if not part then
			if #free + 1 < StepConfig.Pool.MaxSize then
				part = createPart()
				part.Parent = folder
			else
				-- Hard cap; reuse by cycling last
				part = createPart()
				part.Parent = folder
			end
		end
		return part :: Part
	end

	function self:Release(part: Part)
		part.CFrame = CFrame.new(0, -1000, 0)
		part.Parent = folder
		table.insert(free, part)
	end

	return (self :: any) :: Pool
end

return Pool

