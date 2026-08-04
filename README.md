# nvim-config

Личный конфиг Neovim на [lazy.nvim](https://github.com/folke/lazy.nvim): LSP из коробки
для Python/TS/JS/HTML/CSS/Lua/SQL, telescope как единственный пикер, дашборд с недавними
проектами, AI-ассистенты (Copilot + Claude Code) и все шорткаты в одном файле.

## Оглавление

- [Зависимости](#зависимости)
- [Быстрый старт](#быстрый-старт)
- [Структура](#структура)
- [Плагины](#плагины)
- [Шорткаты](#шорткаты)
- [Отступы](#отступы)
- [Кастомизация](#кастомизация)

## Зависимости

| Что | Обязательно | Зачем | Если нет |
|---|---|---|---|
| Neovim **0.11+** | да | `vim.lsp.config`/`vim.lsp.enable`, `vim.diagnostic.jump` — этих API раньше 0.11 нет | конфиг не запустится |
| `git` | да | lazy.nvim ставит и обновляет плагины через `git clone` | нечем поставить плагины |
| C-компилятор (`cc`/`gcc`/`clang`) | да | treesitter собирает парсеры из исходников при `:TSUpdate` | подсветка синтаксиса и отступы через treesitter не заработают |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | да | нужен telescope для `live_grep` | `<leader>fg`, `<leader>sr` и другой поиск не будут работать |
| [fd](https://github.com/sharkdp/fd) | да | быстрый поиск файлов у telescope и venv-selector | venv не найдётся сам, `find_files` упадёт на медленный фолбэк или сломается |
| Node.js + npm | да | под них Mason ставит `ts_ls`, `prettier`, `sqls` и т.п. | часть LSP-серверов и форматтеров не установится |
| [Nerd Font](https://www.nerdfonts.com/) в терминале | нет | иконки в дашборде, дереве файлов, статусбаре, значках git/диагностики | вместо иконок — пустые клетки или кракозябры, функционал не страдает |
| Python 3 + `pip` | нет, но нужен для Python-проектов | `basedpyright`/`ruff`/`black` сами по себе не требуют системного Python, а вот проектные venv — да | venv-selector (`<leader>vs`) нечего будет находить |

На Debian/Ubuntu `fd` часто ставится как пакет `fd-find` и доступен под именем `fdfind` —
тогда в `lua/plugins/lang.lua` для `venv-selector.nvim` нужно передать
`options = { fd_binary_name = "fdfind" }`.

## Быстрый старт

```bash
git clone <repo-url> ~/.config/nvim
nvim
```

При первом запуске lazy.nvim сам себя склонирует и поставит все плагины — подождите,
пока в углу не пропадёт прогресс. Дальше:

- `:Lazy` — статус плагинов, обновления, профиль запуска
- `:Mason` — статус LSP-серверов и форматтеров, довешиваются автоматически при старте
- `:checkhealth` — если что-то не работает, начните отсюда

Дашборд открывается сам при запуске без файла — на нём же список горячих клавиш (`f`/`p`/`g`/`r`/`c`).

## Структура

```
init.lua                    -- точка входа: options → keymaps → autocmds → бутстрап lazy.nvim

lua/config/
  options.lua                -- vim.opt, отступы, leader
  keymaps.lua                -- ВСЕ шорткаты конфига, единый файл
  autocmds.lua                -- отступы для lua/js/ts/html/css/json/yaml

lua/plugins/                 -- один файл на тематическую группу плагинов
  lsp.lua                     -- mason, lspconfig, lspsaga, trouble
  completion.lua               -- nvim-cmp, автозакрытие скобок
  editor.lua                  -- treesitter, flash, multicursor, harpoon, grug-far, conform
  files.lua                   -- neo-tree, telescope
  git.lua                     -- gitsigns
  lang.lua                    -- venv-selector, jupytext, render-markdown
  ai.lua                      -- copilot, claudecode
  terminal.lua                -- toggleterm
  snacks.lua                  -- дашборд и его пикер проектов
  ui.lua                      -- тема, статусбар, вкладки, which-key, уведомления и т.д.

lua/util/
  init.lua                    -- поиск корня проекта (util.root / util.find_root)
  lsp_undo.lua                 -- отмена multi-file LSP-правок (<leader>ru)
```

## Плагины

### LSP и код
| Плагин | Зачем |
|---|---|
| `mason.nvim` + `mason-lspconfig` + `mason-tool-installer` | ставит и обновляет LSP-серверы и форматтеры |
| `nvim-lspconfig` | подключает LSP: `basedpyright` (Python), `ts_ls` (JS/TS), `html`, `cssls`, `lua_ls`, `sqls` |
| `lspsaga.nvim` | всплывающие окна для definition/finder/rename/code action/диагностики строки |
| `trouble.nvim` | постоянная панель диагностики/references/quickfix внизу экрана |
| `conform.nvim` | форматирование: stylua (Lua), ruff/black (Python), prettier (JS/TS/HTML/CSS/JSON/YAML/MD), sql_formatter |
| `nvim-treesitter` | подсветка синтаксиса и отступы через парсеры (ветка `master`) |

### Автодополнение и AI
| Плагин | Зачем |
|---|---|
| `nvim-cmp` + `cmp-nvim-lsp`/`cmp-buffer`/`cmp-path` | автодополнение |
| `nvim-autopairs` | автозакрытие скобок/кавычек |
| `copilot.vim` | инлайн-подсказки GitHub Copilot |
| `claudecode.nvim` | Claude Code прямо в редакторе |

### Навигация и поиск
| Плагин | Зачем |
|---|---|
| `telescope.nvim` | единственный пикер: файлы, grep, буферы, темы |
| `neo-tree.nvim` | дерево файлов |
| `harpoon` (branch `harpoon2`) | быстрые закладки на 6 файлов |
| `flash.nvim` | прыжки по видимому тексту (`s`) |
| `grug-far.nvim` | поиск и замена по проекту/файлу/выделению |
| `multicursor.nvim` | мультикурсор |

### Git
| Плагин | Зачем |
|---|---|
| `gitsigns.nvim` | значки изменений на полях, staging/reset по хункам |

### Языки
| Плагин | Зачем |
|---|---|
| `venv-selector.nvim` | выбор и автоактивация Python-окружения (`.venv`) |
| `jupytext.nvim` | открывает `.ipynb` как обычный python-файл |
| `render-markdown.nvim` | рендер markdown прямо в буфере |

### UI
| Плагин | Зачем |
|---|---|
| `tokyonight.nvim` | цветовая схема |
| `snacks.nvim` | дашборд со списком проектов и недавних файлов |
| `lualine.nvim` | статусбар |
| `bufferline.nvim` | вкладки буферов |
| `which-key.nvim` | подсказки по префиксам `<leader>` |
| `indent-blankline.nvim` | направляющие отступов |
| `nvim-colorizer.lua` | подсветка цветов (`#fff`, `rgb(...)`) прямо в тексте |
| `noice.nvim` + `nvim-notify` | красивые командная строка и уведомления |
| `nvim-scrollbar` + `nvim-hlslens` | скроллбар с метками git/диагностики/поиска и счётчик совпадений при поиске |
| `toggleterm.nvim` | встроенный терминал |

## Шорткаты

Leader — **Space**. Полный список живёт в `lua/config/keymaps.lua` (с `desc`, так что
`which-key` подскажет их и в самом Neovim — просто нажмите `<leader>` и подождите).

### Общее
| Клавиша | Действие |
|---|---|
| `<Esc>` | Снять подсветку поиска |
| `n` / `N` | Следующее / предыдущее совпадение поиска (со счётчиком) |
| `*` / `#` | Поиск слова под курсором |
| `<leader>R` | Сохранить всё и перезапустить Neovim |
| `<leader>F` | Отформатировать буфер |
| `s` | Flash: прыжок по тексту |

### Окна и буферы
| Клавиша | Действие |
|---|---|
| `<C-h/j/k/l>` | Перейти между окнами |
| `<A-h/j/k/l>` | Изменить размер окна |
| `<S-h>` / `<S-l>` | Предыдущий / следующий буфер |
| `<leader>bd` | Закрыть буфер |
| `<leader>b1..9` | Перейти к буферу по номеру |

### `<leader>f` — Find / Files
| Клавиша | Действие |
|---|---|
| `<leader>ff` | Найти файл |
| `<leader>fg` | Live grep |
| `<leader>fb` | Список буферов |
| `<leader>fh` | Поиск по `:help` |
| `<leader>e` | Дерево файлов (toggle) |
| `<leader>fe` | Фокус на дереве файлов |

### `<leader>s` — Search & Replace
| Клавиша | Действие |
|---|---|
| `<leader>sr` | Поиск и замена по проекту (или по выделению в visual) |
| `<leader>sw` | Поиск и замена слова под курсором |
| `<leader>sf` | Поиск и замена в текущем файле |

### LSP и код
| Клавиша | Действие |
|---|---|
| `gd` | Перейти к определению |
| `gr` | Найти использования |
| `K` | Документация под курсором |
| `<leader>ca` | Code action |
| `<leader>rn` | Переименовать символ |
| `<leader>rN` | Переименовать символ (по всему проекту) |
| `<leader>ru` | Отменить последнюю LSP-правку во всех файлах |

### `<leader>x` — Диагностика
| Клавиша | Действие |
|---|---|
| `de` | Диагностика текущей строки |
| `[d` / `]d` | Предыдущая / следующая диагностика |
| `<leader>xx` | Все диагностики (Trouble) |
| `<leader>xw` | Диагностика текущего буфера |
| `<leader>xr` / `<leader>xd` | References / Definitions (Trouble) |
| `<leader>xq` / `<leader>xl` | Quickfix / Loclist |

### `<leader>g` — Git
| Клавиша | Действие |
|---|---|
| `]h` / `[h` | Следующий / предыдущий хунк |
| `<leader>gs` | Застейджить хунк |
| `<leader>gr` | Откатить хунк |
| `<leader>gp` | Превью хунка |

### `<leader>h` — Harpoon
| Клавиша | Действие |
|---|---|
| `<leader>ha` | Добавить файл |
| `<leader>hd` | Убрать файл |
| `<C-e>` | Меню Harpoon |
| `<leader>1..6` | Перейти к файлу по номеру |

### `<leader>m` — Multicursor
| Клавиша | Действие |
|---|---|
| `<C-n>` | Добавить курсор на следующее совпадение |
| `<C-x>` | Пропустить совпадение |
| `<C-Up>` / `<C-Down>` | Добавить курсор строкой выше / ниже |
| `<leader>ma` | Курсор на все совпадения |
| `<C-Left>` / `<C-Right>` / `<C-q>` | Навигация между курсорами (пока курсоров несколько) |

### `<leader>t` — Terminal
| Клавиша | Действие |
|---|---|
| `<C-\>` | Открыть/закрыть терминал (из normal, insert, terminal) |
| `<leader>tt` | Терминал снизу |
| `<leader>tf` | Плавающий терминал |
| `<leader>ts` | Выбрать терминал |
| `<leader>t1..9` | Терминал по номеру |
| `<leader>tp` | Запустить текущий python-файл в терминале |

### `<leader>a` — AI / Claude
| Клавиша | Действие |
|---|---|
| `<C-y>` (insert) | Принять подсказку Copilot |
| `<leader>aa` | Открыть Claude Code (или отправить выделение) |
| `<leader>af` | Фокус на окне Claude |
| `<leader>ab` | Добавить текущий файл в контекст Claude |
| `<leader>am` | Выбрать модель Claude |

### Прочее
| Клавиша | Действие |
|---|---|
| `<leader>ut` | Выбрать цветовую схему (с превью) |
| `<leader>uc` | Toggle подсветки цветов |
| `<leader>vs` | Выбрать Python-окружение |
| `<leader>"` `'` `)` `]` `}` | Обернуть слово в кавычки/скобки |

## Отступы

Глобально — 4 пробела (`lua/config/options.lua`). Исключения на 2 пробела:
Lua, JS/TS/HTML/CSS/JSON/YAML (`lua/config/autocmds.lua`). Python отдельно не задан —
за 4 пробела отвечает встроенный `ftplugin/python.vim` (PEP8).

## Кастомизация

Правило конфига: **шорткаты — только в `keymaps.lua`**, спеки плагинов их не задают
(единственное исключение — `mc.addKeymapLayer` в `editor.lua`, это API самого
multicursor.nvim, а не keymap). Если правите чужой плагин или добавляете свой —
держите этот же порядок.

**Добавить плагин.** Спеки — обычные таблицы lazy.nvim, каждая в файле нужной
тематической группы (см. [Структура](#структура)); если группа не подходит ни под одну —
можно завести новый файл в `lua/plugins/`, lazy.nvim подхватит его сам
(`require("lazy").setup("plugins")` в `init.lua` сканирует всю папку). Минимальный спек:

```lua
{
  "автор/плагин.nvim",
  opts = {},         -- если плагин поддерживает setup(opts)
  -- event / cmd / ft / keys — если плагин должен грузиться лениво
}
```

**Добавить шорткат.** Один `map(...)` в `lua/config/keymaps.lua`, в секцию по смыслу
(они разделены комментариями-разделителями). Формат:

```lua
map("n", "<leader>xy", function()
  require("плагин").какая_то_функция()
end, { desc = "Что делает" })
```

`desc` обязателен — без него which-key не покажет подсказку. Если добавляете новый
префикс `<leader>X`, впишите его в таблицу в шапке `keymaps.lua` и добавьте группу
в `spec` у `which-key.nvim` (`lua/plugins/ui.lua`).

**Добавить LSP-сервер.** В `lua/plugins/lsp.lua`: имя сервера — в `ensure_installed` у
`mason-lspconfig`, затем `vim.lsp.config("имя", { capabilities = capabilities, ... })`
и в список `vim.lsp.enable({...})`. Имя сервера — то, что в
[реестре Mason](https://mason-registry.dev/registry/list), а не в `lspconfig`.

**Добавить форматтер.** В `lua/plugins/editor.lua`, у `conform.nvim`: filetype и
инструмент — в `formatters_by_ft`; сам инструмент, если его ещё нет в системе —
в `ensure_installed` у `mason-tool-installer` (`lua/plugins/lsp.lua`), чтобы Mason
поставил его сам при следующем запуске.
