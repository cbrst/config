local M = {}

function M.setup()
	-- config.theme selects the explicit Spectrum or Light colorscheme after all setup.
	require("monokai-pro").setup({})
end

return M
