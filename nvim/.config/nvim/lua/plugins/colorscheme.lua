return {
	"projekt0n/github-nvim-theme",
	name = "github-theme",
	lazy = false, -- make sure we load this during startup if it is your main colorscheme
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		require("github-theme").setup({
			options = {
				compile_path = vim.fn.stdpath("cache") .. "/github-theme",
				compile_file_suffix = "_compiled",
				hide_end_of_buffer = true,
				hide_nc_statusline = true,
				transparent = true,
				terminal_colors = true,
				dim_inactive = false,
				module_default = true,
			},
		})

		-- Must be called AFTER setup()
		vim.cmd("colorscheme github_dark") -- or whatever variant you use
	end,
}
