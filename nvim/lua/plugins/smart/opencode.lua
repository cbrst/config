local opencode_cmd = "opencode --port"

-- Keep the OpenCode TUI beside the editor while opencode.nvim supplies editor context.
local terminal_opts = {
	win = {
		position = "right",
		enter = false,
	},
}

return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	dependencies = { "folke/snacks.nvim" },
	config = function()
		vim.g.opencode_opts = {
			server = {
				start = function()
					require("snacks").terminal.open(opencode_cmd, terminal_opts)
				end,
			},
		}

		-- Reveal OpenCode whenever a prompt is submitted from the editor.
		vim.api.nvim_create_autocmd("User", {
			pattern = "OpencodeEvent:tui.command.execute",
			callback = function(args)
				if args.data.event.properties.command == "prompt.submit" then
					local terminal = require("snacks").terminal.get(opencode_cmd, { create = false })
					if terminal then
						terminal:show()
					end
				end
			end,
		})
	end,
	keys = {
		{
			"<leader>aa",
			function()
				require("opencode").ask("@this: ")
			end,
			mode = { "n", "x" },
			desc = "[A]sk OpenCode",
		},
		{
			"<leader>as",
			function()
				require("opencode").select()
			end,
			mode = { "n", "x" },
			desc = "[S]elect OpenCode action",
		},
		{
			"<leader>at",
			function()
				require("snacks").terminal.toggle(opencode_cmd, terminal_opts)
			end,
			desc = "[T]oggle OpenCode terminal",
		},
		{
			"<leader>an",
			function()
				require("opencode").command("session.new")
			end,
			desc = "[N]ew OpenCode session",
		},
		{
			"<leader>ai",
			function()
				require("opencode").command("session.interrupt")
			end,
			desc = "[I]nterrupt OpenCode",
		},
		{
			"<leader>au",
			function()
				require("opencode").command("session.undo")
			end,
			desc = "[U]ndo OpenCode change",
		},
		{
			"<leader>ar",
			function()
				require("opencode").command("session.redo")
			end,
			desc = "[R]edo OpenCode change",
		},
		{
			"<C-.>",
			function()
				require("snacks").terminal.toggle(opencode_cmd, terminal_opts)
			end,
			mode = { "n", "t" },
			desc = "Toggle OpenCode terminal",
		},
	},
}
