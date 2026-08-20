# Neovim

This repository's Neovim configuration is in `nvim/`. Home Manager links that
directory to `$XDG_CONFIG_HOME/nvim` through `home-manager/default.nix`, and
sets `EDITOR` to `nvim`. Do not edit the linked configuration in the home

## Requirements

Home Manager installs Neovim, Git, `make`, `ripgrep`, `fd`, Node.js, Prettier,
`markdownlint-cli`, and a JetBrains Mono Nerd Font. The configuration uses the
Nerd Font icons by default. `make` enables Telescope's native FZF extension
and LuaSnip's optional regex support.

`lazy.nvim` bootstraps itself into Neovim's data directory on the first start.
It installs the plugin set described in `nvim/lua/plugins/`; exact plugin
versions are recorded in `nvim/lazy-lock.json`.

## Layout

`nvim/init.lua` establishes Space as the leader and comma as the local leader,
then loads the modules in this order:

`lua/options.lua` configures the editor, folding, indentation, clipboard, and
UI settings. `lua/keymap.lua` holds general keymaps, while `lua/autocmds.lua`

`lua/languages/` contains automatically loaded filetype-specific settings; its
loader imports each Lua module in that directory.
`lua/lazyvim.lua` bootstraps `lazy.nvim` and imports plugin groups.
`lua/myvi/` holds shared helpers, including Monokai Pro theme selection.

Plugins are grouped under `lua/plugins/` as `theme`, `ui`, and `smart`.
Add a plugin specification to the appropriate group; `lazy.nvim` imports every
Lua file in each group containing an `init.lua`.

## Editor Behavior

The configuration enables relative and absolute line numbers, mouse support,
system clipboard integration, persistent undo, smart case search, live
substitution previews, cursor-line highlighting, and right/below split
placement. Tabs display at two columns, use smart indentation, and remain
literal tabs by default. `termguicolors` preserves the full RGB palette defined
by the active colorscheme. Tree-sitter expressions provide folds without
closing them when a file opens. `nvim-treesitter` is loaded at startup and
installs a parser on demand for any opened filetype that has a compatible parser
in its registry. The parser is downloaded and compiled once per language, then
Tree-sitter highlighting and indentation attach to every buffer waiting for it.
Filetypes without a registered parser continue using Neovim defaults; Ruby
retains Neovim's default indentation. Home Manager supplies the `tree-sitter`
CLI needed to compile and update parsers; apply the Home Manager configuration
before running `:TSUpdate` to update all installed parsers or `:TSInstall
<language>` to install one manually. After a parser attaches, its buffer resets
window-local expression folding so `vim.treesitter.foldexpr()` can use the
active syntax tree immediately; `VimEnter` covers files opened during startup,
and its fold cache is recalculated after attachment.

Monokai Pro is selected after plugins load. `auto-dark-mode.nvim` switches
between `monokai-pro-spectrum` for dark appearances and `monokai-pro-light`
for light appearances.

Lua buffers retain two-column indentation and use indent-based folding.
Markdown buffers use conceal level 2, render with `render-markdown.nvim`, and
run `markdownlint` on buffer entry, write, and insert leave.

## Language Tooling

Mason installs and configures `lua_ls`, `phpactor`, and `stylua`. Blink provides
completion from LSP, paths, snippets, open buffers, and LazyDev in Lua files;
LuaSnip provides snippet expansion. TypeScript uses `typescript-tools.nvim`,
and HTML buffers support Emmet wrapping with `<localleader>w`.

Conform formats on save with a 500 ms timeout. Lua uses `stylua`; HTML uses the
first available of `prettierd` or `prettier`. Other filetypes fall back to an
attached LSP except C and C++, where LSP formatting is intentionally disabled.

## Keymaps

Use `:WhichKey` or press `<Space>` and wait to discover the complete active
set. The most useful configured mappings are:

- `<Space>sf`, `<Space>sg`, `<Space>sw`: Find files, live grep, or search the
  word under the cursor.
- `<Space>sn`, `<Space><Space>`: Search Neovim configuration files or open
  buffers.
- `<Space>/`, `<Space>s/`: Search the current buffer or only open files.
- `gd`, `gr`, `gI`, `gD`: LSP definition, references, implementation, and
  declaration.
- `<Space>rn`, `<Space>ca`, `<Space>ds`: LSP rename, code action, and document
  symbols.
- `<Space>f`: Format the current buffer.
- `<Space>vd`: Toggle the Trouble diagnostics view.
- `<Space>vt`, `<Space>vo`, `<Space>vw`: Reveal the file tree, toggle outline,
  or toggle whitespace rendering.
- `<Space>hs`, `<Space>hr`, `<Space>hp`: Stage, reset, or preview the current
  Git hunk.
- `]c`, `[c`: Move to the next or previous Git hunk.
- `<Space>tt`, `<Space>tn`, `<Space>tf`: Toggle, open, or focus a shell
  terminal.
- `<Space>aa`, `<Space>ab`, `<Space>ad`, `<Space>av`: Ask OpenCode about the
  cursor or selection, buffer, diagnostics, or visible code.
- `<Space>as`: Select an OpenCode action. Ask accepts `@this`, `@buffer`,
  `@visible`, `@diagnostics`, `@buffers`, `@marks`, and `@quickfix` context
  placeholders.
- `<Space>at`, `<C-.>`: Toggle the OpenCode terminal on the right.
- `<C-w>` in the OpenCode terminal: Exit terminal mode, then enter a Neovim
  window command such as `h` to return to the editor.
- `<Space>an`, `<Space>ai`, `<Space>au`, `<Space>ar`: Start, interrupt, undo,
  or redo an OpenCode session action.
- `<Space>q`, `<Space>QQ`: Populate diagnostics in the location list or quit
  all windows.
- `<Esc><Esc>`: Leave terminal mode.

Markdown buffers also provide Obsidian commands with the comma local leader:
`,b` backlinks, `,l` links, `,n` new note, `,s` search, `,t` tags, and `,w`
workspace selection. The configured `notes` workspace is `~/Nextcloud/Notes/`.

## Maintenance

Use Neovim's plugin and tool managers to inspect or update the active setup:

```vim
" Inspect installed plugins and their load state.
:Lazy
" Update plugins and write the revised lazy-lock.json.
:Lazy update
" Inspect or install Mason-managed language tools.
:Mason
" Show Conform's formatter resolution for the current buffer.
:ConformInfo
```

After updating plugins, review and commit the resulting `nvim/lazy-lock.json`
with the configuration change. To apply a repository change through the shared
Home Manager setup, use the normal switch command for the consuming flake:

```sh
# Rebuild the user environment using the configured machine profile.
home-manager switch --flake /etc/nixos#cbrst
```

For local checkout testing, use the documented `dotfiles` input override in
[`docs/vscode.md`](vscode.md#apply-changes), substituting the relevant Home
Manager profile when it differs from `cbrst`.
