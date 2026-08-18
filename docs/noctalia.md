# Noctalia

`noctalia/config.toml` defines the shared shell configuration used by both the
Niri and Hyprland sessions.

## Bar

The bar keeps workspaces on the left and the clock in the center. Its right
side contains the tray, notifications, clipboard, volume, control center, and
session controls. Network, Bluetooth, brightness, battery, and media widgets
are intentionally omitted to keep the bar compact; use the control center for
those controls.

The launcher is available through `Super+Space` rather than as a persistent bar
widget. The wider widget spacing keeps the remaining controls distinct.

## Appearance

Noctalia uses the installed `CommitMono` font. If it is unavailable on a
machine, change `shell.font_family` in `noctalia/config.toml` to an installed
font, then apply the Home Manager generation:

```sh
home-manager switch --flake /etc/nixos#cbrst
```
