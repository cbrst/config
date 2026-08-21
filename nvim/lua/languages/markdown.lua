local M = {}

function M.setup()
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("ConfigMarkdownFiletype", { clear = true }),
		pattern = "markdown",
		desc = "Hide concealed Markdown syntax",
		callback = function()
			-- Rendered Markdown markers stay hidden while replacement characters remain visible.
			vim.wo.conceallevel = 2
		end,
	})
end

return M
