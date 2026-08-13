vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.signcolumn = "yes:1"
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"

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
vim.opt.smartindent = true
