return {
	"ray-x/starry.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		require("starry").setup({})
		vim.cmd("colorscheme mariana")
	end,
}
