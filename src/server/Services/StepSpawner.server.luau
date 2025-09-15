--!strict

-- Listens for RequestStep, validates, and spawns/positions a platform from the pool.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Remotes = require(game:GetService("ReplicatedStorage").Shared:WaitForChild("Remotes"))
local StepConfig = require(game:GetService("ReplicatedStorage").Shared:WaitForChild("StepConfig"))

local StepValidation = require(script.Parent:WaitForChild("StepValidation"))
local StepPool = require(script.Parent:WaitForChild("StepPool"))

local Module = {}

local pool
local lastReq: { [Player]: number } = {}

function Module.Init()
	pool = StepPool.new()
end

local function rateLimited(player: Player): boolean
	local now = tick()
	local last = lastReq[player] or 0
	if (now - last) < (1 / StepConfig.MaxStepsPerSecond) then
		return true
	end
	lastReq[player] = now
	return false
end

function Module.Start()
	Remotes.RequestStep.OnServerEvent:Connect(function(player: Player, desiredCf: CFrame, _speed: number)
		-- Basic validation
		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not hrp then return end
		if rateLimited(player) then return end
		if not StepValidation.WithinBounds(hrp.Position, desiredCf.Position) then return end

		-- Spawn or reuse a platform
		local part = pool:Get()
		part.Anchored = true
		part.Parent = workspace:FindFirstChild("SteppingPlatforms") or workspace
		-- Position slightly above to avoid clipping, center on size Y
		local yOffset = StepConfig.Platform.Size.Y * 0.5
		part.CFrame = desiredCf + Vector3.new(0, yOffset, 0)

    -- Auto-return to pool after lifetime (reuse via pool)
    task.delay(StepConfig.Lifetime, function()
        if part and part.Parent then
            pool:Release(part)
        end
    end)

		-- Inform clients (optional; replication already covers the Part)
		Remotes.StepCreated:FireClient(player, part.CFrame)
	end)
end

return Module
