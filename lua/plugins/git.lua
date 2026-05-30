return {
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
			})

			vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<CR>")
			vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<CR>")

			vim.keymap.set("n", "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>")
			vim.keymap.set("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>")
			vim.keymap.set("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>")
		end,
	},
}
