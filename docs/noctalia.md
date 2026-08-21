# Noctalia

`noctalia/config.toml` defines the shared shell configuration used by both the
Niri and Hyprland sessions.

## Bar

The bar groups named workspaces and the active window on the left, keeps the
clock in the center, and groups CPU, RAM, and temperature on the right. The
remaining right-side controls are the tray, notifications, clipboard, volume,
control center, and session controls. Network, Bluetooth, brightness, battery,
and media widgets are intentionally omitted to keep the bar compact; use the
control center for those controls.

The launcher is available through `Super+Space` rather than as a persistent bar
widget. The wider widget spacing keeps the remaining controls distinct.

Update bar groups and widget options in `noctalia/config.toml`, then reload the
active Niri configuration with `niri msg action load-config-file` or restart
Noctalia in another supported session. Wallpaper paths are machine-local;
choose an existing file under `~/Pictures/Wallpapers` before applying a change.

## Appearance

Noctalia uses the installed `CommitMono` font. If it is unavailable on a
machine, change `shell.font_family` in `noctalia/config.toml` to an installed
font, then apply the Home Manager generation:

```sh
home-manager switch --impure --flake /etc/nixos#cbrst
```

Alternatively, run `nixie home`, which refreshes the `dotfiles` input before
applying Home Manager.

The shared configuration selects the editable
`noctalia/palettes/monochrome-custom.json` palette, which begins as a copy of
Noctalia's `Monochrome` community palette. The deployed location is
`~/.config/noctalia/palettes/`; edit the tracked file, keep
`theme.custom_palette = "monochrome-custom"`, and retain
`theme.source = "custom"` to apply changes without wallpaper-derived colors.
