return {
	{ "danilamihailov/beacon.nvim" },
	{ "MeanderingProgrammer/render-markdown.nvim" },
	{
		"sschleemilch/slimline.nvim",
		init = function()
			vim.api.nvim_set_hl(0, "Slimline", { bg = "#1e1e2e" })
		end,
		opts = {
			bold = true,
			configs = {
				filetype_lsp = {
					lsp_sep = vim.g.have_nerd_font and " " or ",",
					map_lsps = vim.g.have_nerd_font and {
						["lua_ls"] = " ",
						["typescript-tools"] = "󰛦 ",
						["tailwindcss"] = "󱏿 ",
					} or {
						["lua_ls"] = "lua",
						["typescript-tools"] = "TS",
						["tailwindcss"] = "TW",
					},
				},
			},
		},
	},
	{
		"bekaboo/dropbar.nvim",
		opts = {
			icons = {
				enable = vim.g.have_nerd_font,
				ui = {
					bar = {
						separator = "  ",
					},
				},
			},
		},
	},
}
