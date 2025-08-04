return {
	"github/copilot.vim",
	config = function()
		-- Enable Copilot by default
		vim.g.copilot_enabled = true
		vim.g.copilot_no_tab_map = true

		vim.keymap.set("i", "<S-Tab>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
		})

		-- Alternative suggestions
		-- Filetypes to disable Copilot (add as needed)
		vim.g.copilot_filetypes = {
			["*"] = true,
			gitcommit = false,
			gitrebase = false,
			help = false,
			markdown = true,
		}
	end,
	event = "InsertEnter", -- Load when entering insert mode
}
