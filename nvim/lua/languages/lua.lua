local M = {}

function M.setup()
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("ConfigLuaFiletype", { clear = true }),
		pattern = "lua",
		desc = "Use Lua-specific indentation and folds",
		callback = function()
			vim.bo.shiftwidth = 2
			vim.bo.tabstop = 2
			-- Folding is window-local, so preserve Lua's indent folds in its active window.
			vim.wo.foldmethod = "indent"
		end,
	})
end

return M
