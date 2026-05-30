return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				dir = "git_dir",
				open_mapping = [[<C-\>]],
				float_opts = { border = "curved" },
			})

			vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Toggle terminal" })
			vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Floating terminal" })
		end,
	},
}
