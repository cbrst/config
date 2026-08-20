return {
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")
			local parsers = {
				"bash",
				"c",
				"diff",
				"html",
				"kdl",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"toml",
				"vim",
				"vimdoc",
			}

			-- This API supersedes the removed nvim-treesitter.configs module.
			treesitter.setup()
			treesitter.install(parsers)

			local function enable_features(event)
				local filetype = vim.bo[event.buf].filetype

				-- Lua keeps the indent-based folding configured by its filetype autocmd.
				if filetype == "lua" then
					return
				end

				-- Filetypes without an installed parser continue using Neovim defaults.
				local has_parser = pcall(vim.treesitter.start, event.buf, filetype)
				if not has_parser then
					return
				end

				-- Reset folds after attaching the parser so foldexpr can query it immediately.
				vim.wo.foldmethod = "expr"
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				-- Clear foldexpr's pre-attachment cache before users issue fold commands.
				vim.cmd("silent! normal! zx")

				if filetype ~= "ruby" then
					vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end

			vim.api.nvim_create_autocmd({ "FileType", "VimEnter" }, {
				group = vim.api.nvim_create_augroup("treesitter-features", { clear = true }),
				callback = enable_features,
			})
		end,
	},
}
