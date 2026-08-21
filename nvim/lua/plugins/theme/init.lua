local M = {}

function M.setup()
	-- Configure the selected family before init.lua applies its active variant.
	require("plugins.theme.meowsoot").setup()
	require("plugins.theme.auto-dark-mode").setup()
end

return M
