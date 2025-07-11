return {
	{
		{
			"rebelot/kanagawa.nvim",
			lazy = false, -- make sure we load this during startup if it is your main colorscheme
			priority = 1000, -- make sure to load this before all the other start plugins
			config = function()
				-- load the colorscheme here
				vim.cmd([[colorscheme kanagawa-wave]])
			end,
		},
	},
	-- {
	-- 	{
	-- 		"catppuccin/nvim",
	-- 		name = "catppuccin",
	-- 		priority = 1000,
	-- 		config = function()
	-- 			require("catppuccin").setup({
	-- 				flavour = "macchiato",
	-- 			})
	-- 			vim.cmd.colorscheme("catppuccin")
	-- 		end,
	-- 	},
	-- },
}
