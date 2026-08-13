return {
	{
		-- Primary inline completion: free, no monthly quota. Run `:Codeium Auth` once.
		"Exafunction/windsurf.vim",
		init = function()
			vim.g.codeium_disable_bindings = 1
		end,
	},

	{
		-- Kept installed but off: the free tier is capped at 2000 completions/month.
		-- `:Copilot enable` turns it back on, <Tab> then prefers its suggestion.
		"github/copilot.vim",
		init = function()
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_enabled = false
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
			-- Args from `:ClaudeCode <args>` are appended to this string, so the
			-- mappings in config/keymaps.lua can add --continue on top of it.
			terminal_cmd = "claude --permission-mode auto",
			terminal = {
				git_repo_cwd = true,
			},
		},
	},
}
