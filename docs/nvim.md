# Neovim

This repository's Neovim configuration is in `nvim/`. Home Manager links that
directory to `$XDG_CONFIG_HOME/nvim`, sets `EDITOR` to `nvim`, and installs
Neovim, its plugins, and supporting command-line tools. Edit the repository
files rather than the linked configuration in the home directory.

## Plugin Management

Home Manager owns every Neovim plugin through `programs.neovim.plugins` in
`home-manager/default.nix`. Plugins are immutable Nix store inputs selected by
the consuming flake's `nixpkgs` lock; no plugin manager downloads or updates
plugins at runtime.

The configuration starts every installed plugin eagerly. This provides a simple
startup baseline; add targeted lazy loading only after measuring startup time.
Update plugin revisions by updating the consumer flake's `nixpkgs` input,
reviewing the resulting lockfile change, and applying Home Manager.

Home Manager supplies every Neovim language tool through
`programs.neovim.extraPackages`: `emmet-language-server`,
`lua-language-server`, `phpactor`, and `stylua`. This avoids Mason's generic
Linux release binaries, which cannot run on NixOS when dynamically linked.
Emmet replaces `nvim-emmet` with LSP completion in HTML, CSS, JavaScript/React,
Sass, Less, Pug, and related buffers. The old visual wrap-with-abbreviation
mapping, `<localleader>w`, is not provided by the language server.

`lua/plugins/lsp/init.lua` configures each server declared in
`lua/config/lsp_servers.lua` only when its command exists in Neovim's PATH. A
single startup warning lists missing tools instead of attempting a failing LSP
launch. To add a server, add its server-specific configuration there, add its
Nix package to `programs.neovim.extraPackages`, then apply Home Manager.

## CodeCompanion

CodeCompanion provides the Neovim AI interface and uses its built-in OpenCode
ACP adapter for chat. OpenCode therefore retains its normal CLI authentication,
MCP servers, skills, sub-agents, provider settings, and project sessions; the
old `opencode.nvim` server and Snacks-terminal integration are not used.

- `<Space>aa`: Toggle the CodeCompanion chat. In visual mode, add the selection
  to the active chat.
- `<Space>as`: Open the CodeCompanion action palette.
- `<Space>ac`: Start an inline CodeCompanion action for the current buffer or
  selection.
- `<Space>ar`: Open CodeCompanion's code-review workflow.

The configured adapter is `opencode`. Use `:CodeCompanionChat` to open a new
chat or `:CodeCompanionChat Toggle` to show the active chat. In a chat, use
OpenCode's advertised ACP slash commands and CodeCompanion editor context,
tools, and action palette as needed.

## Layout

`nvim/init.lua` is intentionally only the startup sequence:

- `lua/config/globals.lua` sets leader keys and the Nerd Font capability.
- `lua/options.lua`, `lua/keymap.lua`, and `lua/autocmds.lua` define editor-wide
  options, mappings, and autocommands.
- `lua/languages/init.lua` explicitly enables each filetype module.
- `lua/plugins/init.lua` configures all installed plugins in eager order:
  foundational UI, completion, LSP, then integrations.
- `lua/config/theme.lua` selects the shared theme family after plugin setup.
- `lua/config/util.lua` contains shared helpers for visual-selection commands.

Plugin configuration modules are grouped by responsibility:

- `lua/plugins/theme/` controls colorscheme selection.
- `lua/plugins/ui/` provides interface and navigation tools.
- `lua/plugins/smart/` contains syntax, formatting, linting, completion, and
  CodeCompanion.
- `lua/plugins/lsp/` configures declarative LSP servers and attach-time mappings.
- `lua/plugins/integrations/` contains external workflows such as Overseer.

Add a plugin in two places: add its Nix package to
`programs.neovim.plugins`, then add its eager setup module to the appropriate
group and call it from `lua/plugins/init.lua`.

## Mini Modules

`mini.nvim` provides small editing and UI primitives:

- `mini.ai` and `mini.surround` provide textobjects and surroundings.
- `mini.pairs` closes delimiters typed in insert mode. Blink retains completion-
  time `auto_brackets` for accepted callable completions.
- `mini.indentscope` renders indentation guides.
- `mini.animate` provides cursor-motion animation only.
- `heirline.nvim` provides a Moody-inspired statusline: a colored mode tab,
  filename, Git worktree state, diagnostics, filetype, and cursor position.
- `mini.icons` replaces `nvim-web-devicons`. It mocks the devicons API so
  Telescope continues to render file icons.

Neo-tree provides the persistent file explorer. `\\` and `<Space>vt` toggle it
and reveal the current buffer's location.

The statusline uses a lighter neutral surface than the active theme's editor
bar. Dropbar instead uses the editor background, including its active path
items and folder icons; active context is conveyed by foreground color rather
than a contrasting folder background. The command line uses a slightly darker
dedicated surface with muted text.
`lua/config/ui_colors.lua` reapplies these surfaces after every colorscheme
change, including automatic light/dark switching.

Set `vim.g.have_nerd_font = false` in `lua/config/globals.lua` when the active
terminal cannot display Nerd Font glyphs. Mini then uses ASCII icons.

## Editor Behavior

The configuration enables relative and absolute line numbers, mouse support,
system clipboard integration, persistent undo, smart-case search, live
substitution previews, cursor-line highlighting, and right/below split
placement. Tabs display at two columns, use smart indentation, and remain
literal tabs by default.

Tree-sitter expressions provide folds without closing them when a file opens.
`nvim-treesitter` installs a parser on demand for opened filetypes with a
compatible parser. Parsers are compiled once per language in Neovim's writable
data directory; use `:TSUpdate` to update installed parsers or `:TSInstall
<language>` to install one manually.

The family selected by `theme` is applied after plugins load; the default is
meowsoot. `auto-dark-mode.nvim` switches between its dark and light variants,
using meowsoot Night and Dawn by default. Lua buffers retain two-column
indentation and use
indent-based folding. Markdown windows use conceal level 2, render with
`render-markdown.nvim`, and run `markdownlint` on buffer entry, write, and
insert leave.

## Language Tooling

Blink provides completion from LSP, paths, snippets, open buffers, and LazyDev
in Lua files; LuaSnip provides snippet expansion. TypeScript uses
`typescript-tools.nvim`. Emmet completion is provided by the Nix-managed Emmet
language server.

Conform formats on save with a 500 ms timeout. Lua uses `stylua`; HTML uses the
first available of `prettierd` or `prettier`. Other filetypes fall back to an
attached LSP except C and C++, where LSP formatting is intentionally disabled.

## Maintenance

Use Neovim's runtime commands to inspect language tooling:

```vim
" Confirm the Nix-managed Lua language server is available to Neovim.
:!lua-language-server --version
" Inspect attached and configured language servers.
:checkhealth vim.lsp
" Show Conform's formatter resolution for the current buffer.
:ConformInfo
" Update all installed Tree-sitter parsers.
:TSUpdate
```

To update Neovim plugins, update the consuming flake's `nixpkgs` lock and apply
the revised Home Manager generation:

```sh
# Rebuild the user environment using the configured machine profile.
home-manager switch --flake /etc/nixos#cbrst@asgard
```

Alternatively, run `nixie update`, then `nixie home`, to update the consuming
flake's Nixpkgs pin and apply the locked Home Manager configuration.

For local checkout testing, use the documented `dotfiles` input override in
[`docs/vscode.md`](vscode.md#apply-changes), substituting the relevant Home
Manager profile when it differs from `cbrst`.
