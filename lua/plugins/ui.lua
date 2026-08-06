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
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",

					diagnostics = "nvim_lsp",

					always_show_bufferline = true,
					show_buffer_close_icons = false,
					show_close_icon = false,

					separator_style = "slant",

					-- Ordinals are jumpable via <leader>b1..b9, see config/keymaps.lua
					numbers = "ordinal",

					offsets = {
						{
							filetype = "neo-tree",
							text = "Explorer",
							text_align = "center",
							separator = true,
						},
					},
				},
			})
		end,
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- Prefix groups. The mappings themselves all live in config/keymaps.lua.
			spec = {
				{ "<leader>a", group = "AI / Claude" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code" },
				{ "<leader>f", group = "Find / Files" },
				{ "<leader>g", group = "Git" },
				{ "<leader>h", group = "Harpoon" },
				{ "<leader>m", group = "Multicursor" },
				{ "<leader>o", group = "Overseer / Tasks" },
				{ "<leader>r", group = "Refactor" },
				{ "<leader>s", group = "Search & Replace" },
				{ "<leader>t", group = "Terminal" },
				{ "<leader>u", group = "UI toggles" },
				{ "<leader>v", group = "Venv" },
				{ "<leader>x", group = "Diagnostics" },
			},
		},
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
		cmd = { "ColorizerToggle", "ColorizerAttachToBuffer" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("colorizer").setup({
				user_default_options = {
					mode = "background",
				},
			})
		end,
	},

	{
		-- Config only, no `vim.notify` assignment: noice.nvim owns vim.notify and
		-- uses this as its rendering backend. Setting it here too raced noice's
		-- own assignment and triggered its "vim.notify has been overwritten"
		-- warning whenever something notified after both had loaded.
		"rcarriga/nvim-notify",
		opts = {
			stages = "fade",
			timeout = 3000,
			render = "default",
			top_down = true,
			background_colour = "#000000",
		},
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
		-- The search handler patches hlslens' config rather than setting it up,
		-- so hlslens has to be configured first. As a dependency it always is.
		dependencies = { "kevinhwang91/nvim-hlslens" },
		config = function()
			require("scrollbar").setup({
				handle = {
					text = " ",
				},
			})

			require("scrollbar.handlers.gitsigns").setup()
			require("scrollbar.handlers.diagnostic").setup()
			require("scrollbar.handlers.search").setup()
		end,
	},

	{
		-- Draws the "[3/12]" counter next to the current match. The n/N/*/#
		-- mappings that drive it live in config/keymaps.lua.
		"kevinhwang91/nvim-hlslens",
		config = function()
			require("hlslens").setup()
		end,
	},
}
