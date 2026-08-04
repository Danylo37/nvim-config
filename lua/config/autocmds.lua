-- Only filetypes that need something other than the global 4 spaces are listed.
-- Python is covered by Neovim's own ftplugin, which applies the PEP8 4/4/4.

vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"javascript",
		"typescript",
		"html",
		"css",
		"json",
		"yaml",
		"javascriptreact",
		"typescriptreact",
	},
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	end,
})
