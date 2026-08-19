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
extensions automatically. The AMO XPIs are version- and hash-pinned in
`home-manager/default.nix`; Firefox does not self-update those Nix-managed
extensions.

## Apply changes

```sh
# Apply extensions, the Firefox profile, and Tridactyl configuration.
home-manager switch --flake /etc/nixos#cbrst@asgard
```

Restart Firefox after the switch and confirm the enabled addons at
`about:addons`.

To upgrade an extension, update its versioned AMO URL and SHA-256 hash in
`firefoxExtensions`, then run the Home Manager switch again. Get the current
artifact details from the AMO API:

```sh
# Print the current version, XPI URL, and SHA-256 for an addon.
curl --fail --silent https://addons.mozilla.org/api/v5/addons/addon/ublock-origin/ \
  | jq -r '.current_version | [.version, .file.url, .file.hash] | @tsv'
```

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
