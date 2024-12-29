--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Overwrite highlight FlnStatusBg on BufEnter
-- Somehow the gui=bold gets removed sometimes
-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	desc = "Make sure FlnStatusBg is bold",
-- 	group = vim.api.nvim_create_augroup("kickstart-highlight-flnstatusbg", { clear = true }),
-- 	callback = function()
-- 		vim.cmd("hi FlnStatusBg cterm=bold gui=bold")
-- 	end,
-- })
