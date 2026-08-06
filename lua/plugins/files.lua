return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			close_if_last_window = false,
			enable_git_status = true,
			enable_diagnostics = true,

			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},

				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},

			window = {
				position = "left",
				width = 30,
			},
		},
	},

	{
		"antosha417/nvim-lsp-file-operations",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-neo-tree/neo-tree.nvim" },
		config = function()
			require("lsp-file-operations").setup()
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			-- Gives `vim.ui.select` a real UI (overseer's task pickers, LSP code
			-- actions, ...). Without it Nvim falls back to `inputlist()`, which
			-- prints the choices to the message area and reads keys from the
			-- cmdline; noice mirrors that message into a Confirm popup, so the
			-- list shows up twice and every keypress goes to the prompt hidden
			-- behind the popup.
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					mappings = {
						i = { ["<C-d>"] = actions.delete_buffer },
						n = { ["<C-d>"] = actions.delete_buffer },
					},
				},

				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			telescope.load_extension("ui-select")
		end,
	},
}
