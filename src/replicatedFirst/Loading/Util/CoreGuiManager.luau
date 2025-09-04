--!strict

local StarterGui = game:GetService("StarterGui")

local CoreGuiManager = {}
local applied = false
local prev: { [Enum.CoreGuiType]: boolean } = {}

local targets = {
  Enum.CoreGuiType.Chat,
  Enum.CoreGuiType.EmotesMenu,
  Enum.CoreGuiType.Health,
  Enum.CoreGuiType.Backpack,
  Enum.CoreGuiType.PlayerList, -- leave enabled by default to avoid selection group spam
}

function CoreGuiManager.apply()
  if applied then
    return
  end
  for _, t in ipairs(targets) do
    local ok, current = pcall(function()
      -- There is no getter; assume true by default
      return true
    end)
    prev[t] = if ok then current else true
    if t == Enum.CoreGuiType.PlayerList then
      -- Avoid toggling PlayerList to reduce selection group spam in Studio
      continue
    end
    pcall(function()
      StarterGui:SetCoreGuiEnabled(t, false)
    end)
  end
  -- Minimal SetCore tweaks
  pcall(function()
    StarterGui:SetCore("TopbarEnabled", false)
    StarterGui:SetCore("BadgesNotificationsActive", false)
    StarterGui:SetCore("PointsNotificationsActive", false)
  end)
  applied = true
end

function CoreGuiManager.restore()
  if not applied then
    return
  end
  for _, t in ipairs(targets) do
    if t == Enum.CoreGuiType.PlayerList then
      continue
    end
    pcall(function()
      StarterGui:SetCoreGuiEnabled(t, true)
    end)
  end
  pcall(function()
    StarterGui:SetCore("TopbarEnabled", true)
    StarterGui:SetCore("BadgesNotificationsActive", true)
    StarterGui:SetCore("PointsNotificationsActive", true)
  end)
  applied = false
end

return CoreGuiManager
