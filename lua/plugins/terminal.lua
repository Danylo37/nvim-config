return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		-- Loaded on demand: every mapping in config/keymaps.lua goes through
		-- one of these commands, so there is no open_mapping here.
		cmd = { "ToggleTerm", "TermSelect", "TermExec" },
		opts = {
			float_opts = {
				border = "curved",
			},
		},
	},

	{
		"stevearc/overseer.nvim",
		cmd = {
			"OverseerOpen",
			"OverseerClose",
			"OverseerToggle",
			"OverseerRun",
			"OverseerShell",
			"OverseerTaskAction",
		},
		opts = {
			-- Redefining the whole `default` bundle: this list replaces overseer's
			-- rather than merging into it. Two changes from upstream:
			-- `on_complete_notify` gets CANCELED, without which long-running tasks
			-- (uvicorn, `docker compose up`) ended silently, and `open_output` is
			-- added so a starting task is visible without opening the list by hand.
			component_aliases = {
				default = {
					"on_exit_set_status",
					{ "on_complete_notify", statuses = { "SUCCESS", "FAILURE", "CANCELED" } },
					{ "open_output", on_start = "always", direction = "dock", focus = false },
					{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
				},
			},
			task_list = {
				direction = "bottom",
				bindings = {
					-- Overseer's defaults shadow the window-nav and harpoon
					-- mappings from config/keymaps.lua inside the task list.
					["<C-h>"] = false,
					["<C-j>"] = false,
					["<C-k>"] = false,
					["<C-l>"] = false,
					["<C-e>"] = false,
					["h"] = "DecreaseDetail",
					["l"] = "IncreaseDetail",
					["e"] = "Edit",
					["<C-u>"] = "ScrollOutputUp",
					["<C-d>"] = "ScrollOutputDown",
				},
			},
		},
		config = function(_, opts)
			local overseer = require("overseer")

			overseer.setup(opts)

			-- Own templates go here, not in `template_dirs`: that option is broken
			-- upstream — the loader matches module names against a hardcoded
			-- "overseer/template/" path, so any other directory errors out.
			--
			-- A provider rather than a plain template because `condition` can only
			-- match a filetype or a fixed path, and this should appear in every
			-- project that has an `app/main.py`, wherever it lives.
			overseer.register_template({
				name = "uvicorn dev",
				generator = function(search)
					local pyproject =
						vim.fs.find("pyproject.toml", { upward = true, type = "file", path = search.dir })[1]

					if not pyproject then
						return "No pyproject.toml found"
					end

					local cwd = vim.fs.dirname(pyproject)

					if not vim.uv.fs_stat(vim.fs.joinpath(cwd, "app", "main.py")) then
						return "No app/main.py found"
					end

					return {
						{
							name = "uvicorn dev",
							desc = "uv run uvicorn app.main:app --reload",
							builder = function()
								return {
									cmd = { "uv", "run", "uvicorn", "app.main:app", "--reload" },
									cwd = cwd,
								}
							end,
						},
					}
				end,
			})

			overseer.register_template({
				name = "pytest",
				generator = function(search)
					local pyproject =
						vim.fs.find("pyproject.toml", { upward = true, type = "file", path = search.dir })[1]

					if not pyproject then
						return "No pyproject.toml found"
					end

					local cwd = vim.fs.dirname(pyproject)
					local ret = {
						{
							name = "pytest",
							desc = "uv run pytest -vv -s",
							builder = function()
								return { cmd = { "uv", "run", "pytest", "-vv", "-s" }, cwd = cwd }
							end,
						},
					}

					local file = vim.api.nvim_buf_get_name(0)

					if file:match("%.py$") then
						table.insert(ret, {
							name = "pytest (current file)",
							desc = "uv run pytest -vv -s " .. vim.fs.basename(file),
							builder = function()
								return { cmd = { "uv", "run", "pytest", "-vv", "-s", file }, cwd = cwd }
							end,
						})
					end

					return ret
				end,
			})

			overseer.register_template({
				name = "docker compose",
				generator = function(search)
					local compose = vim.fs.find({
						"compose.yaml",
						"compose.yml",
						"docker-compose.yaml",
						"docker-compose.yml",
					}, { upward = true, type = "file", path = search.dir })[1]

					if not compose then
						return "No compose file found"
					end

					local cwd = vim.fs.dirname(compose)
					local ret = {}

					for _, args in ipairs({
						{ "up" },
						{ "up", "--build" },
						{ "down" },
						{ "down", "-v" },
					}) do
						local cmd = vim.list_extend({ "docker", "compose" }, args)

						table.insert(ret, {
							name = table.concat(cmd, " "),
							desc = vim.fs.basename(compose),
							builder = function()
								return { cmd = cmd, cwd = cwd }
							end,
						})
					end

					return ret
				end,
			})
		end,
	},
}
