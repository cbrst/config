local M = {}

function M.setup()
	-- LuaSnip is built by Nix, so no runtime make invocation is required.
	require("luasnip").config.setup({})
	require("blink.cmp").setup({
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
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	})
end

return M
