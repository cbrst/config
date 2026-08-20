local M = {}

function M.setup()
	require("outline").setup({ outline_window = { position = "right" } })
	vim.keymap.set("n", "<leader>so", "<cmd>Outline<cr>", { desc = "[S]earch [O]utline" })
	vim.keymap.set("n", "<leader>vo", "<cmd>Outline<cr>", { desc = "[V]iew [O]utline" })
end

return M
