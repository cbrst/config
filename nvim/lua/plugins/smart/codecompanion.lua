local M = {}

-- ┌────────────────────────────┐
-- │ CodeCompanion and OpenCode │
-- └────────────────────────────┘
function M.setup()
	require("codecompanion").setup({
		interactions = {
			-- ACP preserves OpenCode's CLI authentication, MCP servers, skills, and agents.
			chat = { adapter = "opencode" },
		},
		display = {
			-- Reuse the configured picker instead of adding another selection UI.
			action_palette = { provider = "telescope" },
		},
	})

	vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle [A]I chat" })
	vim.keymap.set("x", "<leader>aa", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to [A]I chat" })
	vim.keymap.set({ "n", "x" }, "<leader>as", "<cmd>CodeCompanionActions<cr>", { desc = "[S]elect AI action" })
	vim.keymap.set({ "n", "x" }, "<leader>ac", "<cmd>CodeCompanion<cr>", { desc = "[C]odeCompanion inline action" })
	vim.keymap.set("n", "<leader>ar", "<cmd>CodeCompanionCodeReview<cr>", { desc = "AI code [R]eview" })
end

return M
