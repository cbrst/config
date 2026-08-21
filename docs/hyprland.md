# Hyprland

Home Manager deploys `hypr/hyprland.lua` as the Hyprland configuration and
deploys Noctalia when `machine.noctalia = true`.

## Bindings

Super+T cycles the configured scrolling, master, and dwindle layouts without
reloading Hyprland. Super+V continues to toggle the current split direction.

Super+Shift+Left/Right or Super+Shift+H/L exchanges the active scrolling column
in that direction. In master and dwindle layouts, those bindings move the
active window instead. Super+Shift+Up/Down or Super+Shift+J/K always moves the
active window. Super+Shift with a number still moves the active window to that
workspace.

## Cursor

Linux sessions use the conventional Bibata Modern Ice cursor at 24 pixels.
`hypr/hyprland.lua` applies it to the compositor and inherited clients, while
the shared Home Manager module applies it to GTK and XWayland.

After changing cursor settings, apply the Home Manager generation and restart
the Hyprland session:

```sh
home-manager switch --flake /etc/nixos#cbrst
hyprctl dispatch exit
```

Alternatively, use `nixie home` for the Home Manager switch; keep
`hyprctl dispatch exit` to restart the session.

To use a different installed XCursor theme, update `XCURSOR_THEME` in
`hypr/hyprland.lua`, `home.pointerCursor`, and `gtk.cursorTheme` together in
`home-manager/default.nix`. Keep their names and sizes identical so Hyprland,
GTK, and XWayland applications remain consistent.
