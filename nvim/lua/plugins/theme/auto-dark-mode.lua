return {
	"f-person/auto-dark-mode.nvim",
	priority = 1,
	opts = {
		set_dark_mode = function()
			Myvi.set_colorscheme("dark")
		end,
		set_light_mode = function()
			Myvi.set_colorscheme("light")
		end,
	},
}
