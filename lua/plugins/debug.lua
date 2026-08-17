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
				end,
			},
		},

		config = function()
			local dap = require("dap")

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticSignWarn" })
			vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticSignInfo" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignOk", linehl = "Visual" })

			-- The panels follow the session: up when it starts, down when it is
			-- over, so there is nothing to toggle by hand in the common case.
			local dapui = require("dapui")

			dap.listeners.before.attach.dapui = function()
				dapui.open()
			end

			dap.listeners.before.launch.dapui = function()
				dapui.open()
			end

			dap.listeners.before.event_terminated.dapui = function()
				dapui.close()
			end

			dap.listeners.before.event_exited.dapui = function()
				dapui.close()
			end
		end,
	},
}
