return {
	"brianhuster/live-preview.nvim",
	build = "npm init && npm install && npm install -g nodemon", --- if you use npm
	-- build = 'yarn init && yarn install && yarn global add nodemon', --- if you use yarn
	ft = { "html", "md", "markdown" },
	opts = {},
}
