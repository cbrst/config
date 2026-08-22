# Declarative editor runtimes shared by every Home Manager consumer.
# Application-specific configuration files remain in ../emacs and ../nvim.
{
  emacsConfig,
  emacsPackage,
  meowsootNvim,
}:
{ pkgs, lib, ... }:
{
  programs.emacs = {
    # Package Emacs and every ELisp dependency through Nix instead of package.el.
    enable = true;
    package = emacsPackage;
  };

  programs.neovim = {
    # Home Manager owns the immutable plugin runtime; Lua only configures it.
    enable = true;
    # Home Manager wraps the unwrapped editor with the declared plugin runtime.
    package = pkgs.neovim-unwrapped;
    extraPackages = [
      # Keep all Neovim language tooling Nix-built and available in its wrapped PATH.
      pkgs.emmet-language-server
      pkgs.lua-language-server
      pkgs.phpactor
      pkgs.stylua
    ];
    plugins = with pkgs.vimPlugins; [
      auto-dark-mode-nvim
      blink-cmp
      codecompanion-nvim
      conform-nvim
      dropbar-nvim
      fidget-nvim
      gitsigns-nvim
      heirline-nvim
      lazydev-nvim
      luasnip
      luvit-meta
      mini-nvim
      monokai-pro-nvim
      meowsootNvim
      neo-tree-nvim
      nui-nvim
      nvim-highlight-colors
      nvim-lint
      nvim-lspconfig
      nvim-treesitter
      outline-nvim
      overseer-nvim
      plenary-nvim
      render-markdown-nvim
      snacks-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      telescope-ui-select-nvim
      todo-comments-nvim
      trouble-nvim
      typescript-tools-nvim
      vim-sleuth
      vim-tridactyl
      which-key-nvim
    ];
  };

  home.file.".emacs.d/init.el".text = lib.mkDefault emacsConfig;
}
