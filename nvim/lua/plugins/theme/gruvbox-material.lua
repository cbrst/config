return {
	"sainnhe/gruvbox-material",
	priority = 1000,
	lazy = true,
	init = function()
		vim.g.gruvbox_material_transparent_background = 0
		vim.g.gruvbox_material_foreground = "original"
		vim.g.gruvbox_material_background = "hard"
		vim.g.gruvbox_material_ui_contrast = "high"
		vim.g.gruvbox_material_float_style = "bright"
		vim.g.gruvbox_material_statusline_style = "material"
		vim.g.gruvbox_material_cursor = "auto"
		vim.g.gruvbox_material_transparent_background = 1
		vim.g.gruvbox_enable_bold = 1
		vim.g.gruvbox_enable_italic = 1
	end,
	config = function()
		-- feline colors

		Myvi.feline_themes["gruvbox-material"] = {
			light = {
				bg0 = "#fbf4ec",
				bg1 = "#a89984",
				bg2 = "#3c3836",
				fg0 = "#3c3836",
				fg1 = "#fbf4ec",
				fg2 = "#fbf4ec",
			},
			dark = {
				bg0 = "#1d2021",
				bg1 = "#504945",
				bg2 = "#ebdbb2",
				fg0 = "#ebdbb2",
				fg1 = "#ebdbb2",
				fg2 = "#1d2021",
			},
		}
	end,
}
