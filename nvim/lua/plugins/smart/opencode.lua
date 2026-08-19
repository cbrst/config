local opencode_cmd = "opencode --port"

-- Keep the OpenCode TUI beside the editor while opencode.nvim supplies editor context.
local terminal_opts = {
	-- A fixed terminal identity prevents a mapping count from creating another server.
	count = 1,
	win = {
		position = "right",
		enter = false,
		on_buf = function(terminal)
			-- Terminal mode sends Ctrl-W to the TUI; return to Neovim before window commands.
			vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", {
				buffer = terminal.buf,
				desc = "OpenCode window command",
			})
		end,
	},
}

local function get_terminal()
	return require("snacks").terminal.get(opencode_cmd, terminal_opts)
end

local function toggle_terminal()
	local terminal, created = get_terminal()
	if not created then
		terminal:toggle()
	end
end

return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	dependencies = { "folke/snacks.nvim" },
	config = function()
		vim.g.opencode_opts = {
			server = {
				start = function()
					-- Reuse the visible terminal instead of opening a second OpenCode server.
					get_terminal()
				end,
			},
		}

		-- Reload OpenCode edits when Neovim regains focus, while preserving unsaved buffers.
		vim.o.autoread = true
		vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
			group = vim.api.nvim_create_augroup("OpencodeChecktime", { clear = true }),
			callback = function()
				vim.cmd("checktime")
			end,
			desc = "Refresh unmodified buffers changed outside Neovim",
		})

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
			"<leader>ab",
			function()
				require("opencode").ask("@buffer: ")
			end,
			desc = "Ask OpenCode about [B]uffer",
		},
		{
			"<leader>ad",
			function()
				require("opencode").ask("@diagnostics: ")
			end,
			desc = "Ask OpenCode about [D]iagnostics",
		},
		{
			"<leader>av",
			function()
				require("opencode").ask("@visible: ")
			end,
			desc = "Ask OpenCode about [V]isible code",
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
				toggle_terminal()
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
				toggle_terminal()
			end,
			mode = { "n", "t" },
			desc = "Toggle OpenCode terminal",
		},
	},
}
