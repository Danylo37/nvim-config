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

			vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>")
			vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>")
			vim.keymap.set("n", "K", vim.lsp.buf.hover)

			vim.keymap.set("n", "de", "<cmd>Lspsaga show_line_diagnostics<CR>")
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
			vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "Rename symbol" })
			vim.keymap.set("n", "<leader>rN", "<cmd>Lspsaga rename ++project<CR>", { desc = "Rename symbol (project)" })

			-- Track LSP edits per buffer so they can be undone across every touched file at once
			local edits = {}
			local apply_text_edits = vim.lsp.util.apply_text_edits

			vim.lsp.util.apply_text_edits = function(text_edits, bufnr, position_encoding, change_annotations)
				if next(text_edits or {}) and bufnr and bufnr ~= 0 then
					vim.fn.bufload(bufnr)
					edits[#edits + 1] = {
						buf = bufnr,
						seq = vim.api.nvim_buf_call(bufnr, function()
							return vim.fn.undotree().seq_cur
						end),
						saved = not vim.bo[bufnr].modified,
						time = vim.uv.hrtime(),
					}
				end

				return apply_text_edits(text_edits, bufnr, position_encoding, change_annotations)
			end

			vim.keymap.set("n", "<leader>ru", function()
				if #edits == 0 then
					vim.notify("No LSP edits to undo", vim.log.levels.WARN)
					return
				end

				local last = edits[#edits].time
				local targets = {}

				while #edits > 0 and last - edits[#edits].time < 2e9 do
					local edit = table.remove(edits)
					local seen = targets[edit.buf]

					if not seen or edit.seq < seen.seq then
						targets[edit.buf] = edit
					end
				end

				local reverted = {}

				for buf, edit in pairs(targets) do
					if vim.api.nvim_buf_is_valid(buf) then
						vim.api.nvim_buf_call(buf, function()
							vim.cmd("silent undo " .. edit.seq)

							if edit.saved and vim.bo[buf].modified then
								vim.cmd("silent noautocmd write")
							end
						end)

						reverted[#reverted + 1] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
					end
				end

				vim.notify("Reverted " .. #reverted .. " file(s):\n" .. table.concat(reverted, "\n"))
			end, { desc = "Undo last LSP edit in all files" })
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
