# Home Manager on macOS

The recommended setup is standalone Home Manager. It owns the user's packages
and dotfiles without requiring `nix-darwin`, and it uses the same shared module
as the NixOS configuration. Use the Home Manager `nix-darwin` module instead
only when the Mac already manages system settings through `nix-darwin`.

## Prerequisites

Install Apple's Command Line Tools and the official multi-user Nix installer:

```sh
# Provide Git, Clang, and the system SDK used by macOS builds.
xcode-select --install

# Install the Nix daemon and create the macOS /nix volume.
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

Open a new terminal after the installer completes. Enable the commands used by
flake-based Home Manager in `~/.config/nix/nix.conf`:

```ini
# Enable the modern Nix CLI and flake input locking.
experimental-features = nix-command flakes
```

Verify the prerequisites before creating a Home Manager generation:

```sh
# Both commands should print a version without sudo.
nix --version
git --version
```

`nixie` is installed by the first Home Manager activation, so use the native
`nix --version` command to verify this prerequisite.

## Standalone configuration

Create `~/.config/home-manager`, then copy
`home-manager/example-flake-darwin.nix` from this repository to its
`flake.nix`. Replace both placeholders and choose the platform:

- Apple Silicon: `aarch64-darwin`
- Intel: `x86_64-darwin`

The example enables unfree packages because the shared module contains VSCode
and WebStorm. It also uses the native 1Password SSH-agent socket. Change or
remove `machine.sshAuthSock` when 1Password's SSH agent is not in use. Keep
private values and machine-only overrides in this consumer flake, not in the
shared repository.

Check the evaluated configuration before activation:

```sh
# Impure evaluation resolves intentionally unpinned Firefox and Open VSX downloads.
nix build --impure \
  "$HOME/.config/home-manager#homeConfigurations.$(id -un).activationPackage"
```

`nixie` does not provide a build-only action; retain this native pre-activation
check.

Bootstrap Home Manager and activate the configuration:

```sh
# Back up pre-existing files that collide with Home Manager-managed paths.
nix run home-manager/release-26.05 -- switch --impure -b backup \
  --flake "$HOME/.config/home-manager#$(id -un)"
```

This bootstrap command is required because `nixie` is installed by the Home
Manager generation it creates. After it succeeds, use `nixie home` for later
switches; on macOS its default flake path is `$HOME/.config/home-manager`.

The shared Zsh configuration becomes active in a new shell. Home Manager 25.11
and newer copies graphical packages into `~/Applications/Home Manager Apps`,
which lets Spotlight discover them. macOS-native applications that are not in
the shared Nix package list can continue to be installed with Homebrew or the
App Store. In particular, install Ghostty from its signed macOS release or its
Homebrew cask: the Ghostty flake currently publishes the application package
only for Linux, while the shared configuration still uses `ghostty` as
`TERMINAL`.

## Machine-specific overrides

The macOS consumer supports two kinds of machine-specific configuration:

1. Values explicitly read from the `machine` attrset, such as `terminal`,
   `sshAuthSock`, and the raw Ghostty override text.
2. Arbitrary Home Manager options in a local module imported alongside the
   shared module.

For a small Ghostty override, add the text directly to `machine` in
`~/.config/home-manager/flake.nix`:

```nix
machine = {
  user = username;
  hostName = "YOUR_MAC_HOSTNAME";

  # Home Manager writes this text to ~/.config/ghostty/machine.
  ghostty = ''
    font-size = 14
  '';

  # Use the native macOS 1Password SSH-agent socket.
  sshAuthSock = "/Users/${username}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  niri = false;
  stateVersion = "26.05";
};
```

The shared `ghostty/config` loads `?machine` last, so values in the generated
file override shared values such as `font-size = 12`. For a cleaner consumer,
keep the raw Ghostty configuration in `hosts/ghostty.conf`:

```ini
# Override shared Ghostty settings only on this Mac.
font-size = 14
```

Then read that file from the `machine` attrset:

```nix
machine = {
  user = username;
  hostName = "YOUR_MAC_HOSTNAME";

  # Preserve Ghostty's native configuration syntax in a separate local file.
  ghostty = builtins.readFile ./hosts/ghostty.conf;

  # Keep the remaining simple machine values beside the file reference.
  sshAuthSock = "/Users/${username}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  niri = false;
  stateVersion = "26.05";
};
```

Only fields consumed by `home-manager/default.nix` belong in `machine`. For
other Home Manager settings, create `hosts/home.nix`:

```nix
{ ... }:

{
  # Override one setting from the shared VSCode profile on this Mac.
  programs.vscode.profiles.default.userSettings."editor.fontSize" = 14;

  # Add any other macOS-only Home Manager options in this module.
}
```

Import the local module in the consumer flake alongside the shared one:

```nix
modules = [
  # Load the shared cross-platform packages and configuration.
  inputs.dotfiles.homeManagerModules.default

  # Apply arbitrary settings that belong only to this Mac.
  ./hosts/home.nix

  {
    # Install the Home Manager CLI into the activated user profile.
    programs.home-manager.enable = true;
  }
];
```

Most shared values use `lib.mkDefault`, so an ordinary value in
`hosts/home.nix` overrides them. Lists such as `home.packages` merge instead of
replacing the shared list unless the local module deliberately uses a Nix
module priority function such as `lib.mkForce`.

The resulting consumer layout is:

```text
# Keep machine-owned configuration separate from the shared repository input.
~/.config/home-manager/
├── flake.nix
├── flake.lock
└── hosts/
    ├── ghostty.conf
    └── home.nix
```

If the consumer directory is a Git repository, add new files to the Git index
before evaluating the flake; Nix excludes untracked files from Git-backed flake
sources. A commit is not required for local evaluation.

```sh
# Make new machine files visible to the Git-backed local flake source.
git -C "$HOME/.config/home-manager" add hosts/ghostty.conf hosts/home.nix

# Apply consumer-only changes without updating the remote dotfiles input.
home-manager switch --impure \
  --flake "$HOME/.config/home-manager#$(id -un)"
```

Keep this native command when applying consumer-only changes without refreshing
the remote `dotfiles` input. `nixie home` always refreshes that input, while
`nixie home --local` is for testing a local dotfiles checkout.

## What differs from NixOS

The shared module derives the home directory as `/Users/<user>` on Darwin. It
does not enable systemd user services, GTK and cursor settings, Linux MIME
associations or `.desktop` launchers, Niri, or Noctalia. The Headroom
bootstrap and 1Password desktop autostart services are consequently Linux-only;
define equivalent `launchd.agents` in a machine-specific Home Manager module if
needed.

Home Manager manages user files and packages. It does not manage macOS system
defaults, Homebrew, users, the Nix daemon, or host-wide services in this
standalone setup. Add `nix-darwin` later if those should be declarative.

## Verification and recovery

Inspect the active generation and key paths:

```sh
# Confirm that the expected generation and packages are active.
home-manager generations
command -v nvim
test -L "$HOME/.config/nvim" && echo "Neovim configuration is managed"
```

`nixie` does not inspect Home Manager generations; retain the native command
when verifying the active generation.

The initial `-b backup` option renames conflicting unmanaged files with a
`.backup` suffix. Inspect those files and merge anything worth preserving into
the machine override. A switch stops rather than overwriting when that backup
name already exists; move the earlier backup elsewhere before retrying.

Roll back a bad activation with:

```sh
# Activate the generation immediately before the current one.
home-manager generations
"$(home-manager generations | sed -n '2s/.*-> //p')/activate"
```

`nixie` does not manage generation rollback, so retain these native recovery
commands.

If the generated command is unclear, copy the desired generation's activation
path from `home-manager generations` and run its `activate` executable directly.

## Updates and maintenance

The consumer's `flake.lock` pins Nixpkgs, Home Manager, Ghostty, Noctalia, and
this repository. Normal switches do not update those inputs.

```sh
# Review the lock-file diff after updating all pinned inputs.
cd "$HOME/.config/home-manager"
nix flake update
git diff -- flake.lock

# Build first, then activate the reviewed generation.
home-manager build --impure --flake ".#$(id -un)"
home-manager switch --impure --flake ".#$(id -un)"
```

For the normal update-and-activate workflow without a separate build, run
`nixie all`; it updates all flake inputs and applies Home Manager on macOS.
Keep the native commands above when a build must precede activation.

Keep the Nixpkgs and Home Manager release branches aligned. Do not change
`home.stateVersion` during routine upgrades; it records the compatibility level
of the first installation rather than the currently installed release. Keep
using `--impure`: the shared module fetches the current Firefox add-on and Open
VSX extension releases during each evaluation.

## Optional nix-darwin integration

When a Mac already uses `nix-darwin`, import
`home-manager.darwinModules.home-manager`, set
`home-manager.useGlobalPkgs = true`, pass `inputs` and `machine` with
`home-manager.extraSpecialArgs`, and add the shared module through
`home-manager.sharedModules`. Activation then happens with
`darwin-rebuild switch` instead of `home-manager switch`. Do not activate the
same user through both standalone Home Manager and `nix-darwin`; migrate one
owner at a time to avoid competing generations.

`nixie` applies Home Manager only and does not replace `darwin-rebuild switch`
for macOS system configuration.

## Upstream references

- [Official Nix macOS installation](https://nixos.org/download/)
- [Home Manager standalone flake setup](https://nix-community.github.io/home-manager/nix-flakes/standalone.html)
- [Home Manager as a nix-darwin flake module](https://nix-community.github.io/home-manager/nix-flakes/nix-darwin.html)
