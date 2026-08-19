# GTK

The shared Linux Home Manager module provides GTK defaults, including the
`Noto Sans` interface font. Override them in the consuming machine's trailing
Home Manager module so other machines keep the shared defaults.

```nix
# hosts/asgard/home.nix
{
  # Use the installed CommitMono family for this machine's GTK applications.
  gtk.font.name = "CommitMono";
  # Set the GTK interface font size for this machine.
  gtk.font.size = 10;
}
```

`CommitMono` is installed by the shared Home Manager package list. Apply the
machine configuration after changing the override:

```sh
# Rebuild the active Home Manager profile with the machine-local GTK setting.
home-manager switch --flake /etc/nixos#cbrst
```

Restart affected GTK applications after the switch so they read the generated
GTK settings.
