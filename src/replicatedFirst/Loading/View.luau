--!strict

local scope = require(script.Parent:WaitForChild("FusionScope"))

export type State = {
  progress: any,
  statusText: any,
  opacity: any,
}

local function create(state: State): ScreenGui
  local function alphaFromOpacity(op: number, maxAlpha: number): number
    -- op=1 -> alpha=(1 - 1*maxAlpha) = 1 - maxAlpha (less transparent)
    -- op=0 -> alpha=1 (fully transparent)
    return math.clamp(1 - (op * maxAlpha), 0, 1)
  end

  local overlayAlpha = scope:Computed(function(use)
    return alphaFromOpacity((use(state.opacity) :: number), 0.6)
  end)

  local cardAlpha = scope:Computed(function(use)
    return alphaFromOpacity((use(state.opacity) :: number), 1.0)
  end)

  local percentText = scope:Computed(function(use)
    local p = math.clamp(tonumber(use(state.progress)) or 0, 0, 1)
    return string.format("%d%%", math.floor(p * 100 + 0.5))
  end)

  local fillSize = scope:Computed(function(use)
    local p = math.clamp(tonumber(use(state.progress)) or 0, 0, 1)
    return UDim2.new(p, 0, 1, 0)
  end)

  local textAlpha = scope:Computed(function(use)
    return 1 - (use(state.opacity) :: number)
  end)

  local gui = scope:New("ScreenGui")({
    Name = "LoadingScreen",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

    [scope.Children] = {
      -- Dimmed overlay
      scope:New("Frame")({
        Name = "Overlay",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = overlayAlpha,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
      }),

      -- Center card
      scope:New("Frame")({
        Name = "Card",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(420, 140),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = cardAlpha,
        BorderSizePixel = 0,

        [scope.Children] = {
          scope:New("UICorner")({ CornerRadius = UDim.new(0, 8) }),
          scope:New("UIStroke")({ Color = Color3.fromRGB(60, 60, 60), Thickness = 1 }),
          scope:New("UIPadding")({ PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }),
          scope:New("UIListLayout")({ FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12) }),

          -- Title / status label
          scope:New("TextLabel")({
            Name = "Status",
            LayoutOrder = 0,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.fromRGB(235, 235, 235),
            TextTransparency = textAlpha,
            Text = scope:Computed(function(use)
              return tostring(use(state.statusText))
            end),
          }),

          -- Progress bar
          scope:New("Frame")({
            Name = "Progress",
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,

            [scope.Children] = {
              scope:New("Frame")({
                Name = "BarBg",
                Size = UDim2.new(1, 0, 0, 10),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                BackgroundTransparency = textAlpha,
                BorderSizePixel = 0,

                [scope.Children] = {
                  scope:New("UICorner")({ CornerRadius = UDim.new(0, 6) }),
                  scope:New("Frame")({
                    Name = "Fill",
                    Size = fillSize,
                    BackgroundColor3 = Color3.fromRGB(0, 170, 255),
                    BackgroundTransparency = textAlpha,
                    BorderSizePixel = 0,
                    [scope.Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(0, 6) }) },
                  }),
                },
              }),

              scope:New("TextLabel")({
                Name = "Percent",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, -2),
                Size = UDim2.new(0, 80, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                TextTransparency = textAlpha,
                Text = percentText,
              }),
            },
          }),
        },
      }),
    },
  })

  return gui
end

return {
  create = create,
}

