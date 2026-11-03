vim.filetype.add({
	pattern = {
		[".*%.blade.php"] = "blade",
	},
})

vim.filetype.add({
	extension = {
		mdx = "markdown",
	},
	filename = {},
	pattern = {},
})
