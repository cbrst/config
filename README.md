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
./setup.sh link nvim zsh tmux opencode
./setup.sh unlink
./setup.sh pull ghostty
```

Dependency installation currently targets macOS through Homebrew and Arch-based
Linux through pacman. On macOS, system or Command Line Tools commands such as
`bash`, `curl`, `git`, `make`, and `zsh` are checked but not installed through
Homebrew, so Brew does not shadow Apple-managed components.

## AI coding

`setup.sh install` installs OpenCode, `uv`, Headroom, and a persistent
user-level Headroom proxy. In zsh, `opencode` starts that proxy if necessary,
waits for it to become healthy, then launches the unmodified OpenCode binary.

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
