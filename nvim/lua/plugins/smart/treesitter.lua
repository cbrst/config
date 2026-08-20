return {
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")

			-- This API supersedes the removed nvim-treesitter.configs module.
			treesitter.setup()
			local installing = {}
			local pending_buffers = {}

			local function attach_features(buf, language)
				if not vim.api.nvim_buf_is_valid(buf) then
					return
				end

				local has_parser = pcall(vim.treesitter.start, buf, language)
				if not has_parser then
					return
				end

				-- Reset folds in every visible buffer window after its parser attaches.
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_get_buf(win) == buf then
						vim.wo[win].foldmethod = "expr"
						vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					end
				end
				-- Clear foldexpr's pre-attachment cache before users issue fold commands.
				vim.cmd("silent! normal! zx")

				if vim.bo[buf].filetype ~= "ruby" then
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end

			local function enable_features(event)
				local filetype = vim.bo[event.buf].filetype
				local has_language, language = pcall(vim.treesitter.language.get_lang, filetype)
				if not has_language or not vim.list_contains(treesitter.get_available(), language) then
					return
				end

				if vim.list_contains(treesitter.get_installed(), language) then
					attach_features(event.buf, language)
					return
				end

				-- Queue buffers so a parser download only occurs once per language.
				pending_buffers[language] = pending_buffers[language] or {}
				table.insert(pending_buffers[language], event.buf)
				if installing[language] then
					return
				end

				installing[language] = true
				treesitter.install({ language }):await(function(_, success)
					installing[language] = nil
					if success then
						for _, buf in ipairs(pending_buffers[language]) do
							attach_features(buf, language)
						end
					end
					pending_buffers[language] = nil
				end)
			end

			vim.api.nvim_create_autocmd({ "FileType", "VimEnter" }, {
				group = vim.api.nvim_create_augroup("treesitter-features", { clear = true }),
				callback = enable_features,
			})
		end,
	},
}
