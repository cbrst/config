local M = {}

function M.setup()
	require("auto-dark-mode").setup({
		set_dark_mode = function()
			require("config.theme").set_colorscheme("dark")
		end,
		set_light_mode = function()
			require("config.theme").set_colorscheme("light")
		end,
	})
end

return M
