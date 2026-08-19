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
  mkFirefoxAddon =
    {
      name,
      addonId,
      url,
      hash,
    }:
    pkgs.stdenvNoCC.mkDerivation {
      inherit name;
      src = pkgs.fetchurl { inherit url hash; };
      dontUnpack = true;
      installPhase = ''
        # Home Manager discovers profile extensions by their Mozilla addon ID.
        install -Dm444 "$src" "$out/share/mozilla/extensions/${addonId}.xpi"
      '';
      passthru = { inherit addonId; };
    };
  firefoxExtensions = [
    (mkFirefoxAddon {
      name = "ublock-origin-1.73.0";
      addonId = "uBlock0@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4940584/ublock_origin-1.73.0.xpi";
      hash = "sha256-vMxRp3MVCvSvbh/WLHv963I4t5/yOBuZj6ny449keGo=";
    })
    (mkFirefoxAddon {
      name = "tridactyl-1.24.6";
      addonId = "tridactyl.vim@cmcaine.co.uk";
      url = "https://addons.mozilla.org/firefox/downloads/file/4854935/tridactyl_vim-1.24.6.xpi";
      hash = "sha256-E6vW/vK10TouynCt21SFpPuggAQ29qEsV6uwPzz5kgU=";
    })
    (mkFirefoxAddon {
      name = "1password-8.12.32.33";
      addonId = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4951729/1password_x_password_manager-8.12.32.33.xpi";
      hash = "sha256-uVL7YXAn94tWSf/diPWLwH2pLSHcc8xrtuKIeeXi4ws=";
    })
    (mkFirefoxAddon {
      name = "violentmonkey-2.47.0";
      addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4941753/violentmonkey-2.47.0.xpi";
      hash = "sha256-zOgbiucGTn1wqAX2HnMZD71Ua908eEg9O3Ar4AOxMW8=";
    })
    (mkFirefoxAddon {
      name = "stylus-2.4.10";
      addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4947910/styl_us-2.4.10.xpi";
      hash = "sha256-kHwevP6qp4iQ74LrsaAE+OYH/kgglRZc0bgwk3MRISk=";
    })
  ];
  vscodeExtensions = with pkgs.vscode-extensions; [
    vscodevim.vim
    jnoortheen.nix-ide
    # Provide TOML syntax support, validation, and formatting across shared VSCode profiles.
    tamasfe.even-better-toml
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
      "niri/config.kdl".source = lib.mkDefault "${dotfiles}/niri/config.kdl";
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
      # Tridactyl loads its configuration from the user's XDG config directory.
      "tridactyl".source = lib.mkDefault "${dotfiles}/tridactyl";
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

  programs.firefox = {
    # NixOS may own the browser package while Home Manager owns its profile.
    enable = true;
    package = lib.mkDefault (if machine.firefoxSystem or false then null else pkgs.firefox);
    profiles.default = {
      # Preserve the profile created by Firefox before Home Manager manages it.
      path = machine.firefoxProfilePath or "default";
      settings = {
        # Enable the extensions copied into the profile without a first-run prompt.
        "extensions.autoDisableScopes" = 0;
      };
      extensions.packages = firefoxExtensions;
    };
  };

  programs.vscode = {
    # VSCode and its extensions are shared across every Home Manager consumer.
    enable = true;
    # Consumers can select a newer package set for VSCode without changing their base system.
    package = lib.mkDefault pkgs.vscode;
    profiles.default = {
      extensions = vscodeExtensions;
      userSettings = {
        "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
        "editor.fontFamily" = "CommitMono";
        "workbench.experimental.modernUI" = true;
        "workbench.iconTheme" = "Monokai Pro (Filter Spectrum) Icons";
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
  home.pointerCursor = lib.mkIf isLinux {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
