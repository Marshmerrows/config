return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			theme = "auto",
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
			globalstatus = false,
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff" },
			lualine_c = { { "filename", path = 1 }, "diagnostics" },
			lualine_z = { "location" },
		},
		tabline = {
			lualine_a = {
				{
					"buffers",
					-- show_filename_only = true,
					mode = 4,
					symbols = {
						modified = " ●",
						alternate_file = "",
						directory = "",
					},
				},
			},
		},
	},
}
