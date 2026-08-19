return {
	"folke/snacks.nvim",
	lazy = false,
	opts = {
		-- opencode.nvim uses these interfaces for rich prompt input and action selection.
		input = { enabled = true },
		picker = { enabled = true },
		terminal = { enabled = true },
	},
	keys = {
		{
			"<leader>tt",
			function()
				require("snacks").terminal.toggle()
			end,
			mode = { "n", "t" },
			desc = "[T]oggle shell terminal",
		},
		{
			"<leader>tn",
			function()
				require("snacks").terminal.open()
			end,
			desc = "[N]ew shell terminal",
		},
		{
			"<leader>tf",
			function()
				require("snacks").terminal.focus()
			end,
			mode = { "n", "t" },
			desc = "[F]ocus shell terminal",
		},
	},
}
