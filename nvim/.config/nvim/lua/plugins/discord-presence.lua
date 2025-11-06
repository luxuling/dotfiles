return {
	"andweeb/presence.nvim",
	lazy = false,
	config = function()
		require("presence"):setup({
			neovim_image_text = "The One True Text Editor",
			editing_text = "Editing %s",
			file_explorer_text = "Browsing %s",
			git_commit_text = "Committing changes",
			git_rebase_text = "Rebasing changes",
			plugin_manager_text = "Managing plugins",
			reading_text = "Reading %s",
			workspace_text = "In %s workspace",
			line_number_text = "Line %s of %s",
			show_time = true,
		})
	end,
}
