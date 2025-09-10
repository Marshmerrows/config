local timer = require("hs.timer")
local firstPressUp = 0
local firstPressDown = 0
local firstPressLeft = 0
local firstPressRight = 0
local secondPressLeft = 0
local secondPressRight = 0

timeFrame = 0.18 -- Double tap window (in seconds)

function inTime(time)
	return timer.secondsSinceEpoch() - time < timeFrame
end

-- To easily layout windows on the screen, we use hs.grid to create
-- a 4x4 grid. If you want to use a more detailed grid, simply
-- change its dimension here
local GRID_SIZE = 4
local HALF_GRID_SIZE = GRID_SIZE / 2
local QUARTER_GRID_SIZE = GRID_SIZE / 4
-- Set the grid size and add a few pixels of margin
-- Also, don't animate window changes... That's too slow
hs.grid.setGrid(GRID_SIZE .. "x" .. GRID_SIZE)
hs.grid.setMargins({ 0, 0 })
hs.window.animationDuration = 0

local screenPositions = {}
screenPositions.left = {
	x = 0,
	y = 0,
	w = HALF_GRID_SIZE,
	h = GRID_SIZE,
}
screenPositions.leftLeft = {
	x = 0,
	y = 0,
	w = QUARTER_GRID_SIZE,
	h = GRID_SIZE,
}
screenPositions.leftRight = {
	x = QUARTER_GRID_SIZE,
	y = 0,
	w = QUARTER_GRID_SIZE,
	h = GRID_SIZE,
}
screenPositions.leftLeftLeft = {
	x = 0,
	y = 0,
	w = HALF_GRID_SIZE + QUARTER_GRID_SIZE,
	h = GRID_SIZE,
}
screenPositions.right = {
	x = HALF_GRID_SIZE,
	y = 0,
	w = HALF_GRID_SIZE,
	h = GRID_SIZE,
}
screenPositions.rightRight = {
	x = HALF_GRID_SIZE + QUARTER_GRID_SIZE,
	y = 0,
	w = QUARTER_GRID_SIZE,
	h = GRID_SIZE,
}
screenPositions.rightLeft = {
	x = HALF_GRID_SIZE,
	y = 0,
	w = QUARTER_GRID_SIZE,
	h = GRID_SIZE,
}
screenPositions.rightRightRight = {
	x = QUARTER_GRID_SIZE,
	y = 0,
	w = HALF_GRID_SIZE + QUARTER_GRID_SIZE,
	h = GRID_SIZE,
}
screenPositions.top = {
	x = 0,
	y = 0,
	w = GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions.bottom = {
	x = 0,
	y = HALF_GRID_SIZE,
	w = GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions.topLeft = {
	x = 0,
	y = 0,
	w = HALF_GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions.topRight = {
	x = HALF_GRID_SIZE,
	y = 0,
	w = HALF_GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions.bottomLeft = {
	x = 0,
	y = HALF_GRID_SIZE,
	w = HALF_GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions.bottomRight = {
	x = HALF_GRID_SIZE,
	y = HALF_GRID_SIZE,
	w = HALF_GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions = screenPositions

-- This function will move either the specified or the focuesd
-- window to the requested screen position
function moveWindowToPosition(cell, window)
	if window == nil then
		window = hs.window.focusedWindow()
	end
	if window then
		local screen = window:screen()
		hs.grid.set(window, cell, screen)
	end
end
-- This function will move either the specified or the focused
-- window to the center of the sreen and let it fill up the
-- entire screen.
function windowMaximize(factor, window)
	if window == nil then
		window = hs.window.focusedWindow()
	end
	if window then
		window:maximize()
	end
end
prevFrames = {}
function storeFrames()
	local curWin = hs.window.focusedWindow()
	local curWinSize = curWin:size()
	if not prevFrames[curWin:id()] then
		prevFrames[curWin:id()] = hs.geometry.copy(curWinSize)
	end
end

local mods = { "ctrl", "alt" }
-- Hotkeys
hs.hotkey.bind(mods, "up", function()
	storeFrames()
	if inTime(firstPressUp) then
		moveWindowToPosition(screenPositions.top)
	else
		windowMaximize()
	end

	firstPressUp = timer.secondsSinceEpoch()
end)

hs.hotkey.bind(mods, "left", function()
	storeFrames()
	if inTime(firstPressUp) then
		moveWindowToPosition(screenPositions.topLeft)
	elseif inTime(firstPressDown) then
		moveWindowToPosition(screenPositions.bottomLeft)
	elseif inTime(secondPressLeft) then
		moveWindowToPosition(screenPositions.leftLeftLeft)
	elseif inTime(firstPressLeft) then
		moveWindowToPosition(screenPositions.leftLeft)
		secondPressLeft = timer.secondsSinceEpoch()
	elseif inTime(firstPressRight) then
		moveWindowToPosition(screenPositions.rightLeft)
	else
		moveWindowToPosition(screenPositions.left)
	end

	firstPressLeft = timer.secondsSinceEpoch()
end)

hs.hotkey.bind(mods, "right", function()
	storeFrames()
	if inTime(firstPressUp) then
		moveWindowToPosition(screenPositions.topRight)
	elseif inTime(firstPressDown) then
		moveWindowToPosition(screenPositions.bottomRight)
	elseif inTime(secondPressRight) then
		moveWindowToPosition(screenPositions.rightRightRight)
	elseif inTime(firstPressRight) then
		moveWindowToPosition(screenPositions.rightRight)
		secondPressRight = timer.secondsSinceEpoch()
	elseif inTime(firstPressLeft) then
		moveWindowToPosition(screenPositions.leftRight)
	else
		moveWindowToPosition(screenPositions.right)
	end

	firstPressRight = timer.secondsSinceEpoch()
end)

hs.hotkey.bind(mods, "down", function()
	if inTime(firstPressDown) then
		storeFrames()
		moveWindowToPosition(screenPositions.bottom)
	else
		local curWin = hs.window.focusedWindow()
		if prevFrames[curWin:id()] then
			curWin:setSize(prevFrames[curWin:id()])
			prevFrames[curWin:id()] = nil
		end
	end

	firstPressDown = timer.secondsSinceEpoch()
end)
