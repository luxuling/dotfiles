local cmp = require("cmp_nvim_lsp")
return {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		-- "vue"
	},
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
	settings = {
		typescript = {
			-- Remove tsdk setting to allow auto-detection
			tsserver = {
				useSyntaxServer = false,
			},
		},
		javascript = {
			-- Remove tsdk setting to allow auto-detection
		},
	},
	capabilities = cmp.default_capabilities(),
}
