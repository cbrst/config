return {
	{
		"bezhermoso/tree-sitter-ghostty",
		build = "make nvim_install",
	},

	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		-- main = "nvim-treesitter.configs", -- Sets main module to use for opts
		config = function()
			require("nvim-treesitter.configs").setup({
				modules = {},
				ensure_installed = {
					"bash",
					"c",
					"diff",
					"html",
					"lua",
					"luadoc",
					"markdown",
					"markdown_inline",
					"query",
					"vim",
					"vimdoc",
				},
				sync_install = true,
				auto_install = true,
				ignore_install = {},

				highlight = {
					enable = true,
					-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
					--  If you are experiencing weird indenting issues, add the language to
					--  the list of additional_vim_regex_highlighting and disabled languages for indent.
					additional_vim_regex_highlighting = { "ruby" },
				},
				indent = { enable = true, disable = { "ruby" } },
			})

			-- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			-- parser_config.ghostty = {
			-- 	install_info = {
			-- 		url = "https://github.com/bezhermoso/tree-sitter-ghostty",
			-- 		files = { "src/parser.c" },
			-- 		branch = "main",
			-- 		requires_generate_from_grammar = true,
			-- 	},
			-- }
		end,
	},
}
