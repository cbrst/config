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

### `theme`

This sets the theme. Theme switching is handled by a ZSH function that sets both
Ghostty and Neovim themes. Doing this in a seperate file makes it easier to
handle, plus it's also ignored in the repo

### `themes` Folder

Just a collection of themes which are either not included in or modified from upstream.

---

## Setup

This config module automatically runs `setup.sh` to fetch some themes.

---

## Additional Notes

This config uses a version of San Francisco Mono with added ligatures and Nerd
Font symbols. Due to licensing, this font cannot be included in the repo and
needs to be sourced independently.
