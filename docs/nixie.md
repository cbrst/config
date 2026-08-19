# Nixie

`nixie` manages the daily Nix workflow from zsh. It is deployed as an
autoloaded function by `home-manager/default.nix` and follows the commands in
the NixOS configuration's `docs/daily-workflow.md`.

```sh
# Choose an action from the interactive menu.
nixie

# Update inputs, apply the system configuration, then apply Home Manager.
nixie all

# Run one layer at a time. `home` refreshes only the dotfiles input first.
nixie update  # all flake inputs
nixie system  # NixOS only
nixie home    # dotfiles input, then Home Manager

# Display built-in usage documentation.
nixie --help
```

`all` runs the complete daily workflow:

```sh
nix flake update /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#asgard
home-manager switch --flake /etc/nixos#cbrst@asgard
```

Each action stops at the first failure. `update` changes only the flake lock.
`home` updates only the `dotfiles` input, then switches Home Manager, so shared
dotfile changes are fetched and applied without rebuilding NixOS. Commit the
resulting `flake.lock` change from the consuming flake when you want other
machines to use the same pinned revisions.

## Runtime profile selection

On NixOS, `nixie` discovers the available `nixosConfigurations` and matches
the current short hostname to each profile's configured `networking.hostName`.
It then chooses the only Home Manager output ending in `@<host-profile>`.
This supports host profiles whose directory name differs from their display
hostname, such as `asgard` and `Asgard`.

On a non-NixOS machine, `all` updates the flake and applies Home Manager while
skipping the NixOS-only system switch. `system` instead exits with an explicit
error. For standalone Home Manager flakes, `nixie` selects either a profile
named after `$USER` or one named `$USER@<short-hostname>`.

Set an override when a flake has more than one possible profile or uses another
layout:

```sh
# Apply a standalone Home Manager flake on macOS or another Linux distribution.
NIXIE_FLAKE="$HOME/src/home" \
NIXIE_HOME_PROFILE="alice" \
nixie all

# Select a particular NixOS host and its matching Home Manager output.
NIXIE_FLAKE="$HOME/src/nixos" \
NIXIE_HOST_PROFILE="laptop" \
NIXIE_HOME_PROFILE="alice@laptop" \
nixie all
```

`NIXIE_FLAKE` defaults to `/etc/nixos`. `NIXIE_HOST_PROFILE` and
`NIXIE_HOME_PROFILE` override automatic selection. The legacy
`NIXOS_FLAKE` and `HOME_MANAGER_PROFILE` variables remain accepted for existing
shell setups, but new configuration should use the `NIXIE_*` names.

## Local dotfiles testing

Use `home --local` to evaluate the local dotfiles checkout without updating the
consumer flake's lockfile. Unlike `nixie home`, it does not fetch the remote
`dotfiles` input. `DOTFILES_DIR` defaults to `$HOME/Projects/config`.

```sh
# Apply uncommitted shared dotfile changes to the active home profile.
nixie home --local

# Test a different checkout and standalone Home Manager flake.
DOTFILES_DIR="$HOME/src/config" \
NIXIE_FLAKE="$HOME/src/home" \
NIXIE_HOME_PROFILE="alice" \
nixie home --local
```

This mode passes `--override-input dotfiles path:<DOTFILES_DIR>` to
`home-manager switch`; it does not modify Git history or `flake.lock`.

## Impure Home Manager evaluation

`nixie` passes `--impure` to both Home Manager switch paths. The shared Firefox
configuration downloads the current signed AMO release for its managed addons,
and unpackaged VS Code extensions are fetched from Open VSX's latest release
metadata while Home Manager evaluates. `nixie home`, `nixie home --local`, and
`nixie all` can therefore update those extensions without changing the dotfiles
revision. This makes Home Manager generations non-reproducible by design.
