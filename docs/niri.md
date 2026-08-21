# Niri

Set `machine.niri = true` in the consuming machine configuration to install
Niri, deploy `niri/config.kdl`, and enable Noctalia. Niri starts Noctalia as
the desktop shell; it supplies the bar, launcher, control center,
notifications, wallpaper, lock screen, and OSDs.

The shared configuration uses a 2px Catppuccin gradient border rather than a
focus ring, with 8px rounded window geometry and compositor shadows. It applies
Niri's `background-effect` blur to Noctalia's bar, notification, dock, panel,
attached-panel, and OSD layer surfaces and their pop-ups. The Noctalia backdrop
is matched separately and placed within the backdrop layer. This needs Niri
26.04 or newer.

Niri exports `SSH_AUTH_SOCK` as `$HOME/.1password/agent.sock`, allowing
graphical applications to use the 1Password SSH agent.

Firefox windows open in a tiled column that occupies 80% of the output width.
This is an initial width; use `Super+-` or `Super+=` to adjust the focused
column after it opens.

The `Games` workspace has no gaps, struts, or borders. Steam opens there at
full column width. A single visible column stays centered, and Noctalia shows
named workspace labels in its bar.

## Apply And Reload

Apply the Home Manager generation, then choose the Niri session in the display
manager or start it from a TTY:

```sh
home-manager switch --flake /etc/nixos#cbrst
niri-session
```

Alternatively, use `nixie home` for the Home Manager switch; keep
`niri-session` to start the compositor.

After editing `niri/config.kdl`, reload the active session without logging out:

```sh
niri msg action load-config-file
```

Inspect the Noctalia namespaces when adding or adjusting layer rules:

```sh
niri msg layers
```

Keep the interactive surface names in the blur rule explicit. Add a new
Noctalia namespace only after confirming it with `niri msg layers`; leave the
`noctalia-backdrop` rule separate so wallpaper/backdrop placement is preserved.

## Key Bindings

`Super+Return`, `Super+B`, and `Super+E` open Ghostty, Firefox, and Nemo.
`Super+Space` opens the Noctalia launcher, `Super+C` toggles its control center,
and `Super+Shift+L` locks through Noctalia. Use Super plus arrow keys or H/J/K/L to
focus windows; add Control to move columns.

Use `Super+-` and `Super+=` to shrink or grow the focused column by 10%. Add
Shift to resize the focused window's height instead.

Use `Super+,` to stack the window to the right below the focused window.
`Super+.` removes the bottom window from that stack into its own column.

`Super+1` through `Super+8` focus their numbered workspaces; add Control to
move the focused column instead. `Super+mouse wheel` changes workspace, with
the directions reversed for the naturally scrolling touchpad.

## Machine Overrides

Add monitor-specific `output` blocks in the consuming machine's
`~/.config/niri/config.kdl` override workflow, or override
`xdg.configFile."niri/config.kdl"` from its final Home Manager module. Keep
the `noctalia-*` layer rule when overriding the shared file so the shell
continues to receive blur, and retain the separate `noctalia-backdrop` rule.

For a different SSH agent socket, set `machine.sshAuthSock` in the consuming
machine configuration; it overrides the shared Home Manager default.
