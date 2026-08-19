local M = {}

M.set_colorscheme = function(variant)
	-- Keep the editor on the two Monokai Pro variants used by Ghostty and OpenCode.
	variant = variant or vim.opt.background:get()
	vim.api.nvim_set_option_value("background", variant, {})
	vim.cmd("colorscheme " .. (variant == "light" and "monokai-pro-light" or "monokai-pro-spectrum"))
end

return M
