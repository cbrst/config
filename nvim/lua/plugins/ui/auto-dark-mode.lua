return {
	"f-person/auto-dark-mode.nvim",
	opts = {
		update_interval = 1000,
		set_dark_mode = function()
			vim.opt.background = "dark"
			vim.cmd("colorscheme rose-pine")
		end,
		set_light_mode = function()
			vim.opt.background = "light"
			vim.cmd("colorscheme rose-pine")
		end,
	},
}
