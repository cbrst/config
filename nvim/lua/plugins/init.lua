return {
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	{ -- highlight special comments
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{ -- Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()
		end,
	},
	"tridactyl/vim-tridactyl",

	-- Obisidian
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		lazy = true,
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
			"nvim-telescope/telescope.nvim",
		},
		opts = {
			workspaces = {
				{
					name = "notes",
					path = "~/Nextcloud/Notes/",
				},
			},
			-- mappings = {
			-- 	["<localleader>n"] = {
			-- 		action = function()
			-- 			require("obsidian").util.ObsidianNew()
			-- 		end,
			-- 		opts = { buffer = true },
			-- 	},
			-- },
		},
		keys = {
			-- normal maps
			{ "<localleader>b", "<cmd>ObsidianBacklinks<CR>", ft = "markdown", desc = "Show [B]acklinks" },
			{ "<localleader>l", "<cmd>ObsidianLinks<CR>", ft = "markdown", desc = "Show [L]inks in buffer" },
			{ "<localleader>n", "<cmd>ObsidianNew<CR>", ft = "markdown", desc = "[N]ew Note" },
			{ "<localleader>s", "<cmd>ObsidianSearch<CR>", ft = "markdown", desc = "[S]earch Notes" },
			{ "<localleader>t", "<cmd>ObsidianTags<CR>", ft = "markdown", desc = "Show [T]ags" },
			{ "<localleader>w", "<cmd>ObsidianWorkspace<CR>", ft = "markdown", desc = "Switch [W]orkspace" },

			-- visual maps
			{
				"<localleader>l",
				function()
					require("myvi.util").prompt_command("ObsidianLink", "Link to")
				end,
				mode = "v",
				ft = "markdown",
				desc = "[L]ink Selection to Note",
			},
			{
				"<localleader>L",
				function()
					require("myvi.util").prompt_command("ObsidianLinkNew", "Link to new note")
				end,
				mode = "v",
				ft = "markdown",
				desc = "[L]ink Selection to new Note",
			},
			{
				"<localleader>x",
				function()
					require("myvi.util").prompt_command("ObsidianExtractNote", "New note")
				end,
				mode = "v",
				ft = "markdown",
				desc = "E[x]tract Selection into Note",
			},
		},
	},
	{
		"stevearc/overseer.nvim",
		opts = {},
		keys = {
			{ "<leader>or", "<cmd>OverseerRun<cr>", desc = "[O]verseer: [r]un" },
			{ "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "[O]verseer: [t]oggle" },
		},
	},
}
