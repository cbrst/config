# Hyprland

Home Manager deploys `hypr/hyprland.lua` as the Hyprland configuration and
deploys Noctalia when `machine.noctalia = true`.

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

To use a different installed XCursor theme, update `XCURSOR_THEME` in
`hypr/hyprland.lua`, `home.pointerCursor`, and `gtk.cursorTheme` together in
`home-manager/default.nix`. Keep their names and sizes identical so Hyprland,
GTK, and XWayland applications remain consistent.
