-- Version guard
if vim.fn.has("nvim-0.12") == 0 then
	error("This config requires Neovim 0.12+")
end

-- Leader key (must be before plugins)
vim.g.mapleader = " "

-- =============================================================================
-- OPTIONS
-- =============================================================================
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.winborder = "rounded"
vim.o.signcolumn = "yes:1"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.autoread = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 3
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.confirm = true

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- =============================================================================
-- KEYMAPS
-- =============================================================================
vim.keymap.set("i", "ii", "<Esc>", { desc = "Exit insert mode" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus up" })

-- Buffer navigation
vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprev<cr>", { desc = "Previous buffer" })

-- Resize splits
vim.keymap.set("n", "<C-S-Up>", "<cmd>resize +2<cr>", { desc = "Increase height" })
vim.keymap.set("n", "<C-S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease height" })
vim.keymap.set("n", "<C-S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
vim.keymap.set("n", "<C-S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })

-- Window management
vim.keymap.set("n", "<leader>wf", "<C-w>_<C-w>|", { desc = "Window fullscreen" })
vim.keymap.set("n", "<leader>we", "<C-w>=", { desc = "Window equalize" })

-- =============================================================================
-- AUTOCOMMANDS
-- =============================================================================
local augroup = vim.api.nvim_create_augroup("user-config", { clear = true })

-- Reload buffer on external change
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	group = augroup,
	callback = function()
		if vim.fn.getcmdwintype() == "" then
			vim.cmd.checktime()
		end
	end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = augroup,
	callback = function()
		vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
	end,
})

-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Auto-recover and clean swap files
vim.api.nvim_create_autocmd("SwapExists", {
	group = augroup,
	callback = function()
		vim.v.swapchoice = "r"
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = augroup,
	callback = function(args)
		if not vim.api.nvim_buf_is_valid(args.buf) then
			return
		end
		local ok, swapfile = pcall(vim.fn.swapname, args.buf)
		if ok and swapfile ~= "" and vim.fn.filereadable(swapfile) == 1 then
			vim.fn.delete(swapfile)
		end
	end,
})

-- =============================================================================
-- PLUGINS
-- =============================================================================
vim.pack.add({
	-- Theme
	{ src = "https://github.com/rebelot/kanagawa.nvim" },

	-- LSP & Tools
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/j-hui/fidget.nvim" },

	-- Completion & Snippets
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },

	-- Treesitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },

	-- UI
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },

	-- Navigation
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },

	-- Editing
	{ src = "https://github.com/echasnovski/mini.nvim" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	{ src = "https://github.com/smjonas/inc-rename.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- Git
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/ruifm/gitlinker.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },

	-- Utilities
	{ src = "https://github.com/moll/vim-bbye" },
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{ src = "https://github.com/github/copilot.vim" },
})

-- Colorscheme
vim.cmd.colorscheme("kanagawa-dragon")

-- =============================================================================
-- PLUGIN SETUP
-- =============================================================================

-- Helper for safe requires
local function setup(name, opts)
	local ok, mod = pcall(require, name)
	if not ok then
		vim.notify("Failed to load " .. name, vim.log.levels.WARN)
		return nil
	end
	if opts ~= nil then
		mod.setup(opts)
	end
	return mod
end

-- Mason
setup("mason", {})
setup("mason-tool-installer", {
	ensure_installed = {
		"lua-language-server", "typescript-language-server", "basedpyright",
		"svelte-language-server", "html-lsp", "css-lsp", "json-lsp", "yaml-language-server",
		"stylua", "ruff", "black", "isort", "prettierd", "pgformatter", "biome",
	},
})

-- Fidget
setup("fidget", {})

-- Blink.cmp
setup("blink.cmp", {
	keymap = { preset = "default" },
	appearance = { nerd_font_variant = "mono" },
	completion = { documentation = { auto_show = true, auto_show_delay_ms = 500 } },
	sources = { default = { "lsp", "path", "snippets" } },
	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "prefer_rust" },
	signature = { enabled = true },
})

-- Treesitter
setup("nvim-treesitter.configs", {
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true, disable = { "ruby", "python", "c" } },
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer", ["if"] = "@function.inner",
				["ac"] = "@class.outer", ["ic"] = "@class.inner",
				["at"] = "@tag.outer", ["it"] = "@tag.inner",
			},
		},
	},
})

-- Lualine
setup("lualine", {
	options = {
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { { "filename", path = 1 }, "diagnostics" },
		lualine_c = {},
		lualine_y = { "branch", "diff" },
		lualine_z = { "location" },
	},
	tabline = {
		lualine_a = { { "buffers", mode = 4, symbols = { modified = " ●" } } },
	},
})

-- Indent Blankline
setup("ibl", { indent = { char = "│" } })

-- Which-key
setup("which-key", {
	delay = 500,
	icons = { mappings = vim.g.have_nerd_font },
	spec = {
		{ "<leader>s", group = "Search" },
		{ "<leader>t", group = "Toggle" },
		{ "<leader>h", group = "Git Hunk", mode = { "n", "v" } },
	},
})

-- Snacks
local snacks = setup("snacks", {
	picker = {
		prompt = " ",
		ui_select = true,
		layout = {
			preset = function()
				return vim.o.columns >= 120 and "default" or "vertical"
			end,
		},
		win = {
			input = {
				keys = { ["<Esc>"] = { "close", mode = { "i", "n" } } },
			},
		},
	},
	notifier = { enabled = true },
	quickfile = { enabled = true },
	words = { enabled = true },
})

-- Snacks keymaps
if snacks then
	local picker = snacks.picker
	vim.keymap.set("n", "<leader>sh", picker.help, { desc = "Search help" })
	vim.keymap.set("n", "<leader>sk", picker.keymaps, { desc = "Search keymaps" })
	vim.keymap.set("n", "<leader>sf", picker.files, { desc = "Search files" })
	vim.keymap.set("n", "<leader>sw", picker.grep_word, { desc = "Search word" })
	vim.keymap.set("n", "<leader>sg", picker.grep, { desc = "Search grep" })
	vim.keymap.set("n", "<leader>sd", picker.diagnostics, { desc = "Search diagnostics" })
	vim.keymap.set("n", "<leader>sr", picker.resume, { desc = "Search resume" })
	vim.keymap.set("n", "<leader>s.", picker.recent, { desc = "Search recent" })
	vim.keymap.set("n", "<leader><leader>", picker.buffers, { desc = "Find buffers" })
	vim.keymap.set("n", "<leader>ss", picker.lsp_symbols, { desc = "Search symbols" })
	vim.keymap.set("n", "<leader>sS", picker.lsp_workspace_symbols, { desc = "Search workspace symbols" })
	vim.keymap.set("n", "<leader>sp", picker.pickers, { desc = "Search pickers" })
	vim.keymap.set("n", "<leader>/", picker.lines, { desc = "Search in buffer" })
	vim.keymap.set("n", "<leader>s/", picker.grep_buffers, { desc = "Search in open files" })
end

-- Oil
local oil = setup("oil", {
	watch_for_changes = true,
	keymaps = {
		["<C-x>"] = { "actions.select", opts = { horizontal = true } },
		["<C-v>"] = { "actions.select", opts = { vertical = true } },
		["<C-t>"] = { "actions.select", opts = { tab = true } },
	},
})
if oil then
	vim.keymap.set("n", "<leader>e", oil.open, { desc = "Open file explorer" })
end

-- Mini.nvim
setup("mini.ai", { n_lines = 500 })
setup("mini.surround", {})
setup("mini.icons", {})

-- Autopairs & Autotags
setup("nvim-autopairs", {})
setup("nvim-ts-autotag", {
	opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
})

-- Inc-rename
setup("inc_rename", {})

-- Conform
local conform = setup("conform", {
	notify_on_error = false,
	format_on_save = function(bufnr)
		local disable = { c = true, cpp = true }
		if disable[vim.bo[bufnr].filetype] then
			return nil
		end
		return { timeout_ms = 1000, lsp_format = "fallback" }
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black", "ruff_fix" },
		javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
		typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
		json = { "biome", "prettierd", "prettier", stop_after_first = true },
		yaml = { "prettierd", "prettier", stop_after_first = true },
		svelte = { "prettierd", "prettier", stop_after_first = true },
		sql = { "pg_format" },
	},
})
if conform then
	vim.keymap.set({ "n", "v" }, "<leader>f", function()
		conform.format({ async = true, lsp_format = "fallback" })
	end, { desc = "Format buffer" })
end

-- JsonFormat command
vim.api.nvim_create_user_command("JsonFormat", function()
	vim.bo.filetype = "json"
	if conform then
		conform.format({ async = true, lsp_format = "fallback" })
	end
end, {})

-- Gitsigns
setup("gitsigns", { current_line_blame = true })

-- Gitlinker
local gitlinker_actions = require("gitlinker.actions")
setup("gitlinker", {
	opts = {
		add_current_line_on_normal_mode = true,
		action_callback = gitlinker_actions.copy_to_clipboard,
		print_url = true,
	},
	callbacks = {
		["github.com"] = require("gitlinker.hosts").get_github_type_url,
	},
	mappings = "<leader>gy",
})
vim.keymap.set("n", "<leader>gY", function()
	require("gitlinker").get_repo_url()
end, { desc = "Copy repo URL" })
vim.keymap.set({ "n", "v" }, "<leader>gb", function()
	require("gitlinker").get_buf_range_url("n", { action_callback = gitlinker_actions.open_in_browser })
end, { desc = "Open in browser" })

-- Trouble
local trouble = setup("trouble", {
	modes = { lsp_references = { params = { include_declaration = true } } },
})
if trouble then
	vim.keymap.set("n", "]t", function() trouble.next({ skip_groups = true, jump = true }) end, { desc = "Next trouble" })
	vim.keymap.set("n", "[t", function() trouble.prev({ skip_groups = true, jump = true }) end, { desc = "Prev trouble" })
end
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols" })
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location list" })
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list" })

-- Todo Comments
setup("todo-comments", { signs = false })

-- Vim-bbye
vim.keymap.set("n", "<leader>bd", "<cmd>Bdelete<cr>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bw", "<cmd>Bwipeout<cr>", { desc = "Wipeout buffer" })

-- Copilot
vim.g.copilot_enabled = true
vim.g.copilot_no_tab_map = true
vim.keymap.set("i", "<S-Tab>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
vim.g.copilot_filetypes = { ["*"] = true, gitcommit = false, gitrebase = false, help = false }

-- =============================================================================
-- LSP
-- =============================================================================
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = { source = "if_many", spacing = 2 },
})

vim.lsp.enable({
	"lua_ls", "ts_ls", "basedpyright", "svelte", "html", "cssls", "jsonls", "yamlls",
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- Navigation (using Snacks picker)
		if snacks then
			map("gd", snacks.picker.lsp_definitions, "Go to definition")
			map("gr", snacks.picker.lsp_references, "Go to references")
			map("gi", snacks.picker.lsp_implementations, "Go to implementation")
			map("gt", snacks.picker.lsp_type_definitions, "Go to type definition")
		end
		map("gD", vim.lsp.buf.declaration, "Go to declaration")

		-- Actions
		map("grn", vim.lsp.buf.rename, "Rename")
		map("ga", vim.lsp.buf.code_action, "Code action", { "n", "x" })

		-- Document highlights
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
			local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = hl_group,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = hl_group,
				callback = vim.lsp.buf.clear_references,
			})
			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
				callback = function(e)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = e.buf })
				end,
			})
		end

		-- Inlay hints
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "Toggle inlay hints")
		end
	end,
})
