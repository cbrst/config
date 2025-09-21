Myvi = require("myvi")

-- Set <space> as the leader key See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Basic options ]]
require("options")

-- [[ Neovide specific configuration ]]
if vim.g.neovide then
	require("neovide")
end

-- [[ Basic Keymaps ]]
require("keymap")

-- [[ Basic Autocommands ]]
require("autocmds")

-- [[ Language Configs ]]
require("languages")

-- [[ Bootstrap lazyvim ]]
require("lazyvim")

-- Set the colorscheme after everything is loaded,
-- just to make sure all plugins show the right colors
Myvi.set_colorscheme()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
