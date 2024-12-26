return {
	"rose-pine/neovim",
	priority = 1000,
	init = function()
		vim.cmd.colorscheme("rose-pine")
	end,
	config = function()
		require("rose-pine").setup({
			variant = "auto",
			dark_variant = "main",
			dim_inactive_windows = false,
			extend_background_behind_borders = true,

			enable = {
				terminal = true,
			},

			styles = {
				bold = true,
				italic = true,
				transparency = false,
			},

			highlight_groups = {
				FlnBlue = { fg = "pine" },
				FlnCyan = { fg = "foam" },
				FlnMagenta = { fg = "iris" },
				FlnRed = { fg = "love" },
				FlnYellow = { fg = "gold" },
				FlnBlueAlt = { fg = "pine", bg = "highlight_med" },
				FlnCyanAlt = { fg = "foam", bg = "highlight_med" },
				FlnMagentaAlt = { fg = "iris", bg = "highlight_med" },
				FlnRedAlt = { fg = "love", bg = "highlight_med" },
				FlnYellowAlt = { fg = "gold", bg = "highlight_med" },

				FlnStatus = { bg = "base", fg = "muted" },
				FlnStatusAlt = { bg = "muted", fg = "surface" },
				FlnStatusBg = { bg = "text", fg = "surface" },

				FlnViBlue = { bg = "pine", fg = "highlight_med" },
				FlnViCyan = { bg = "foam", fg = "highlight_med" },
				FlnViMagenta = { bg = "iris", fg = "highlight_med" },
				FlnViRed = { bg = "love", fg = "highlight_med" },
				FlnViYellow = { bg = "gold", fg = "highlight_med" },

				FlnViBlueSep = { bg = "pine", fg = "text" },
				FlnViCyanSep = { bg = "foam", fg = "text" },
				FlnViMagentaSep = { bg = "iris", fg = "text" },
				FlnViRedSep = { bg = "love", fg = "text" },
				FlnViYellowSep = { bg = "gold", fg = "text" },

				FlnAlt = { bg = "base", fg = "text" },
				FlnSep = { bg = "base", fg = "text" },
				FlnSepBgAlt = { bg = "muted", fg = "text" },
				FlnSepAltDefault = { bg = "base", fg = "muted" },
				-- FlnAltSep = { bg = "overlay", fg = "base" },

				-- LineNr = { bg = "overlay", fg = "muted" },
				-- FoldColumn = { link = "LineNr" },
				-- SignColumn = { link = "LineNr" },

				NeoTreeNormal = { bg = "surface" },
				NeoTreeNormalNC = { bg = "surface" },
				NeoTreeVertSplit = { bg = "surface" },

				TelescopeBorder = { fg = "overlay", bg = "overlay" },
				TelescopeNormal = { fg = "subtle", bg = "overlay" },
				TelescopeSelection = { fg = "text", bg = "highlight_med" },
				TelescopeSelectionCaret = { fg = "love", bg = "highlight_med" },
				TelescopeTitle = { fg = "base", bg = "love" },
				TelescopePromptTitle = { fg = "base", bg = "pine" },
				TelescopePreviewTitle = { fg = "base", bg = "iris" },
				TelescopePromptNormal = { fg = "text", bg = "surface" },
				TelescopePromptBorder = { fg = "surface", bg = "surface" },
			},
		})
	end,
}
