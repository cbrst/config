# Linux-only user services and GTK integration. Keeping these here prevents
# NixOS-specific desktop details from leaking into macOS Home Manager profiles.
{ config, pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  fonts.fontconfig.enable = lib.mkDefault true;

  systemd.user.services.headroom-bootstrap = {
    Unit = {
      Description = "Install the Headroom CLI used by the OpenCode profile";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Reinstall the uv tool when its Python interpreter was garbage-collected or replaced.
      ExecStart = "${pkgs.runtimeShell} -c 'if ! ${config.home.homeDirectory}/.local/bin/headroom --version >/dev/null 2>&1; then ${pkgs.uv}/bin/uv tool install --reinstall --python 3.13 \"headroom-ai[all]\"; fi; ${config.home.homeDirectory}/.local/bin/headroom install apply --preset persistent-service --providers manual'";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Quote the numeric-leading name so systemd generates 1password.service.
  systemd.user.services."1password" = {
    Unit = {
      Description = "1Password Linux desktop client";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs._1password-gui}/bin/1password --silent";
      Restart = "on-abnormal";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.tailscale-systray = {
    Unit = {
      Description = "Tailscale system tray client";
      After = [ "graphical-session.target" ];
    };
    Service = {
      # Use the NixOS system profile so Home Manager does not install Tailscale.
      ExecStart = "/run/current-system/sw/bin/tailscale systray";
      Restart = "on-abnormal";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  gtk = {
    enable = lib.mkDefault true;
    # Keep GTK applications aligned with the session-wide Bibata pointer theme.
    cursorTheme = {
      name = lib.mkDefault "Bibata-Modern-Ice";
      package = lib.mkDefault pkgs.bibata-cursors;
      size = lib.mkDefault 24;
    };
    theme = {
      name = lib.mkDefault "Adwaita-dark";
      package = lib.mkDefault pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = lib.mkDefault "Adwaita";
      package = lib.mkDefault pkgs.adwaita-icon-theme;
    };
    font = {
      name = lib.mkDefault "Noto Sans";
      size = lib.mkDefault 11;
    };
  };

  # Install Bibata and use its familiar blue arrow in XWayland and GTK applications.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
