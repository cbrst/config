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
		vim.g.gruvbox_enable_bold = 1
		vim.g.gruvbox_enable_italic = 1
	end,
	config = function()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("custom_highlights_gruvbox", {}),
			pattern = "gruvbox-material",
			callback = function()
				-- less pissy background for light variant
				if vim.opt.background:get() == "light" then
					vim.g.gruvbox_material_colors_override = {
						bg0 = { "#fbf4ec", "NONE" },
						bg1 = { "#f9f1e8", "NONE" },
						bg2 = { "#f8efe7", "NONE" },
						bg3 = { "#f6eee5", "NONE" },
						bg4 = { "#f5ece4", "NONE" },
						bg5 = { "#f2e9e1", "NONE" },
						bg_dim = { "#9893a5", "NONE" },
					}
				end
			end,
		})

		-- feline colors

		Myvi.feline_themes["gruvbox-material"] = {
			light = {
				bg0 = "#fbf4ec",
				bg1 = "#a89984",
				bg2 = "#3c3836",
				fg0 = "#3c3836",
				fg1 = "#3c3836",
				fg2 = "#1d2021",
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
