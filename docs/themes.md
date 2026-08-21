# Theme Families

`theme` selects a shared family while each application continues to choose its
light or dark variant from the operating system appearance. Meowsoot is the
default when no family has been selected.

| Family | Dark | Light |
| --- | --- | --- |
| meowsoot | Night (`meowsoot`) | Dawn (`meowsoot-dawn`) |
| monokai-pro | Spectrum | Light |

Run one of these commands from a shell after Home Manager has deployed the
configuration:

```sh
# Select a family without rewriting Home Manager-managed files.
theme meowsoot
theme monokai-pro

# Print the selected family; reports meowsoot before the first selection.
theme status
```

The command stores the selection in
`$XDG_STATE_HOME/config-theme/family` and writes Ghostty's optional final
override at `$XDG_CONFIG_HOME/ghostty/theme`. Neovim reads the state at startup,
WezTerm watches it and reloads its configuration, and the `opencode` function
starts `opencode-themed`, which creates a private runtime `tui.json`. Restart
existing OpenCode sessions after a switch. Existing Ghostty windows can reload through
the default `Ctrl+Shift+,` binding.

VS Code and Emacs intentionally remain on their fixed Monokai Pro themes.

## Palette Sources

Meowsoot Night and Dawn are copied from the pinned upstream source at
<https://github.com/marekh19/meowsoot.nvim>. The local OpenCode theme maps that
palette into OpenCode semantic roles. The retained Monokai Pro Spectrum Ghostty
palette comes from <https://cmuxthemes.com/themes/monokai-pro-spectrum/>; its
Light palette comes from `loctvl842/monokai-pro.nvim`.

## Apply Changes

Home Manager deploys theme assets and initializes the state file only when it
does not already exist. Test local changes on the NixOS machine with:

```sh
# Resolve the module's intentionally unpinned evaluation fetches.
home-manager switch --impure --flake /etc/nixos#cbrst \
  --override-input dotfiles path:/home/cbrst/Projects/config
```

Start Neovim and OpenCode, then change the system appearance, to verify both
variants. Restart Ghostty after changing a family.
