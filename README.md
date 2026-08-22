# config

## Home Manager

This repository is a flake that exposes a shared Home Manager module for NixOS,
other Linux distributions, and macOS. It owns user-profile dependencies
(Ghostty, Noctalia, and Pixibb) and composes focused modules for editors, VS
Code, and optional Linux desktop integration. Each consumer supplies Nixpkgs
and Home Manager, then makes the dotfiles follow that Nixpkgs:

```nix
modules = [
  inputs.dotfiles.homeManagerModules.default
  ./hosts/home.nix
];
```

See the standalone consumer examples:

- `home-manager/example-flake-nixos.nix`
- `home-manager/example-flake-linux.nix`
- `home-manager/example-flake-darwin.nix`

The consuming flake passes only a `machine` attrset through `extraSpecialArgs`.
`machine.user` is required; these fields are optional:

| Field | Default | Purpose |
| --- | --- | --- |
| `hostName` | none | Machine identity and logging. |
| `homeDirectory` | `/home/<user>` on Linux, `/Users/<user>` on macOS | Home path. |
| `terminal` | `ghostty` | `TERMINAL` value. |
| `sshAuthSock` | `$HOME/.1password/agent.sock` | SSH agent socket. |
| `ghostty` | `""` | Machine-local Ghostty text written to `ghostty/machine`. |
| `firefoxSystem` | `false` | Leaves Firefox package ownership to NixOS while Home Manager configures its profile. |
| `firefoxProfilePath` | `"default"` | Existing Firefox profile path to preserve. |
| `stateVersion` | `26.05` | Home Manager state version. |

Simple values come from `machine`; machine flakes can add a Home Manager module
after the shared module for rare host-specific exceptions. Shared settings use
`mkDefault`. Put everyday, cross-machine preferences here and reserve the
consuming host's `home.nix` for actual machine differences.

The default profile is desktop-agnostic. A consumer that wants Niri or the
Noctalia shell enables the explicit Home Manager options:

```nix
cbrst.desktop = {
  niri.enable = true;
  noctalia.enable = true;
};
```

On NixOS, set `cbrst.desktop.niri.installPackage = false` when the system
already provides Niri. The shared Firefox profile includes Pixibb; its flake
dependency is owned and pinned here rather than repeated by every consumer.
Linux-only features are conditional, so macOS consumers can evaluate the
module; macOS-specific services such as `launchd.agents` belong in a machine
override module. Keep secrets, Ghostty themes, and Ghostty machine overrides in
the consuming machine repository.

On the NixOS machine, apply it with:

```sh
# Resolve the module's intentionally unpinned Firefox and Open VSX downloads.
# NixOS host profiles include both the user and host name.
home-manager switch --impure --flake /etc/nixos#cbrst@asgard
```

Run `nixie update` to refresh pinned inputs, then `nixie home` to apply the
locked Home Manager configuration with `--impure`.

### macOS quick start

Use standalone Home Manager unless the Mac already has a `nix-darwin`
configuration. Install Apple's Command Line Tools and the official multi-user
Nix package manager, then enable flakes:

```sh
# Git and the compiler toolchain are required by common Nix builds.
xcode-select --install

# Install Nix using the official macOS multi-user installer.
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

Create `~/.config/nix/nix.conf` with:

```ini
# Home Manager in this repository is consumed as a flake.
experimental-features = nix-command flakes
```

Copy `home-manager/example-flake-darwin.nix` to
`~/.config/home-manager/flake.nix`, replace `YOUR_USERNAME` and
`YOUR_MAC_HOSTNAME`, and select `x86_64-darwin` instead of `aarch64-darwin` on
an Intel Mac. Bootstrap and activate it with:

```sh
# The first invocation supplies Home Manager before it exists in the profile.
nix run home-manager/release-26.05 -- switch --impure -b backup \
  --flake "$HOME/.config/home-manager#$(id -un)"

# Later switches use the Home Manager command installed by the configuration.
home-manager switch --impure --flake "$HOME/.config/home-manager#$(id -un)"
```

After the bootstrap switch installs `nixie`, later switches can instead use
`nixie home`. On macOS it defaults to this standalone Home Manager flake and
passes `--impure` automatically. The bootstrap command remains necessary before
`nixie` is installed.

The shared module automatically uses `/Users/<user>`, skips its Linux-only
systemd, GTK, Niri, and Noctalia settings, and puts graphical Nix
applications in `~/Applications/Home Manager Apps`. Linux `.desktop` launchers
and MIME associations are skipped too. The example also selects the native
macOS 1Password SSH-agent socket. Install the native Ghostty app separately;
its flake does not publish the macOS application as a Nix package. See
[`docs/macos-home-manager.md`](docs/macos-home-manager.md) for prerequisites,
machine-specific Ghostty and Home Manager overrides, verification, collisions,
updates, Intel Macs, and optional `nix-darwin` integration. `--impure` is
required because the shared module intentionally resolves the latest Firefox
add-ons and Open VSX extensions during evaluation.

For local shared-configuration tests and daily NixOS or Home Manager workflows,
use [`nixie`](docs/nixie.md).

## Emacs

Home Manager installs standard Emacs on Linux and native Emacs Mac Port on
macOS. The declarative Evil-based configuration and its Neovim-compatible
keymaps are documented in [`docs/emacs.md`](docs/emacs.md).

## Firefox

Firefox extensions, the Tridactyl configuration, and GitHub-backed userscript
updates are documented in [`docs/firefox.md`](docs/firefox.md). NixOS systems
that install Firefox themselves should set `machine.firefoxSystem = true`.

## Niri

Enable `cbrst.desktop.niri` and `cbrst.desktop.noctalia` in a consuming Home
Manager module to deploy the full Niri profile. When both are enabled, Niri
starts Noctalia and applies a background blur to its layer surfaces and pop-ups.
See [`docs/niri.md`](docs/niri.md) for bindings, reload instructions, and
monitor overrides.

Noctalia's shared bar layout and appearance are documented in
[`docs/noctalia.md`](docs/noctalia.md).

## 1Password

The Linux Home Manager profile starts the 1Password desktop client after the
graphical session is ready. See [`docs/1password.md`](docs/1password.md) for
activation, verification, and recovery commands.

## Tailscale

The Linux Home Manager profile starts the globally installed Tailscale systray
client after the graphical session is ready. See
[`docs/tailscale.md`](docs/tailscale.md) for system configuration, activation,
verification, and recovery commands.

## GTK

The shared Linux GTK defaults and machine-specific font override pattern are
documented in [`docs/gtk.md`](docs/gtk.md).

## Flatpak

The shared Linux Home Manager profile configures the per-user Flathub remote and
installs JDownloader and SONE. Host-level Flatpak prerequisites, activation,
verification, updates, and recovery are documented in
[`docs/flatpak.md`](docs/flatpak.md).

## Themes

OpenCode, Ghostty, Neovim, WezTerm, Tridactyl, and the Wayland Firefox profile
select the meowsoot family by default; use `theme monokai-pro` to switch to the
retained Monokai Pro family. Each family follows the operating system light/dark
appearance. See [`docs/themes.md`](docs/themes.md) for palette sources,
switching, deployment, and maintenance.

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

## Git

The shared Git configuration uses native hooks to draft editable commit messages
from staged diffs with OpenCode; it does not use Husky. Personal and work Git
identities remain machine-local. See [`docs/git.md`](docs/git.md) for identity
migration, activation, verification, recovery, and hook behavior.
