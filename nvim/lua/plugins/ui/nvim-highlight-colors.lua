local M = {}

function M.setup()
	require("nvim-highlight-colors").setup({
		render = "virtual",
		virtual_symbol = "",
		virtual_symbol_prefix = "",
		virtual_symbol_suffix = "",
		virtual_symbol_position = "eol",
		enable_tailwind = true,
	})
end

return M
