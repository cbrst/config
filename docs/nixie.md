# Nixie

`nixie` manages the daily Nix workflow from zsh. Home Manager links the
executable `zsh/scripts/nixie` to `~/.local/bin/nixie`, so it works from
interactive shells, VSCode tasks, and other processes that do not inherit ZSH
functions. It follows the commands in the NixOS configuration's
`docs/daily-workflow.md`.

```sh
# Choose an action from the interactive menu.
nixie

# Update inputs, apply the system configuration, then apply Home Manager.
nixie all

# Run one layer at a time. `update` changes lockfiles; `home` applies them.
nixie update  # consumer inputs and local shared inputs when checked out
nixie publish # commit and push changed flake.lock files
nixie system  # NixOS only
nixie home    # locked Home Manager configuration

# Preview packages that would change without changing flake.lock or activating.
nixie overview

# Display built-in usage documentation.
nixie --help
```

ZSH completes the actions (`all`, `update`, `publish`, `system`, `home`, and `overview`)
and offers `--local` only after `nixie home`. Open a new ZSH session after
applying Home Manager to load the completion.

`all` runs the complete daily workflow:

```sh
nix flake update --flake /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#asgard
home-manager switch --flake /etc/nixos#cbrst@asgard
```

Each action stops at the first failure. `update` changes the consumer flake's
lockfile and, when `$DOTFILES_DIR` contains a shared checkout, its lockfile too.
`home` does not update a lockfile or override inputs: it activates exactly the
consumer configuration recorded in `flake.lock`. `publish` stages only changed
`flake.lock` files, commits each affected repository separately, and pushes the
commits. It does not include unrelated worktree changes.

Use this sequence when updating a shared dependency such as Pixibb:

```sh
# On the machine that maintains the shared checkout, update and publish its pins.
nixie update
nixie publish

# On every machine, adopt the published dotfiles revision and activate it.
nixie update
nixie home
```

The maintainer machine must also run the final `nixie update` and `nixie home`
after publishing so its consumer lockfile records the newly published shared
revision. `nixie all` performs the update and activation steps, but does not
publish lockfile changes.

## Package overview

`nixie overview` creates an updated lock file in a temporary directory and
compares evaluation-only package manifests from the current and candidate
configurations. On NixOS it also compares `environment.systemPackages`. It
prints changed packages in aligned rows, including additions and removals:

```text
╭────────────────────────────────────────╮
│  NIXIE  package constellation          │
├────────────────────────────────────────╯
│
│  ╭─ Home Manager ─────────────────────╮
│  firefox                            141.0 ──▶ 142.0
│  neovim                            0.11.3 ──▶ 0.11.4
│  ╰────────────────────────────────────╯
│
│  ✦ 2 packages would change
│
│  No packages built · no generation activated
│
╰╸ Apply with nixie all
```

The arrow begins in the same column on every package row. This operation may
fetch updated flake metadata and source expressions, but uses `nix eval
--read-only`: it does not download or build package sources or outputs, modify
the consuming flake's `flake.lock`, or activate a NixOS or Home Manager
generation. The comparison is between the flake's current and updated
declarative package lists; run `nixie all` on NixOS or `nixie update` followed
by `nixie home` elsewhere after reviewing the result.

`overview` buffers its presentation until every manifest evaluation succeeds,
so its frame and summary are never interleaved with routine Nix diagnostics.
Warnings and errors are shown only when an overview calculation fails.

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

On NixOS, `NIXIE_FLAKE` defaults to `/etc/nixos`. On other Linux distributions
and macOS, it defaults to `${XDG_CONFIG_HOME:-$HOME/.config}/home-manager`,
which is the standalone Home Manager location used by the setup guides. Set
`NIXIE_FLAKE` when the consumer flake lives elsewhere. `NIXIE_HOST_PROFILE` and
`NIXIE_HOME_PROFILE` override automatic selection. The legacy
`NIXOS_FLAKE` and `HOME_MANAGER_PROFILE` variables remain accepted for existing
shell setups, but new configuration should use the `NIXIE_*` names.

## Local dotfiles testing

Use `home --local` to evaluate the local dotfiles checkout without updating the
consumer flake's lockfile. Unlike `nixie home`, it overrides the locked remote
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
