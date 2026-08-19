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
  # Home Manager expects per-profile Firefox extensions below this profile UUID.
  firefoxExtensionProfile = "{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";
  mkFirefoxAddon =
    {
      name,
      addonId,
      slug,
    }:
    pkgs.stdenvNoCC.mkDerivation {
      inherit name;
      # Impure evaluation retrieves AMO's current signed addon release on each switch.
      src = builtins.fetchurl "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      dontUnpack = true;
      installPhase = ''
        # Home Manager discovers profile extensions by their Mozilla addon ID.
        install -Dm444 "$src" "$out/share/mozilla/extensions/${firefoxExtensionProfile}/${addonId}.xpi"
      '';
      passthru = { inherit addonId; };
    };
  # All profiles receive these extensions; Tridactyl is intentionally compositor-profile only.
  commonFirefoxExtensions = [
    (mkFirefoxAddon {
      name = "ublock-origin";
      addonId = "uBlock0@raymondhill.net";
      slug = "ublock-origin";
    })
    (mkFirefoxAddon {
      name = "1password";
      addonId = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
      slug = "1password-x-password-manager";
    })
    (mkFirefoxAddon {
      name = "violentmonkey";
      addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
      slug = "violentmonkey";
    })
    (mkFirefoxAddon {
      name = "stylus";
      addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
      slug = "styl-us";
    })
    # SponsorBlock is shared so YouTube sponsor skipping works in every profile.
    (mkFirefoxAddon {
      name = "sponsorblock";
      addonId = "sponsorBlocker@ajay.app";
      slug = "sponsorblock";
    })
  ];
  tridactylExtension = mkFirefoxAddon {
    name = "tridactyl";
    addonId = "tridactyl.vim@cmcaine.co.uk";
    slug = "tridactyl-vim";
  };
  firefoxSyncSettings = {
    # Firefox Account credentials stay private; these select its Sync engines after sign-in.
    "services.sync.engine.addons" = false;
    "services.sync.engine.addresses" = false;
    "services.sync.engine.bookmarks" = true;
    "services.sync.engine.creditcards" = false;
    "services.sync.engine.history" = true;
    "services.sync.engine.passwords" = false;
    "services.sync.engine.prefs" = false;
    "services.sync.engine.tabs" = false;
  };
  firefoxProfileSettings = firefoxSyncSettings // {
    # Enable the extensions copied into the profile without a first-run prompt.
    "extensions.autoDisableScopes" = 0;
    # Restore the prior window and tabs when Firefox starts normally.
    "browser.startup.page" = 3;
  };
  firefoxSession = pkgs.writeShellScriptBin "firefox-session" (
    # Keep session detection in a versioned script instead of embedding it in generated Nix.
    builtins.readFile "${dotfiles}/firefox/scripts/firefox-session"
  );
  firefoxDefaultProfilePath = machine.firefoxProfilePath or "default";
  firefoxProfilePaths = [
    firefoxDefaultProfilePath
    "wayland"
  ];
  mkFirefoxProfile = path: extensions: {
    inherit path;
    settings = firefoxProfileSettings;
    extensions.packages = extensions;
  };
  mkLatestVscodeExtension =
    {
      publisher,
      name,
    }:
    let
      # Open VSX resolves the current version before Nix fetches its VSIX.
      metadata = builtins.fromJSON (
        builtins.readFile (builtins.fetchurl "https://open-vsx.org/api/${publisher}/${name}/latest")
      );
    in
    pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        inherit publisher name;
        version = metadata.version;
      };
      # Impure evaluation retrieves the VSIX selected by the latest metadata.
      vsix = builtins.fetchurl metadata.files.download;
    };
  vscodeExtensions = with pkgs.vscode-extensions; [
    vscodevim.vim
    jnoortheen.nix-ide
    # Provide TOML syntax support, validation, and formatting across shared VSCode profiles.
    tamasfe.even-better-toml
    # Open VSX's latest metadata keeps unpackaged extensions current on each switch.
    (mkLatestVscodeExtension {
      publisher = "monokai";
      name = "theme-monokai-pro-vscode";
    })
    (mkLatestVscodeExtension {
      publisher = "sst-dev";
      name = "opencode";
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
      # Select the profile that matches the desktop session for shell-launched browsers.
      BROWSER = lib.mkDefault "firefox-session";
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
        # Route terminal and launcher browser requests through the active-session selector.
        firefoxSession
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
    desktopEntries.firefox = {
      # Prefer the session-aware profile selector over the package's stock desktop entry.
      name = "Firefox";
      genericName = "Web Browser";
      exec = "${lib.getExe firefoxSession} %U";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      # Home Manager's desktop-entry module does not expose StartupWMClass.
    };
  }
  // lib.optionalAttrs isLinux {
    mimeApps.defaultApplications = {
      "inode/directory" = lib.mkDefault [ "nemo.desktop" ];
      # Open links through the launcher so each session gets its matching Firefox profile.
      "text/html" = lib.mkDefault [ "firefox.desktop" ];
      "x-scheme-handler/http" = lib.mkDefault [ "firefox.desktop" ];
      "x-scheme-handler/https" = lib.mkDefault [ "firefox.desktop" ];
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
    # Allow Tridactyl to read the XDG configuration deployed by Home Manager.
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
    profiles = {
      # Firefox requires unique IDs and exactly one default profile.
      default = (mkFirefoxProfile firefoxDefaultProfilePath commonFirefoxExtensions) // {
        id = 0;
        isDefault = true;
      };
      wayland = (mkFirefoxProfile "wayland" (commonFirefoxExtensions ++ [ tridactylExtension ])) // {
        id = 1;
        isDefault = false;
        # Preserve the shared extension and startup preferences in the compact profile.
        settings = firefoxProfileSettings // {
          # Keep the Downloads action beside tabs in the compact Wayland layout.
          "browser.uiCustomization.state" = builtins.toJSON {
            currentVersion = 22;
            placements = {
              "TabsToolbar" = [
                "tabbrowser-tabs"
                "new-tab-button"
                "alltabs-button"
                "downloads-button"
              ];
              "nav-bar" = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "urlbar-container"
              ];
              "PersonalToolbar" = [ "import-button" "personal-bookmarks" ];
            };
            seen = [
              "save-to-pocket-button"
              "developer-button"
              "screenshot-button"
              "fxa-toolbar-menu-button"
            ];
            dirtyAreaCache = [ "nav-bar" "TabsToolbar" "PersonalToolbar" ];
            newElementCount = 5;
          };
          # Firefox otherwise ignores userChrome.css in new profiles.
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        # This profile alone removes the navigation bar and native window controls.
        userChrome = builtins.readFile "${dotfiles}/firefox/userChrome-wayland.css";
      };
    };
  };

  home.activation.removeStaleFirefoxExtensionLinks = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    # Recreate only old Home Manager links before the new extension tree is linked.
    extensions_root=${lib.escapeShellArg config.programs.firefox.profilesPath}
    for profile_path in ${lib.concatMapStringsSep " " lib.escapeShellArg firefoxProfilePaths}; do
      extensions_path="$extensions_root/$profile_path/extensions"
      if [[ -L "$extensions_path" ]]; then
        rm -- "$extensions_path"
      fi
    done
  '';

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
        # Reinstall the uv tool when its Python interpreter was garbage-collected or replaced.
        ExecStart = "${pkgs.runtimeShell} -c 'if ! ${config.home.homeDirectory}/.local/bin/headroom --version >/dev/null 2>&1; then ${pkgs.uv}/bin/uv tool install --reinstall --python 3.13 \"headroom-ai[all]\"; fi; ${config.home.homeDirectory}/.local/bin/headroom install apply --preset persistent-service --providers manual'";
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
