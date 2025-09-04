--!strict

local Theme = require(script.Parent.Parent.Theme)

export type SkipButton = {
  instance: TextButton,
  setVisible: (self: SkipButton, v: boolean) -> (),
  onActivated: (self: SkipButton, cb: () -> ()) -> (),
  destroy: (self: SkipButton) -> (),
}

local Skip = {}
Skip.__index = Skip

function Skip.new(parent: Instance): SkipButton
  local theme = Theme.get()
  local btn = Instance.new("TextButton")
  btn.Name = "Skip"
  btn.BackgroundColor3 = theme.unloadedA
  btn.BorderSizePixel = 0
  btn.AutoButtonColor = true
  btn.Text = "Skip (at your own peril)"
  btn.TextColor3 = theme.text
  btn.TextTransparency = 0.25
  btn.Font = Enum.Font.GothamMedium
  btn.TextSize = 14
  btn.AnchorPoint = Vector2.new(0.5, 1)
  btn.Position = UDim2.fromScale(0.5, 0.98)
  btn.Size = UDim2.fromOffset(300, 40)
  btn.Visible = false
  btn.ZIndex = 4
  btn.Parent = parent

  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 6)
  corner.Parent = btn

  local self = setmetatable({ instance = btn }, Skip) :: any
  return self :: any
end

function Skip:setVisible(v: boolean)
  self.instance.Visible = v
end

function Skip:onActivated(cb: () -> ())
  self.instance.Activated:Connect(cb)
end

function Skip:destroy()
  self.instance:Destroy()
end

return Skip
