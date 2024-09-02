return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	opts = {},
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()
		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			local finder = function()
				local paths = {}
				for _, item in ipairs(harpoon_files.items) do
					table.insert(paths, item.value)
				end

				return require("telescope.finders").new_table({
					results = paths,
				})
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr, map)
						map("i", "<C-d>", function()
							local state = require("telescope.actions.state")
							local selected_entry = state.get_selected_entry()
							local current_picker = state.get_current_picker(prompt_bufnr)

							table.remove(harpoon_files.items, selected_entry.index)
							current_picker:refresh(finder())
						end)
						return true
					end,
				})
				:find()
		end

		local keymap = vim.keymap

		keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end)
		keymap.set("n", "<C-e>", function()
			toggle_telescope(harpoon:list())
		end, { desc = "Open harpoon window" })

		keymap.set("n", "<C-1>", function()
			harpoon:list():select(1)
		end)
		keymap.set("n", "<C-2>", function()
			harpoon:list():select(2)
		end)
		keymap.set("n", "<C-3>", function()
			harpoon:list():select(3)
		end)
		keymap.set("n", "<C-4>", function()
			harpoon:list():select(4)
		end)

		-- Toggle previous & next buffers stored within Harpoon list
		keymap.set("n", "<C-S-P>", function()
			harpoon:list():prev()
		end)
		keymap.set("n", "<C-S-N>", function()
			harpoon:list():next()
		end)
	end,
}
