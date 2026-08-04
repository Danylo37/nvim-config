-- Shared helpers. Kept tiny on purpose: only things more than one place needs.

local M = {}

-- Markers that identify the root of a project, most specific first.
M.markers = {
	".git",
	"pyproject.toml",
	"package.json",
	"Cargo.toml",
	".venv",
	"venv",
}

--- Nearest directory above `path` containing a project marker, or nil.
--- @param path string|nil defaults to the current buffer's file
--- @return string|nil
function M.find_root(path)
	path = path or vim.api.nvim_buf_get_name(0)

	if path == "" then
		return nil
	end

	return vim.fs.root(vim.fs.normalize(path), M.markers)
end

--- Like `find_root`, but always returns a usable directory.
--- Anything under the nvim config dir resolves to the config dir itself, so the
--- file tree and terminals stay scoped to the config instead of $HOME.
--- @param path string|nil defaults to the current buffer's file
--- @return string
function M.root(path)
	path = path or vim.api.nvim_buf_get_name(0)

	local config = vim.fs.normalize(vim.fn.stdpath("config"))

	if path ~= "" and vim.startswith(vim.fs.normalize(path), config) then
		return config
	end

	return M.find_root(path) or vim.uv.cwd()
end

return M
