return {
	"rmagatti/goto-preview",
	config = function()
		require("goto-preview").setup({
			width = 120, -- Width of the floating window
			height = 25, -- Height of the floating window
			border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" }, -- Border characters of the floating window
			default_mappings = false, -- Bind default mappings (we'll set our own)
			debug = false, -- Print debug information
			opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully opaque
			resizable = true, -- Whether the floating window is resizable
			post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook
			post_close_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook
			references = { -- Configure the telescope UI for slowing the references cycling window.
				telescope = require("telescope.themes").get_dropdown({ hide_preview = false }),
			},
			-- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
			focus_on_open = true, -- Focus the floating window when opening it
			dismiss_on_move = false, -- Dismiss the floating window when moving the cursor
			force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
			bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
			stack_floating_preview_windows = true, -- Whether to nest floating windows
			preview_window_title = { enable = true, position = "left" }, -- Whether to set the preview window title as the filename
		})
	end,
	keys = {
		-- Override K for definition preview instead of regular LSP hover
		{
			"K",
			function()
				if vim.bo.filetype == "help" then
					vim.cmd("help " .. vim.fn.expand("<cword>"))
				else
					require("goto-preview").goto_preview_definition()
				end
			end,
			desc = "Preview Definition",
		},

		-- Close all preview windows
		{ "<leader>pc", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close All Previews" },
	},
}
