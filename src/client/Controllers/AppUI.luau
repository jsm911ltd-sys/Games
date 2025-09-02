--!strict

local Players = game:GetService("Players")
local scope = require(script.Parent:WaitForChild("FusionScope"))

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Small reactive state (no events yet)
local count = scope:Value(0)
local showButtons = scope:Value(true)

-- Minimal UI: one ScreenGui with a single TextLabel
local app = scope:New("ScreenGui") {
    Name = "FusionApp",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

    [scope.Children] = {
        -- Root container with padding and vertical layout
        scope:New("Frame") {
            Name = "Root",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 12),
            Size = UDim2.fromOffset(320, 0),
            AutomaticSize = Enum.AutomaticSize.Y,

            [scope.Children] = {
                -- Optional toggle control
                scope:New("TextButton") {
                    Name = "ToggleButtons",
                    LayoutOrder = 0,
                    Size = UDim2.fromOffset(140, 28),
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    BorderSizePixel = 0,

                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = Color3.new(1, 1, 1),
                    Text = scope:Computed(function(use)
                        return use(showButtons) and "Hide Buttons" or "Show Buttons"
                    end),

                    [scope.OnEvent("Activated")] = function()
                        showButtons:set(not scope.peek(showButtons))
                    end,

                    [scope.Children] = {
                        scope:New("UICorner") {
                            CornerRadius = UDim.new(0, 6),
                        },
                    },
                },
                scope:New("UIPadding") {
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                },
                scope:New("UIListLayout") {
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8),
                },

                scope:New("TextLabel") {
                    Name = "HelloLabel",
                    LayoutOrder = 1,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.GothamBold,
                    TextSize = 18,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = scope:Computed(function(use)
                        return string.format("Hello Fusion (%d)", use(count))
                    end),
                },

                -- Button row with horizontal layout and spacing
                scope:New("Frame") {
                    Name = "Buttons",
                    LayoutOrder = 2,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    Visible = scope:Computed(function(use)
                        return use(showButtons)
                    end),

                    [scope.Children] = {
                        scope:New("UIListLayout") {
                            FillDirection = Enum.FillDirection.Horizontal,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Padding = UDim.new(0, 8),
                        },

                        scope:New("TextButton") {
                            Name = "IncButton",
                            LayoutOrder = 1,
                            Size = UDim2.fromOffset(140, 36),
                            BackgroundColor3 = Color3.fromRGB(30, 144, 255),
                            BorderSizePixel = 0,

                            Font = Enum.Font.Gotham,
                            TextSize = 16,
                            TextColor3 = Color3.new(1, 1, 1),
                            Text = "Increment",

                            [scope.OnEvent("Activated")] = function()
                                count:set(scope.peek(count) + 1)
                            end,
                            [scope.Children] = {
                                scope:New("UICorner") {
                                    CornerRadius = UDim.new(0, 6),
                                },
                            },
                        },

                        scope:New("TextButton") {
                            Name = "ResetButton",
                            LayoutOrder = 2,
                            Size = UDim2.fromOffset(140, 36),
                            BackgroundColor3 = Color3.fromRGB(80, 80, 80),
                            BorderSizePixel = 0,

                            Font = Enum.Font.Gotham,
                            TextSize = 16,
                            TextColor3 = Color3.new(1, 1, 1),
                            Text = "Reset",

                            [scope.OnEvent("Activated")] = function()
                                count:set(0)
                            end,
                            [scope.Children] = {
                                scope:New("UICorner") {
                                    CornerRadius = UDim.new(0, 6),
                                },
                            },
                        },
                    },
                },
            },
        },
    },

    Parent = playerGui,
}

return app
