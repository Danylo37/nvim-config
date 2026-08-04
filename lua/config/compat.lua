-- Shims for APIs Nvim 0.12 deprecated that third-party plugins still call.
-- Upstream has no fix in any of these, so patch here to keep :checkhealth clean.
-- Drop an entry once the plugin stops using the old API.

-- nvim-lsp-file-operations
vim.lsp.get_active_clients = vim.lsp.get_clients

-- jupytext.nvim, toggleterm.nvim: `vim.validate{ name = { value, validator, optional } }`
local validate = vim.validate

vim.validate = function(...)
	local spec = ...

	if select("#", ...) == 1 and type(spec) == "table" then
		for name, entry in pairs(spec) do
			validate(name, entry[1], entry[2], entry[3])
		end
		return
	end

	return validate(...)
end
