return {
	"ellisonleao/gruvbox.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		require("gruvbox").setup({
			transparent_mode = true,
		})
		vim.cmd("colorscheme gruvbox")
	end,
}
