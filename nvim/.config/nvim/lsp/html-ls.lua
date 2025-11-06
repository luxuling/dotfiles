local cmp = require("cmp_nvim_lsp")

return {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = {
		"html",
		"blade",
		"javascriptreact",
		"typescriptreact",
		"svelte",
	},
	root_markers = { "index.html", ".git" },
	init_options = { provideFormatter = true },
	capabilities = cmp.default_capabilities(),
}
