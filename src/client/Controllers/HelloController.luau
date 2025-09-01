--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages:WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Simple reactive counter button to prove Fusion + Loader work
local count = Value(0)

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
            Text = Computed(function()
                return string.format("Hello Fusion (%d)", count:get())
            end),

            [OnEvent("Activated")] = function()
                count:set(count:get() + 1)
            end,
        },
    },

    Parent = playerGui,
}

-- Return the root so tests or callers can reference it if needed
return app

