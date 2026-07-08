return {
	"loctvl842/monokai-pro.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("monokai-pro").setup({
			day_night = {
				enable = true,
				day_filter = "light",
				night_filter = "spectrum",
			},
		})
	end,
}
