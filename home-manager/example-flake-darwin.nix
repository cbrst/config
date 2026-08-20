{
  description = "Example standalone macOS consumer for cbrst/config";

  inputs = {
    # Keep Nixpkgs and Home Manager on matching release branches.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty.url = "github:ghostty-org/ghostty";
    noctalia.url = "github:noctalia-dev/noctalia";
    # This repository is a module source rather than a flake.
    dotfiles = {
      url = "github:cbrst/config";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      # Replace this value with the output of `id -un`.
      username = "YOUR_USERNAME";
      # Apple Silicon uses aarch64-darwin; Intel Macs use x86_64-darwin.
      system = "aarch64-darwin";
      machine = {
        user = username;
        hostName = "YOUR_MAC_HOSTNAME";
        # Use the native 1Password SSH agent socket when that agent is enabled.
        sshAuthSock = "/Users/${username}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        # Linux-only desktop modules remain disabled on macOS.
        niri = false;
        noctalia = false;
        stateVersion = "26.05";
      };
      # The shared profile includes unfree applications such as VSCode and WebStorm.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs machine; };
        modules = [
          "${inputs.dotfiles}/home-manager/default.nix"
          {
            # Install the Home Manager CLI into the activated user profile.
            programs.home-manager.enable = true;
          }
        ];
      };
    };
}
