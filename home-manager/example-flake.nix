{
  description = "Example consumer for cbrst/config home-manager module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty.url = "github:ghostty-org/ghostty";
    noctalia.url = "github:noctalia-dev/noctalia";
    dotfiles = {
      url = "github:cbrst/config";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      # Machine values and private Ghostty settings live beside this consuming flake.
      machine = (import ./hosts/local.nix) // {
        ghostty = builtins.readFile ./hosts/ghostty.conf;
        # Set niri = true to install the shared Niri session and its Noctalia shell.
        niri = true;
      };
    in
    {
      homeConfigurations.${machine.user} = home-manager.lib.homeManagerConfiguration {
        # The shared profile includes unfree applications such as VSCode and WebStorm.
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs machine; };
        modules = [
          "${inputs.dotfiles}/home-manager/default.nix"
          # This module is applied last for machine-specific deep overrides.
          ./hosts/home.nix
        ];
      };
    };
}
