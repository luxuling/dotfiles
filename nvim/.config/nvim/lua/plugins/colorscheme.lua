return {
	"olimorris/onedarkpro.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		require("onedarkpro").setup({
			options = {
				terminal_colors = false,
				cursorline = true,
				transparency = true,
			},
			highlights = {
				Comment = { fg = "#4DFFBE", bg = "#FFFFFF", italic = true },
			},
		})
		vim.cmd("colorscheme vaporwave")
	end,
}
