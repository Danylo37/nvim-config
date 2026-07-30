return {
	{
		"github/copilot.vim",
	},

	{
		"coder/claudecode.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		config = function()
			require("claudecode").setup({
				terminal = {
					git_repo_cwd = true,
				},
			})
		end,
	},
}
