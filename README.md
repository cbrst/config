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
Linux through pacman. On macOS, system or Command Line Tools commands such as
`bash`, `curl`, `git`, `make`, and `zsh` are checked but not installed through
Homebrew, so Brew does not shadow Apple-managed components.
