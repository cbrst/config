local M = {}

function M.setup()
	local lint = require("lint")
	lint.linters_by_ft = { markdown = { "markdownlint" } }

	-- Run linting after buffer changes while avoiding unconfigured default linters.
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
		group = vim.api.nvim_create_augroup("ConfigLint", { clear = true }),
		callback = function()
			lint.try_lint()
		end,
	})
end

return M
