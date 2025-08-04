return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		modes = {
			-- Built-in modes
			lsp_references = {
				params = {
					include_declaration = true,
				},
			},
			-- Custom modes
			symbols = {
				desc = "document symbols",
				mode = "lsp_document_symbols",
				focus = false,
				win = { position = "right" },
				filter = {
					-- remove Package since luals uses it for control flow structures
					["not"] = { ft = "lua", kind = "Package" },
					any = {
						-- all symbol kinds for help / markdown files
						ft = { "help", "markdown" },
						-- default set of symbol kinds
						kind = {
							"Class",
							"Constructor",
							"Enum",
							"Field",
							"Function",
							"Interface",
							"Method",
							"Module",
							"Namespace",
							"Package",
							"Property",
							"Struct",
							"Trait",
						},
					},
				},
			},
		},
		-- Global settings
		warn_no_results = false, -- show a warning when there are no results
		open_no_results = false, -- open the trouble window when there are no results
		win = {
			border = "single",
		},
		preview = {
			type = "split",
			relative = "win",
			position = "right",
			size = 0.3,
		},
		throttle = {
			refresh = 20, -- fetches new data when needed
			update = 10, -- updates the window
			render = 10, -- renders the window
			follow = 100, -- follows the current item
			preview = { ms = 100, debounce = true }, -- preview delay
		},
		-- Key mappings for trouble list
		keys = {
			["?"] = "help",
			r = "refresh",
			R = "toggle_refresh",
			q = "close",
			o = "jump_close",
			["<esc>"] = "cancel",
			["<cr>"] = "jump",
			["<2-leftmouse>"] = "jump",
			["<c-s>"] = "jump_split",
			["<c-v>"] = "jump_vsplit",
			-- go down to next item (accepts count)
			j = "next",
			["}"] = "next",
			["]]"] = "next",
			-- go up to previous item (accepts count)
			k = "prev",
			["{"] = "prev",
			["[["] = "prev",
			dd = "delete",
			d = { action = "delete", mode = "v" },
			i = "inspect",
			p = "preview",
			P = "toggle_preview",
			zo = "fold_open",
			zO = "fold_open_recursive",
			zc = "fold_close",
			zC = "fold_close_recursive",
			za = "fold_toggle",
			zA = "fold_toggle_recursive",
			zm = "fold_more",
			zM = "fold_close_all",
			zr = "fold_reduce",
			zR = "fold_open_all",
			zx = "fold_update",
			zX = "fold_update_all",
			zn = "fold_disable",
			zN = "fold_enable",
			zi = "fold_toggle_enable",
			gb = { -- example of a custom action that toggles the active view filter
				action = function(view)
					view:filter({ buf = 0 }, { toggle = true })
				end,
				desc = "Toggle Current Buffer Filter",
			},
			s = { -- example of a custom action that toggles the severity
				action = function(view)
					local f = view:get_filter("severity")
					local severity = ((f and f.filter.severity or 0) + 1) % 5
					view:filter({ severity = severity }, {
						id = "severity",
						template = "{hl:Title}Filter:{hl} {severity}",
						del = severity == 0,
					})
				end,
				desc = "Toggle Severity Filter",
			},
		},
	},
	keys = {
		-- Diagnostics
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },

		-- LSP
		{ "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
		-- { "gR", "<cmd>Trouble lsp_references toggle<cr>", desc = "LSP References (Trouble)" },
		-- { "gD", "<cmd>Trouble lsp_definitions toggle<cr>", desc = "LSP Definitions (Trouble)" },
		-- { "gI", "<cmd>Trouble lsp_implementations toggle<cr>", desc = "LSP Implementations (Trouble)" },
		-- { "gt", "<cmd>Trouble lsp_type_definitions toggle<cr>", desc = "LSP Type Definitions (Trouble)" },

		-- Location and Quickfix lists
		{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
		{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
	},
}
