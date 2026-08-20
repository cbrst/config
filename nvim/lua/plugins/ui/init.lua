local M = {}

function M.setup()
	-- Explicit setup enables rendering with the package's default behavior.
	require("render-markdown").setup({})
	require("dropbar").setup({
		icons = {
			enable = vim.g.have_nerd_font,
			ui = {
				bar = { separator = "  " },
			},
		},
	})
end

return M
