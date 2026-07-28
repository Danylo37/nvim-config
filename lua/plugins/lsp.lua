return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"pyright",
				"ts_ls",
				"lua_ls",
				"html",
				"cssls",
				"sqls",
			},
		},
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"prettier",
					"stylua",
					"black",
					"ruff",
				},
				run_on_start = true,
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.lsp.config("pyright", {
				capabilities = capabilities,

				root_dir = function(bufnr, on_dir)
					local root = vim.fs.root(bufnr, {
						"pyproject.toml",
						"setup.py",
						"requirements.txt",
						".git",
					})

					on_dir(root)
				end,

				settings = {
					python = {
						venvPath = ".",
						venv = ".venv",

						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
			})

			vim.lsp.config("html", { capabilities = capabilities })
			vim.lsp.config("cssls", { capabilities = capabilities })

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			vim.lsp.config("sqls", { capabilities = capabilities })

			vim.lsp.enable({
				"pyright",
				"ts_ls",
				"html",
				"cssls",
				"lua_ls",
        "sqls",
			})

			vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>")
			vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>")
			vim.keymap.set("n", "K", vim.lsp.buf.hover)

			vim.keymap.set("n", "de", "<cmd>Lspsaga show_line_diagnostics<CR>")
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
		end,
	},

	{
		"nvimdev/lspsaga.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		event = "LspAttach",
		config = function()
			require("lspsaga").setup({})
		end,
	},

	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "All diagnostics" },
			{ "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
			{ "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>", desc = "References" },
			{ "<leader>xd", "<cmd>Trouble lsp_definitions toggle<CR>", desc = "Definitions" },
			{ "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Quickfix" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Loclist" },
		},
	},

	{
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("venv-selector").setup({
				auto_refresh = true,
				stay_on_this_version = true,
			})
			vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<CR>", { desc = "Select Python venv" })
		end,
	},
}
