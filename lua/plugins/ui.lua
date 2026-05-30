return {
	{
		"folke/tokyonight.nvim",
		config = function()
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup()
		end,
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup({})
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = {
				char = "│",
			},
			scope = {
				enabled = true,
				show_start = false,
				show_end = false,
			},
		},
	},

	{
		"catgoose/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				user_default_options = {
					mode = "background",
				},
			})

			vim.keymap.set("n", "<leader>uc", "<cmd>ColorizerToggle<CR>")
		end,
	},

	{
		"folke/snacks.nvim",
		opts = {
			image = {
				enabled = true,
			},
		},
	},
}
