return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		indent = { enabled = true },
		input = { enabled = true },
		picker = { enabled = true },
		notifier = { enabled = true },
		scope = { enabled = true },
		dim = { enabled = true },
		scroll = {
			enabled = true,
		},
		image = {
			enabled = true,
			doc = {
				enabled = false,
			},
		},
	},
}
