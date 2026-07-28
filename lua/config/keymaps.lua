vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", '<leader>"', 'ysiw"', { remap = true, desc = 'Surround word with "' })
vim.keymap.set("n", "<leader>'", "ysiw'", { remap = true, desc = "Surround word with '" })
vim.keymap.set("n", "<leader>)", "ysiw(", { remap = true, desc = "Surround word with ()" })
vim.keymap.set("n", "<leader>]", "ysiw[", { remap = true, desc = "Surround word with []" })
vim.keymap.set("n", "<leader>}", "ysiw{", { remap = true, desc = "Surround word with {}" })

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

vim.keymap.set("n", "<leader>rpy", function()
	vim.cmd("w")

	local dir = vim.fn.expand("%:p:h")
	local file = vim.fn.expand("%:t")

	vim.cmd("botright split")
	vim.cmd("terminal")

	vim.fn.chansend(vim.b.terminal_job_id, "cd '" .. dir .. "'\n")
	vim.fn.chansend(vim.b.terminal_job_id, "python '" .. file .. "'\n")
end, { desc = "Run current python file" })
