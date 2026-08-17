-- ------------------------------------------------------------ swap files ---

-- A swap file outliving the session that made it puts the next `:edit` behind
-- the E325 prompt. When that edit comes from a Lua callback — the dashboard's
-- recent files, a picker — the prompt cannot be answered where it is drawn, and
-- what you get instead is an E5108 traceback with the file left unopened.
--
-- So decide here and let the edit through. `v:swapchoice` takes the same
-- letters the prompt offers.
vim.api.nvim_create_autocmd("SwapExists", {
	callback = function(ev)
		local swap = vim.v.swapname
		local info = vim.fn.swapinfo(swap)
		local running = info.pid and info.pid > 0 and vim.uv.kill(info.pid, 0) == 0

		-- Deferred: this runs while the buffer is being loaded, and at startup
		-- the notifier may not be up yet.
		local function notify(msg)
			vim.schedule(function()
				vim.notify(msg, vim.log.levels.WARN)
			end)
		end

		if running then
			-- Another Neovim really does have the file open.
			vim.v.swapchoice = "o"
			notify(vim.fn.fnamemodify(ev.file, ":t") .. " is open in Neovim " .. info.pid .. ", opened read-only")
		elseif info.dirty == 1 then
			-- The session died with unsaved changes in it. They are only in the
			-- swap file, so it stays where it is.
			vim.v.swapchoice = "e"
			notify("Stale swap file holds unsaved changes, `:recover` to see them: " .. swap)
		else
			-- Nothing in it that isn't already on disk.
			vim.v.swapchoice = "d"
		end
	end,
})

-- --------------------------------------------------------------- indent ----

-- Only filetypes that need something other than the global 4 spaces are listed.
-- Python is covered by Neovim's own ftplugin, which applies the PEP8 4/4/4.

vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"javascript",
		"typescript",
		"html",
		"css",
		"json",
		"yaml",
		"javascriptreact",
		"typescriptreact",
	},
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	end,
})
