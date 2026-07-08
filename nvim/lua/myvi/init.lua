local M = {}

-- Set a default colorscheme
-- and overwrite with theme set by ts
local success, ts_theme = pcall(require, "myvi.colorscheme")
M.colorscheme = success and ts_theme or "catppuccin"

local function resolve_colorscheme(theme, variant)
	-- Monokai Pro exposes each filter as its own colorscheme, so pick the
	-- light or Ghostty-matching dark filter while keeping "monokai-pro" as the base theme.
	if theme == "monokai-pro" then
		return variant == "light" and "monokai-pro-light" or "monokai-pro-octagon"
	end

	return theme
end

M.set_colorscheme = function(theme, variant)
	theme = theme or Myvi.colorscheme
	Myvi.colorscheme = theme

	-- set background light/dark
	variant = variant or vim.opt.background:get()
	vim.api.nvim_set_option_value("background", variant, {})

	-- set colorscheme
	-- local colorscheme = vim.g.colors_name:match("(.+)%-[^-]*$")
	vim.cmd("colorscheme " .. resolve_colorscheme(theme, variant))
end

return M
