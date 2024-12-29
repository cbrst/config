local fmt = string.format
local icons = require("utils.icons")

-- components
local c = {
	vimode = {
		provider = function()
			return fmt("%s ", icons.vimode[vim.fn.mode()])
		end,
		hl = { fg = "fg1", bg = "bg1" },
		left_sep = { str = "left_rounded", hl = { fg = "bg1", bg = "bg0" } },
		right_sep = { str = "left_rounded", hl = { fg = "bg2", bg = "bg1" } },
	},

	-- File
	--
	fileinfo = {
		provider = { name = "file_info", opts = { type = "relative" } },
		hl = { fg = "fg2", bg = "bg2", style = "bold" },
		right_sep = {
			str = "right_rounded",
			hl = function()
				if require("feline.providers.git").git_info_exists() then
					return { fg = "bg2", bg = "bg1" }
				else
					return { fg = "bg2", bg = "bg0" }
				end
			end,
		},
	},

	-- Git
	--
	gitbranch = {
		provider = "git_branch",
		icon = "  ",
		hl = { fg = "fg1", bg = "bg1" },
		right_sep = function()
			local g = vim.b.gitsigns_status_dict
			if g and (g["added"] or 0) + (g["changed"] or 0) + (g["removed"] or 0) > 0 then
				return {
					str = "right_rounded_thin",
					hl = { fg = "fg1", bg = "bg1" },
				}
			else
				return {
					str = "right_rounded",
					hl = { fg = "bg1", bg = "bg0" },
				}
			end
		end,
	},
	git_added = {
		provider = "git_diff_added",
		hl = { fg = "fg1", bg = "bg1" },
	},
	git_changed = {
		provider = "git_diff_changed",
		hl = { fg = "fg1", bg = "bg1" },
	},
	git_removed = {
		provider = "git_diff_removed",
		hl = { fg = "fg1", bg = "bg1" },
	},
	git_end = {
		provider = function()
			local g = vim.b.gitsigns_status_dict
			if g and (g["added"] or 0) + (g["changed"] or 0) + (g["removed"] or 0) > 0 then
				return ""
			else
				return ""
			end
		end,
		hl = { fg = "bg1", bg = "bg0" },
	},

	-- Default
	--
	default = {
		provider = "",
		hl = { fg = "fg0", bg = "bg0" },
	},

	-- Outline
	--
	outline = {
		provider = function()
			return require("outline").get_symbol({
				depth = 1,
			}) or ""
		end,
		icon = icons.general.outline .. " ",
		hl = { fg = "fg0", bg = "bg0" },
		right_sep = { str = " ", hl = { fg = "fg0", bg = "bg0" } },
	},

	-- LSP
	--
	lsp_status = {
		provider = "lsp_client_names",
		hl = { fg = "fg2", bg = "bg2", style = "bold" },
		left_sep = {
			str = "left_rounded",
			hl = function()
				if require("feline.providers.lsp").diagnostics_exist() then
					return { fg = "bg2", bg = "bg1" }
				else
					return { fg = "bg2", bg = "bg0" }
				end
			end,
		},
		right_sep = { str = "right_rounded", hl = { fg = "bg2", bg = "bg0" } },
	},
	lsp_error = {
		provider = "diagnostic_errors",
		hl = { fg = "fg1", bg = "bg1" },
		right_sep = { str = " ", hl = { fg = "fg1", bg = "bg1" } },
	},
	lsp_warning = {
		provider = "diagnostic_warnings",
		hl = { fg = "fg1", bg = "bg1" },
		left_sep = {
			str = function()
				if require("feline.providers.lsp").diagnostics_exist("ERROR") then
					return "left_rounded_thin"
				else
					return ""
				end
			end,
			hl = { fg = "fg1", bg = "bg1" },
		},
		right_sep = { str = " ", hl = { fg = "fg1", bg = "bg1" } },
	},
	lsp_hint = {
		provider = "diagnostic_hints",
		hl = { fg = "fg1", bg = "bg1" },
		left_sep = {
			str = function()
				if require("feline.providers.lsp").diagnostics_exist({ "ERROR", "WARN" }) then
					return "left_rounded_thin"
				else
					return ""
				end
			end,
			hl = { fg = "fg1", bg = "bg1" },
		},
		right_sep = { str = " ", hl = { fg = "fg1", bg = "bg1" } },
	},
	lsp_start = {
		provider = "",
		enabled = function()
			return require("feline.providers.lsp").diagnostics_exist()
		end,
		hl = { fg = "bg1", bg = "bg0" },
	},
	search = {
		provider = function()
			if vim.v.hlsearch == 0 then
				return ""
			end

			local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 250 })
			if not ok or next(result) == nil or result.incomplete == 1 then
				return ""
			end

			local denominator = math.min(result.total, result.maxcount)
			return fmt(" %s/%s ", result.current, denominator)
		end,
		icon = icons.general.search .. " ",
		hl = { fg = "fg0", bg = "bg0" },
	},
	macro = {
		provider = function()
			return vim.fn.reg_recording()
		end,
		icon = icons.general.macro .. " ",
		hl = { fg = "fg0", bg = "bg0" },
	},
}

local active = {
	{
		c.vimode,
		c.fileinfo,
		c.gitbranch,
		c.git_added,
		c.git_changed,
		c.git_removed,
		c.git_end,
		c.default,
	},
	{
		c.search,
		c.macro,
	},
	{
		c.outline,
		c.lsp_start,
		c.lsp_error,
		c.lsp_warning,
		c.lsp_hint,
		c.lsp_status,
	},
}
local inactive = {}

-- winbar
local function get_winbar_filename()
	local filename = vim.api.nvim_buf_get_name(0)

	-- no name
	if filename == "" then
		filename = "[No Name]"

	-- neo-tree filesystem
	elseif filename:find("tree filesystem") then
		filename = fmt("%s %s", icons.general.folder, vim.fn.fnamemodify(filename, ":~:h"))

	-- outline
	elseif filename:find("OUTLINE") then
		filename = fmt("%s Outline", icons.general.outline)

	-- normal files
	else
		filename = vim.fn.fnamemodify(filename, ":~:.")
	end

	return fmt(" %s", filename)
end

local w = {
	fileinfo = {
		provider = function()
			return get_winbar_filename()
		end,
		hl = { fg = "fg0", bg = "bg0" },
	},
}
local winbar_active = {
	{ w.fileinfo },
	{},
}
local winbar_inactive = winbar_active

return {
	"freddiehaddad/feline.nvim",
	opts = {},
	config = function(_, opts)
		require("feline").setup({
			components = {
				active = active,
				inactive = inactive,
			},
		})
		require("feline").winbar.setup({
			components = {
				active = winbar_active,
				inactive = winbar_inactive,
			},
		})
	end,
}
