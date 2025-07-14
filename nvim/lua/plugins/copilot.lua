return {
	"github/copilot.vim",
	config = function()
		-- Enable Copilot by default
		vim.g.copilot_enabled = true

		-- VS Code-like tab completion
		vim.g.copilot_no_tab_map = true
		vim.g.copilot_assume_mapped = true

		-- Set up keymaps for VS Code-like experience
		vim.keymap.set("i", "<Tab>", function()
			if vim.fn["copilot#Accept"]("") ~= "" then
				return vim.fn["copilot#Accept"]("")
			else
				return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
			end
		end, { expr = true, replace_keycodes = false })

		-- Alternative suggestions
		vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
		vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", { desc = "Previous Copilot suggestion" })

		-- Dismiss suggestion
		vim.keymap.set("i", "<C-]>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot suggestion" })

		-- Manual trigger (if you want to manually request suggestions)
		vim.keymap.set("i", "<M-\\>", "<Plug>(copilot-suggest)", { desc = "Trigger Copilot suggestion" })

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
