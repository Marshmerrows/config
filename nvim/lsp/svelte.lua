return {
	cmd = { 'svelteserver', '--stdio' },
	filetypes = { 'svelte' },
	root_markers = { 'package.json', '.git' },
	single_file_support = true,
	settings = {
		svelte = {
			plugin = {
				typescript = { enable = true },
				css = { enable = true },
			},
		},
	},
}
