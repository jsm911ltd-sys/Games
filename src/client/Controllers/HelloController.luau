--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages:WaitForChild("Fusion"))

-- Bind Fusion.New to this scope
local function New(className: string)
    return Fusion.New(scope, className)
end
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children
local peek = Fusion.peek

-- Fusion 0.3 requires a scope for state
local scope = Fusion.scoped(Fusion)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Simple reactive counter button to prove Fusion + Loader work
local count = scope:Value(0)

local app = New "ScreenGui" {
    Name = "FusionDemo",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    [Children] = {
        New "TextButton" {
            Name = "HelloButton",
            Size = UDim2.fromOffset(180, 44),
            Position = UDim2.fromOffset(12, 12),
            BackgroundColor3 = Color3.fromRGB(30, 144, 255),
            BorderSizePixel = 0,

            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = Color3.new(1, 1, 1),
            Text = scope:Computed(function(use)
                return string.format("Hello Fusion (%d)", use(count))
            end),

            [OnEvent("Activated")] = function()
                count:set(peek(count) + 1)
            end,
        },
    },

    Parent = playerGui,
}

-- Return the root so tests or callers can reference it if needed
return app
