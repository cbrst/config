return vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua" },
	callback = function()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		-- Folding is window-local, so preserve Lua's indent folds in its active window.
		vim.wo.foldmethod = "indent"
	end,
})
