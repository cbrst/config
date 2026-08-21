# Flatpak applications

The shared Linux Home Manager profile maintains these applications in the
invoking user's Flatpak installation:

- JDownloader: `org.jdownloader.JDownloader`
- SONE: `io.github.lullabyX.sone`

During activation, Home Manager adds the Flathub remote when it is absent and
installs both applications non-interactively. Flatpak downloads application
runtimes and updates outside the Nix store. The shared module does not configure
Flatpak on macOS.

## Prerequisites

Flatpak is owned by the Linux host, not Home Manager. The shared profile assumes
modern Linux distributions provide the `flatpak` command and its required system
integration. On NixOS, enable the system service and portal support in the
consuming system configuration:

```nix
{
  # Required for Flatpak sandboxing and user installations.
  services.flatpak.enable = true;

  # Let sandboxed applications open files and use desktop integration.
  xdg.portal.enable = true;
}
```

On another Linux distribution, install the distribution's `flatpak` package if
it is not already present and ensure its required services are running. Home
Manager cannot configure host-level sandboxing.

Home Manager activation first looks for `flatpak` in `PATH`; on NixOS it falls
back to `/run/current-system/sw/bin/flatpak`, because the activation environment
does not inherit the system profile path.

## Activation and verification

Apply the shared profile with the normal impure Home Manager command. The
activation downloads the applications and their runtimes on first use:

```sh
# Resolve the module's intentionally unpinned Firefox and Open VSX downloads.
home-manager switch --impure --flake /etc/nixos#cbrst
```

Verify the user remote and installed applications afterward:

```sh
flatpak --user remotes
flatpak --user list --app
```

Launch either application from the desktop launcher or with:

```sh
flatpak run org.jdownloader.JDownloader
flatpak run io.github.lullabyX.sone
```

## Maintenance and recovery

Update installed Flatpak applications and runtimes independently of a Home
Manager switch:

```sh
flatpak --user update
```

To reinstall a damaged application, remove it and run the normal Home Manager
switch again; the activation step installs the declared application again:

```sh
flatpak --user uninstall org.jdownloader.JDownloader
home-manager switch --impure --flake /etc/nixos#cbrst
```
