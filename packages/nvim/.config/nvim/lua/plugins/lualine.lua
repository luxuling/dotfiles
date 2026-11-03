return {
	"nvim-lualine/lualine.nvim",
	config = function()
		local mode_color = {
			n = { fg = "#a6e3a1", bg = "none" }, -- NORMAL
			i = { fg = "#89b4fa", bg = "none" }, -- INSERT
			v = { fg = "#f38ba8", bg = "none" }, -- VISUAL
			V = { fg = "#f38ba8", bg = "none" }, -- VISUAL LINE
			["\22"] = { fg = "#f38ba8", bg = "none" }, -- VISUAL BLOCK
			c = { fg = "#fab387", bg = "none" }, -- COMMAND
			R = { fg = "#f9e2af", bg = "none" }, -- REPLACE
		}

		require("lualine").setup({
			options = {
				section_separators = "",
				component_separators = "",
			},
			sections = {
				lualine_a = {
					{
						"mode",
						color = function()
							return mode_color[vim.fn.mode()] or { fg = "#ffffff", bg = "none" }
						end,
					},
				},
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { {
					"filename",
					file_status = true,
					path = 1,
				} },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = {
					{ "progress", color = { fg = "#ffffff", bg = "none" } },
				},
				lualine_z = {
					{ "location", color = { fg = "#ffffff", bg = "none" } },
				},
			},
		})
	end,
}
