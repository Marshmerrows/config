-- Replace Ghostty's built-in `global:option+space=toggle_quick_terminal`
-- with a Hammerspoon-driven version so macOS activates Ghostty as a real
-- frontmost app (menu bar swaps). On close, focus falls back to another
-- Ghostty window if one exists, otherwise to the app that was frontmost
-- before the quick terminal opened.

local M = {}

local INNER_MODS = { "cmd", "shift", "ctrl", "alt" }
local INNER_KEY = "f18"

local quickTerminalOpen = false
local previousApp = nil

local function sendToggle()
	hs.eventtap.keyStroke(INNER_MODS, INNER_KEY, 0)
end

local function ghosttyHasStandardWindow(ghostty)
	for _, w in ipairs(ghostty:allWindows()) do
		if w:isVisible() and w:isStandard() then
			return true
		end
	end
	return false
end

hs.hotkey.bind({ "alt" }, "space", function()
	local ghostty = hs.application.get("Ghostty")

	if not ghostty then
		hs.application.launchOrFocus("Ghostty")
		hs.timer.doAfter(0.6, function()
			sendToggle()
			quickTerminalOpen = true
		end)
		return
	end

	if quickTerminalOpen then
		sendToggle()
		quickTerminalOpen = false
		hs.timer.doAfter(0.1, function()
			if ghosttyHasStandardWindow(ghostty) then
				return
			end
			if previousApp and previousApp:isRunning() then
				previousApp:activate()
			end
		end)
	else
		local front = hs.application.frontmostApplication()
		if front and front:bundleID() ~= ghostty:bundleID() then
			previousApp = front
		end
		ghostty:activate()
		hs.timer.doAfter(0.05, function()
			sendToggle()
			quickTerminalOpen = true
		end)
	end
end)

return M
