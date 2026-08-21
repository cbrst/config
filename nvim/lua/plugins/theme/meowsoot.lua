local M = {}

function M.setup()
	require("meowsoot").setup({
		plugins = { all = true },
	})
end

return M
