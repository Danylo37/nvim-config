local util = require("util")

-- Extra folders the dashboard's project picker scans, on top of recent files.
local dev_dirs = { vim.fn.expand("~/MyStuff/Projects") }

--- Project roots derived from recently opened files, newest first.
local function recent_project_dirs(limit)
	local dirs = {}

	for file in Snacks.dashboard.oldfiles() do
		local dir = util.find_root(file)

		if dir and not vim.tbl_contains(dirs, dir) then
			dirs[#dirs + 1] = dir

			if #dirs >= limit then
				break
			end
		end
	end

	return dirs
end

--- Recent projects plus anything with a project marker under `dev_dirs`, in
--- snacks' own project picker. Picking one cd's into it and opens a file picker.
local function pick_project()
	Snacks.picker.projects({
		dev = dev_dirs,
		-- A project can sit several grouping folders deep (e.g. work/client/repo).
		max_depth = 4,
		patterns = {
			".git",
			"_darcs",
			".hg",
			".bzr",
			".svn",
			"package.json",
			"Makefile",
			".venv",
			"venv",
		},
	})
end

--- Picker config for overseer's `vim.ui.select` prompts: a small box you pick
--- from by number, like lspsaga's code action window. Opening focused on the
--- list instead of the filter is what frees up 1-9; `n` matches the number
--- snacks prints in front of an entry, not its row, so filtering first does
--- not shift what a digit does.
local function numbered_select()
	local actions, keys = {}, {}

	for n = 1, 9 do
		local action = "confirm_" .. n

		actions[action] = function(picker)
			for row = 1, picker.list:count() do
				local item = picker.list:get(row)

				if item and item.idx == n then
					picker.list:move(row, true)
					picker:action("confirm")
					return
				end
			end
		end

		keys[tostring(n)] = action
	end

	return {
		focus = "list",
		-- No filter row: the prompt is already the window title and the digits
		-- do the picking, so the input would only take up a line.
		layout = { preset = "select", hidden = { "input", "preview" } },
		actions = actions,
		win = { list = { keys = keys } },
	}
end

return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			-- The picker for everything: files, grep, buffers, the dashboard keys
			-- and, through `ui_select`, `vim.ui.select`.
			--
			-- `ui_select` matters beyond looks: left to Nvim, `vim.ui.select` is
			-- `inputlist()` — it prints the choices as a message and reads keys from
			-- the cmdline, which noice mirrors into a Confirm popup, so the list is
			-- drawn twice and keypresses go to the prompt hidden behind it.
			picker = {
				enabled = true,
				ui_select = true,

				sources = {
					-- Same wide window as every other picker, minus the preview pane:
					-- select items (overseer tasks, code actions) are plain strings
					-- with nothing to preview.
					select = {
						layout = { preset = "default", hidden = { "preview" } },

						-- Overseer tags its prompts with a `kind`, so only <leader>or,
						-- <leader>oa and <leader>ot get the numbered box.
						kinds = {
							overseer_template = numbered_select(),
							overseer_task_options = numbered_select(),
						},
					},
				},
			},
			input = { enabled = true },
			image = { enabled = true },

			-- Opens the lazygit binary in a float, themed from the colorscheme.
			lazygit = { enabled = true },

			dashboard = {
				enabled = true,

				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },

					{
						icon = " ",
						title = "Recent Files",
						section = "recent_files",
						indent = 2,
						padding = 1,
					},
					{
						icon = " ",
						title = "Projects",
						section = "projects",
						indent = 2,
						padding = 1,
						dirs = function()
							return recent_project_dirs(5)
						end,
					},

					{ section = "startup" },
				},

				preset = {
					keys = {
						{
							icon = " ",
							key = "f",
							desc = "Find File",
							action = function()
								Snacks.picker.files()
							end,
						},
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{
							icon = " ",
							key = "p",
							desc = "Projects",
							action = pick_project,
						},
						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = function()
								Snacks.picker.grep()
							end,
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = function()
								Snacks.picker.recent()
							end,
						},
						{
							icon = " ",
							key = "c",
							desc = "Config",
							action = function()
								Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
							end,
						},
						{
							icon = "󰒲 ",
							key = "L",
							desc = "Lazy",
							action = ":Lazy",
							enabled = package.loaded.lazy ~= nil,
						},
						{ icon = "󰈆 ", key = "M", desc = "Mason", action = ":Mason" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
				},
			},
		},
	},
}
