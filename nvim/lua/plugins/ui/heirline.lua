local M = {}

-- ┌─────────────────────────────┐
-- │ Moody-inspired statusline   │
-- └─────────────────────────────┘
local function mode_color(mode)
	local palette = {
		n = { label = " N ", fg = "#5ad4e6", bg = "#2d4649" },
		i = { label = " I ", fg = "#7bd88f", bg = "#344638" },
		v = { label = " V ", fg = "#fce566", bg = "#4d492f" },
		V = { label = " V ", fg = "#fce566", bg = "#4d492f" },
		["\22"] = { label = " V ", fg = "#fce566", bg = "#4d492f" },
		R = { label = " R ", fg = "#fc618d", bg = "#4d2e37" },
		c = { label = " E ", fg = "#948ae3", bg = "#393748" },
	}
	return palette[mode] or palette.n
end

function M.setup()
	local colors = require("config.ui_colors")
	local conditions = require("heirline.conditions")

	local mode = {
		init = function(self)
			self.mode = vim.fn.mode(1)
		end,
		provider = function(self)
			return mode_color(self.mode).label
		end,
		hl = function(self)
			local state = mode_color(self.mode)
			return { fg = state.fg, bg = state.bg, bold = true }
		end,
	}

	local mode_separator = {
		init = function(self)
			self.mode = vim.fn.mode(1)
		end,
		provider = "",
		hl = function(self)
			return { fg = colors.get().tab, bg = mode_color(self.mode).bg }
		end,
	}

	local filename = {
		provider = function()
			local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
			return " " .. (name == "" and "[No Name]" or name) .. " "
		end,
		hl = function()
			return { bg = colors.get().tab, fg = colors.get().fg, bold = true }
		end,
	}

	local divider = {
		provider = "  ",
		hl = function()
			return { bg = colors.get().bar, fg = colors.get().label, bold = true }
		end,
	}

	local filename_separator = {
		provider = "",
		hl = function()
			return { fg = colors.get().tab, bg = colors.get().bar }
		end,
	}

	local filetype = {
		provider = function()
			local icon = MiniIcons.get("filetype", vim.bo.filetype)
			return " " .. icon .. " " .. (vim.bo.filetype == "" and "text" or vim.bo.filetype)
		end,
		hl = function()
			return { bg = colors.get().bar, fg = colors.get().muted }
		end,
	}

	local label_separator_pre = {
		provider = "",
		hl = function()
			return { fg = colors.get().bar, bg = colors.get().label }
		end,
	}

	local label_separator_post = {
		provider = "",
		hl = function()
			return { fg = colors.get().label, bg = colors.get().bar }
		end,
	}

	local git = {
		condition = conditions.is_git_repo,
		provider = function()
			local status = vim.b.gitsigns_status_dict
			if not status or not status.head then
				return ""
			end
			local changes = {}
			if status.added and status.added > 0 then
				table.insert(changes, "+" .. status.added)
			end
			if status.changed and status.changed > 0 then
				table.insert(changes, "~" .. status.changed)
			end
			if status.removed and status.removed > 0 then
				table.insert(changes, "-" .. status.removed)
			end
			return "  " .. status.head .. (#changes > 0 and " " .. table.concat(changes, " ") or "") .. " "
		end,
		hl = function()
			return { bg = colors.get().label, fg = "#a8e8ef" }
		end,
	}

	local diagnostics = {
		condition = conditions.has_diagnostics,
		provider = function()
			local counts = vim.diagnostic.count(0)
			local parts = {}
			if (counts[vim.diagnostic.severity.ERROR] or 0) > 0 then
				table.insert(parts, "󰅚 " .. counts[vim.diagnostic.severity.ERROR])
			end
			if (counts[vim.diagnostic.severity.WARN] or 0) > 0 then
				table.insert(parts, "󰀪 " .. counts[vim.diagnostic.severity.WARN])
			end
			if (counts[vim.diagnostic.severity.INFO] or 0) > 0 then
				table.insert(parts, "󰋽 " .. counts[vim.diagnostic.severity.INFO])
			end
			return #parts > 0 and " " .. table.concat(parts, " ") or ""
		end,
		hl = function()
			return { bg = colors.get().bar, fg = "#fce566" }
		end,
	}

	local position = {
		provider = " %3l:%-2c %P ",
		hl = function()
			return { bg = colors.get().bar, fg = colors.get().fg }
		end,
	}

	require("heirline").setup({
		statusline = {
			mode,
			mode_separator,
			filename,
			filename_separator,
			filetype,
			divider,
			diagnostics,
			{ provider = "%=" },
			label_separator_pre,
			git,
			label_separator_post,
			position
		},
	})
end

return M
