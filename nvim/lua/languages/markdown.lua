return vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- Set conceallevel=2 for markdown files
		-- 0: No concealing
		-- 1: Concealed text shows as one character
		-- 2: Concealed text is hidden unless it has replacement character
		-- 3: Concealed text is hidden
		vim.bo.conceallevel = 2
	end,
	desc = "Set concealment level for markdown files",
})
