# config

## Home Manager

`home-manager/default.nix` is the shared Home Manager module for NixOS, other
Linux distributions, and macOS. This repository intentionally remains a
non-flake input; each machine flake supplies its own pinned inputs and imports
the module:

```nix
modules = [
  "${inputs.dotfiles}/home-manager/default.nix"
  ./hosts/home.nix
];
```

See `home-manager/example-flake.nix` for a complete standalone consumer.
The consuming flake must pass `inputs` and a `machine` attrset through
`extraSpecialArgs`. `machine.user` is required; these fields are optional:

| Field | Default | Purpose |
| --- | --- | --- |
| `hostName` | none | Machine identity and logging. |
| `homeDirectory` | `/home/<user>` on Linux, `/Users/<user>` on macOS | Home path. |
| `terminal` | `ghostty` | `TERMINAL` value. |
| `sshAuthSock` | `$HOME/.1password/agent.sock` | SSH agent socket. |
| `ghostty` | `""` | Machine-local Ghostty text written to `ghostty/machine`. |
| `niri` | `false` | Installs and deploys the Niri session with Noctalia on Linux. |
| `noctalia` | `false` | Enables Noctalia on Linux. |
| `firefoxSystem` | `false` | Leaves Firefox package ownership to NixOS while Home Manager configures its profile. |
| `firefoxProfilePath` | `"default"` | Existing Firefox profile path to preserve. |
| `stateVersion` | `26.05` | Home Manager state version. |

Simple values come from `machine`; machine flakes can add a Home Manager module
after the shared module for deep overrides. Shared settings use `mkDefault`.
Linux-only features are conditional, so macOS consumers can evaluate the
module; macOS-specific services such as `launchd.agents` belong in a machine
override module. Keep secrets, Ghostty themes, and Ghostty machine overrides in
the consuming machine repository.

On the NixOS machine, apply it with:

```sh
home-manager switch --flake /etc/nixos#cbrst
```

For local shared-configuration tests and daily NixOS or Home Manager workflows,
use [`nixie`](docs/nixie.md).

## Legacy Setup

`setup.sh` remains for dependencies and configuration modules that are not yet
Home Manager-owned. The Home Manager-owned modules are no longer linked,
pulled, or provisioned with a Headroom service by it.

```sh
./setup.sh install
```

Useful non-mutating checks:

```sh
./setup.sh check
./setup.sh install --dry-run --optional
```

Config-only commands are available too:

```sh
./setup.sh link tridactyl thefuck userscripts
./setup.sh unlink
```

## Hyprland

Home Manager deploys the `hypr` and `noctalia` modules. Set `machine.noctalia =
true` in the consuming machine flake to enable Noctalia as the Hyprland shell:

```sh
home-manager switch --flake /etc/nixos#cbrst
```

`hypr/hyprland.lua` is a native Hyprland Lua configuration. It sets Ghostty as
`TERMINAL` and also defines `BROWSER`, `FILE_MANAGER`, `EDITOR`, and `VISUAL`.
The Super+Return, Super+B, and Super+E bindings consume those values.
Noctalia provides the bar, launcher (Super+Space), control center (Super+C),
notifications, wallpaper, lock screen, and OSDs. Add machine-specific monitor
rules with `hl.monitor(...)` in `hypr/hyprland.lua`. The shared Linux profile
uses the Bibata Modern Ice cursor; see [`docs/hyprland.md`](docs/hyprland.md)
for cursor maintenance and session reload steps.

## Firefox

Firefox extensions, the Tridactyl configuration, and GitHub-backed userscript
updates are documented in [`docs/firefox.md`](docs/firefox.md). NixOS systems
that install Firefox themselves should set `machine.firefoxSystem = true`.

## Niri

Set `machine.niri = true` to install Niri, deploy `niri/config.kdl`, and enable
Noctalia as its shell. The Niri profile starts Noctalia and applies a background
blur to its layer surfaces and pop-ups. See [`docs/niri.md`](docs/niri.md) for
bindings, reload instructions, and monitor overrides.

Noctalia's shared bar layout and appearance are documented in
[`docs/noctalia.md`](docs/noctalia.md).

## GTK

The shared Linux GTK defaults and machine-specific font override pattern are
documented in [`docs/gtk.md`](docs/gtk.md).

## Themes

OpenCode, Ghostty, and Neovim share Monokai Pro Spectrum in dark mode and
Monokai Pro Light in light mode. See [`docs/themes.md`](docs/themes.md) for
palette sources, deployment, and maintenance.

Dependency installation currently targets macOS through Homebrew and Arch-based
Linux through pacman. On macOS, system or Command Line Tools commands such as
`bash`, `curl`, `git`, `make`, and `zsh` are checked but not installed through
Homebrew, so Brew does not shadow Apple-managed components.

## AI coding

The Linux Home Manager module installs the Headroom CLI with `uv` and provisions
its persistent user service. OpenCode itself is installed independently as a
Nix package, so it remains available if Headroom is unavailable. macOS machines
can add an equivalent `launchd.agents` definition in their machine-specific
override. In zsh, `opencode` starts that proxy if necessary, waits for it to
become healthy, and falls back to direct OpenCode if the proxy cannot run.

OpenCode routing and its Headroom MCP server are defined only in the checked-in
`opencode/opencode.jsonc`; the launcher never lets Headroom rewrite OpenCode
configuration. That config enables only the Headroom GPT-5.6 and local Qwen3
providers. Restart OpenCode after changing that file.

```sh
opencode
headroom install status
headroom doctor
headroom savings
```

Do not run `headroom wrap opencode` or target OpenCode with `headroom install`:
both flows can rewrite OpenCode configuration. The `opencode` module contains
the portable provider and MCP settings; local credentials and plugin
dependencies are intentionally ignored.

See [`docs/opencode.md`](docs/opencode.md) for the OpenCode and Headroom
architecture, operation, recovery, and maintenance commands.
