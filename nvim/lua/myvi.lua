local M = {}

M.colorscheme = "rose-pine"
M.feline_themes = {
	default = {
		light = {
			bg0 = "#ffffff",
			bg1 = "#444444",
			bg2 = "#000000",
			fg0 = "#999999",
			fg1 = "#ffffff",
			fg2 = "#ffffff",
		},
		dark = {
			bg0 = "#000000",
			bg1 = "#bbbbbb",
			bg2 = "#ffffff",
			fg0 = "#888888",
			fg1 = "#000000",
			fg2 = "#000000",
		},
	},
}

local function get_feline_theme(theme, variant)
	if Myvi.feline_themes[theme] then
		return Myvi.feline_themes[theme][variant]
	end
	return Myvi.feline_themes.default[variant]
end

M.set_colorscheme = function(theme, variant)
	theme = theme or Myvi.colorscheme
	Myvi.colorscheme = theme

	-- set background light/dark
	variant = variant or vim.opt.background:get()
	vim.api.nvim_set_option_value("background", variant, {})

	-- set colorscheme
	-- local colorscheme = vim.g.colors_name:match("(.+)%-[^-]*$")
	vim.cmd("colorscheme " .. theme)

	-- set feline colors
	-- require("feline").use_theme(Myvi.feline_themes[theme][variant])
	require("feline").use_theme(get_feline_theme(theme, variant))
end

return M
