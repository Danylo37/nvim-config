return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		-- Loaded on demand: every mapping in config/keymaps.lua goes through
		-- one of these commands, so there is no open_mapping here.
		cmd = { "ToggleTerm", "TermSelect", "TermExec" },
		opts = {
			float_opts = {
				border = "curved",
			},
		},
	},
}
