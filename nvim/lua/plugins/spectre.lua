return {
	"nvim-pack/nvim-spectre",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{
			"<leader>S",
			function()
				require("spectre").open()
			end,
			desc = "Search and Replace in files (Spectre)",
		},
	},
	opts = {
		live_update = true,
		highlight = {
			ui = "String",
			search = "DiffChange",
			replace = "DiffDelete",
			selected = "DiffAdd",
		},
	},
}
