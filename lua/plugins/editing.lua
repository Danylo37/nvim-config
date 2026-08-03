return {
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
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
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

			local set = vim.keymap.set

			set({ "n", "x" }, "<C-n>", function()
				mc.matchAddCursor(1)
			end, { desc = "Add cursor at next match" })

			set({ "n", "x" }, "<C-x>", function()
				mc.matchSkipCursor(1)
			end, { desc = "Skip match" })

			set({ "n", "x" }, "<C-Up>", function()
				mc.lineAddCursor(-1)
			end, { desc = "Add cursor above" })

			set({ "n", "x" }, "<C-Down>", function()
				mc.lineAddCursor(1)
			end, { desc = "Add cursor below" })

			set({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors, { desc = "Add cursor to all matches" })
			set("n", "<C-LeftMouse>", mc.handleMouse, { desc = "Add cursor with mouse" })

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
		keys = {
			{
				"<leader>sr",
				function()
					require("grug-far").open()
				end,
				desc = "Search & replace (project)",
			},
			{
				"<leader>sr",
				mode = "x",
				function()
					require("grug-far").with_visual_selection()
				end,
				desc = "Search & replace (selection)",
			},
			{
				"<leader>sw",
				function()
					require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
				end,
				desc = "Search & replace word under cursor",
			},
			{
				"<leader>sf",
				function()
					require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
				end,
				desc = "Search & replace (current file)",
			},
		},
	},

	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{
				"<leader>F",
				function()
					require("conform").format({
						async = true,
						lsp_format = "fallback",
					})
				end,
				desc = "Format buffer",
			},
		},
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
