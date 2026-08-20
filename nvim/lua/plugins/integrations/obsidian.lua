local M = {}

-- ┌────────────────────────────┐
-- │ Obsidian notes workspace   │
-- └────────────────────────────┘
function M.setup()
	local notes_path = vim.fn.expand("~/Nextcloud/Notes/")
	if vim.fn.isdirectory(notes_path) == 0 then
		-- Avoid aborting startup when the optional Nextcloud workspace is not mounted.
		return
	end

	require("obsidian").setup({ workspaces = { { name = "notes", path = notes_path } } })
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("ConfigObsidianMaps", { clear = true }),
		pattern = "markdown",
		callback = function(event)
			local map = function(mode, keys, action, description)
				vim.keymap.set(mode, keys, action, { buffer = event.buf, desc = description })
			end
			map("n", "<localleader>b", "<cmd>ObsidianBacklinks<CR>", "Show [B]acklinks")
			map("n", "<localleader>l", "<cmd>ObsidianLinks<CR>", "Show [L]inks in buffer")
			map("n", "<localleader>n", "<cmd>ObsidianNew<CR>", "[N]ew Note")
			map("n", "<localleader>s", "<cmd>ObsidianSearch<CR>", "[S]earch Notes")
			map("n", "<localleader>t", "<cmd>ObsidianTags<CR>", "Show [T]ags")
			map("n", "<localleader>w", "<cmd>ObsidianWorkspace<CR>", "Switch [W]orkspace")
			map("v", "<localleader>l", function()
				require("config.util").prompt_command("ObsidianLink", "Link to")
			end, "[L]ink Selection to Note")
			map("v", "<localleader>L", function()
				require("config.util").prompt_command("ObsidianLinkNew", "Link to new note")
			end, "[L]ink Selection to new Note")
			map("v", "<localleader>x", function()
				require("config.util").prompt_command("ObsidianExtractNote", "New note")
			end, "E[x]tract Selection into Note")
		end,
	})
end

return M
