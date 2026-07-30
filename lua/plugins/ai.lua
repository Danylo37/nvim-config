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
			require("claudecode").setup()
		end,
	},
}
