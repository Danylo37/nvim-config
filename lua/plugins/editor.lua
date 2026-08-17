return {
	{
		-- `main` is the rewrite for Neovim 0.12+: no modules, Neovim itself drives
		-- highlighting. It needs a system tree-sitter-cli (>= 0.26.1) plus curl/tar.
		-- `master` is frozen at Neovim 0.11 and is broken here: it registers query
		-- directives with the `all = false` option that 0.12 removed, so `match[id]`
		-- arrives as TSNode[] and its markdown injection directive dies on
		-- `node:range()`. Does not support lazy-loading.
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
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
			})

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					local lang = vim.treesitter.language.get_lang(ev.match)
					if not lang or not pcall(vim.treesitter.start, ev.buf, lang) then
						return
					end
					-- Only where Neovim ships nothing of its own. This autocmd runs
					-- after the runtime indent file, so an `indentexpr` that is
					-- still empty means there is no built-in to displace.
					--
					-- The built-ins win because they read intent, not just the
					-- tree: dedent a blank line to leave a block and the next
					-- <CR> stays where you put it, where the treesitter expression
					-- recomputes from the enclosing node and pulls the indent
					-- straight back.
					if vim.bo[ev.buf].indentexpr == "" and vim.treesitter.query.get(lang, "indents") then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},

	{
		-- Text objects for what the code *is* — a function, a class, an
		-- argument — instead of what it is wrapped in. `main` for the same
		-- reason nvim-treesitter is: the old branch's module system is gone,
		-- and every mapping is spelled out in config/keymaps.lua instead.
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			select = {
				-- `vaf` from above a function still selects it, rather than
				-- failing because the cursor is not inside one yet.
				lookahead = true,
			},
			move = {
				-- A jump is a jump: <C-o> comes back from it.
				set_jumps = true,
			},
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
		-- Regex-based on purpose: the treesitter route needs the `comment` parser
		-- injected into every comment, which is slow on big docstrings and only
		-- covers languages whose injections.scm asks for it.
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPost", "BufNewFile" },
		cmd = { "TodoTrouble", "TodoQuickFix", "TodoLocList" },
		opts = {},
	},

	{
		-- Wordlists of programming jargon, compiled together with this repo's
		-- spell/programming.words into a `programming` entry for 'spelllang', so
		-- spell checking identifiers doesn't flag `args` or `kubectl` as typos.
		-- The plugin is never loaded: only its `wordlists/` are used. Its own
		-- :DirtytalkUpdate is dead on Neovim 0.12 (it calls
		-- spellfile#WritableSpellDir(), gone with runtime/spellfile.vim), so the
		-- spell file is built here. Rerun with `:Lazy build vim-dirtytalk`.
		"psliwka/vim-dirtytalk",
		lazy = true,
		build = function(plugin)
			local files = vim.fn.glob(plugin.dir .. "/wordlists/*.words", true, true)
			table.insert(files, vim.fn.stdpath("config") .. "/spell/programming.words")

			local words = {}
			for _, file in ipairs(files) do
				if vim.fn.filereadable(file) == 1 then
					for _, line in ipairs(vim.fn.readfile(file)) do
						if line ~= "" and not vim.startswith(line, "#") then
							table.insert(words, line)
						end
					end
				end
			end

			local dir = vim.fn.stdpath("data") .. "/site/spell"
			local input = vim.fn.tempname()
			vim.fn.mkdir(dir, "p")
			vim.fn.writefile(words, input)
			vim.cmd.mkspell({ args = { dir .. "/programming", input }, bang = true })
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
		opts = {
			headerMaxWidth = 80,
			keymaps = {
				close = { n = "q" },
				abort = { n = "<localleader>B" },
			},
		},
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
		cmd = "ConformInfo",
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
