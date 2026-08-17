# nvim-config

Personal Neovim config on [lazy.nvim](https://github.com/folke/lazy.nvim): LSP out of
the box for Python/TS/JS/HTML/CSS/Lua/SQL, snacks.picker as the picker, a dashboard
with recent projects, AI assistants (Windsurf + Claude Code), and every keymap in one file.

## Table of contents

- [Dependencies](#dependencies)
- [Quick start](#quick-start)
- [Structure](#structure)
- [Plugins](#plugins)
- [Keymaps](#keymaps)
- [Indentation](#indentation)
- [Customizing](#customizing)

## Dependencies

| What | Required | Why | If missing |
|---|---|---|---|
| Neovim **0.11+** | yes | uses `vim.lsp.config`/`vim.lsp.enable`, `vim.diagnostic.jump` — none of these exist before 0.11 | the config won't start |
| `git` | yes | lazy.nvim installs and updates plugins via `git clone` | nothing to install plugins with |
| C compiler (`cc`/`gcc`/`clang`) | yes | treesitter builds parsers from source on `:TSUpdate` | syntax highlighting and treesitter-based indent won't work |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | yes | snacks.picker needs it for `<leader>fg`, todo-comments for `<leader>xt` | `<leader>fg`, `<leader>sr`, `<leader>xt`, and other search stop working |
| [fd](https://github.com/sharkdp/fd) | yes | fast file search for snacks.picker and venv-selector | venv won't auto-discover itself, `find_files` falls back to something slow or breaks |
| Node.js + npm | yes | Mason installs `ts_ls`, `prettier`, `sqls`, etc. through it | some LSP servers and formatters won't install |
| [lazygit](https://github.com/jesseduffield/lazygit) | no | the git TUI behind `<leader>gg` / `<leader>gl` / `<leader>gf` | those three mappings error out; gitsigns still works |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | no | the docker TUI behind `<leader>td` | that mapping opens an empty terminal |
| [lazysql](https://github.com/jorgerojas26/lazysql) | no | the database TUI behind `<leader>tl` | that mapping opens an empty terminal |
| [Nerd Font](https://www.nerdfonts.com/) in your terminal | no | icons in the dashboard, file tree, statusline, git/diagnostic signs | icons show as blank boxes or garbled glyphs; nothing else breaks |
| Python 3 + `pip` | no, but needed for Python projects | `basedpyright`/`ruff`/`black` don't need a system Python themselves, but project venvs do | venv-selector (`<leader>vs`) has nothing to find |

On Debian/Ubuntu, `fd` is often packaged as `fd-find` and only available as `fdfind` —
in that case pass `options = { fd_binary_name = "fdfind" }` to `venv-selector.nvim`
in `lua/plugins/lang.lua`.

![Dashboard](assets/dashboard.png)

## Quick start

```bash
git clone https://github.com/Danylo37/nvim-config ~/.config/nvim
nvim
```

On first launch, lazy.nvim clones itself and installs every plugin — wait for the
progress indicator in the corner to disappear. From there:

- `:Lazy` — plugin status, updates, startup profile
- `:Mason` — LSP server and formatter status; they install automatically on startup
- `:checkhealth` — start here if something isn't working

The dashboard opens by itself when you launch Neovim without a file — it also lists
its hotkeys: `f` files, `n` new file, `p` projects, `g` grep, `r` recent files,
`c` config, `L` Lazy, `M` Mason, `q` quit.

## Structure

```
init.lua                    -- entry point: options -> keymaps -> autocmds -> lazy.nvim bootstrap

lua/config/
  options.lua               -- vim.opt, indent, leader
  keymaps.lua               -- EVERY keymap in the config, one file
  autocmds.lua              -- indent overrides for lua/js/ts/html/css/json/yaml

lua/plugins/                -- one file per plugin theme
  lsp.lua                   -- mason, lspconfig, lspsaga, trouble
  completion.lua            -- nvim-cmp, LuaSnip, autopairs
  editor.lua                -- treesitter, flash, multicursor, harpoon, grug-far, conform, surround, comment, todo-comments, dirtytalk
  files.lua                 -- neo-tree
  git.lua                   -- gitsigns
  lang.lua                  -- venv-selector, jupytext, render-markdown
  ai.lua                    -- windsurf, copilot, claudecode
  terminal.lua              -- toggleterm, overseer
  snacks.lua                -- dashboard, picker, input, image, lazygit
  ui.lua                    -- theme, statusline, tabs, which-key, notifications, etc.

lua/util/
  init.lua                  -- project root lookup (util.root / util.find_root)
  lsp_undo.lua              -- undo multi-file LSP edits (<leader>ru)

after/queries/              -- `(identifier) @spell`: which names the spell checker reads
snippets/                   -- personal snippets, VSCode format (package.json lists the files)
spell/
  programming.words         -- extra dictionary words, compiled into `programming`
```

## Plugins

### LSP and code
| Plugin | What it's for |
|---|---|
| `mason.nvim` + `mason-lspconfig` + `mason-tool-installer` | installs and updates LSP servers and formatters |
| `nvim-lspconfig` | wires up LSP: `basedpyright` (Python), `ts_ls` (JS/TS), `html`, `cssls`, `lua_ls`, `sqls` |
| `lspsaga.nvim` | floating windows for definition/finder/rename/code action/line diagnostics |
| `trouble.nvim` | persistent panel for diagnostics/references/quickfix at the bottom |
| `conform.nvim` | formatting: stylua (Lua), ruff/black (Python), prettier (JS/TS/HTML/CSS/JSON/YAML/MD), sql_formatter |
| `nvim-treesitter` | syntax highlighting and indent via parsers (`main` branch, wired by hand) |

### Completion, editing and AI
| Plugin | What it's for |
|---|---|
| `nvim-cmp` + `cmp-nvim-lsp`/`cmp-buffer`/`cmp-path`/`cmp_luasnip` | autocompletion |
| `LuaSnip` + `friendly-snippets` | expands snippets, including the ones LSP completions carry |
| `nvim-autopairs` | auto-closes brackets/quotes |
| `vim-surround` | adds/changes/removes surrounding quotes and brackets (`ys`/`cs`/`ds`) |
| `mini.comment` | comments lines and motions with `gc` |
| `todo-comments.nvim` | highlights `TODO:`/`FIXME:`/`NOTE:` and lists them project-wide |
| `vim-dirtytalk` | wordlists of programming jargon, compiled into the `programming` dictionary |
| `windsurf.vim` | inline AI suggestions, no monthly quota (`:Codeium Auth` once) |
| `copilot.vim` | inline GitHub Copilot suggestions, installed but disabled by default |
| `claudecode.nvim` | Claude Code inside the editor, started with `--permission-mode auto` |

### Navigation and search
| Plugin | What it's for |
|---|---|
| `snacks.picker` | the one picker: files, grep, buffers, colorschemes, projects, and every `vim.ui.select` prompt |
| `neo-tree.nvim` | file tree |
| `harpoon` (branch `harpoon2`) | quick bookmarks for up to 6 files |
| `flash.nvim` | jump to visible text (`s`) |
| `grug-far.nvim` | search and replace across the project/file/selection |
| `multicursor.nvim` | multiple cursors |

### Git
| Plugin | What it's for |
|---|---|
| `gitsigns.nvim` | change markers in the gutter, stage/reset by hunk |
| `snacks.lazygit` | opens the `lazygit` TUI in a float, themed from the colorscheme |

### Languages
| Plugin | What it's for |
|---|---|
| `venv-selector.nvim` | picks and auto-activates a Python virtualenv (`.venv`) |
| `jupytext.nvim` | opens `.ipynb` files as plain python |
| `render-markdown.nvim` | renders markdown right in the buffer |

### UI and tools
| Plugin | What it's for |
|---|---|
| `tokyonight.nvim` | color scheme |
| `snacks.nvim` | dashboard with recent projects and recent files |
| `lualine.nvim` | statusline |
| `bufferline.nvim` | buffer tabs |
| `which-key.nvim` | shows hints for `<leader>` prefixes |
| `indent-blankline.nvim` | indent guides |
| `nvim-colorizer.lua` | highlights colors (`#fff`, `rgb(...)`) inline |
| `noice.nvim` + `nvim-notify` | nicer cmdline and notifications |
| `nvim-scrollbar` + `nvim-hlslens` | scrollbar with git/diagnostic/search marks, plus a match counter while searching |
| `snacks.input` | floating replacement for `vim.ui.input` prompts |
| `snacks.image` | inline image previews in the buffer and in the picker |
| `toggleterm.nvim` | built-in terminal |
| `overseer.nvim` | task runner: make/npm/cargo/shell tasks with a status list |
| `snacks.terminal` | opens the `lazydocker` and `lazysql` TUIs in a float |

## Keymaps

Leader is **Space**. The full list lives in `lua/config/keymaps.lua` (with `desc`, so
`which-key` shows it inside Neovim too — just press `<leader>` and wait).

### General
| Key | Action |
|---|---|
| `<Esc>` | Clear search highlight |
| `n` / `N` | Next / previous search match (with counter) |
| `*` / `#` / `g*` / `g#` | Search word under cursor |
| `<leader>R` | Save all and restart Neovim |
| `<leader>F` | Format buffer |
| `s` | Flash: jump to text |
| `gc` / `gcc` | Comment a motion / the current line |

### Completion and snippets
| Key | Action |
|---|---|
| `<C-Space>` | Open the completion menu |
| `<C-s>` | Open it with snippets only |
| `<C-j>` / `<C-k>` | Next / previous item (`<C-n>`/`<C-p>` do the same) |
| `<CR>` | Confirm (a snippet item expands, placeholders included) |
| `<Tab>` | Next placeholder while a snippet is active, otherwise accept the AI suggestion |
| `<S-Tab>` | Previous placeholder |

### Windows and buffers
| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Move between windows |
| `<A-h/j/k/l>` | Resize window |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bd` | Close buffer |
| `<leader>b1..9` | Go to buffer by number |

### `<leader>f` — Find / Files
| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | List buffers |
| `<leader>fh` | Search `:help` |
| `<leader>e` | Toggle file tree |
| `<leader>fe` | Focus file tree |

### `<leader>s` — Search & Replace
| Key | Action |
|---|---|
| `<leader>sr` | Search & replace across the project (or the selection, in visual mode) |
| `<leader>sw` | Search & replace the word under cursor |
| `<leader>sf` | Search & replace in the current file |

### LSP and code
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover docs |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>rN` | Rename symbol (project-wide) |
| `<leader>ru` | Undo the last LSP edit across all files |

### `<leader>x` — Diagnostics
| Key | Action |
|---|---|
| `de` | Line diagnostics |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>xx` | All diagnostics (Trouble) |
| `<leader>xw` | Buffer diagnostics |
| `<leader>xr` / `<leader>xd` | References / Definitions (Trouble) |
| `<leader>xq` / `<leader>xl` | Quickfix / Loclist |
| `<leader>xt` | TODO/FIXME comments across the project (Trouble) |
| `[t` / `]t` | Previous / next TODO comment |

### `<leader>g` — Git
| Key | Action |
|---|---|
| `]h` / `[h` | Next / previous hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gg` | Lazygit (project root) |
| `<leader>gl` | Lazygit log |
| `<leader>gf` | Lazygit history for the current file |

### `<leader>h` — Harpoon
| Key | Action |
|---|---|
| `<leader>ha` | Add file |
| `<leader>hd` | Remove file |
| `<C-e>` | Toggle Harpoon menu |
| `<leader>1..6` | Go to file by number |

### `<leader>m` — Multicursor
| Key | Action |
|---|---|
| `<C-n>` | Add cursor at next match |
| `<C-x>` | Skip match |
| `<C-Up>` / `<C-Down>` | Add cursor above / below |
| `<leader>ma` | Add cursor to every match |
| `<C-LeftMouse>` | Add cursor with the mouse |
| `<C-Left>` / `<C-Right>` / `<C-q>` | Navigate cursors (only while multiple cursors are active) |

### `<leader>t` — Terminal
| Key | Action |
|---|---|
| `<C-\>` | Toggle terminal (from normal, insert, or terminal mode) |
| `<C-q>` (terminal) | Leave terminal mode |
| `<leader>tt` | Terminal at the bottom |
| `<leader>tf` | Floating terminal |
| `<leader>ts` | Select terminal |
| `<leader>t1..9` | Terminal by number |
| `<leader>td` | Lazydocker (project root) |
| `<leader>tl` | Lazysql |
| `<leader>tp` | Run the current python file in a terminal |

### `<leader>o` — Overseer / Tasks
| Key | Action |
|---|---|
| `<leader>oo` | Toggle the task list |
| `<leader>or` | Run a task from a template (make, npm, cargo, …) |
| `<leader>oc` | Run a shell command as a task (project root) |
| `<leader>oa` | Action on the most recent task (restart, stop, open output) |
| `<leader>ot` | Action on a task picked from the list |

`<leader>or`, `<leader>oa` and `<leader>ot` open a small numbered box — list only, no
filter row: press `1`-`9` to run that entry outright, or `j`/`k` and `<CR>`. `/` brings
up the filter if the list is long.

On top of overseer's own templates, `lua/plugins/terminal.lua` registers three that
resolve their working directory upwards from the current file: `uvicorn dev` and
`pytest` (whole project or current file, both `uv run`) off the nearest
`pyproject.toml`, and `docker compose up`/`down` off the nearest compose file. Every
task opens its output in a dock as it starts and notifies when it ends, including
tasks stopped by hand.

### `<leader>a` — AI / Claude
| Key | Action |
|---|---|
| `<Tab>` (insert) | Accept AI suggestion (Windsurf, or Copilot when enabled) — an unfinished snippet takes it first |
| `<leader>ua` | Toggle inline completion (off silences both engines) |
| `<leader>aa` | Resume the last Claude Code session in this directory (or send selection) |
| `<leader>an` | Start a new Claude Code session |
| `<leader>af` | Focus Claude window |
| `<leader>ab` | Add current file to Claude's context |
| `<leader>am` | Select Claude model |

### Misc
| Key | Action |
|---|---|
| `<leader>ut` | Pick a colorscheme (with preview) |
| `<leader>uc` | Toggle colorizer |
| `<leader>us` | Toggle spell check in this buffer (on everywhere by default) |
| `z=` / `zg` | Suggest a correction / add the word to the dictionary |
| `]s` / `[s` | Next / previous misspelling |
| `<leader>vs` | Select Python virtualenv |
| `<leader>"` `'` `)` `]` `}` | Surround word with quotes/brackets |

## Snippets

Two sources, both through LuaSnip:

- **`friendly-snippets`** — a library covering every common language, loaded lazily per
  filetype. Its entries show up in the completion menu like any other item;
- **`snippets/`** in this repository — your own, same VSCode JSON format. A new file
  there has to be listed in `snippets/package.json`, then it is picked up on the next
  restart.

LSP completions carry snippet bodies of their own (that is what puts the parentheses and
arguments in after a function name); `nvim-cmp` hands those to LuaSnip too. Whatever the
source, `<Tab>` walks forward through the placeholders and `<S-Tab>` back, until you
leave the snippet region.

So that snippets don't drown in the rest of the menu, the `luasnip` source carries the
highest `priority` (added straight to an entry's match score, so a matching snippet ranks
above the LSP items), and the right-hand column names the source every item came from.
`<C-s>` skips the question entirely and opens a menu built from snippets alone.

## Spell checking

On in every buffer, in `en`, `uk`, `ru` and `programming`. What gets checked is
narrow on purpose, roughly what a JetBrains IDE checks:

- comments, strings and prose, via treesitter's own `@spell` captures;
- names *declared* in the file (functions, classes, parameters, variables), via
  `after/queries/<lang>/highlights.scm`. Imports and library calls are left alone:
  their spelling isn't yours to fix. Covered languages: Python, Lua, JS, TS, TSX;
- nothing at all in a buffer with no treesitter parser (`spelloptions=noplainbuffer`).

`spelloptions=camel` splits `userReponse`, and the dictionaries split on `_`, so
`test_get_produgts` flags `produgts` alone. Keywords and syntax are never checked —
they aren't captured as `@spell`.

Language jargon comes from `spell/programming.words` plus vim-dirtytalk's wordlists,
compiled into `~/.local/share/nvim/site/spell/programming.utf-8.spl`. Add a project's
vocabulary to that file and rerun `:Lazy build vim-dirtytalk`; use `zg` for one-off
words, they land in `~/.local/share/nvim/site/spell/en.utf-8.add` whatever the
language.

The `en`/`uk`/`ru` dictionaries download themselves on first use, or by hand from
`https://ftp.nluug.nl/pub/vim/runtime/spell/`. There is no `uk.utf-8.sug`, so `z=`
gives worse suggestions for Ukrainian.

## Indentation

4 spaces globally (`lua/config/options.lua`). 2-space overrides: Lua,
JS/TS/HTML/CSS/JSON/YAML (`lua/config/autocmds.lua`). Python has no override of its
own — Neovim's built-in `ftplugin/python.vim` already does 4 spaces (PEP8).

Where the indent of a *new* line comes from is Neovim's own `indent/<ft>.vim`.
nvim-treesitter's `indentexpr` is installed only for filetypes that have no built-in
(markdown, today): it recomputes the indent from the syntax tree, which undoes a manual
dedent — press `<CR>`, dedent out of a Python block, press `<CR>` again, and it would
pull you back in. `smartindent` is off for the same reason; it predates filetype indent
files and only ever applies where `indentexpr` is empty.

## Customizing

House rule: **keymaps live only in `keymaps.lua`**, plugin specs never set them
(the one exception is multicursor's `mc.addKeymapLayer` in `editor.lua` — that's the
plugin's own API, not a keymap). Keep that same split when editing a plugin or adding
your own.

**Add a plugin.** Specs are plain lazy.nvim tables, each in whichever theme file fits
(see [Structure](#structure)); if none fit, start a new file under `lua/plugins/` —
lazy.nvim picks it up on its own (`require("lazy").setup("plugins")` in `init.lua`
scans the whole folder). Minimal spec:

```lua
{
  "author/plugin.nvim",
  opts = {},         -- if the plugin supports setup(opts)
  -- event / cmd / ft / keys -- if the plugin should load lazily
}
```

**Add a keymap.** One `map(...)` call in `lua/config/keymaps.lua`, in whichever
section fits (they're split by comment headers). Shape:

```lua
map("n", "<leader>xy", function()
  require("plugin").some_function()
end, { desc = "What it does" })
```

`desc` is required — without it which-key won't show a hint. If you add a new
`<leader>X` prefix, list it in the table at the top of `keymaps.lua` and add a group
to `which-key.nvim`'s `spec` (`lua/plugins/ui.lua`).

**Add an LSP server.** In `lua/plugins/lsp.lua`: the server name goes in
`mason-lspconfig`'s `ensure_installed`, then `vim.lsp.config("name", { capabilities =
capabilities, ... })`, then into the `vim.lsp.enable({...})` list. The name is
whatever's in the [Mason registry](https://mason-registry.dev/registry/list), not
`lspconfig`'s.

**Add a formatter.** In `lua/plugins/editor.lua`, under `conform.nvim`: the filetype
and tool go in `formatters_by_ft`; if the tool isn't installed yet, add it to
`mason-tool-installer`'s `ensure_installed` (`lua/plugins/lsp.lua`) so Mason installs
it on the next launch.
