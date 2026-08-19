# Niri

Set `machine.niri = true` in the consuming machine configuration to install
Niri, deploy `niri/config.kdl`, and enable Noctalia. Niri starts Noctalia as
the desktop shell; it supplies the bar, launcher, control center,
notifications, wallpaper, lock screen, and OSDs.

The shared configuration applies Niri's `background-effect` blur to every
`noctalia-*` layer surface and its pop-ups. This needs Niri 26.04 or newer.

Niri exports `SSH_AUTH_SOCK` as `$HOME/.1password/agent.sock`, allowing
graphical applications to use the 1Password SSH agent.

## Apply And Reload

Apply the Home Manager generation, then choose the Niri session in the display
manager or start it from a TTY:

```sh
home-manager switch --flake /etc/nixos#cbrst
niri-session
```

After editing `niri/config.kdl`, reload the active session without logging out:

```sh
niri msg action load-config-file
```

Inspect the Noctalia namespaces when adding or adjusting layer rules:

```sh
niri msg layers
```

## Key Bindings

`Super+Return`, `Super+B`, and `Super+E` open Ghostty, Firefox, and Nemo.
`Super+Space` opens the Noctalia launcher, `Super+C` toggles its control center,
and `Super+Shift+L` locks through Noctalia. Use Super plus arrow keys or H/J/K/L to
focus windows; add Control to move columns.

Use `Super+-` and `Super+=` to shrink or grow the focused column by 10%. Add
Shift to resize the focused window's height instead.

Use `Super+,` to stack the window to the right below the focused window.
`Super+.` removes the bottom window from that stack into its own column.

## Machine Overrides

Add monitor-specific `output` blocks in the consuming machine's
`~/.config/niri/config.kdl` override workflow, or override
`xdg.configFile."niri/config.kdl"` from its final Home Manager module. Keep
the `noctalia-*` layer rule when overriding the shared file so the shell
continues to receive blur.

For a different SSH agent socket, set `machine.sshAuthSock` in the consuming
machine configuration; it overrides the shared Home Manager default.
