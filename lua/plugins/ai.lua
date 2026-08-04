return {
	{
		"github/copilot.vim",
		init = function()
			-- Tab is left alone; suggestions are accepted with <C-y>.
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_enabled = true
			vim.g.copilot_assume_mapped = true
			vim.g.copilot_tab_fallback = ""
		end,
	},

	{
		"coder/claudecode.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		cmd = {
			"ClaudeCode",
			"ClaudeCodeFocus",
			"ClaudeCodeSend",
			"ClaudeCodeAdd",
			"ClaudeCodeSelectModel",
		},
		opts = {
			terminal = {
				git_repo_cwd = true,
			},
		},
	},
}
