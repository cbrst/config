return {
	{ "danilamihailov/beacon.nvim" },
	{ "MeanderingProgrammer/render-markdown.nvim" },
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
