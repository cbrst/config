return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	lazy = false,
	config = function()
		require("catppuccin").setup({
			integrations = {
				beacon = true,
				dropbar = true,
				fidget = true,
				mason = true,
				which_key = true,
			},
		})

		local create_feline_colors = function(colors)
			return {
				bg0 = colors.base,
				-- bg0 = colors.crust,
				bg1 = colors.surface2,
				bg2 = colors.subtext1,
				fg0 = colors.subtext0,
				fg1 = colors.base,
				fg2 = colors.base,
			}
		end

		Myvi.feline_themes.catppuccin = {
			light = create_feline_colors(require("catppuccin.palettes").get_palette("latte")),
			dark = create_feline_colors(require("catppuccin.palettes").get_palette("mocha")),
		}
	end,
}
