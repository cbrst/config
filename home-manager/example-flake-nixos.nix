{
  description = "Example NixOS consumer with standalone Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "github:cbrst/config";
      # Reuse the system's package set for the dotfiles and its dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    machine = {
      user = "YOUR_USERNAME";
      hostName = "YOUR_HOSTNAME";
      timeZone = "Europe/Berlin";
      keyMap = "us";
      stateVersion = "26.05";
    };
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs machine; };
      modules = [
        ./hosts/configuration.nix
        # NixOS owns the system desktop. Home Manager remains standalone below.
        ({ ... }: {
          programs.niri.enable = true;
          environment.systemPackages = [ inputs.dotfiles.packages.${system}.ghostty ];
        })
      ];
    };

    homeConfigurations."${machine.user}@example" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit machine; };
      modules = [
        inputs.dotfiles.homeManagerModules.default
        {
          # NixOS already installs Niri; the user profile owns its full config.
          cbrst.desktop = {
            niri = {
              enable = true;
              installPackage = false;
            };
            noctalia.enable = true;
          };
        }
        ./hosts/home.nix
      ];
    };
  };
}
