vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", '<leader>"', 'ysiw"', { remap = true, desc = 'Surround word with "' })
vim.keymap.set("n", "<leader>'", "ysiw'", { remap = true, desc = "Surround word with '" })
vim.keymap.set("n", "<leader>)", "ysiw(", { remap = true, desc = "Surround word with ()" })
vim.keymap.set("n", "<leader>]", "ysiw[", { remap = true, desc = "Surround word with []" })
vim.keymap.set("n", "<leader>}", "ysiw{", { remap = true, desc = "Surround word with {}" })

vim.keymap.set("n", "<leader>ji", "<cmd>MoltenInit<CR>", { desc = "Jupyter Init" })
vim.keymap.set("n", "<leader>jr", "<cmd>MoltenEvaluateOperator<CR>", { desc = "Run Cell" })
vim.keymap.set("v", "<leader>jr", "<cmd>MoltenEvaluateVisual<CR>", { desc = "Run Selection" })
vim.keymap.set("n", "<leader>jo", "<cmd>MoltenEnterOutput<CR>", { desc = "Open Output" })
vim.keymap.set("n", "<leader>jh", "<cmd>MoltenHideOutput<CR>", { desc = "Hide Output" })

vim.g.copilot_no_tab_map = true
vim.g.copilot_enabled = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""

vim.keymap.set("n", "<leader>ut", function()
	require("telescope.builtin").colorscheme({
		enable_preview = true,
	})
end, { desc = "Choose Theme" })

vim.keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")', {
	expr = true,
	replace_keycodes = false,
})
