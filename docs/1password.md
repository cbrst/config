# 1Password

On Linux, `home-manager/default.nix` installs the 1Password desktop client and
starts it as `1password.service` once `graphical-session.target` is active.
The service passes `--silent`, so it runs in the background without opening a
window. Use the 1Password launcher or browser integration to bring it forward.

## Apply And Verify

Apply the Home Manager generation, then inspect the user service:

```sh
home-manager switch --flake /etc/nixos#cbrst@asgard
systemctl --user status 1password.service
```

Alternatively, use `nixie home` for the Home Manager switch; keep the native
`systemctl` command to inspect the service.

The service should show `active (running)`. A new graphical session starts it
automatically after the switch.

## Maintenance

Restart 1Password after changing its settings or to recover from a failed
launch. Inspect its journal if it does not remain active:

```sh
systemctl --user restart 1password.service
journalctl --user-unit=1password.service -b --no-pager
```
