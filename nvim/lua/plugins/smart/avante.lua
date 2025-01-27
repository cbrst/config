return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	version = false,
	opts = {
		provider = "claude",
		auto_suggestions_provider = "claude",
	},
	build = "make",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
}
