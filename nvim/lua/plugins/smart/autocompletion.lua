return { -- Autocompletion
	"saghen/blink.cmp",
	event = "InsertEnter",
	version = "1.*",
	dependencies = {
		-- LuaSnip remains the snippet engine used by the existing configuration.
		{
			"L3MON4D3/LuaSnip",
			build = (function()
				-- Regex support is unavailable without make and on Windows.
				if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
					return
				end
				return "make install_jsregexp"
			end)(),
		},
	},
	opts = {
		keymap = {
			preset = "default",
			["<C-l>"] = { "snippet_forward", "fallback" },
			["<C-h>"] = { "snippet_backward", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			documentation = { auto_show = false },
			-- Replace the former nvim-cmp/autopairs function-call integration.
			accept = { auto_brackets = { enabled = true } },
		},
		snippets = { preset = "luasnip" },
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				opencode_ask = { "lsp", "buffer" },
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	config = function(_, opts)
		-- Configure LuaSnip before Blink requests snippets from it.
		require("luasnip").config.setup({})
		require("blink.cmp").setup(opts)
	end,
}
