local M = {}

function M.setup()
	-- Configure both theme plugins before init.lua applies the active palette.
	require("plugins.theme.monokai-pro").setup()
	require("plugins.theme.auto-dark-mode").setup()
end

return M
