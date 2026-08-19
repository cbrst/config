-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		-- Blink provides completion-aware auto-brackets, so no nvim-cmp event hook is needed.
		require("nvim-autopairs").setup({})
	end,
}
