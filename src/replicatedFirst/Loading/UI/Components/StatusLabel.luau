--!strict

local Theme = require(script.Parent.Parent.Theme)

export type StatusLabel = {
  instance: TextLabel,
  setText: (self: StatusLabel, text: string) -> (),
  destroy: (self: StatusLabel) -> (),
}

local Status = {}
Status.__index = Status

function Status.new(parent: Instance): StatusLabel
  local theme = Theme.get()
  local lbl = Instance.new("TextLabel")
  lbl.Name = "Status"
  lbl.BackgroundTransparency = 1
  lbl.Text = ""
  lbl.TextColor3 = theme.text
  lbl.TextTransparency = 0.15
  lbl.Font = Enum.Font.Gotham
  lbl.TextSize = 14
  lbl.AnchorPoint = Vector2.new(0.5, 1)
  lbl.Position = UDim2.fromScale(0.5, 0.96)
  lbl.Size = UDim2.fromOffset(400, 20)
  lbl.ZIndex = 3
  lbl.TextXAlignment = Enum.TextXAlignment.Center
  lbl.TextYAlignment = Enum.TextYAlignment.Center
  lbl.Parent = parent

  local self = setmetatable({ instance = lbl }, Status) :: any
  return self :: any
end

function Status:setText(text: string)
  self.instance.Text = text
end

function Status:destroy()
  self.instance:Destroy()
end

return Status
