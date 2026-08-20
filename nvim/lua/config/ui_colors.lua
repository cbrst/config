local M = {}

-- ┌───────────────────────────────┐
-- │ Shared status and WinBar hues │
-- └───────────────────────────────┘
function M.get()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	local visual = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
	if vim.o.background == "light" then
		return {
			bar = "#eeeeee",
			inactive = "#e3e3e3",
			fg = "#34332f",
			muted = "#77746b",
			tab = normal.bg or "#f8f8f2",
			label = "#e3e3e3",
			editor = normal.bg or "#f8f8f2",
			context = visual.fg or "#5a5a52",
			command = "#d9d7ce",
		}
	end

	return {
		-- Lighter than Monokai Pro's default status-bar shade while remaining subdued.
		bar = "#3b3b3b",
		inactive = "#2b2b2b",
		fg = "#fbf8ff",
		muted = "#aaa8a0",
		tab = normal.bg or "#222222",
		label = "#2b2b2b",
		editor = normal.bg or "#222222",
		context = visual.fg or "#fce566",
		command = "#181818",
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
