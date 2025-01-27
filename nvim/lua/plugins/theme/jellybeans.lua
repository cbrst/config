return {
	"wtfox/jellybeans.nvim",
	priority = 1000,
	config = function()
		require("jellybeans").setup()

		Myvi.feline_themes.jellybeans = {
			light = (function()
				local colors = require("jellybeans.palettes.jellybeans_light")
				return {
					bg0 = colors.background,
					bg1 = colors.silver,
					bg2 = colors.scorpion,
					fg0 = colors.scorpion,
					fg1 = colors.background,
					fg2 = colors.background,
				}
			end)(),
			dark = (function()
				local colors = require("jellybeans.palettes.jellybeans")
				return {
					bg0 = colors.background,
					bg1 = colors.scorpion,
					bg2 = colors.silver,
					fg0 = colors.silver,
					fg1 = colors.background,
					fg2 = colors.background,
				}
			end)(),
		}
	end,
}
