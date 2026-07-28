return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",

					diagnostics = "nvim_lsp",

					always_show_bufferline = true,
					show_buffer_close_icons = false,
					show_close_icon = false,

					separator_style = "slant",

					numbers = "ordinal",

					offsets = {
						{
							filetype = "neo-tree",
							text = "Explorer",
							text_align = "center",
							separator = true,
						},
					},
				},
			})
		end,
	},
}
