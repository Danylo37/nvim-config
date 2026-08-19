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
--   <leader>d  Debug
--   <leader>f  Find / files      <leader>v  Venv
--   <leader>g  Git               <leader>x  Diagnostics
--   <leader>h  Harpoon           <leader>m  Multicursor
--   <leader>r  Refactor          <leader>o  Overseer / tasks
--   <leader>w  Windows

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

-- Same letters as the built-in <C-w>v / <C-w>s / <C-w>o they stand in for.
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split window right" })
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "Split window below" })
map("n", "<leader>wd", "<cmd>close<CR>", { desc = "Close window" })
map("n", "<leader>wo", "<cmd>only<CR>", { desc = "Close other windows" })
map("n", "<leader>w=", "<C-w>=", { desc = "Balance window sizes" })

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

-- ------------------------------------------------------------ textobjects ---

-- Objects named after what the code is, not what wraps it. `x` is visual and
-- `o` is what an operator waits for, so one mapping serves both `vaf` and
-- `daf`. `a` takes the whole thing, `i` only its insides.
-- The query captures both the definition and the `decorated_definition` that
-- wraps it, and the smallest match at the cursor wins, so `af`/`ac` stop below
-- the decorators. Grow the selection back up over them.
local function include_decorators()
	if not vim.fn.mode():match("^[vV\22]") then
		return
	end

	local srow, scol = vim.fn.line("v") - 1, vim.fn.col("v") - 1
	local node = vim.treesitter.get_node({ pos = { srow, scol } })

	while node do
		local nrow, ncol = node:start()
		if nrow ~= srow or ncol ~= scol then
			return
		end

		local parent = node:parent()
		if parent and parent:type() == "decorated_definition" then
			local drow, dcol = parent:start()
			vim.cmd("normal! o")
			vim.api.nvim_win_set_cursor(0, { drow + 1, dcol })
			return vim.cmd("normal! o")
		end

		node = parent
	end
end

for lhs, object in pairs({
	["af"] = { "@function.outer", "Function" },
	["if"] = { "@function.inner", "Function body" },
	["ac"] = { "@class.outer", "Class" },
	["ic"] = { "@class.inner", "Class body" },
	["aa"] = { "@parameter.outer", "Argument" },
	["ia"] = { "@parameter.inner", "Argument value" },
}) do
	map({ "x", "o" }, lhs, function()
		require("nvim-treesitter-textobjects.select").select_textobject(object[1], "textobjects")

		if object[1] == "@function.outer" or object[1] == "@class.outer" then
			include_decorators()
		end
	end, { desc = object[2] })
end

-- `]c`/`[c` are Vim's own "next change" in a diff, which is worth more than a
-- class jump while a diff is what you are looking at.
local function ts_move(direction, capture, in_diff)
	return function()
		if in_diff and vim.wo.diff then
			return vim.cmd("normal! " .. vim.v.count1 .. in_diff)
		end

		require("nvim-treesitter-textobjects.move")[direction](capture, "textobjects")
	end
end

map({ "n", "x", "o" }, "]f", ts_move("goto_next_start", "@function.outer"), { desc = "Next function" })
map({ "n", "x", "o" }, "[f", ts_move("goto_previous_start", "@function.outer"), { desc = "Previous function" })
map({ "n", "x", "o" }, "]c", ts_move("goto_next_start", "@class.outer", "]c"), { desc = "Next class" })
map({ "n", "x", "o" }, "[c", ts_move("goto_previous_start", "@class.outer", "[c"), { desc = "Previous class" })

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

-- snacks.words highlights every reference to the word under the cursor; these
-- walk them without leaving the buffer, which is the cheap version of `gr`.
map("n", "]r", function()
	require("snacks").words.jump(vim.v.count1, true)
end, { desc = "Next reference" })

map("n", "[r", function()
	require("snacks").words.jump(-vim.v.count1, true)
end, { desc = "Previous reference" })

-- ------------------------------------------------------------ diagnostics ---

-- `float = true`, so walking the diagnostics already shows each message; the
-- one below is for reading the message on the line you are already on.
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })

map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

-- Was `de`, which is Vim's own "delete to end of word" and stopped working
-- because of it.
map("n", "<leader>xe", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Line diagnostics" })

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

-- -------------------------------------------------------------------- dap ---

-- The panels open with the session and stay up after it (lua/plugins/debug.lua),
-- so a run is <leader>db to mark the line and <leader>dc to get there;
-- <leader>du puts them away.
map("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end, { desc = "Toggle breakpoint" })

map("n", "<leader>dB", function()
	vim.ui.input({ prompt = "Break when: " }, function(condition)
		if condition and condition ~= "" then
			require("dap").set_breakpoint(condition)
		end
	end)
end, { desc = "Conditional breakpoint" })

-- Starts the session when none is running, resumes it when one is.
map("n", "<leader>dc", function()
	require("dap").continue()
end, { desc = "Continue / start" })

map("n", "<leader>dC", function()
	require("dap").run_to_cursor()
end, { desc = "Run to cursor" })

map("n", "<leader>do", function()
	require("dap").step_over()
end, { desc = "Step over" })

map("n", "<leader>di", function()
	require("dap").step_into()
end, { desc = "Step into" })

map("n", "<leader>dO", function()
	require("dap").step_out()
end, { desc = "Step out" })

map("n", "<leader>dl", function()
	require("dap").run_last()
end, { desc = "Run last configuration" })

map("n", "<leader>dt", function()
	require("dap").terminate()
end, { desc = "Terminate session" })

map("n", "<leader>dr", function()
	require("dap").repl.toggle()
end, { desc = "Toggle REPL" })

map("n", "<leader>du", function()
	require("dapui").toggle()
end, { desc = "Toggle debugger panels" })

-- In visual mode the selection is the expression, which is how you check what
-- half of a long condition actually evaluates to.
map({ "n", "x" }, "<leader>de", function()
	require("dapui").eval()
end, { desc = "Evaluate expression" })

map("n", "<leader>dm", function()
	require("dap-python").test_method()
end, { desc = "Debug nearest test" })

map("n", "<leader>dM", function()
	require("dap-python").test_class()
end, { desc = "Debug test class" })

-- The stepping loop is what a debugger session mostly is, and reaching for
-- <leader> on every step gets old. Same keys every other debugger uses.
map("n", "<F5>", function()
	require("dap").continue()
end, { desc = "Debug: continue" })

map("n", "<F10>", function()
	require("dap").step_over()
end, { desc = "Debug: step over" })

map("n", "<F11>", function()
	require("dap").step_into()
end, { desc = "Debug: step into" })

map("n", "<F12>", function()
	require("dap").step_out()
end, { desc = "Debug: step out" })

-- -------------------------------------------------------------------- git ---

map("n", "]h", "<cmd>Gitsigns nav_hunk next<CR>", { desc = "Next hunk" })
map("n", "[h", "<cmd>Gitsigns nav_hunk prev<CR>", { desc = "Previous hunk" })

map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })

-- The scroll-bound split JetBrains calls Annotate: a commit against every line,
-- following the buffer as it scrolls. <CR> inside it opens a menu to show that
-- commit or reblame from it.
map("n", "<leader>gb", "<cmd>Gitsigns blame<CR>", { desc = "Blame the file (side split)" })

-- One line instead of all of them, but the whole commit: message, author, and
-- the diff of the hunk it touched.
map("n", "<leader>gB", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame the current line (full)" })

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
		-- `true` is snacks' way of saying "whatever `winborder` is"; without a
		-- border key at all a snacks float has none.
		win = { position = "float", border = true },
	})
end, { desc = "Lazydocker" })

-- No `cwd`: lazysql takes its connections from its own config file, not the
-- project.
map("n", "<leader>tl", function()
	require("snacks").terminal.toggle("lazysql", {
		-- `true` is snacks' way of saying "whatever `winborder` is"; without a
		-- border key at all a snacks float has none.
		win = { position = "float", border = true },
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
-- An unfinished snippet outranks both: accepting a suggestion instead of moving
-- to the next placeholder would strand the expansion half-filled.
map("i", "<Tab>", function()
	if require("luasnip").locally_jumpable(1) then
		-- Returned rather than called: an expr mapping runs under textlock, so
		-- the jump has to happen after it, through <Cmd>. The termcodes are
		-- resolved here because `replace_keycodes = false` below is what keeps
		-- the escapes in the AI engines' own output intact.
		return vim.api.nvim_replace_termcodes("<Cmd>lua require('luasnip').jump(1)<CR>", true, true, true)
	end

	if vim.g.copilot_enabled and vim.fn["copilot#GetDisplayedSuggestion"]().text ~= "" then
		return vim.fn["copilot#Accept"]("\t")
	end
	return vim.fn["codeium#Accept"]()
end, {
	expr = true,
	replace_keycodes = false,
	silent = true,
	desc = "Accept AI suggestion / next snippet placeholder",
})

-- A jump leaves the placeholder selected, i.e. in select mode, where nothing
-- else is competing for <Tab>.
map("s", "<Tab>", function()
	require("luasnip").jump(1)
end, { desc = "Next snippet placeholder" })

map({ "i", "s" }, "<S-Tab>", function()
	require("luasnip").jump(-1)
end, { desc = "Previous snippet placeholder" })

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

-- --continue picks up the last conversation in this directory; with none to
-- resume claude exits with an error, so <leader>an starts a fresh one.
map("n", "<leader>aa", "<cmd>ClaudeCode --continue<CR>", { desc = "Claude Code (last session)" })
map("n", "<leader>an", "<cmd>ClaudeCode<CR>", { desc = "Claude Code (new session)" })
map("x", "<leader>aa", "<cmd>ClaudeCodeSend<CR>", { desc = "Send selection to Claude" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<CR>", { desc = "Focus Claude" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", { desc = "Add current file to Claude" })
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<CR>", { desc = "Select Claude model" })

-- ------------------------------------------------------------------- misc ---

map("n", "<leader>ut", function()
	Snacks.picker.colorschemes()
end, { desc = "Choose theme" })

map("n", "<leader>uc", "<cmd>ColorizerToggle<CR>", { desc = "Toggle colorizer" })

map("n", "<leader>us", function()
	vim.wo.spell = not vim.wo.spell
	vim.notify("Spell " .. (vim.wo.spell and "on" or "off"))
end, { desc = "Toggle spell check" })

map("n", "<leader>vs", "<cmd>VenvSelect<CR>", { desc = "Select Python venv" })
