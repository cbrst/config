local M = {}

-- ┌────────────────────────────┐
-- │ Eager plugin configuration │
-- └────────────────────────────┘
function M.setup()
	-- These Vim plugins configure themselves when their runtime files are sourced.
	require("todo-comments").setup({ signs = false })

	-- Set up foundational UI components before plugins that consume their APIs.
	require("plugins.theme").setup()
	require("plugins.ui").setup()
	require("plugins.ui.mini").setup()
	require("plugins.ui.neo-tree").setup()
	require("plugins.ui.heirline").setup()
	require("plugins.ui.telescope").setup()
	require("plugins.ui.which-key").setup()
	require("plugins.ui.snacks").setup()
	require("plugins.ui.outline").setup()
	require("plugins.ui.nvim-highlight-colors").setup()
	require("plugins.ui.gitsigns").setup()

	-- Blink must initialize before LSP capabilities are derived from it.
	require("plugins.smart").setup()
	require("plugins.lsp").setup()
	require("plugins.integrations").setup()
end

return M
