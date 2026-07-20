# config

## Set up

Use the setup utility as the single entry point on a new machine:

```sh
./setup.sh all
```

Useful non-mutating checks:

```sh
./setup.sh check
./setup.sh install --dry-run --optional
```

Config-only commands are available too:

```sh
./setup.sh link nvim zsh tmux
./setup.sh unlink
./setup.sh pull ghostty
```

Dependency installation currently targets macOS through Homebrew and Arch-based
Linux through pacman, with optional AUR helper support for packages that are not
in the official repositories.
