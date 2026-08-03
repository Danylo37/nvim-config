local project_markers = { ".git", ".venv", "venv" }

local function has_marker(dir)
	for _, marker in ipairs(project_markers) do
		if (vim.uv or vim.loop).fs_stat(dir .. "/" .. marker) then
			return true
		end
	end
	return false
end

local function project_root(path)
	path = vim.fs.normalize(path)
	if has_marker(path) then
		return path
	end
	for dir in vim.fs.parents(path) do
		if has_marker(dir) then
			return dir
		end
	end
end

local function recent_project_dirs(limit)
	local dirs = {}
	for file in Snacks.dashboard.oldfiles() do
		local dir = project_root(file)
		if dir and not vim.tbl_contains(dirs, dir) then
			table.insert(dirs, dir)
			if #dirs >= limit then
				break
			end
		end
	end
	return dirs
end

return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			dashboard = {
				enabled = true,

				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },

					{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
					{ icon = " ", title = "Projects",
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
							action = ":lua Snacks.dashboard.pick('files')",
						},
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{
							icon = " ",
							key = "p",
							desc = "Projects",
							action = ":lua Snacks.dashboard.pick('projects', { dev = { '~/MyStuff/Projects' }, max_depth = 4, patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'package.json', 'Makefile', '.venv', 'venv' } })",
						},
						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = ":lua Snacks.dashboard.pick('live_grep')",
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = ":lua Snacks.dashboard.pick('oldfiles')",
						},
						{
							icon = " ",
							key = "c",
							desc = "Config",
							action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
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
