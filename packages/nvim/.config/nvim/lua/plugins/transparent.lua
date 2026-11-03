return {
	"xiyaowong/transparent.nvim",
	priority = 1000,
	lazy = false,

	config = function()
		require("transparent").setup({})
		vim.cmd("TransparentEnable")
	end,
}
