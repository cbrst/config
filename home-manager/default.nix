{
  config,
  pkgs,
  lib,
  inputs,
  machine,
  ...
}:
let
  # Keep shared paths relative to the consuming flake's non-flake dotfiles input.
  dotfiles = inputs.dotfiles;
  isLinux = pkgs.stdenv.isLinux;
  noctaliaEnabled = machine.noctalia or false;
  noctaliaModule =
    { pkgs, lib, ... }:
    # Imports must be static, so defer Linux gating until this submodule evaluates.
    lib.mkIf pkgs.stdenv.isLinux {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };
    };
  opencodeConfig =
    lib.replaceStrings
      [ "/Users/cbrst/.local/bin/headroom" ]
      [ "${config.home.homeDirectory}/.local/bin/headroom" ]
      (builtins.readFile "${dotfiles}/opencode/opencode.jsonc");
  vscodeExtensions = with pkgs.vscode-extensions; [
    vscodevim.vim
    jnoortheen.nix-ide
    # These extensions are not packaged in nixpkgs, so their VSIX releases are pinned below.
    (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        publisher = "monokai";
        name = "theme-monokai-pro-vscode";
        version = "2.0.14";
      };
      vsix = pkgs.fetchurl {
        url = "https://open-vsx.org/api/monokai/theme-monokai-pro-vscode/2.0.14/file/monokai.theme-monokai-pro-vscode-2.0.14.vsix";
        hash = "sha256-4YdGtgdxCaRzpwXR2tyoJJxjGjgpimS3nub8mSeMIsw=";
      };
    })
    (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        publisher = "sst-dev";
        name = "opencode";
        version = "0.0.13";
      };
      vsix = pkgs.fetchurl {
        url = "https://open-vsx.org/api/sst-dev/opencode/0.0.13/file/sst-dev.opencode-0.0.13.vsix";
        hash = "sha256-6adXUaoh/OP5yYItH3GAQ7GpupfmTGaxkKP6hYUMYNQ=";
      };
    })
  ];
in
{
  # Noctalia is opt-in; its submodule gates configuration to Linux at evaluation.
  imports = lib.optionals noctaliaEnabled [
    inputs.noctalia.homeModules.default
    noctaliaModule
  ];

  home = {
    username = machine.user;
    homeDirectory = lib.mkDefault (
      machine.homeDirectory or (if isLinux then "/home/${machine.user}" else "/Users/${machine.user}")
    );
    stateVersion = lib.mkDefault (machine.stateVersion or "26.05");
    sessionVariables = {
      EDITOR = lib.mkDefault "nvim";
      TERMINAL = lib.mkDefault (machine.terminal or "ghostty");
      BROWSER = lib.mkDefault "firefox";
      SSH_AUTH_SOCK = lib.mkDefault (machine.sshAuthSock or "$HOME/.1password/agent.sock");
    }
    // lib.optionalAttrs isLinux {
      NIXOS_OZONE_WL = lib.mkDefault "1";
    };
    # Use normal priority so package lists from optional modules merge with these tools.
    packages = (
      with pkgs;
      [
        bat
        bat-extras.batdiff
        cmake
        eza
        fastfetch
        fd
        ffmpeg
        fzf
        gcc
        gnumake
        go
        jetbrains.webstorm
        jq
        lazygit
        lua
        markdownlint-cli
        neovim
        nodejs
        prettier
        opencode
        pkg-config
        python3
        ripgrep
        rustup
        shellcheck
        shfmt
        starship
        tmux
        unzip
        uv
        libwebp
        wezterm
        yt-dlp
        zoxide
        zsh
        nerd-fonts.jetbrains-mono
        commit-mono
        inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
      ]
    );
  };

  xdg = {
    enable = lib.mkDefault true;
    userDirs = {
      enable = lib.mkDefault true;
      createDirectories = lib.mkDefault true;
    };
    configFile = {
      "hypr".source = lib.mkDefault "${dotfiles}/hypr";
      "noctalia".source = lib.mkDefault "${dotfiles}/noctalia";
      "fastfetch".source = lib.mkDefault "${dotfiles}/fastfetch";
      # Per-file Ghostty links leave room for the generated machine override.
      "ghostty/config".source = lib.mkDefault "${dotfiles}/ghostty/config";
      "ghostty/keybindings".source = lib.mkDefault "${dotfiles}/ghostty/keybindings";
      "ghostty/themes".source = lib.mkDefault "${dotfiles}/ghostty/themes";
      "ghostty/machine".text = lib.mkDefault (machine.ghostty or "");
      "lazygit".source = lib.mkDefault "${dotfiles}/lazygit";
      "nvim".source = lib.mkDefault "${dotfiles}/nvim";
      "starship".source = lib.mkDefault "${dotfiles}/starship";
      "tmux".source = lib.mkDefault "${dotfiles}/tmux";
      "wezterm".source = lib.mkDefault "${dotfiles}/wezterm";
      "yt-dlp".source = lib.mkDefault "${dotfiles}/yt-dlp";
      # Keep the zsh entry files and autoloaded OpenCode wrapper together.
      "zsh/env.zsh".source = lib.mkDefault "${dotfiles}/zsh/env.zsh";
      "zsh/dotfiles.zprofile".source = lib.mkDefault "${dotfiles}/zsh/.zprofile";
      "zsh/dotfiles.zshrc".source = lib.mkDefault "${dotfiles}/zsh/.zshrc";
      "zsh/functions".source = lib.mkDefault "${dotfiles}/zsh/functions";
      "zsh/utils".source = lib.mkDefault "${dotfiles}/zsh/utils";
      "zsh/zimrc.zsh".source = lib.mkDefault "${dotfiles}/zsh/zimrc.zsh";
      "zsh/zshrc.zsh".source = lib.mkDefault "${dotfiles}/zsh/zshrc.zsh";
      "opencode/opencode.jsonc".text = lib.mkDefault opencodeConfig;
    };
  }
  // lib.optionalAttrs isLinux {
    mimeApps.defaultApplications = {
      "inode/directory" = lib.mkDefault [ "nemo.desktop" ];
    };
  };

  programs.zsh = {
    # These definitions must merge at normal priority so generated zsh files source the wrapper.
    enable = true;
    dotDir = "${config.home.homeDirectory}/.config/zsh";
    loginExtra = ''
      source "$ZDOTDIR/dotfiles.zprofile"
    '';
    initContent = ''
      source "$ZDOTDIR/dotfiles.zshrc"
    '';
  };

  programs.vscode = {
    # VSCode and its extensions are shared across every Home Manager consumer.
    enable = true;
    # Consumers can select a newer package set for VSCode without changing their base system.
    package = lib.mkDefault pkgs.vscode;
    profiles.default = {
      extensions = vscodeExtensions;
      userSettings = {
        "workbench.colorTheme" = "Monokai Pro";
        "workbench.iconTheme" = "material-icon-theme";
        "editor.fontFamily" = "CommitMono";
        "workbench.experimental.modernUI" = true;
      };
    };
  };

  fonts = lib.mkIf isLinux {
    fontconfig.enable = lib.mkDefault true;
  };

  systemd = lib.mkIf isLinux {
    user.services.headroom-bootstrap = {
      Unit = {
        Description = "Install the Headroom CLI used by the OpenCode profile";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Headroom is not packaged in Nixpkgs; uv isolates it from system Python.
        ExecStart = "${pkgs.runtimeShell} -c 'if [[ ! -x ${config.home.homeDirectory}/.local/bin/headroom ]]; then ${pkgs.uv}/bin/uv tool install --python 3.13 \"headroom-ai[all]\"; fi; ${config.home.homeDirectory}/.local/bin/headroom install apply --preset persistent-service --providers manual'";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };

  gtk = lib.mkIf isLinux {
    enable = lib.mkDefault true;
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
}
