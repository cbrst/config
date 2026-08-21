local M = {}

-- ┌───────────────────────────────┐
-- │ Shared status and WinBar hues │
-- └───────────────────────────────┘
function M.get()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	local visual = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
	if vim.o.background == "light" then
		return {
			bar = "#e6e0db",
			inactive = "#f2eee9",
			fg = "#3c312a",
			muted = "#7e7063",
			tab = normal.bg or "#f9f6f1",
			label = "#e6e0db",
			editor = normal.bg or "#f9f6f1",
			context = visual.fg or "#911256",
			command = "#e8e3de",
		}
	end

	return {
		bar = "#201f1d",
		inactive = "#171616",
		fg = "#e2e0df",
		muted = "#b1ada9",
		tab = normal.bg or "#171616",
		label = "#171616",
		editor = normal.bg or "#171616",
		context = visual.fg or "#eaa4c9",
		command = "#100f0f",
	}
end

function M.apply()
	local colors = M.get()
	local directory = vim.api.nvim_get_hl(0, { name = "Directory", link = false })

	-- Heirline owns StatusLine; Dropbar inherits the editor-colored WinBar surface.
	vim.api.nvim_set_hl(0, "StatusLine", { bg = colors.bar, fg = colors.fg })
	vim.api.nvim_set_hl(0, "StatusLineNC", { bg = colors.inactive, fg = colors.muted })
	vim.api.nvim_set_hl(0, "WinBar", { bg = colors.editor, fg = colors.fg })
	vim.api.nvim_set_hl(0, "WinBarNC", { bg = colors.editor, fg = colors.muted })

	-- Dropbar marks the active path item with Visual by default, including a contrasting background.
	-- Retain the foreground cue while keeping current folders flush with the editor background.
	vim.api.nvim_set_hl(0, "DropBarCurrentContext", { bg = colors.editor, fg = colors.context })
	vim.api.nvim_set_hl(0, "DropBarCurrentContextIcon", { bg = colors.editor, fg = colors.context })
	vim.api.nvim_set_hl(0, "DropBarCurrentContextName", { bg = colors.editor, fg = colors.context })
	vim.api.nvim_set_hl(0, "DropBarHover", { bg = colors.editor, fg = colors.context })
	-- Directory's theme background leaks through Dropbar's active folder icons.
	vim.api.nvim_set_hl(0, "DropBarIconKindFolder", { bg = colors.editor, fg = directory.fg })

	-- Keep command entry distinct with subdued text and without changing editor surfaces.
	vim.api.nvim_set_hl(0, "MsgArea", { bg = colors.command, fg = colors.muted })
	vim.api.nvim_set_hl(0, "MsgSeparator", { bg = colors.command, fg = colors.command })
end

return M
