local M = {}

-- ┌─────────────────────────────────────┐
-- │ Cohesive editor primitives          │
-- └─────────────────────────────────────┘
function M.setup()
	-- Textobjects and surroundings retain the established editing workflow.
	require("mini.ai").setup({ n_lines = 500 })
	require("mini.surround").setup()

	-- Typed pairs complement Blink's completion-time function-call brackets.
	require("mini.pairs").setup()
	require("mini.indentscope").setup({
		options = { try_as_border = true },
		symbol = "│",
	})

	-- Provide one icon source, including a devicons-compatible API for Telescope.
	require("mini.icons").setup({
		style = vim.g.have_nerd_font and "glyph" or "ascii",
	})
	MiniIcons.mock_nvim_web_devicons()

	-- Restrict animation to cursor movement so opening and resizing windows stay immediate.
	require("mini.animate").setup({
		scroll = { enable = false },
		resize = { enable = false },
		open = { enable = false },
		close = { enable = false },
	})

end

return M
