return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = false,
				enable_git_status = true,
				enable_diagnostics = true,
				filesystem = {
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
			})
			require("neo-tree").setup({
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
			})
			local function project_root()
				local file = vim.api.nvim_buf_get_name(0)
				local config = vim.fn.stdpath("config")

				if vim.startswith(file, config) then
					return config
				end

				return vim.fs.root(file, {
					".git",
					"pyproject.toml",
					"package.json",
					"Cargo.toml",
				}) or vim.fn.getcwd()
			end

			vim.keymap.set("n", "<leader>e", function()
				require("neo-tree.command").execute({
					toggle = true,
					reveal = true,
					dir = project_root(),
				})
			end, { desc = "Toggle file tree" })
			vim.keymap.set("n", "<leader>fe", "<cmd>Neotree focus<CR>", { desc = "Focus file tree" })
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = { ["<C-d>"] = require("telescope.actions").delete_buffer },
						n = { ["<C-d>"] = require("telescope.actions").delete_buffer },
					},
				},
			})

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
		end,
	},
}
