# Ghostty

## Split Files

My Ghostty config is split up into several files for readability and
cross-platform support:

### `config`

This is the main configuration file. This sets global options and sources the
other parts.

### `keybinds`

These are custom keybindings. Mostly to handle splits.

### `machine`

Machine-specific settings. Everything set here overwrites settings made in
`config`. This file is not included in the git repo.

### `themes` Folder

Contains the tracked meowsoot and Monokai Pro palettes. Ghostty defaults to
meowsoot Night in dark mode and Dawn in light mode. `theme` writes the optional
`theme` override file to switch families without modifying `config`.

---

## Additional Notes

This config uses a version of San Francisco Mono with added ligatures and Nerd
Font symbols. Due to licensing, this font cannot be included in the repo and
needs to be sourced independently.
