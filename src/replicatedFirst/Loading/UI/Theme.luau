--!strict

local Config = require(script.Parent.Parent.Core.Config)

export type Theme = Config.Theme

local function GetTheme(): Theme
  return Config.theme
end

return {
  get = GetTheme,
}
