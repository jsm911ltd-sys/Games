--!strict

local State = require(script:WaitForChild("State"))
local View = require(script:WaitForChild("View"))

local state = State.create()
local app = View.createApp(state)

return app
