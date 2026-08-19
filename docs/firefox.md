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

Home Manager installs uBlock Origin, 1Password, Violentmonkey, Stylus, and
SponsorBlock into both managed profiles, and Tridactyl into the Niri/Hyprland
profile only. Firefox is configured to enable those profile extensions
automatically. Home Manager fetches the latest signed XPI for each addon from
Mozilla Add-ons during an impure evaluation, so each Home Manager switch checks
for addon updates. This intentionally makes the result non-reproducible and
requires `--impure`.

Home Manager writes these XPIs under Firefox's profile extension UUID directory;
do not replace the generated `extensions` symlink in the Firefox profile.

The managed `default` profile restores the previous window and tabs on normal
startup. Home Manager also creates a `wayland` profile for Niri and Hyprland.
The `firefox-session` launcher selects `wayland` when `XDG_CURRENT_DESKTOP`
contains `niri` or `Hyprland` (or when Hyprland's instance variable is present)
and otherwise selects `default`. The local `firefox.desktop` entry and the Niri
and Hyprland browser bindings use this launcher.

The profiles use fixed Home Manager IDs: `default` is ID `0` and the sole
default profile; `wayland` is ID `1`. Keep these IDs unique when adding a
machine-specific Firefox profile.

## Extension Link Recovery

When switching from an earlier shared configuration, Home Manager removes a
stale `extensions` symlink before linking the managed add-on tree for each
profile. This migration runs automatically with `nixie home --local` and normal
Home Manager switches. It removes only symlinks; an existing real `extensions`
directory is preserved and Home Manager will report any ownership conflict.

The generated desktop entry intentionally omits `StartupWMClass`: Home
Manager's `xdg.desktopEntries` option does not support that field. Firefox still
uses its normal window class.

The Wayland profile loads `userChrome.css`, which collapses the navigation bar
until the Firefox toolbox is hovered and hides Firefox window controls. Its
Downloads button remains on the tab bar; extension action buttons and Firefox's
unified extensions menu remain in the navigation bar and are available on hover.
Tridactyl is installed only in this compact profile; uBlock Origin, 1Password,
Violentmonkey, Stylus, and SponsorBlock are installed in both profiles.
Both profiles set `extensions.autoDisableScopes = 0`, so Firefox enables their
Home Manager-provided extensions instead of treating them as disabled sideloads.

## Firefox Sync

Firefox Account authentication cannot be stored in this repository. On first
launch in each profile, sign in to the same Firefox Account at
`about:preferences#sync`. The managed preferences preselect Bookmarks and
History, while Add-ons, Settings, Open tabs, Passwords, Addresses, and Payment
methods are disabled. Confirm those selections before enabling Sync.

Do not share Firefox profile directories or copy `places.sqlite` between them:
Firefox Sync safely synchronizes bookmarks and history, while Home Manager owns
the extensions installed in each profile.

Tridactyl uses its Home Manager-installed native messaging host to load
`$XDG_CONFIG_HOME/tridactyl/tridactylrc`. After applying this configuration,
restart Firefox, then run `:native` in Tridactyl to confirm the host responds.

## Apply changes

```sh
# Apply extensions, both Firefox profiles, and Tridactyl configuration.
home-manager switch --impure --flake /etc/nixos#cbrst@asgard
```

Restart Firefox after the switch. In a Niri or Hyprland session, run
`firefox-session` and confirm the compact toolbar and Tridactyl. In another
session, confirm the normal toolbar and common extensions at `about:addons`.
If Firefox was already running, close every Firefox window before starting the
Wayland profile so it reloads the managed toolbar layout.

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
