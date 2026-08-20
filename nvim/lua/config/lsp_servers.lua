-- ┌────────────────────────────┐
-- │ Server-specific settings  │
-- └────────────────────────────┘
return {
	phpactor = {},
	emmet_language_server = {
		cmd = { "emmet-language-server", "--stdio" },
		filetypes = {
			"css",
			"eruby",
			"html",
			"javascript",
			"javascriptreact",
			"less",
			"sass",
			"scss",
			"pug",
			"typescriptreact",
		},
		init_options = {
			-- Keep abbreviation suggestions visible in Blink's completion menu.
			showAbbreviationSuggestions = true,
			showExpandedAbbreviation = "always",
		},
	},
	lua_ls = {
		settings = {
			Lua = {
				-- Replace a call expression with the selected Lua snippet.
				completion = { callSnippet = "Replace" },
			},
		},
	},
}
