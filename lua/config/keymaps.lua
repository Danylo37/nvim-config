-- Every keymap in this config lives here. Nothing is set from a plugin spec.
--
-- Plugin mappings are wrapped in functions that `require` the plugin, or go
-- through a `<cmd>` — both make lazy.nvim load it on first use, so keeping them
-- here costs nothing at startup.
--
-- One exception: multicursor's `addKeymapLayer` (lua/plugins/editor.lua) is a
-- plugin API, not a keymap. It binds <C-Left>/<C-Right>/<C-q>/<Esc> only while
-- extra cursors are alive.
--
-- Prefixes (see the which-key groups in lua/plugins/ui.lua):
--   <leader>a  AI / Claude       <leader>s  Search & replace
--   <leader>b  Buffer            <leader>t  Terminal
--   <leader>c  Code              <leader>u  UI toggles
--   <leader>f  Find / files      <leader>v  Venv
--   <leader>g  Git               <leader>x  Diagnostics
--   <leader>h  Harpoon           <leader>m  Multicursor
--   <leader>r  Refactor          <leader>o  Overseer / tasks

local map = vim.keymap.set
local util = require("util")

-- ---------------------------------------------------------------- general ---

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Search motions run through hlslens so it can draw the "[3/12]" match counter
-- and feed the search marks on the scrollbar. <Esc> above clears both.
local function hlslens_jump(key)
	return function()
		vim.cmd("normal! " .. vim.v.count1 .. key)
		require("hlslens").start()
	end
end

map("n", "n", hlslens_jump("n"), { desc = "Next search match" })
map("n", "N", hlslens_jump("N"), { desc = "Previous search match" })

for _, key in ipairs({ "*", "#", "g*", "g#" }) do
	map("n", key, key .. "<Cmd>lua require('hlslens').start()<CR>", {
		remap = true,
		desc = "Search word under cursor",
	})
end

map("n", "<leader>R", function()
	vim.cmd("silent! wa")
	vim.cmd("restart")
end, { desc = "Restart Neovim" })

map("n", "<leader>F", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

-- ---------------------------------------------------------------- windows ---

map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

map("n", "<A-h>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<A-l>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })
map("n", "<A-j>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<A-k>", "<cmd>resize +2<CR>", { desc = "Increase window height" })

-- ---------------------------------------------------------------- buffers ---

map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

map("n", "<leader>bd", function()
	require("snacks").bufdelete()
end, { desc = "Close buffer" })

-- Jump to the ordinals bufferline draws on each tab.
for i = 1, 9 do
	map("n", "<leader>b" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer " .. i })
end

-- ------------------------------------------------------------- edit / txt ---

map("n", '<leader>"', 'ysiw"', { remap = true, desc = 'Surround word with "' })
map("n", "<leader>'", "ysiw'", { remap = true, desc = "Surround word with '" })
map("n", "<leader>)", "ysiw(", { remap = true, desc = "Surround word with ()" })
map("n", "<leader>]", "ysiw[", { remap = true, desc = "Surround word with []" })
map("n", "<leader>}", "ysiw{", { remap = true, desc = "Surround word with {}" })

map({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash jump" })

-- ------------------------------------------------------------ multicursor ---

map({ "n", "x" }, "<C-n>", function()
	require("multicursor-nvim").matchAddCursor(1)
end, { desc = "Add cursor at next match" })

map({ "n", "x" }, "<C-x>", function()
	require("multicursor-nvim").matchSkipCursor(1)
end, { desc = "Skip match" })

map({ "n", "x" }, "<C-Up>", function()
	require("multicursor-nvim").lineAddCursor(-1)
end, { desc = "Add cursor above" })

map({ "n", "x" }, "<C-Down>", function()
	require("multicursor-nvim").lineAddCursor(1)
end, { desc = "Add cursor below" })

map({ "n", "x" }, "<leader>ma", function()
	require("multicursor-nvim").matchAllAddCursors()
end, { desc = "Add cursor to all matches" })

map("n", "<C-LeftMouse>", function()
	require("multicursor-nvim").handleMouse()
end, { desc = "Add cursor with mouse" })

-- ---------------------------------------------------------- find / files ----

map("n", "<leader>ff", function()
	Snacks.picker.files()
end, { desc = "Find files" })

map("n", "<leader>fg", function()
	Snacks.picker.grep()
end, { desc = "Live grep" })

map("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })

map("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Help tags" })

map("n", "<leader>e", function()
	require("neo-tree.command").execute({ toggle = true, reveal = true, dir = util.root() })
end, { desc = "Toggle file tree" })

map("n", "<leader>fe", "<cmd>Neotree focus<CR>", { desc = "Focus file tree" })

-- -------------------------------------------------------- search /replace ---

map("n", "<leader>sr", function()
	require("grug-far").open()
end, { desc = "Search & replace (project)" })

map("x", "<leader>sr", function()
	require("grug-far").with_visual_selection()
end, { desc = "Search & replace (selection)" })

map("n", "<leader>sw", function()
	require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search & replace word under cursor" })

map("n", "<leader>sf", function()
	require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search & replace (current file)" })

-- -------------------------------------------------------------------- lsp ---

map("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "Go to definition" })
map("n", "gr", "<cmd>Lspsaga finder<CR>", { desc = "Find references" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })

map("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code action" })

map("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "Rename symbol" })
map("n", "<leader>rN", "<cmd>Lspsaga rename ++project<CR>", { desc = "Rename symbol (project)" })

map("n", "<leader>ru", function()
	require("util.lsp_undo").undo()
end, { desc = "Undo last LSP edit in all files" })

-- ------------------------------------------------------------ diagnostics ---

map("n", "de", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Line diagnostics" })

map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })

map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "All diagnostics" })
map("n", "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer diagnostics" })
map("n", "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>", { desc = "References" })
map("n", "<leader>xd", "<cmd>Trouble lsp_definitions toggle<CR>", { desc = "Definitions" })
map("n", "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", { desc = "Quickfix" })
map("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", { desc = "Loclist" })
map("n", "<leader>xt", "<cmd>TodoTrouble<CR>", { desc = "TODO comments" })

map("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next TODO comment" })

map("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous TODO comment" })

-- -------------------------------------------------------------------- git ---

map("n", "]h", "<cmd>Gitsigns nav_hunk next<CR>", { desc = "Next hunk" })
map("n", "[h", "<cmd>Gitsigns nav_hunk prev<CR>", { desc = "Previous hunk" })

map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })

map("n", "<leader>gg", function()
	require("snacks").lazygit({ cwd = util.root() })
end, { desc = "Lazygit" })

map("n", "<leader>gl", function()
	require("snacks").lazygit.log({ cwd = util.root() })
end, { desc = "Lazygit log" })

map("n", "<leader>gf", function()
	require("snacks").lazygit.log_file()
end, { desc = "Lazygit file history" })

-- ---------------------------------------------------------------- harpoon ---

map("n", "<leader>ha", function()
	require("harpoon"):list():add()
end, { desc = "Harpoon: add file" })

map("n", "<leader>hd", function()
	require("harpoon"):list():remove()
end, { desc = "Harpoon: remove file" })

map("n", "<C-e>", function()
	local harpoon = require("harpoon")
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: toggle menu" })

for i = 1, 6 do
	map("n", "<leader>" .. i, function()
		require("harpoon"):list():select(i)
	end, { desc = "Harpoon: go to file " .. i })
end

-- ------------------------------------------------------------- terminal ----

map("t", "<C-q>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Replaces toggleterm's `open_mapping`, which bound the same three modes.
map("n", [[<C-\>]], "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
map("i", [[<C-\>]], "<Esc><cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
map("t", [[<C-\>]], [[<C-\><C-n><cmd>ToggleTerm<CR>]], { desc = "Toggle terminal" })

map("n", "<leader>tt", function()
	vim.cmd("ToggleTerm direction=horizontal dir=" .. vim.fn.fnameescape(util.root()))
end, { desc = "Toggle terminal" })

map("n", "<leader>tf", function()
	vim.cmd("ToggleTerm direction=float dir=" .. vim.fn.fnameescape(util.root()))
end, { desc = "Floating terminal" })

map("n", "<leader>ts", "<cmd>TermSelect<CR>", { desc = "Select terminal" })

for i = 1, 9 do
	map("n", "<leader>t" .. i, function()
		vim.cmd(i .. "ToggleTerm direction=horizontal dir=" .. vim.fn.fnameescape(util.root()))
	end, { desc = "Terminal " .. i })
end

-- Same treatment as lazygit: the binary in a snacks float, scoped to the root
-- so docker-compose projects are picked up.
map("n", "<leader>td", function()
	require("snacks").terminal.toggle("lazydocker", {
		cwd = util.root(),
		win = { position = "float", border = "rounded" },
	})
end, { desc = "Lazydocker" })

-- No `cwd`: lazysql takes its connections from its own config file, not the
-- project.
map("n", "<leader>tl", function()
	require("snacks").terminal.toggle("lazysql", {
		win = { position = "float", border = "rounded" },
	})
end, { desc = "Lazysql" })

map("n", "<leader>tp", function()
	vim.cmd("w")

	local dir = vim.fn.expand("%:p:h")
	local file = vim.fn.expand("%:t")

	vim.cmd("botright split")
	vim.cmd("terminal")

	vim.fn.chansend(vim.b.terminal_job_id, "cd '" .. dir .. "'\n")
	vim.fn.chansend(vim.b.terminal_job_id, "python '" .. file .. "'\n")
end, { desc = "Run current python file" })

-- ------------------------------------------------------ overseer / tasks ---

map("n", "<leader>oo", "<cmd>OverseerToggle<CR>", { desc = "Toggle task list" })
map("n", "<leader>or", "<cmd>OverseerRun<CR>", { desc = "Run task from template" })
map("n", "<leader>ot", "<cmd>OverseerTaskAction<CR>", { desc = "Action on a picked task" })

-- Same prompt :OverseerShell puts up, but that command leaves `cwd` unset and
-- overseer then falls back to `getcwd()` — the one launcher here not scoped to
-- the project, unlike the terminals, lazygit and lazydocker.
map("n", "<leader>oc", function()
	vim.ui.input({ prompt = "command", completion = "shellcmdline" }, function(cmd)
		if cmd and cmd ~= "" then
			require("overseer").new_task({ cmd = cmd, cwd = util.root() }):start()
		end
	end)
end, { desc = "Run shell command as task" })

-- Stands in for :OverseerQuickAction, dropped in overseer 2.0 along with
-- :OverseerBuild and :OverseerInfo (the latter is now `:checkhealth overseer`).
map("n", "<leader>oa", function()
	local task_list = require("overseer.task_list")
	local task = task_list.list_tasks({ sort = task_list.sort_newest_first })[1]

	if not task then
		vim.notify("No overseer tasks", vim.log.levels.WARN)
		return
	end

	require("overseer").run_action(task)
end, { desc = "Action on the last task" })

-- ------------------------------------------------------------ ai / claude ---

-- Windsurf drives inline suggestions; Copilot wins only while explicitly enabled.
map("i", "<Tab>", function()
	if vim.g.copilot_enabled and vim.fn["copilot#GetDisplayedSuggestion"]().text ~= "" then
		return vim.fn["copilot#Accept"]("\t")
	end
	return vim.fn["codeium#Accept"]()
end, {
	expr = true,
	replace_keycodes = false,
	silent = true,
	desc = "Accept AI suggestion",
})

-- Kills suggestions from both engines at once, so the state matches what <Tab>
-- above actually reads. Turning them back on restores Windsurf only — Copilot
-- stays where it belongs, off until `:Copilot enable`.
map("n", "<leader>ua", function()
	local on = vim.g.codeium_enabled ~= false or vim.g.copilot_enabled == true

	if on then
		vim.cmd("CodeiumDisable")
		if vim.g.copilot_enabled then
			vim.cmd("Copilot disable")
		end
	else
		vim.cmd("CodeiumEnable")
	end

	vim.notify("Inline completion " .. (on and "off" or "on"))
end, { desc = "Toggle inline completion" })

map("n", "<leader>aa", "<cmd>ClaudeCode<CR>", { desc = "Claude Code" })
map("x", "<leader>aa", "<cmd>ClaudeCodeSend<CR>", { desc = "Send selection to Claude" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<CR>", { desc = "Focus Claude" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", { desc = "Add current file to Claude" })
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<CR>", { desc = "Select Claude model" })

-- ------------------------------------------------------------------- misc ---

map("n", "<leader>ut", function()
	Snacks.picker.colorschemes()
end, { desc = "Choose theme" })

map("n", "<leader>uc", "<cmd>ColorizerToggle<CR>", { desc = "Toggle colorizer" })

map("n", "<leader>vs", "<cmd>VenvSelect<CR>", { desc = "Select Python venv" })
