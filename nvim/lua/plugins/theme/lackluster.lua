return {
	"slugbyte/lackluster.nvim",
	enabled = false,
	lazy = false,
	priority = 1000,
	init = function()
		Myvi.feline_themes.lackluster = {
			light = {
				bg0 = "#101010",
				bg1 = "#2a2a2a",
				bg2 = "#444444",
				fg0 = "#555555",
				fg1 = "#cccccc",
				fg2 = "#cccccc",
			},
			dark = {
				bg0 = "#101010",
				bg1 = "#2a2a2a",
				bg2 = "#444444",
				fg0 = "#555555",
				fg1 = "#cccccc",
				fg2 = "#cccccc",
			},
		}
	end,
}
