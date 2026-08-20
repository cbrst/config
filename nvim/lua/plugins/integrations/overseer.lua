local M = {}

function M.setup()
	require("overseer").setup({})
	vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun<cr>", { desc = "Overseer: [R]un" })
	vim.keymap.set("n", "<leader>ot", "<cmd>OverseerToggle<cr>", { desc = "Overseer: [T]oggle" })
end

return M
