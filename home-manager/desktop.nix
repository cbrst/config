# Optional Linux desktop session features. The default profile deliberately
# avoids choosing a compositor, so generic Linux and macOS remain portable.
{
  dotfiles,
  dotfilesInputs,
}:
{ config, pkgs, lib, ... }:
let
  cfg = config.cbrst.desktop;
  isLinux = pkgs.stdenv.isLinux;
in {
  options.cbrst.desktop = {
    niri = {
      enable = lib.mkEnableOption "the managed Niri session";
      installPackage = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Home Manager installs Niri. Set this to false when NixOS provides it system-wide.";
      };
    };
    noctalia.enable = lib.mkEnableOption "the Noctalia desktop shell";
  };

  # Nix module imports must be static. This makes Noctalia's option schema
  # available everywhere; the `mkIf` block below still leaves it disabled by
  # default and avoids configuring it on desktop-agnostic consumers.
  imports = [
    dotfilesInputs.noctalia.homeModules.default
  ];

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.niri.enable || cfg.noctalia.enable) || isLinux;
          message = "Niri and Noctalia are Linux-only Home Manager features.";
        }
      ];
    }
    (lib.mkIf cfg.niri.enable {
      home.packages = lib.optionals cfg.niri.installPackage [ pkgs.niri ];
      # Noctalia-specific bindings are present only in the full session config.
      xdg.configFile."niri/config.kdl".source = lib.mkDefault (
        if cfg.noctalia.enable
        then "${dotfiles}/niri/config.kdl"
        else "${dotfiles}/niri/minimal-config.kdl"
      );
    })
    (lib.mkIf cfg.noctalia.enable {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };
      xdg.configFile."noctalia".source = lib.mkDefault "${dotfiles}/noctalia";
    })
  ];
}
