return vim.api.nvim_create_autocmd("FileType", {
	patter = { "lua" },
	callback = function()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.foldmethod = "indent"
	end,
})
