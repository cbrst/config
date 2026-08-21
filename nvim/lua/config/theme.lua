local M = {}

-- ┌────────────────────────────┐
-- │ Theme family selection │
-- └────────────────────────────┘
function M.set_colorscheme(variant)
	-- Keep Neovim aligned with the family selected by the shared theme command.
	variant = variant or vim.opt.background:get()
	vim.api.nvim_set_option_value("background", variant, {})
	local state_home = vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")
	local family_file = state_home .. "/config-theme/family"
	local family = "meowsoot"
	local file = io.open(family_file, "r")
	if file then
		family = file:read("*l") or family
		file:close()
	end
	if family ~= "monokai-pro" then
		family = "meowsoot"
	end
	local colorscheme = family == "monokai-pro"
		and (variant == "light" and "monokai-pro-light" or "monokai-pro-spectrum")
		or (variant == "light" and "meowsoot-dawn" or "meowsoot")
	vim.cmd.colorscheme(colorscheme)
	-- The colorscheme clears generated Heirline groups, so rebuild them before rendering.
	require("heirline.utils").on_colorscheme()
	-- Reapply shared UI surfaces after the colorscheme resets status and window highlights.
	require("config.ui_colors").apply()
end

return M
