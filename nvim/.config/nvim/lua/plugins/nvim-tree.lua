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
				sorter = function(nodes)
					table.sort(nodes, function(a, b)
						local a_rank = a.type == "directory" and 0 or (a.name:match("_test%.go$") and 2 or 1)
						local b_rank = b.type == "directory" and 0 or (b.name:match("_test%.go$") and 2 or 1)
						return a_rank == b_rank and a.name < b.name or a_rank < b_rank
					end)
				end,
			},
			view = {
				width = 40,
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
