# Dotfiles Update Command

`dotfiles-update` publishes the current dotfiles checkout, updates the
consuming NixOS flake's pinned `dotfiles` input, and applies the Home Manager
profile. It is installed as a zsh autoloaded function by
`home-manager/default.nix`.

Use local mode to evaluate and apply uncommitted changes without modifying Git
history or `/etc/nixos/flake.lock`:

```sh
# Use the current checkout instead of the consumer's pinned dotfiles input.
dotfiles-update --local
```

Local mode runs only:

```sh
home-manager switch --flake /etc/nixos#cbrst \
  --override-input dotfiles "path:$HOME/Projects/config"
```

For this command's initial deployment, source it from this checkout so it can
commit itself and complete the first switch:

```sh
# Bootstrap the function before Home Manager has deployed it.
source "$HOME/Projects/config/zsh/functions/dotfiles-update"
dotfiles-update "Add dotfiles update command"
```

Open a new shell after that switch. The function will then autoload normally.

```sh
# Stage all changes in the dotfiles repository, commit, push, update the lock,
# and switch the default cbrst Home Manager profile.
dotfiles-update "Enable the VS Code modern UI"
```

The command runs these operations in order and stops after the first failure:

```sh
git -C "$HOME/Projects/config" add --all
git -C "$HOME/Projects/config" commit -m "Enable the VS Code modern UI"
git -C "$HOME/Projects/config" push
nix flake update dotfiles --flake /etc/nixos
home-manager switch --flake /etc/nixos#cbrst
```

It refuses to create an empty commit. Review the working tree before running
it because `git add --all` includes every tracked, modified, and untracked file
in the dotfiles checkout.

Set these environment variables when a machine uses different paths or a
different Home Manager profile. They work in both publish and local modes:

```sh
# Apply the same flow to a different consumer and Home Manager profile.
DOTFILES_DIR="$HOME/src/config" \
NIXOS_FLAKE="$HOME/src/nixos" \
HOME_MANAGER_PROFILE="alice" \
dotfiles-update "Update shared configuration"
```
