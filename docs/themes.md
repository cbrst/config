# Monokai Pro Themes

OpenCode, Ghostty, and Neovim use Monokai Pro variants selected from the
operating system appearance:

| Appearance | Variant |
| --- | --- |
| Dark | Monokai Pro Spectrum |
| Light | Monokai Pro Light |

Neovim uses `auto-dark-mode.nvim` to switch between `monokai-pro-spectrum` and
`monokai-pro-light`. Ghostty selects the matching tracked palette with its
light/dark `theme` setting. OpenCode uses the `dark` and `light` definitions in
`opencode/themes/monokai-pro.json`.

## Palette Sources

The Spectrum Ghostty palette comes from
<https://cmuxthemes.com/themes/monokai-pro-spectrum/>. The Light palette and
the OpenCode variants use the corresponding palette values from the pinned
`loctvl842/monokai-pro.nvim` plugin. OpenCode's semantic role mapping is based
on <https://github.com/monokai-pro/opencode>.

## Apply Changes

Home Manager deploys the OpenCode files and Ghostty configuration. Test local
changes on the NixOS machine with:

```sh
# Deploy the local checkout, including the shared Monokai Pro configuration.
home-manager switch --flake /etc/nixos#cbrst \
  --override-input dotfiles path:/home/cbrst/Projects/config
```

Restart Ghostty and OpenCode after applying the generation. Neovim picks up a
changed configuration when it is restarted; switch the system appearance to
verify both variants.

## Maintain The Pair

Keep both variants aligned when updating a palette. Edit the corresponding
Ghostty file, `opencode/themes/monokai-pro.json`, and the Monokai Pro Neovim
configuration together. Do not add per-machine or ignored theme overrides:
the tracked pair is the source of truth for all three applications.
