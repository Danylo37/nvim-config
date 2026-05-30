return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			local function project_root()
				return vim.fs.root(0, {
					".git",
					"pyproject.toml",
					"package.json",
					"Cargo.toml",
				}) or vim.fn.getcwd()
			end

			require("toggleterm").setup({
				open_mapping = [[<C-\>]],
				float_opts = {
					border = "curved",
				},
			})

			vim.keymap.set("n", "<leader>tt", function()
				local dir = vim.fn.fnameescape(project_root())
				vim.cmd("ToggleTerm direction=horizontal dir=" .. dir)
			end, { desc = "Toggle terminal" })

			vim.keymap.set("n", "<leader>tf", function()
				local dir = vim.fn.fnameescape(project_root())
				vim.cmd("ToggleTerm direction=float dir=" .. dir)
			end, { desc = "Floating terminal" })
		end,
	},
}
