--!strict

local StepConfig = require(game:GetService("ReplicatedStorage").Shared:WaitForChild("StepConfig"))

export type Ghost = {
	Part: Part,
	Destroy: (self: any) -> (),
	UpdateCFrame: (self: any, cf: CFrame) -> (),
}

local function makeGhost(): Ghost
	local p = Instance.new("Part")
	p.Name = "StepGhost"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = StepConfig.Platform.Size
	p.Color = StepConfig.Ghost.Color
	p.Material = Enum.Material.Neon
	p.Transparency = StepConfig.Ghost.Transparency
	p.Parent = workspace

	local self = {}
	function self:Destroy()
		p:Destroy()
	end
	function self:UpdateCFrame(cf: CFrame)
		p.CFrame = cf
	end
	return (self :: any) :: Ghost
end

return {
	Create = makeGhost,
}

