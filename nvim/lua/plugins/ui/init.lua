local M = {}

function M.setup()
	require("render-markdown").setup({
		file_types = { "markdown", "codecompanion" },
		render_modes = true,
	})
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
