{
  description = "Example generic Linux Home Manager consumer for cbrst/config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # The dotfiles flake owns Ghostty, Noctalia, and Pixibb. Following this
    # consumer's Nixpkgs keeps all packages on one compatible revision.
    dotfiles = {
      url = "github:cbrst/config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      # Machine values and private Ghostty settings live beside this consumer.
      machine = (import ./hosts/machine.nix) // {
        ghostty = builtins.readFile ./hosts/ghostty.conf;
      };
    in
    {
      homeConfigurations.${machine.user} = home-manager.lib.homeManagerConfiguration {
        # The shared profile includes unfree applications such as VSCode and WebStorm.
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit machine; };
        modules = [
          inputs.dotfiles.homeManagerModules.default
          # This module is applied last for machine-specific deep overrides.
          ./hosts/home.nix
        ];
      };
    };
}
