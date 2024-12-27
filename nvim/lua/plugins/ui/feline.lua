local fmt = string.format
local icons = require("utils.icons")

local u = {
	vi = {
		colors = {
			n = "FlnViCyan",
			no = "FlnViCyan",
			i = "FlnViYellow",
			v = "FlnViMagenta",
			V = "FlnViMagenta",
			[""] = "FlnViMagenta",
			R = "FlnViRed",
			Rv = "FlnViRed",
			r = "FlnViBlue",
			rm = "FlnViBlue",
			s = "FlnViMagenta",
			S = "FlnViMagenta",
			[""] = "FelnMagenta",
			c = "FlnViYellow",
			["!"] = "FlnViBlue",
			t = "FlnViBlue",
		},
		sep = {
			n = "FlnCyan",
			no = "FlnCyan",
			i = "FlnYellow",
			v = "FlnMagenta",
			V = "FlnMagenta",
			[""] = "FlnMagenta",
			R = "FlnRed",
			Rv = "FlnRed",
			r = "FlnBlue",
			rm = "FlnBlue",
			s = "FlnMagenta",
			S = "FlnMagenta",
			[""] = "FelnMagenta",
			c = "FlnYellow",
			["!"] = "FlnBlue",
			t = "FlnBlue",
		},
	},
}

local function vi_mode_hl()
	return u.vi.colors[vim.fn.mode()] or "FlnViBlack"
end

local function vi_sep_hl_right()
	return u.vi.colors[vim.fn.mode()] .. "Sep" or "FlnBlack"
end

local function vi_sep_hl()
	return u.vi.sep[vim.fn.mode()] or "FlnBlack"
end

-- components
local c = {
	vimode = {
		provider = function()
			return fmt("%s ", icons.vimode[vim.fn.mode()])
		end,
		hl = vi_mode_hl,
		left_sep = { str = "left_rounded", hl = vi_sep_hl },
		right_sep = { str = "left_rounded", hl = vi_sep_hl_right },
	},
	fileinfo = {
		provider = { name = "file_info", opts = { type = "relative" } },
		hl = "FlnStatusBg",
		right_sep = {
			str = "right_rounded",
			hl = function()
				if require("feline.providers.git").git_info_exists() then
					return "FlnSepBgAlt"
				else
					return "FlnSep"
				end
			end,
		},
	},
	file_type = {
		provider = function()
			return fmt(" %s ", vim.bo.filetype:upper())
		end,
		hl = "FlnAlt",
	},

	-- Git
	--
	gitbranch = {
		provider = "git_branch",
		icon = "  ",
		hl = "FlnStatusAlt",
		right_sep = function()
			local g = vim.b.gitsigns_status_dict
			if g and (g["added"] or 0) + (g["changed"] or 0) + (g["removed"] or 0) > 0 then
				return {
					str = "right_rounded_thin",
					hl = "FlnStatusAlt",
				}
			else
				return {
					str = "right_rounded",
					hl = "FlnSepAltDefault",
				}
			end
		end,
	},
	git_added = {
		provider = "git_diff_added",
		hl = "FlnStatusAlt",
	},
	git_changed = {
		provider = "git_diff_changed",
		hl = "FlnStatusAlt",
	},
	git_removed = {
		provider = "git_diff_removed",
		hl = "FlnStatusAlt",
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
		hl = "FlnSepAltDefault",
	},

	-- Default
	--
	default = {
		provider = "",
		hl = "FlnStatus",
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
		hl = "FlnStatus",
		right_sep = { str = " ", hl = "FlnStatus" },
	},

	-- LSP
	--
	lsp_status = {
		provider = "lsp_client_names",
		hl = "FlnStatusBg",
		left_sep = {
			str = "left_rounded",
			hl = function()
				if require("feline.providers.lsp").diagnostics_exist() then
					return "FlnSepBgAlt"
				else
					return "FlnSep"
				end
			end,
		},
		right_sep = { str = "right_rounded", hl = "FlnSep" },
	},
	lsp_error = {
		provider = "diagnostic_errors",
		hl = "FlnStatusAlt",
		right_sep = { str = " ", hl = "FlnStatusAlt" },
	},
	lsp_warning = {
		provider = "diagnostic_warnings",
		hl = "FlnStatusAlt",
		left_sep = {
			str = function()
				if require("feline.providers.lsp").diagnostics_exist("ERROR") then
					return "left_rounded_thin"
				else
					return ""
				end
			end,
			hl = "FlnStatusAlt",
		},
		right_sep = { str = " ", hl = "FlnStatusAlt" },
	},
	lsp_hint = {
		provider = "diagnostic_hints",
		hl = "FlnStatusAlt",
		left_sep = {
			str = function()
				if require("feline.providers.lsp").diagnostics_exist({ "ERROR", "WARN" }) then
					return "left_rounded_thin"
				else
					return ""
				end
			end,
			hl = "FlnStatusAlt",
		},
		right_sep = { str = " ", hl = "FlnStatusAlt" },
	},
	lsp_start = {
		provider = "",
		enabled = function()
			return require("feline.providers.lsp").diagnostics_exist()
		end,
		hl = "FlnSepAltDefault",
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
		hl = "FlnStatus",
	},
	macro = {
		provider = function()
			return vim.fn.reg_recording()
		end,
		icon = icons.general.macro .. " ",
		hl = "FlnStatus",
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
		hl = "FlnStatus",
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
			-- disable = {
			-- 	filetypes = {
			-- 		"^neo-tree$",
			-- 		"^Outline$",
			-- 		"^qf$",
			-- 	},
			-- 	buftypes = {
			-- 		"^nofile$",
			-- 	},
			-- },
			components = {
				active = winbar_active,
				inactive = winbar_inactive,
			},
		})
	end,
}
