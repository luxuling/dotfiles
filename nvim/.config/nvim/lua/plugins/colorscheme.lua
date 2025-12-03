return {
	"olimorris/onedarkpro.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		require("onedarkpro").setup({
			options = {
				terminal_colors = false,
				cursorline = true,
			},
			highlights = {
				Comment = { fg = "#4DFFBE", italic = true },
			},
		})
		vim.cmd("colorscheme vaporwave")
		vim.api.nvim_set_hl(0, "Visual", {
			bg = "#f4dbd6",
			blend = 0,
		})
	end,
}
