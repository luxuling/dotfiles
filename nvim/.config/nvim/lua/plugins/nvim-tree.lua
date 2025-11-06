return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("nvim-tree").setup({
			actions = {
				open_file = {
					quit_on_open = true,
				},
			},
			sort = {
				sorter = "case_sensitive",
			},
			view = {
				width = 30,
				relativenumber = false,
				side = "left",
			},
			filters = {
				custom = { "^.git$", "node_modules" },
			},
			git = {
				enable = true,
				ignore = false,
			},
			log = {
				enable = true,
				truncate = true,
				types = {
					diagnostics = true,
					git = true,
					profile = true,
					watcher = true,
				},
			},
		})
	end,
}
