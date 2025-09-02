--!strict

local State = require(script.Parent:WaitForChild("State"))
local View = require(script.Parent:WaitForChild("View"))

local state = State.create()
local app = View.createApp(state)

return app

