-- Copilot LSP configuration
-- This file is automatically loaded by the mason-lspconfig handler in init.lua
return {
	cmd = { "copilot-language-server", "--stdio" },
	root_markers = { ".git" },
	-- Copilot will attach to all filetypes by default
	-- Authentication: Run :LspCopilotSignIn after starting nvim
}
