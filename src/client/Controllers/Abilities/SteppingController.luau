--!strict

-- Handles input/state for Stepping Platforms and client-side prediction.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Remotes = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Remotes"))
local StepConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StepConfig"))

local StepPlanner = require(script.Parent:WaitForChild("StepPlanner"))
local StepGhost = require(script.Parent:WaitForChild("StepGhost"))

type State = "Idle" | "Primed" | "Stepping" | "Cooldown" | "Blocked"

local Controller = {}

local player = Players.LocalPlayer
local currentState: State = "Idle"
local lastStepTime = 0
local activeGhost: any? = nil

local function getCharacter(): Model?
	return player.Character or player.CharacterAdded:Wait()
end

local function canStep(now: number): boolean
	if currentState == "Blocked" then return false end
	return (now - lastStepTime) >= StepConfig.Cooldown
end

local function doStep()
	local character = getCharacter()
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local speed = humanoid.MoveDirection.Magnitude > 0 and (humanoid.WalkSpeed) or 0
	local plan = StepPlanner.PlanNext(character, speed)
	if not plan then return end

	-- Predict: show ghost immediately
	if activeGhost == nil then
		activeGhost = StepGhost.Create()
	end
	activeGhost:UpdateCFrame(plan.CFrame)

	-- Fire request to server
	Remotes.RequestStep:FireServer(plan.CFrame, speed)

	lastStepTime = tick()
	currentState = "Cooldown"
end

local function onInputBegan(input: InputObject, gameProcessed: boolean)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Space then
		local now = tick()
		if canStep(now) then
			currentState = "Stepping"
			doStep()
		end
	end
end

local function onStepCreated(_player: Player, cf: CFrame)
	-- Reconcile ghost to authoritative pose
	if activeGhost then
		activeGhost:UpdateCFrame(cf)
		-- Let the ghost linger briefly, then clean up
		delay(0.2, function()
			if activeGhost then
				activeGhost:Destroy()
				activeGhost = nil
			end
		end)
	end
	currentState = "Idle"
end

function Controller.Init()
	-- no-op for now
end

function Controller.Start()
	UserInputService.InputBegan:Connect(onInputBegan)
	Remotes.StepCreated.OnClientEvent:Connect(function(cf: CFrame)
		onStepCreated(player, cf)
	end)
end

return Controller

