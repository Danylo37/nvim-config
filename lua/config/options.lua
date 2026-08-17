vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.signcolumn = "yes:1"
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"

-- New windows open right and below, i.e. where the cursor is going, so the
-- window you were reading does not jump somewhere else on the screen.
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Never let the cursor sit against the top or bottom edge; the eight lines
-- after the one you are on are context you almost always want.
vim.opt.scrolloff = 8

-- Undo survives closing the file, in ~/.local/state/nvim/undo.
vim.opt.undofile = true

-- Case-insensitive search, unless the pattern itself has a capital in it.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- :s previews as you type it, with the affected lines in a split.
vim.opt.inccommand = "split"

-- How long the cursor has to sit still before `CursorHold` fires, which is
-- what anything appearing "when you pause" waits on. The default 4s is long
-- enough that those hints never show up at all. Not a polling interval: the
-- timer runs once after you stop, and resets the moment you move.
vim.opt.updatetime = 200

-- `:q` with unsaved changes asks instead of failing with E37.
vim.opt.confirm = true

-- Default frame for floating windows that do not ask for one themselves.
vim.o.winborder = "rounded"

vim.diagnostic.config({
	virtual_text = false,
})

-- Spell files live in ~/.local/share/nvim/site/spell; Neovim's built-in
-- spellfile plugin offers to download a missing one on first use. `programming`
-- is built from vim-dirtytalk's wordlists (lua/plugins/editor.lua).
--
-- On everywhere, but `noplainbuffer` limits it to treesitter's @spell regions:
-- comments, strings, and the identifiers added in after/queries/. A buffer with
-- no parser is left alone entirely.
vim.opt.spell = true
vim.opt.spelllang = { "en", "uk", "ru", "programming" }
vim.opt.spelloptions = "camel,noplainbuffer"

-- Off: the default pattern treats every line start as a sentence start, so in
-- code each variable first on its line is a SpellCap error. That is a rule, not
-- a dictionary lookup, so `zg` never silences it.
vim.opt.spellcapcheck = ""

-- Pinned: with a spell/ dir in this repo, `zg` would default to writing there.
vim.opt.spellfile = vim.fn.stdpath("data") .. "/site/spell/en.utf-8.add"

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

-- Off: a C-shaped guess at what the next line should look like, from before
-- filetype indent files existed. It is ignored outright wherever `indentexpr`
-- is set, and where it isn't (markdown, plain text) its rules about `{`, `}`
-- and `#` do more harm than `autoindent` alone.
vim.opt.smartindent = false
