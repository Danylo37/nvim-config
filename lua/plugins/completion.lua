return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",

			{
				"L3MON4D3/LuaSnip",
				-- jsregexp is only used by snippets with regex transforms; every
				-- other part of LuaSnip works without it, so a failed build here
				-- costs a handful of friendly-snippets entries, nothing more.
				build = "make install_jsregexp",
				dependencies = { "rafamadriz/friendly-snippets" },
				opts = {
					-- Without these, a snippet you have already walked away from
					-- stays "active", and the next <Tab> jumps back into it.
					region_check_events = "InsertEnter",
					delete_check_events = "TextChanged,InsertLeave",
				},
				config = function(_, opts)
					require("luasnip").setup(opts)

					local from_vscode = require("luasnip.loaders.from_vscode")

					-- Anything on runtimepath shipping VSCode-format snippets,
					-- which today means friendly-snippets.
					from_vscode.lazy_load()

					-- Personal snippets, same format, in this repo.
					from_vscode.lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
				end,
			},
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				-- Load-bearing: an LSP completion item can carry a snippet body
				-- (every function signature does). With no expander configured,
				-- cmp inserts that body verbatim, `${1:...}` placeholders and all.
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),

					-- The preset already binds <C-n>/<C-p>; these are the same
					-- thing under the hand that moves between windows.
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-k>"] = cmp.mapping.select_prev_item(),

					-- A menu of nothing but snippets, for when you know one exists
					-- and don't want to hunt for it among the LSP items.
					["<C-s>"] = cmp.mapping.complete({
						config = { sources = { { name = "luasnip" } } },
					}),
				}),

				-- `priority` is added straight to an entry's fuzzy score, and the
				-- default is derived from the source's position in this list — far
				-- too small a gap to keep a snippet visible. Spelled out instead,
				-- so a matching snippet sits above the LSP items rather than
				-- somewhere in the middle of them.
				sources = {
					{ name = "luasnip", priority = 100 },
					{ name = "nvim_lsp", priority = 80 },
					{ name = "buffer", priority = 40 },
					{ name = "path", priority = 20 },
				},

				-- Which source an item came from, in the right-hand column. The
				-- kind column already says "Snippet", but it is easy to miss.
				formatting = {
					format = function(entry, item)
						item.menu = ({
							luasnip = "snippet",
							nvim_lsp = "lsp",
							buffer = "buffer",
							path = "path",
						})[entry.source.name]

						return item
					end,
				},
			})
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local autopairs = require("nvim-autopairs")

			autopairs.setup({
				check_ts = true,
			})

			local cmp = require("cmp")
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
}
