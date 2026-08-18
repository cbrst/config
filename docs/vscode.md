# VSCode

The shared Home Manager module installs proprietary Microsoft VSCode and its
extensions for every machine that imports `home-manager/default.nix`. The
configuration is declarative: Home Manager installs the selected extensions on
every switch, so the shared setup does not rely on manual VSCode UI installs.

## Consumer Setup

Each consuming flake must import the shared module from its `dotfiles` input;
otherwise it will continue to use any machine-local copy and will not receive
shared VSCode changes. Keep machine-specific overrides after the shared module:

```nix
modules = [
  # Import the shared packages, VSCode configuration, and dotfiles.
  "${inputs.dotfiles}/home-manager/default.nix"
  # Apply settings that belong only to this machine afterwards.
  ./hosts/home.nix
];
```

## Requirements

The consuming flake must allow unfree packages because `pkgs.vscode` is
proprietary. The NixOS flake at `/etc/nixos` already does this. Other consumers
need the equivalent package import:

```nix
# Allow the proprietary VSCode package for this machine.
pkgs = import nixpkgs {
  inherit system;
  config.allowUnfree = true;
};
```

## Apply Changes

After changing this repository, commit and push it, then update the consuming
flake input before switching:

```sh
# Update the shared dotfiles input in the machine flake.
nix flake update dotfiles --flake /etc/nixos

# Rebuild the user environment without rebuilding the NixOS system.
home-manager switch --flake /etc/nixos#cbrst
```

To test uncommitted local changes on the NixOS machine, override the remote
input:

```sh
# Evaluate the local checkout instead of the GitHub dotfiles input.
home-manager switch --flake /etc/nixos#cbrst \
  --override-input dotfiles path:/home/cbrst/Projects/config
```

## Isolated VSCode Upgrades

The NixOS flake can keep its base `nixpkgs` input on a stable release while
using a separate unstable input solely for VSCode. Declare the extra input in
the consuming flake, then import it only in the machine-specific Home Manager
override:

```nix
# Keep system packages on the stable NixOS release.
nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
# Use this input only for applications that need newer releases.
nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
```

```nix
# hosts/home.nix
{ inputs, lib, pkgs, ... }:
let
  # This package set is isolated from the system and Home Manager base package set.
  unstablePkgs = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  # Override the shared module's stable package selection.
  programs.vscode.package = lib.mkForce unstablePkgs.vscode;
}
```

Update and apply only that input when a newer VSCode release is needed:

```sh
# Refresh the isolated source, then install the resulting Home Manager profile.
nix flake update nixpkgs-unstable --flake /etc/nixos
home-manager switch --flake /etc/nixos#cbrst
```

This does not update the NixOS system package set. The unstable VSCode closure
is installed alongside the stable Home Manager packages.

## Change Settings

Add settings to `programs.vscode.profiles.default.userSettings` in
`home-manager/default.nix`. For example, set the installed Monokai Pro theme
and enable Vim line numbers:

```nix
programs.vscode.profiles.default.userSettings = {
  # Use a theme provided by the declaratively installed extension.
  "workbench.colorTheme" = "Monokai Pro";
  # Configure the VSCode Vim extension.
  "vim.number" = true;
};
```

Home Manager manages these settings in VSCode's user configuration. Do not edit
the generated settings file directly; change the Nix expression and run a
switch instead.

## Add Extensions

The `vscodeExtensions` list near the top of `home-manager/default.nix` is the
single shared extension list. It includes Even Better TOML
(`tamasfe.even-better-toml`) for TOML syntax support, validation, and
formatting on every configured machine.

For an extension available in `pkgs.vscode-extensions`, add its attribute to
the list. The Nix REPL can inspect available names:

```sh
# Search the packaged extension attribute set before adding an extension.
nix repl '<nixpkgs>'
```

```nix
vscodeExtensions = with pkgs.vscode-extensions; [
  vscodevim.vim
  jnoortheen.nix-ide
  # Add a packaged extension using its Nix attribute path.
  ms-python.python
];
```

For an extension missing from Nixpkgs, pin a VSIX release with
`pkgs.vscode-utils.buildVscodeMarketplaceExtension`. Use the extension's
publisher and name for `mktplcRef`, pin the exact version in both the URL and
metadata, then calculate the SRI hash:

```sh
# Download a fixed VSIX release and print its Nix-compatible content hash.
nix store prefetch-file --json 'https://open-vsx.org/api/PUBLISHER/NAME/VERSION/file/PUBLISHER.NAME-VERSION.vsix'
```

```nix
# Pin an unpackaged extension so builds remain reproducible.
(pkgs.vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    publisher = "publisher";
    name = "extension-name";
    version = "1.2.3";
  };
  vsix = pkgs.fetchurl {
    url = "https://open-vsx.org/api/publisher/extension-name/1.2.3/file/publisher.extension-name-1.2.3.vsix";
    hash = "sha256-REPLACE-WITH-PREFETCH-HASH=";
  };
})
```

Keep the version, URL, and hash together when upgrading an external extension.
Run `home-manager switch` to verify the revised configuration.
