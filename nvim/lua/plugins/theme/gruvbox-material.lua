return {
	"sainnhe/gruvbox-material",
	enabled = true,
	priority = 1000,
	init = function() end,
	config = function()
		vim.g.gruvbox_material_transparent_background = 0
		vim.g.gruvbox_material_foreground = "original"
		vim.g.gruvbox_material_background = "hard"
		vim.g.gruvbox_material_ui_contrast = "high"
		vim.g.gruvbox_material_float_style = "bright"
		vim.g.gruvbox_material_statusline_style = "material"
		vim.g.gruvbox_material_cursor = "auto"
		vim.g.gruvbox_enable_bold = 1
		vim.g.gruvbox_enable_italic = 1

		vim.g.gruvbox_material_colors_override = { bg0 = { "#141617", "234" } } -- #0e1010

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("custom_highlights_gruvbox", {}),
			pattern = "gruvbox-material",
			callback = function()
				local config = vim.fn["gruvbox_material#get_configuration"]()
				local palette =
					vim.fn["gruvbox_material#get_palette"](config.background, config.foreground, config.colors_override)
				local set_hl = vim.fn["gruvbox_material#highlight"]

				-- set_hl(hi, fg, bg)
				set_hl("FlnStatusAlt", palette.bg_dim, palette.bg_statusline3)
				set_hl("FlnStatusBg", palette.bg_dim, palette.fg0)
				set_hl("FlnAlt", palette.fg0, palette.bg0)

				set_hl("FlnSep", palette.fg0, palette.bg0)
				set_hl("FlnSepBgAlt", palette.fg0, palette.bg_statusline3)
				set_hl("FlnSepAltDefault", palette.bg_statusline3, palette.bg0)

				set_hl("FlnBlue", palette.bg_diff_blue, palette.bg0)
				set_hl("FlnViBlue", palette.fg1, palette.bg_diff_blue)
				set_hl("FlnViBlueSep", palette.fg0, palette.bg_diff_blue)
				set_hl("FlnCyan", palette.bg_visual_blue, palette.bg0)
				set_hl("FlnViCyan", palette.fg1, palette.bg_visual_blue)
				set_hl("FlnViCyanSep", palette.fg0, palette.bg_visual_blue)
				set_hl("FlnMagenta", palette.bg_diff_red, palette.bg0)
				set_hl("FlnViMagenta", palette.fg1, palette.bg_diff_red)
				set_hl("FlnViMagentaSep", palette.fg0, palette.bg_diff_red)
				set_hl("FlnRed", palette.bg_visual_red, palette.bg0)
				set_hl("FlnViRed", palette.fg1, palette.bg_visual_red)
				set_hl("FlnViRedSep", palette.fg0, palette.bg_visual_red)
				set_hl("FlnYellow", palette.bg_visual_yellow, palette.bg0)
				set_hl("FlnViYellow", palette.fg1, palette.bg_visual_yellow)
				set_hl("FlnViYellowSep", palette.fg0, palette.bg_visual_yellow)
			end,
		})

		vim.cmd.colorscheme("gruvbox-material")

		-- vim.g.gruvbox_material_better_performance = 1

		-- vim.cmd.colorscheme("gruvbox-material")
	end,
}