# OpenCode And Headroom

The shared Home Manager module installs OpenCode as a normal Nix package. It is
available independently of Headroom on every machine that imports
`home-manager/default.nix`.

Headroom is an optional AI proxy that is not packaged in Nixpkgs. On Linux, the
`headroom-bootstrap` Home Manager user service installs it with `uv` at
`~/.local/bin/headroom` and configures its persistent service. The OpenCode zsh
wrapper uses that proxy when it is healthy and otherwise launches OpenCode
directly.

## Use OpenCode

Open a new zsh session after applying the Home Manager configuration, then run:

```sh
# Start through Headroom when its proxy is healthy.
opencode

# Bypass the zsh wrapper and run the Nix-provided OpenCode CLI directly.
command opencode
```

The wrapper reports a warning and falls back to direct OpenCode if Headroom is
not installed, cannot start, or does not become healthy. This keeps OpenCode
usable when the optional proxy is unavailable.

## Use OpenCode In Neovim

Neovim uses `opencode.nvim` and starts OpenCode as `opencode --port` in a
right-side Snacks terminal. The plugin sends buffer and visual-selection
context to that server, and Neovim presents OpenCode edit requests for review.

| Mapping | Modes | Action |
| --- | --- | --- |
| `<leader>aa` | Normal, visual | Ask OpenCode about the cursor or selection |
| `<leader>as` | Normal, visual | Select an OpenCode action |
| `<leader>at` | Normal | Toggle the OpenCode terminal |
| `<leader>an` | Normal | Start a new OpenCode session |
| `<leader>ai` | Normal | Interrupt the active OpenCode request |
| `<leader>au` | Normal | Undo the last OpenCode change |
| `<leader>ar` | Normal | Redo the last undone OpenCode change |
| `<C-.>` | Normal, terminal | Toggle the OpenCode terminal |

The `<leader>a` group is listed as **AI / OpenCode** by which-key. When
OpenCode requests an edit, use its diff view to accept (`da`), reject (`dr`),
or work hunk-by-hunk (`dp`/`do`).

## Use Snacks Terminals

Snacks supplies the terminal UI for OpenCode and general shell work. The
`<leader>t` which-key group contains the terminal mappings:

| Mapping | Modes | Action |
| --- | --- | --- |
| `<leader>tt` | Normal, terminal | Toggle the default shell terminal |
| `<leader>tn` | Normal | Open a new shell terminal |
| `<leader>tf` | Normal, terminal | Focus or hide the default shell terminal |

## Completion In Neovim

The Neovim configuration uses `blink.cmp` rather than `nvim-cmp`. Blink
provides LSP, path, LuaSnip, buffer, and lazydev completion; its standard
`<C-n>`, `<C-p>`, `<C-y>`, and `<C-Space>` mappings remain available. `<C-l>`
and `<C-h>` move forward and backward through LuaSnip placeholders.

OpenCode's Ask input uses Blink's LSP and buffer sources through the
`opencode_ask` filetype. Snacks input and picker provide the prompt and action
selection interfaces, so do not disable either module while using
`opencode.nvim`.

## Check Headroom

On Linux, inspect the bootstrap and persistent services with:

```sh
# Confirm that the bootstrap service installed and configured Headroom.
systemctl --user status headroom-bootstrap.service

# Check Headroom's own persistent-service installation.
headroom install status

# Diagnose a configured Headroom installation.
headroom doctor
```

If `headroom` is unavailable after a successful switch, start the bootstrap
service again and inspect its journal:

```sh
# Retry the one-shot installation service.
systemctl --user restart headroom-bootstrap.service

# Show installation errors from the current boot.
journalctl --user -u headroom-bootstrap.service -b
```

The bootstrap checks `headroom --version` before every configuration switch. If
the uv-managed wrapper has a missing Python interpreter, it reinstalls Headroom
automatically; rerun the service only when that reinstall itself fails.

## Maintain The Integration

The OpenCode executable belongs in `home.packages` in
`home-manager/default.nix`; do not replace it with a mutable global npm install.
The zsh wrapper lives at `zsh/functions/opencode` and is deployed through the
same module with the rest of the zsh support files.

The `programs.zsh` activation settings also use normal priority so Home
Manager's generated `.zshrc` always sources the shared wrapper. Use an explicit
machine-level definition or `lib.mkForce` only when a machine must replace that
shared shell initialization.

## Group Unstaged Commits

The shared `group-unstaged-commits` skill organizes the current repository's
unstaged work into small, related commits. It preserves existing staged changes
unless explicitly asked to include them, reviews untracked files before staging
them, and never discards work. Ask OpenCode to "group and commit my unstaged
changes" or explicitly invoke the `group-unstaged-commits` skill.

Each commit receives a concise conventional-style subject and a detailed body
based on the reviewed diff. The body explains the behavior changed,
implementation details, and actual validation; it must not use placeholder
text, repeat the subject, or make unsupported claims. Ambiguous groups or files
that contain mixed concerns require confirmation before anything is staged.

The skill is stored at `opencode/skills/group-unstaged-commits/SKILL.md` and
Home Manager deploys it to `$XDG_CONFIG_HOME/opencode/skills`. To change its
workflow, edit that source file and apply the shared module:

```sh
# Test the updated shared OpenCode configuration from this checkout.
home-manager switch --flake /etc/nixos#cbrst \
  --override-input dotfiles path:/home/cbrst/Projects/config
```

Quit and restart OpenCode after the switch; skills are loaded only when
OpenCode starts.

The shared `.zshrc` loads `env.zsh` before Zim initialization so the wrapper's
runtime directories are available in interactive shells as well as login shells.

The shared `home.packages` list intentionally uses normal Nix module priority.
This lets it merge with package lists contributed by optional modules such as
Noctalia; do not wrap the whole list in `lib.mkDefault`, or those modules can
discard the shared OpenCode package.

The OpenCode MCP configuration is managed as
`opencode/opencode.jsonc`. The Home Manager module rewrites its Headroom binary
path to the current home directory. After changing it, apply the shared module:

```sh
# Test this uncommitted checkout on the NixOS machine.
home-manager switch --flake /etc/nixos#cbrst \
  --override-input dotfiles path:/home/cbrst/Projects/config
```

Do not use `headroom wrap opencode` or use `headroom install` to target
OpenCode. Those flows can rewrite the declarative OpenCode configuration.

After changing the Neovim plugin specifications, synchronize plugins and check
the OpenCode integration:

```sh
# Install, remove, and lock Neovim plugins from this configuration.
nvim --headless "+Lazy sync" +qa

# Confirm that opencode.nvim can reach or start its OpenCode server.
nvim "+checkhealth opencode"

# Inspect Blink completion providers, including the OpenCode Ask source.
nvim "+BlinkCmp status"
```
