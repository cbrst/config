# VS Code package and extension defaults. A consuming host may override only
# `programs.vscode.package` when it needs another package channel.
{ vscodeExtensions }:
{ pkgs, lib, ... }:
{
  programs.vscode = {
    enable = true;
    # Consumers can select a newer package set without changing their base system.
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
}
