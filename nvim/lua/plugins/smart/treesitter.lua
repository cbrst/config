return {
	{
		"bezhermoso/tree-sitter-ghostty",
		build = function(plugin)
			-- treesitter queries dir
			local runtime_queries_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/queries"
			local target_dir = runtime_queries_path .. "/ghostty"
			vim.fn.mkdir(target_dir, "p")

			-- copy the highlights.scm from the repo to treesitter
			local src_file = io.open(plugin.dir .. "/queries/highlights.scm", "r")
			if src_file then
				-- read the file from the cloned repository
				local content = src_file:read("*all")
				src_file:close()

				local target_file = io.open(target_dir .. "/highlights.scm", "w")
				if target_file then
					target_file:write(content)
					target_file:close()
				end
			end
		end,
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

			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.ghostty = {
				install_info = {
					url = "https://github.com/bezhermoso/tree-sitter-ghostty",
					files = { "src/parser.c" },
					branch = "main",
					requires_generate_from_grammar = true,
				},
			}
		end,
	},
}
