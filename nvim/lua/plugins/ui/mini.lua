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

	-- Replace the persistent tree with an editable explorer focused on the current file.
	require("mini.files").setup({
		mappings = {
			close = "\\",
		},
	})

	-- Restrict animation to cursor movement so opening and resizing windows stay immediate.
	require("mini.animate").setup({
		scroll = { enable = false },
		resize = { enable = false },
		open = { enable = false },
		close = { enable = false },
	})

	-- These global mappings replace Lazy's former key-trigger declarations.
	vim.keymap.set("n", "\\", function()
		require("mini.files").open(vim.api.nvim_buf_get_name(0))
	end, { desc = "Browse files near current buffer" })
	vim.keymap.set("n", "<leader>vt", function()
		require("mini.files").open(vim.api.nvim_buf_get_name(0))
	end, { desc = "[V]iew [T]ree files" })
end

return M
