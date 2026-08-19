# Firefox

Firefox is configured by Home Manager while NixOS may own the browser package.
Set the following machine values in the consuming flake's host-local settings
when Firefox is supplied by NixOS:

```nix
{
  # Keep Firefox installed by the NixOS system configuration.
  firefoxSystem = true;
  # Reuse the existing Firefox profile instead of creating a new one.
  firefoxProfilePath = "tf1cpal5.default";
}
```

Find the current profile path in
`$XDG_CONFIG_HOME/mozilla/firefox/profiles.ini`. Omit `firefoxSystem` on a
machine where Home Manager should install Firefox. Omit `firefoxProfilePath`
only for a new profile; it defaults to `default`.

Home Manager installs uBlock Origin, Tridactyl, 1Password, Violentmonkey, and
Stylus into the selected profile. Firefox is configured to enable those profile
extensions automatically. Home Manager fetches the latest signed XPI for each
addon from Mozilla Add-ons during an impure evaluation, so each Home Manager
switch checks for addon updates. This intentionally makes the result
non-reproducible and requires `--impure`.

## Apply changes

```sh
# Apply extensions, the Firefox profile, and Tridactyl configuration.
home-manager switch --impure --flake /etc/nixos#cbrst@asgard
```

Restart Firefox after the switch and confirm the enabled addons at
`about:addons`.

`nixie home`, `nixie home --local`, and the Home Manager phase of `nixie all`
pass `--impure` automatically. A switch can therefore change addon versions
without a dotfiles commit; rerun it if an AMO download or a Firefox startup
fails after an upstream addon release.

## Userscripts and userstyles

Violentmonkey uses the GitHub `main` branch as the canonical source for the
scripts in `userscripts/`. Each script contains `@downloadURL` and `@updateURL`
metadata, so Violentmonkey checks that source for later versions after it is
installed once. Install each script from its raw GitHub URL:

```text
https://raw.githubusercontent.com/cbrst/config/main/userscripts/wallhaven-downloader.user.js
https://raw.githubusercontent.com/cbrst/config/main/userscripts/send-nzb-to-sabnzbd.user.js
https://raw.githubusercontent.com/cbrst/config/main/userscripts/safari-picture-in-picture.user.js
```

Open an URL in Firefox and let Violentmonkey confirm the installation. Increment
the script's `@version` whenever its behavior changes so the update is
detected. The `tridactyl/` directory is deployed directly to
`$XDG_CONFIG_HOME/tridactyl` by Home Manager.

There are currently no standalone Stylus userstyles in this repository.
Add new styles as `.user.css` files with `@updateURL` and `@downloadURL`
metadata pointing to their raw GitHub URLs, then open the raw URL in Firefox to
install it through Stylus. Stylus will subsequently update the style from that
source.
