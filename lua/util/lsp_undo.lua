-- Undo a multi-file LSP edit (project-wide rename, code action) in one keystroke.
--
-- The LSP applies a workspace edit as a series of independent per-buffer edits,
-- so a plain `u` only reverts whichever buffer happens to be focused. We wrap
-- `vim.lsp.util.apply_text_edits` to record the undo sequence of every buffer it
-- touches, then rewind all buffers from the same burst together.

local M = {}

-- Edits landing within this window of each other count as one logical operation.
local BURST_NS = 2e9

---@type { buf: integer, seq: integer, saved: boolean, time: integer }[]
local edits = {}

--- Install the `apply_text_edits` wrapper. Idempotent.
function M.setup()
	if M._installed then
		return
	end

	M._installed = true

	local apply_text_edits = vim.lsp.util.apply_text_edits

	vim.lsp.util.apply_text_edits = function(text_edits, bufnr, position_encoding, change_annotations)
		if next(text_edits or {}) and bufnr and bufnr ~= 0 then
			vim.fn.bufload(bufnr)
			edits[#edits + 1] = {
				buf = bufnr,
				-- State *before* the edit, so undoing to it reverts the edit.
				seq = vim.api.nvim_buf_call(bufnr, function()
					return vim.fn.undotree().seq_cur
				end),
				saved = not vim.bo[bufnr].modified,
				time = vim.uv.hrtime(),
			}
		end

		return apply_text_edits(text_edits, bufnr, position_encoding, change_annotations)
	end
end

--- Revert every buffer touched by the most recent LSP edit burst.
function M.undo()
	if #edits == 0 then
		vim.notify("No LSP edits to undo", vim.log.levels.WARN)
		return
	end

	local last = edits[#edits].time
	local targets = {}

	-- Pop the whole burst, keeping the earliest recorded state per buffer.
	while #edits > 0 and last - edits[#edits].time < BURST_NS do
		local edit = table.remove(edits)
		local seen = targets[edit.buf]

		if not seen or edit.seq < seen.seq then
			targets[edit.buf] = edit
		end
	end

	local reverted = {}

	for buf, edit in pairs(targets) do
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_call(buf, function()
				vim.cmd("silent undo " .. edit.seq)

				-- Buffers the LSP wrote to disk get written back in their old state.
				if edit.saved and vim.bo[buf].modified then
					vim.cmd("silent noautocmd write")
				end
			end)

			reverted[#reverted + 1] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
		end
	end

	vim.notify("Reverted " .. #reverted .. " file(s):\n" .. table.concat(reverted, "\n"))
end

return M
