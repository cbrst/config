local M = {}

-- ╭─────────────────────────────╮
-- │ Persistent file exploration │
-- ╰─═══════════════════════════─╯
function M.setup()
	require("neo-tree").setup({
		filesystem = {
			follow_current_file = { enabled = true },
		},
	})

	-- Always reveal the current buffer so the tree opens in the relevant directory.
	vim.keymap.set("n", "\\", "<cmd>Neotree toggle reveal_force_cwd<cr>", { desc = "Browse files near current buffer" })
	vim.keymap.set("n", "<leader>vt", "<cmd>Neotree toggle reveal_force_cwd<cr>", { desc = "[V]iew [T]ree files" })
end

return M
