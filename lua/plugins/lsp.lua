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
				"basedpyright",
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
			"antosha417/nvim-lsp-file-operations",
		},
		config = function()
			local capabilities = vim.tbl_deep_extend(
				"force",
				require("cmp_nvim_lsp").default_capabilities(),
				require("lsp-file-operations").default_capabilities()
			)

			vim.lsp.config("basedpyright", {
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
					},

					basedpyright = {
						analysis = {
							typeCheckingMode = "standard",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							autoImportCompletions = true,
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
							globals = { "vim", "Snacks" },
						},
					},
				},
			})

			vim.lsp.config("sqls", { capabilities = capabilities })

			vim.lsp.enable({
				"basedpyright",
				"ts_ls",
				"html",
				"cssls",
				"lua_ls",
				"sqls",
			})

			-- Makes <leader>ru able to revert a whole multi-file LSP edit.
			require("util.lsp_undo").setup()
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
	},
}
