return {
	{
		-- The debug adapter client: breakpoints, stepping, and the session
		-- itself. Everything else here plugs into it.
		"mfussenegger/nvim-dap",

		-- Loaded by the <leader>d mappings in config/keymaps.lua, which all go
		-- through `require("dap")`.
		lazy = true,

		dependencies = {
			{
				-- The windows: scopes, breakpoints, stacks, watches, plus the
				-- REPL along the bottom.
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				opts = {},
			},

			{
				-- Knows how to launch a Python file, a pytest test or a module
				-- under debugpy, so no launch.json is needed.
				"mfussenegger/nvim-dap-python",
				config = function()
					-- debugpy comes from Mason and brings its own venv. It only
					-- runs the debugger; the code being debugged runs under the
					-- project's interpreter, which dap-python resolves per
					-- session from $VIRTUAL_ENV (what <leader>vs sets) or a
					-- .venv in the project root.
					require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")

					require("dap-python").test_runner = "pytest"

					-- dap-python pushes every line of `./.env` into the
					-- debuggee's environment, with a parser that does not
					-- expand `${VAR}`. A file written for python-dotenv
					-- therefore arrives literal, and `load_dotenv()` will not
					-- overwrite what is already set, so the project ends up
					-- connecting as the user `${POSTGRES_USER}`. Projects load
					-- their own `.env`; pointing this at an empty file is the
					-- only way to opt out.
					local dap = require("dap")
					local python = dap.adapters.python

					dap.adapters.python = function(cb, config, parent)
						python(function(adapter)
							local enrich = adapter.enrich_config

							adapter.enrich_config = function(conf, on_config)
								conf.envFile = "/dev/null"
								enrich(conf, on_config)
							end

							cb(adapter)
						end, config, parent)
					end

					dap.adapters.debugpy = dap.adapters.python
				end,
			},
		},

		config = function()
			local dap = require("dap")

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticSignWarn" })
			vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticSignInfo" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignOk", linehl = "Visual" })

			-- The panels open with the session but deliberately stay up after it
			-- ends: closing them on `terminated` wiped the console before the
			-- traceback of a test that failed on the way in could be read.
			-- <leader>du puts them away.
			local dapui = require("dapui")

			dap.listeners.before.attach.dapui = function()
				dapui.open()
			end

			dap.listeners.before.launch.dapui = function()
				dapui.open()
			end
		end,
	},
}
