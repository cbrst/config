local M = {}

-- ┌────────────────────────────┐
-- │ Monokai Pro theme selection │
-- └────────────────────────────┘
function M.set_colorscheme(variant)
	-- Keep Neovim aligned with the Monokai variants used by Ghostty and OpenCode.
	variant = variant or vim.opt.background:get()
	vim.api.nvim_set_option_value("background", variant, {})
	vim.cmd.colorscheme(variant == "light" and "monokai-pro-light" or "monokai-pro-spectrum")
	-- Monokai clears generated Heirline groups, so rebuild them before the next render.
	require("heirline.utils").on_colorscheme()
	-- Reapply shared UI surfaces after the colorscheme resets status and window highlights.
	require("config.ui_colors").apply()
end

return M
