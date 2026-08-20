local M = {}

function M.setup()
	require("plugins.integrations.obsidian").setup()
	require("plugins.integrations.overseer").setup()
end

return M
