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
