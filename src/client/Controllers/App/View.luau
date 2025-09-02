--!strict

local Players = game:GetService("Players")

local scope = require(script.Parent.Parent:WaitForChild("FusionScope"))

local function createApp(state)
  local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

  local app = scope:New("ScreenGui")({
    Name = "FusionApp",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

    [scope.Children] = {
      scope:New("Frame")({
        Name = "Root",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(320, 0),
        AutomaticSize = Enum.AutomaticSize.Y,

        [scope.Children] = {
          -- Toggle visibility of the buttons row
          scope:New("TextButton")({
            Name = "ToggleButtons",
            LayoutOrder = 0,
            Size = UDim2.fromOffset(140, 28),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            BorderSizePixel = 0,

            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Color3.new(1, 1, 1),
            Text = scope:Computed(function(use)
              return use(state.showButtons) and "Hide Buttons" or "Show Buttons"
            end),

            [scope.OnEvent("Activated")] = function()
              state.toggleButtons()
            end,

            [scope.Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(0, 6) }) },
          }),

          scope:New("UIPadding")({
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
          }),

          scope:New("UIListLayout")({
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
          }),

          -- Counter label
          scope:New("TextLabel")({
            Name = "HelloLabel",
            LayoutOrder = 1,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = scope:Computed(function(use)
              return string.format("Hello Fusion (%d)", use(state.count))
            end),
          }),

          -- Button row
          scope:New("Frame")({
            Name = "Buttons",
            LayoutOrder = 2,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Visible = scope:Computed(function(use)
              return use(state.showButtons)
            end),

            [scope.Children] = {
              scope:New("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
              }),

              scope:New("TextButton")({
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
                  state.inc()
                end,
                [scope.Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(0, 6) }) },
              }),

              scope:New("Frame")({
                Name = "Reset",
                LayoutOrder = 2,
                Size = UDim2.fromOffset(140, 36),
                BackgroundColor3 = scope:Computed(function(use)
                  return (use(state.count) > 0) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(60, 60, 60)
                end),
                BorderSizePixel = 0,

                [scope.Children] = {
                  scope:New("UICorner")({ CornerRadius = UDim.new(0, 6) }),
                  scope:New("TextLabel")({
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    Text = "Reset",
                  }),
                  scope:New("TextButton")({
                    Name = "HitTarget",
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    ZIndex = 2,
                    Size = UDim2.fromScale(1, 1),
                    Visible = scope:Computed(function(use)
                      return use(state.count) > 0
                    end),
                    [scope.OnEvent("Activated")] = function()
                      state.openResetConfirm()
                    end,
                  }),

                  -- Confirm popover appears offset so the pointer must move
                  scope:New("Frame")({
                    Name = "ResetConfirm",
                    ZIndex = 10,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    BorderSizePixel = 0,
                    Visible = scope:Computed(function(use)
                      return use(state.showResetConfirm)
                    end),
                    -- Offset above the button so the cursor is not already over it
                    Position = UDim2.fromOffset(0, -52),
                    Size = UDim2.fromOffset(160, 64),
                    [scope.Children] = {
                      scope:New("UICorner")({ CornerRadius = UDim.new(0, 6) }),
                      scope:New("UIPadding")({
                        PaddingTop = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                      }),
                      scope:New("UIListLayout")({
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 6),
                      }),
                      scope:New("TextLabel")({
                        LayoutOrder = 0,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "Confirm reset?",
                      }),
                      scope:New("Frame")({
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 28),
                        [scope.Children] = {
                          scope:New("UIListLayout")({
                            FillDirection = Enum.FillDirection.Horizontal,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Padding = UDim.new(0, 8),
                          }),
                          scope:New("TextButton")({
                            Name = "Yes",
                            LayoutOrder = 0,
                            Size = UDim2.fromOffset(64, 28),
                            BackgroundColor3 = Color3.fromRGB(200, 60, 60),
                            BorderSizePixel = 0,
                            Font = Enum.Font.Gotham,
                            TextSize = 14,
                            TextColor3 = Color3.new(1, 1, 1),
                            Text = "Yes",
                            [scope.OnEvent("Activated")] = function()
                              state.confirmReset()
                            end,
                            [scope.Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(0, 4) }) },
                          }),
                          scope:New("TextButton")({
                            Name = "No",
                            LayoutOrder = 1,
                            Size = UDim2.fromOffset(64, 28),
                            BackgroundColor3 = Color3.fromRGB(80, 80, 80),
                            BorderSizePixel = 0,
                            Font = Enum.Font.Gotham,
                            TextSize = 14,
                            TextColor3 = Color3.new(1, 1, 1),
                            Text = "No",
                            [scope.OnEvent("Activated")] = function()
                              state.cancelResetConfirm()
                            end,
                            [scope.Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(0, 4) }) },
                          }),
                        },
                      }),
                    },
                  }),
                },
              }),
            },
          }),
        },
      }),
    },

    Parent = playerGui,
  })

  return app
end

return {
  createApp = createApp,
}
