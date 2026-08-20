local M = {}

-- ┌───────────────────────────────┐
-- │ Neovim process-wide settings │
-- └───────────────────────────────┘
function M.setup()
	-- Define leaders before loading plugins so their mappings use these values.
	vim.g.mapleader = " "
	vim.g.maplocalleader = ","

	-- The Home Manager profile installs Nerd Font symbols for configured terminals.
	vim.g.have_nerd_font = true
end

return M
