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

	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")

			notify.setup({
				stages = "fade",
				timeout = 3000,
				render = "default",
				top_down = true,
				background_colour = "#000000",
			})

			vim.notify = notify
		end,
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				lsp = {
					progress = {
						enabled = true,
					},
					hover = {
						enabled = true,
					},
					signature = {
						enabled = true,
					},
				},

				presets = {
					bottom_search = false,
					command_palette = true,
					long_message_to_split = true,
					lsp_doc_border = true,
				},
			})
		end,
	},

	{
		"petertriho/nvim-scrollbar",
		event = "VeryLazy",
		config = function()
			require("scrollbar").setup({
				handle = {
					text = " ",
				},
			})

			require("scrollbar.handlers.gitsigns").setup()
			require("scrollbar.handlers.diagnostic").setup()
		end,
	},

	{
		"kevinhwang91/nvim-hlslens",
		event = "VeryLazy",
		config = function()
			require("hlslens").setup()
		end,
	},
}
