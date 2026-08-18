return {
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"basedpyright",
				"ruff",
				"ts_ls",
				"lua_ls",
				"html",
				"cssls",
				"sqls",
			},

			-- Off: left on, this starts every server Mason happens to have
			-- installed, configured here or not — which is how an unconfigured
			-- `ruff` and `eslint` ended up attaching to buffers. The
			-- `vim.lsp.enable` call below is the only list that decides.
			automatic_enable = false,
		},
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"prettier",
					"stylua",
					"sql-formatter",

					-- The Python debug adapter behind nvim-dap-python.
					"debugpy",
				},
				run_on_start = true,
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
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
						-- Ruff owns imports, both the sorting and the removing.
						disableOrganizeImports = true,

						analysis = {
							typeCheckingMode = "standard",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							autoImportCompletions = true,

							-- Ruff reports these as F401/F841 already, and two
							-- diagnostics for one unused name is one too many.
							-- Type checking, which is why basedpyright is here,
							-- is untouched.
							diagnosticSeverityOverrides = {
								reportUnusedImport = "none",
								reportUnusedVariable = "none",
								reportUnusedExpression = "none",
							},
						},
					},
				},
			})

			-- Linting, import sorting and the fixes for both. Type checking is
			-- basedpyright's, and the two are configured not to overlap.
			vim.lsp.config("ruff", {
				capabilities = capabilities,

				-- Ruff's hover only explains `noqa` codes, so basedpyright is
				-- left as the single answer to `K`.
				on_attach = function(client)
					client.server_capabilities.hoverProvider = false
				end,

				-- A buffer with no file behind it (`:enew`, a scratch buffer)
				-- makes the server panic on a path it cannot take a parent of,
				-- and it takes the whole client down with it. Not calling
				-- `on_dir` leaves such a buffer without ruff, which is all it
				-- could have offered anyway.
				root_dir = function(bufnr, on_dir)
					local name = vim.api.nvim_buf_get_name(bufnr)

					if name == "" then
						return
					end

					on_dir(vim.fs.root(bufnr, {
						"pyproject.toml",
						"ruff.toml",
						".ruff.toml",
						".git",
					}) or vim.fs.dirname(name))
				end,
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
				"ruff",
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
