return {
	dir = "~/Projects/muted-ocean/muted-ocean.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		local create_feline_colors = function(colors)
			return {
				bg0 = colors.bg0,
				bg1 = colors.bg1,
				bg2 = colors.fg,
				fg0 = colors.fg,
				fg1 = colors.fg,
				fg2 = colors.bg0,
			}
		end

		Myvi.feline_themes["muted-ocean"] = {
			light = create_feline_colors(require("muted-ocean.colors").light),
			dark = create_feline_colors(require("muted-ocean.colors").dark),
		}
	end,
}
