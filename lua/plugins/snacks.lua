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

--- Recent projects plus anything with a project marker under `dev_dirs`.
local function all_project_dirs()
	local dirs = recent_project_dirs(10)
	local seen = {}

	for _, dir in ipairs(dirs) do
		seen[dir] = true
	end

	for _, dev in ipairs(dev_dirs) do
		if vim.uv.fs_stat(dev) then
			-- Depth 4, matching the snacks built-in project picker this replaced,
			-- so a project can sit several grouping folders deep (e.g. work/client/repo).
			for name, kind in vim.fs.dir(dev, { depth = 4 }) do
				if kind == "directory" then
					local path = vim.fs.normalize(dev .. "/" .. name)

					if not seen[path] and util.find_root(path) == path then
						seen[path] = true
						dirs[#dirs + 1] = path
					end
				end
			end
		end
	end

	return dirs
end

--- Telescope picker over `all_project_dirs`: cd into the pick, then find files.
local function pick_project()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Projects",

			finder = finders.new_table({
				results = all_project_dirs(),
				entry_maker = function(dir)
					return {
						value = dir,
						display = vim.fn.fnamemodify(dir, ":~"),
						ordinal = dir,
					}
				end,
			}),

			sorter = conf.generic_sorter({}),

			attach_mappings = function(bufnr)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(bufnr)

					if entry then
						vim.fn.chdir(entry.value)
						require("telescope.builtin").find_files({ cwd = entry.value })
					end
				end)

				return true
			end,
		})
		:find()
end

return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			-- Telescope is the picker for this config; snacks only does UI bits.
			picker = { enabled = false },
			input = { enabled = true },
			image = { enabled = true },

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
								require("telescope.builtin").find_files()
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
								require("telescope.builtin").live_grep()
							end,
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = function()
								require("telescope.builtin").oldfiles()
							end,
						},
						{
							icon = " ",
							key = "c",
							desc = "Config",
							action = function()
								require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
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
