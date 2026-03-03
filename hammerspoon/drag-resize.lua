-- Inspired by Linux alt-drag or Better Touch Tools move/resize functionality
-- from https://gist.github.com/kizzx2/e542fa74b80b7563045a
-- Command-Ctrl-move: move window under mouse
-- Command-Control-Shift-move: resize window under mouse
function get_window_under_mouse()
	local my_pos = hs.geometry.new(hs.mouse.absolutePosition())
	local my_screen = hs.mouse.getCurrentScreen()
	return hs.fnutils.find(hs.window.orderedWindows(), function(w)
		return my_screen == w:screen() and (not w:isFullScreen()) and my_pos:inside(w:frame())
	end)
end

dragging = {} -- global variable to hold the dragging/resizing state

drag_event = hs.eventtap.new({ hs.eventtap.event.types.mouseMoved }, function(e)
	if not dragging then
		return nil
	end
	-- Focus the window on first actual movement
	if not dragging.focused then
		dragging.win:focus()
		dragging.focused = true
	end
	if dragging.mode == 1 then -- just move
		local pos = hs.mouse.absolutePosition()
		local x1 = dragging.pos.x + (pos.x - dragging.off.x)
		local y1 = dragging.pos.y + (pos.y - dragging.off.y)
		dragging.win:setTopLeft({ x = x1, y = y1 })
	else -- resize (keeping original absolute positioning for external display compatibility)
		local pos = hs.mouse.absolutePosition()
		local w1 = dragging.size.w + (pos.x - dragging.off.x)
		local h1 = dragging.size.h + (pos.y - dragging.off.y)
		dragging.win:setSize(w1, h1)
	end
end)

flags_event = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
	local flags = e:getFlags()
	local mode = (flags.ctrl and 1 or 0) + (flags.alt and 2 or 0)
	if mode == 1 or mode == 3 then -- valid modes
		if dragging then
			if dragging.mode == mode then
				return nil
			end -- already working
		else
			-- only update window if we hadn't started dragging/resizing already
			dragging = { win = get_window_under_mouse(), focused = false }
			if not dragging.win then -- no good window
				dragging = nil
				return nil
			end
		end
		dragging.mode = mode -- 1=drag, 3=resize
		dragging.off = hs.mouse.absolutePosition()
		if mode == 1 then
			dragging.pos = dragging.win:topLeft()
		else -- mode==3
			dragging.size = dragging.win:size()
		end
		drag_event:start()
	else -- not a valid mode
		if dragging then
			drag_event:stop()
			dragging = nil
		end
	end
	return nil
end)
flags_event:start()

