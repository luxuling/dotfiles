return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
		"nvim-telescope/telescope-media-files.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local transform_mod = require("telescope.actions.mt").transform_mod

		local trouble = require("trouble")
		local trouble_telescope = require("trouble.sources.telescope")
		local builtin = require("telescope.builtin")

		-- or create your custom action
		local custom_actions = transform_mod({
			open_trouble_qflist = function(prompt_bufnr)
				trouble.toggle("quickfix")
			end,
		})

		telescope.setup({
			defaults = {
				dynamic_preview_title = true,
				file_ignore_patterns = {
					"node_modules/",
					"%.env",
					"yarn.lock",
					"package-lock.json",
					"target/",
				},
				path_display = { "absolute" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
						["<C-t>"] = trouble_telescope.open,
					},
				},
			},
			extensions = {
				media_files = {
					filetypes = { "png", "webp", "jpg", "jpeg" },
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("media_files")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "fd", "<cmd>Telescope media_files<cr>", { desc = "Find Images" })
		keymap.set("n", "fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "gr", builtin.lsp_references, { desc = "GO To References" })
		keymap.set("n", "gI", builtin.lsp_implementations, { desc = "Go To Implementations" })
	end,
}
