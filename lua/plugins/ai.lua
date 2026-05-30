return {
	{
		"github/copilot.vim",
	},

	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "github/copilot.vim" },
			{ "nvim-lua/plenary.nvim" },
		},
		build = "make tiktoken",
		config = function()
			require("CopilotChat").setup({
				model = "claude-haiku-4.5",
				debug = false,
				show_help = "yes",
				auto_follow_cursor = true,
				window = {
					layout = "vertical",
					width = 0.4,
				},
			})

			local chat = require("CopilotChat")

			vim.keymap.set("n", "<leader>cc", ":CopilotChat<CR>", { desc = "CopilotChat - open" })

			vim.keymap.set("v", "<leader>cc", function()
				chat.ask("Explain this code", {
					selection = require("CopilotChat.select").visual,
				})
			end, { desc = "CopilotChat - explain selection" })

			vim.keymap.set("n", "<leader>cq", function()
				local input = vim.fn.input("Ask Copilot: ")
				if input ~= "" then
					chat.ask(input, {
						selection = require("CopilotChat.select").buffer,
					})
				end
			end, { desc = "CopilotChat - quick question" })

			vim.keymap.set("v", "<leader>cf", function()
				chat.ask("Fix this code", {
					selection = require("CopilotChat.select").visual,
				})
			end, { desc = "CopilotChat - fix code" })

			vim.keymap.set("v", "<leader>co", function()
				chat.ask("Optimize this code", {
					selection = require("CopilotChat.select").visual,
				})
			end, { desc = "CopilotChat - optimize" })
		end,
	},
}
