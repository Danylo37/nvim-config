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

vim.keymap.set("i", "<C-y>", 'copilot#Accept("<CR>")', {
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

vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", {
	desc = "Next buffer",
})

vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", {
	desc = "Previous buffer",
})

vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", {
	desc = "Close buffer",
})

vim.keymap.set("n", "<leader>R", function()
	vim.cmd("silent! wa")
	vim.cmd("restart")
end, { desc = "Restart Neovim" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", {
	desc = "Go to left window",
})

vim.keymap.set("n", "<C-j>", "<C-w>j", {
	desc = "Go to lower window",
})

vim.keymap.set("n", "<C-k>", "<C-w>k", {
	desc = "Go to upper window",
})

vim.keymap.set("n", "<C-l>", "<C-w>l", {
	desc = "Go to right window",
})

-- Resize windows
vim.keymap.set("n", "<A-h>", "<cmd>vertical resize -2<CR>", {
	desc = "Decrease window width",
})

vim.keymap.set("n", "<A-l>", "<cmd>vertical resize +2<CR>", {
	desc = "Increase window width",
})

vim.keymap.set("n", "<A-j>", "<cmd>resize -2<CR>", {
	desc = "Decrease window height",
})

vim.keymap.set("n", "<A-k>", "<cmd>resize +2<CR>", {
	desc = "Increase window height",
})

-- Terminal mode
vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], {
	desc = "Exit terminal mode",
})

-- LSP Saga keymaps
vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", {
	desc = "Code action",
})

-- Claude Code keymaps
vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<CR>", {
	desc = "Claude Code",
})

vim.keymap.set("n", "<leader>cf", "<cmd>ClaudeCodeFocus<CR>", {
	desc = "Focus Claude",
})

vim.keymap.set("v", "<leader>cc", "<cmd>ClaudeCodeSend<CR>", {
	desc = "Send selection to Claude",
})

vim.keymap.set("n", "<leader>cA", "<cmd>ClaudeCodeAdd %<CR>", {
	desc = "Add current file to Claude",
})

vim.keymap.set("n", "<leader>cm", "<cmd>ClaudeCodeSelectModel<CR>", {
	desc = "Select Claude model",
})
