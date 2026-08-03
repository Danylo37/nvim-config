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

			for i = 1, 9 do
				vim.keymap.set("n", "<leader>t" .. i, function()
					local dir = vim.fn.fnameescape(project_root())
					vim.cmd(i .. "ToggleTerm direction=horizontal dir=" .. dir)
				end, { desc = "Terminal " .. i })
			end

			vim.keymap.set("n", "<leader>ts", "<cmd>TermSelect<cr>", { desc = "Select terminal" })
		end,
	},
}
