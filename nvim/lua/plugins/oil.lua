return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		watch_for_changes = true,
		keymaps = {
			["<C-x>"] = { "actions.select", opts = { horizontal = true } },
			["<C-v>"] = { "actions.select", opts = { vertical = true } },
			["<C-t>"] = { "actions.select", opts = { tab = true } },
		},
	},
	keys = {
		{
			"<leader>e",
			function()
				require("oil").open()
			end,
			desc = "Open parent directory",
		},
	},
	-- Optional dependencies
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
}
