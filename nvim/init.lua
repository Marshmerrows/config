vim.g.mapleader = " "

-- See `:help vim.o`
--  For more options, you can see `:help option-list`
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

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

vim.o.tabstop = 2 -- Number of spaces a tab character displays as
vim.o.softtabstop = 2 -- Number of spaces for <Tab> in insert mode
vim.o.shiftwidth = 2 -- Number of spaces for autoindent (e.g. when you press Enter)
vim.o.expandtab = true -- Convert tabs to spaces
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
-- Map ii to escape in insert mode
vim.keymap.set("i", "ii", "<Esc>", { desc = "Exit insert mode" })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- tab buffer navigation
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>", { desc = "Previous buffer" })
-- Resize splits
vim.keymap.set("n", "<C-S-Up>", ":resize +2<CR>", { desc = "Increase height" })
vim.keymap.set("n", "<C-S-Down>", ":resize -2<CR>", { desc = "Decrease height" })
vim.keymap.set("n", "<C-S-Left>", ":vertical resize -2<CR>", { desc = "Decrease width" })
vim.keymap.set("n", "<C-S-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })

-- Maximize/minimize splits
vim.keymap.set("n", "<leader>wf", "<C-w>_<C-w>|", { desc = "[W]indow [F]ull" })
vim.keymap.set("n", "<leader>we", "<C-w>=", { desc = "[W]indow [E]qualize" })

-- Reload buffer on external change
vim.api.nvim_create_autocmd("FocusGained", {
	desc = "Reload files from disk when we focus vim",
	pattern = "*",
	command = "if getcmdwintype() == '' | checktime | endif",
})
vim.api.nvim_create_autocmd("BufEnter", {
	desc = "Every time we enter an unmodified buffer, check if it changed on disk",
	pattern = "*",
	command = "if &buftype == '' && !&modified && expand('%') != '' | exec 'checktime ' . expand('<abuf>') | endif",
})
-- Notification when file is reloaded
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	pattern = "*",
	command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None",
})
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
-- Auto-delete swap files after successful recovery
vim.api.nvim_create_autocmd("SwapExists", {
	callback = function()
		-- Auto-recover and delete swap file
		vim.v.swapchoice = "r" -- Auto-recover
	end,
})

-- Delete swap file after successful buffer write
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function(args)
		-- Use the actual buffer number from the event instead of bufname()
		local bufnr = args.buf

		-- Check if buffer is still valid
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		local ok, swapfile = pcall(vim.fn.swapname, bufnr)
		if not ok or swapfile == "" then
			return
		end

		if vim.fn.filereadable(swapfile) == 1 then
			vim.fn.delete(swapfile)
		end
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	{ import = "plugins" },
}, {})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
