# Git

The shared Home Manager module deploys `git/config` as `~/.gitconfig` and the
native `prepare-commit-msg` hook as
`$XDG_CONFIG_HOME/git/hooks/prepare-commit-msg`. The configuration sets
`core.hooksPath` to that directory, so the hook applies to every local
repository without Husky or per-repository installation.

## Local identities

Git identities are machine-local and intentionally excluded from this
repository. Before the first activation, migrate the identity from the current
global configuration into the file included by the shared config:

```sh
# Create the local identity file without placing personal values in this checkout.
git config --file "$HOME/.gitconfig-local" user.name "$(git config --global --get user.name)"
git config --file "$HOME/.gitconfig-local" user.email "$(git config --global --get user.email)"
```

`git/config` retains the existing `~/Projects/GitLab/` conditional include.
Keep its referenced `~/.gitconfig-gitlab` file local, or remove that include in
the consuming machine's override when it is not needed.

Apply the module with a backup extension because Home Manager will replace the
pre-existing `~/.gitconfig`:

```sh
# Creates ~/.gitconfig.pre-home-manager-git before linking the managed config.
home-manager switch -b pre-home-manager-git --flake /etc/nixos#cbrst@asgard \
  --override-input dotfiles path:/home/cbrst/Projects/config
```

Confirm that Git resolves the shared configuration and sees the deployed hook:

```sh
git config --show-origin --get core.hooksPath
test -x "${XDG_CONFIG_HOME:-$HOME/.config}/git/hooks/prepare-commit-msg"
```

If activation needs to be reversed, restore the saved configuration and rebuild
without this module. Do not delete `~/.gitconfig-local` or
`~/.gitconfig-gitlab`; they hold local identities.

## Commit-message drafts

For an ordinary staged change, invoke `git commit` without `-m` or `-F`. The
hook attaches only `git diff --cached` to OpenCode's read-only `local-quick`
agent, writes its draft to Git's message file, and then opens the normal editor.
Review and edit the draft before completing the commit.

The hook intentionally skips explicit messages, templates, merges, squashes,
amends, and empty indexes. If OpenCode, its local model, or generation fails,
the hook reports the problem and leaves Git's normal message flow intact.

```sh
# Stage a coherent change, generate a draft, then review it in $EDITOR.
git add -- path/to/file
git commit
```

Use `git commit -m "type: summary"` whenever a generated draft is not wanted.
