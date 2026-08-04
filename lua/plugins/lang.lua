return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },

		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},

		opts = {},
	},

	{
		-- Not lazy: it has to hook BufRead to turn .ipynb into a py:percent buffer.
		"GCBallesteros/jupytext.nvim",
		opts = {
			format = "py:percent",
		},
	},

	{
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-telescope/telescope.nvim",
		},
		cmd = { "VenvSelect", "VenvSelectCached" },
		-- Also load on `ft = "python"`: setup() registers the plugin's own
		-- BufReadPost/FileType autocmds that restore a workspace's cached venv,
		-- but only once setup() has actually run. Gated on `cmd` alone, that
		-- never happened until you invoked :VenvSelect yourself.
		ft = "python",
		opts = {
			auto_refresh = true,
			stay_on_this_version = true,
		},
	},
}
