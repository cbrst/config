{
  description = "Portable Home Manager profile and dotfiles";

  # These inputs are part of the user profile itself. Consumers choose their
  # Nixpkgs and make this input follow it, keeping one package universe.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pixibb-downloader = {
      url = "gitlab:krassnik/pixibb-downloader";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  let
    linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
  in {
    # This is a reusable module, not a complete user configuration. The
    # consumer supplies Home Manager, pkgs, and the small `machine` attrset.
    homeManagerModules.default = import ./home-manager/default.nix {
      dotfiles = self.outPath;
      dotfilesInputs = inputs;
    };

    # NixOS installs Ghostty system-wide for the minimal viable desktop. Other
    # Linux consumers receive it through the Home Manager profile instead.
    packages = nixpkgs.lib.genAttrs linuxSystems (system: {
      ghostty = inputs.ghostty.packages.${system}.default;
    });
  };
}
