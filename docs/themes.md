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
# Interactively select a family. Uses fzf when available, with a numbered
# prompt as a portable fallback.
theme

# Select a family without rewriting Home Manager-managed files.
theme meowsoot
theme monokai-pro

# Print the selected family; reports meowsoot before the first selection.
theme status
```

The command stores the selection in `$XDG_STATE_HOME/config-theme/family` and
writes Ghostty's optional final override at `$XDG_CONFIG_HOME/ghostty/theme`.
Neovim reads the state at startup, WezTerm watches it and reloads its
configuration, and the `opencode` function starts `opencode-themed`, which
creates a private runtime `tui.json`. Restart existing OpenCode sessions after a
switch. Existing Ghostty windows can reload through the default `Ctrl+Shift+,`
binding.

The Wayland Firefox profile imports the palette copy at
`$XDG_STATE_HOME/config-theme/firefox-wayland.css`; restart Firefox after a
switch to reload `userChrome.css`. Tridactyl sources
`$XDG_STATE_HOME/config-theme/tridactylrc` and follows the same family after its
next configuration load or Firefox restart. Both browser palettes use
`prefers-color-scheme`, so their light and dark variants continue to follow the
operating system appearance.

VS Code and Emacs intentionally remain on their fixed Monokai Pro themes.

## Palette Sources

Meowsoot Night and Dawn are copied from the pinned upstream source at
<https://github.com/marekh19/meowsoot.nvim>. The local OpenCode, Tridactyl, and
Firefox palettes map those colors into their respective semantic roles. The
retained Monokai Pro Spectrum palette comes from
<https://cmuxthemes.com/themes/monokai-pro-spectrum/>; its Light palette comes
from `loctvl842/monokai-pro.nvim`. The same four source palettes drive Ghostty,
WezTerm, Tridactyl, and Firefox Wayland styling.

Tridactyl keeps its shared command-line and completion layout in
`tridactyl/themes/_global.css` and its palette variables in one file per family.
Because Tridactyl does not support CSS `@import`, Home Manager concatenates the
layout and selected palette into each deployed theme. The shared layout is
scoped only to Tridactyl's stable namespace, not a family-specific class, so it
applies to every selected palette.

## Apply Changes

Home Manager deploys theme assets and initializes the state file only when it
does not already exist. Test local changes on the NixOS machine with:

```sh
# Resolve the module's intentionally unpinned evaluation fetches.
home-manager switch --impure --flake /etc/nixos#cbrst@asgard \
  --override-input dotfiles path:/home/cbrst/Projects/config
```

Alternatively, run `nixie home --local`; it uses the local checkout and passes
`--impure` automatically.

Start Neovim, OpenCode, and Firefox, then change the system appearance, to
verify both variants. Restart Ghostty and Firefox after changing a family; in
Tridactyl, run `:source` if Firefox remains open.
