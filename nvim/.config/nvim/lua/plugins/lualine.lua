return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")

		lualine.setup({
			options = {
				theme = "auto",
			},
			disabled_filetypes = {
				"NVimTree",
			},
			extensions = {
				"nvim-tree",
			},
			sections = {
				lualine_a = {
					{
						"filename",
						file_status = true,
						path = 1,
					},
				},
				lualine_x = {
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
		})
	end,
}
