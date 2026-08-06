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
	"CMakeLists.txt",
	".idea",
}

--- Nearest directory above `path` containing a project marker, or nil.
--- Not `vim.fs.root`: that walks to the filesystem root for each marker in turn,
--- so a stray `package.json` in $HOME outranks the `CMakeLists.txt` sitting next
--- to the file. Here the closest directory wins, whichever marker it holds.
--- @param path string|nil defaults to the current buffer's file
--- @return string|nil
function M.find_root(path)
	path = path or vim.api.nvim_buf_get_name(0)

	if path == "" then
		return nil
	end

	local start = vim.fs.normalize(path)

	if vim.fn.isdirectory(start) == 1 then
		start = start .. "/."
	end

	for dir in vim.fs.parents(start) do
		for _, marker in ipairs(M.markers) do
			if vim.uv.fs_stat(dir .. "/" .. marker) then
				return dir
			end
		end
	end

	return nil
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
