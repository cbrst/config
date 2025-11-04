local icons = require("utils.icons")

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.conceallevel = 2

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Folding
--  Enable folding and use treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
--  Show a maximum of 4 folds in the foldcolumn
vim.opt.foldcolumn = "auto:4"
--  Disable foldtext and show the first line with highlighting
vim.opt.foldtext = ""
--  Do not close folds when opening a file
vim.opt.foldlevel = 99
--  Limit folding depth
vim.opt.foldnestmax = 1
--  Set characters for folcolumn
vim.opt.fillchars = "foldopen:" .. icons.folds.foldopen .. ",foldclose:" .. icons.folds.foldclose

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.shiftwidth = 2
vim.opt.expandtab = false

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Have a global statusline
vim.opt.laststatus = 3

-- Hide cmdline
vim.opt.cmdheight = 1

-- Neovide
if vim.g.neovide then
	local alpha = function()
		return string.format("%x", math.floor(255 * vim.g.neovide_opacity_point or 1.0))
	end

	vim.opt.guifont = "LigSFMono Nerd Font"
	vim.g.neovide_opacity = 1.0
	vim.g.neovide_opacity_point = 1.0
	vim.g.neovide_normal_opacity = 1.0
	vim.g.neovide_background_color = "#181616" .. alpha()
	vim.g.transparency = 0.0
	vim.g.neovide_hide_mouse_when_typing = true
end
