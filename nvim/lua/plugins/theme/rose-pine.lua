return {
	"rose-pine/neovim",
	priority = 1000,
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
		})

		Myvi.feline_themes["rose-pine"] = {
			light = {
				bg0 = "#faf4ed",
				bg1 = "#9993a7",
				bg2 = "#575279",
				fg0 = "#9893a5",
				fg1 = "#faf4ed",
				fg2 = "#faf4ed",
			},
			dark = {
				bg0 = "#191724",
				-- bg0 = "#0e0d14",
				bg1 = "#908caa",
				bg2 = "#e0def4",
				fg0 = "#908caa",
				fg1 = "#191724",
				fg2 = "#191724",
			},
		}
	end,
}
