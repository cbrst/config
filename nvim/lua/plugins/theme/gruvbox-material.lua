return {
	"f4z3r/gruvbox-material.nvim",
	priority = 1000,
	lazy = true,
	config = function()
		local colors = require("gruvbox-material.colors").get(vim.o.background, "hard")

		require("gruvbox-material").setup({
			contrast = "hard",
			customize = function(_, o)
				if vim.o.background == "dark" then
					return o
				end

				if o.bg == colors.bg0 then
					o.bg = "#faf4ed"
				elseif o.bg == colors.bg1 then
					o.bg = "#f4eee9"
				elseif o.bg == colors.bg2 then
					o.bg = "#efe9e4"
				elseif o.bg == colors.bg3 then
					o.bg = "#e9e4e0"
				elseif o.bg == colors.bg4 then
					o.bg = "#e4dfdc"
				elseif o.bg == colors.bg5 then
					o.bg = "#dedbd7"
				end

				return o
			end,
		})

		-- feline colors

		Myvi.feline_themes["gruvbox-material"] = {
			light = {
				bg0 = "#fbf4ed",
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
