# Tailscale Systray

On Linux, `home-manager/default.nix` starts `tailscale systray` as
`tailscale-systray.service` once `graphical-session.target` is active. The
service uses Tailscale from the NixOS system profile, so Home Manager does not
install a second copy. Enable Tailscale globally in the NixOS configuration:

```nix
# Provide tailscale from the NixOS system profile used by the user service.
services.tailscale.enable = true;
```

## Apply And Verify

Apply the Home Manager generation, then inspect the user service:

```sh
home-manager switch --flake /etc/nixos#cbrst
systemctl --user status tailscale-systray.service
```

Alternatively, use `nixie home` for the Home Manager switch; keep the native
`systemctl` command to inspect the service.

The service should show `active (running)` and its icon should appear in the
desktop shell's system tray. A new graphical session starts it automatically
after the switch.

## Maintenance

Restart the systray client after changing Tailscale settings or to recover from
a failed launch. Inspect its journal if it does not remain active:

```sh
systemctl --user restart tailscale-systray.service
journalctl --user-unit=tailscale-systray.service -b --no-pager
```
