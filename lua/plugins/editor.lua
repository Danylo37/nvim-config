return {
	{
		-- Pinned to `master` on purpose. The `main` branch is a full rewrite that
		-- needs Neovim 0.12+ and an external tree-sitter-cli; `master` only needs
		-- a C compiler and ships pre-generated parsers.
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"python",
				"lua",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"json",
				"yaml",
				"sql",
				"markdown",
				"markdown_inline",
				"bash",
				"vim",
				"vimdoc",
				"query",
			},
			highlight = { enable = true },
			indent = { enable = true },
		},
	},

	{
		"tpope/vim-surround",
	},

	{
		"echasnovski/mini.comment",
		version = false,
		config = function()
			require("mini.comment").setup()
		end,
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				char = {
					enabled = false,
				},
			},
		},
	},

	{
		"jake-stewart/multicursor.nvim",
		branch = "1.0",
		event = "VeryLazy",
		config = function()
			local mc = require("multicursor-nvim")
			mc.setup()

			-- Entry-point mappings live in config/keymaps.lua. This layer can't:
			-- it is a multicursor API that only binds while cursors are alive.
			mc.addKeymapLayer(function(layerSet)
				layerSet({ "n", "x" }, "<C-Left>", mc.prevCursor)
				layerSet({ "n", "x" }, "<C-Right>", mc.nextCursor)
				layerSet({ "n", "x" }, "<C-q>", mc.toggleCursor)

				layerSet("n", "<Esc>", function()
					if not mc.cursorsEnabled() then
						mc.enableCursors()
					else
						mc.clearCursors()
					end
				end)
			end)

			local hl = vim.api.nvim_set_hl
			hl(0, "MultiCursorCursor", { link = "Cursor" })
			hl(0, "MultiCursorVisual", { link = "Visual" })
			hl(0, "MultiCursorSign", { link = "SignColumn" })
			hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
			hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
			hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
		end,
	},

	{
		"MagicDuck/grug-far.nvim",
		cmd = "GrugFar",
		opts = { headerMaxWidth = 80 },
	},

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon"):setup()
		end,
	},

	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "ConformInfo", "Format" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },

					python = { "ruff_format", "black" },

					javascript = { "prettier" },
					javascriptreact = { "prettier" },

					typescript = { "prettier" },
					typescriptreact = { "prettier" },

					html = { "prettier" },
					css = { "prettier" },

					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },

					sql = { "sql_formatter" },
				},
			})

			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}
