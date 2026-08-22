<!-- Repository-level agent instructions -->

# Repository Instructions

## What this is

This repository contains personal configuration managed primarily through a
shared Home Manager module. It must evaluate and deploy on NixOS, other Linux
distributions, and macOS.

The repository is a flake that owns shared user-profile inputs and exposes
`homeManagerModules.default`. Consumers pin Nixpkgs and Home Manager, then make
this flake's Nixpkgs input follow theirs. Do not add machine-specific inputs.

Read `README.md` and the relevant file in `docs/` before changing an unfamiliar
module. They define the supported deployment and recovery procedures.

## Configuration ownership

`home-manager/default.nix` owns every shared package and configuration file
deployed by this repository. Do not add a parallel provisioning, linking, or
package-installation path outside Home Manager.

Keep shared defaults in this repository and machine-specific values in the
consuming machine flake or override module. Never add hostnames, user-specific
paths, tokens, credentials, private keys, or other secrets to tracked files.

## Platform support

Treat cross-platform evaluation as a requirement, not a future enhancement.

- Gate Linux-only packages, systemd services, desktop entries, GTK, Niri,
  Noctalia, and Linux paths with `pkgs.stdenv.isLinux` or the established
  `isLinux` binding.
- Gate macOS-only behavior with the appropriate Darwin platform check.
- Prefer portable shell and POSIX-compatible behavior where practical. When a
  script requires Bash or Zsh features, declare the interpreter explicitly.
- Preserve the `machine` attrset as the interface for documented per-machine
  values. Add a field only when it is genuinely shared across consumers; use
  `cbrst.desktop.*` options for optional user-session features.

## Nix and Home Manager

Use the existing module style and prefer `lib.mkDefault` for shared values that
machine overrides should replace. Imports must be static; keep their configured
behavior platform-gated with `lib.mkIf` and explicit assertions.

This module intentionally fetches current Firefox add-ons and Open VSX
extensions during evaluation. Do not make it pure by accident or remove
`--impure` from documented build and switch commands unless those fetches are
made reproducible in the same change.

Do not change `home.stateVersion` as part of normal maintenance. It is a
compatibility value selected by each consuming machine.

## Commenting

Always include useful comments in generated code and configuration. Explain
non-obvious intent, platform constraints, compatibility choices, and external
workarounds; do not narrate self-evident assignments.

Group related code into sections with banner comments using these Unicode
borders. Adapt the comment prefix to the file format:

╭──────────────╮
│ Comment here │
╰─════════════─╯

Maintain the surrounding file's indentation, formatter, naming conventions,
and comment syntax. Prefer focused edits over broad rewrites of generated or
declarative configuration.

## Userscripts

Safari Userscripts does not provide `GM.download`. For userscripts that download
files, provide a Blob URL fallback that does not navigate the current tab.

Keep userscripts compatible with their declared manager and browser targets.
Avoid browser-specific APIs unless there is a tested fallback or the script is
explicitly scoped to that browser. Do not expose credentials, cookies, or other
private browser data in a script.

## OpenCode

`opencode/opencode.jsonc` is the checked-in source for portable OpenCode
routing and MCP configuration. Do not run `headroom wrap opencode` or install
Headroom around OpenCode; those flows can rewrite the managed configuration.

Local credentials, runtime dependencies, and machine-specific OpenCode state
are intentionally untracked. Restart OpenCode after changing its managed
configuration.

## Documentation

Document every configuration change in `docs/`, including configuration and
maintenance examples when applicable. Update `README.md` when the change
affects its top-level setup, activation, supported-platform, or module-owner
guidance.

Use commands that are safe to paste. Label destructive commands, explain
required flags such as `--impure`, and include verification or recovery steps
for changes that affect activation or services.

## Validation

Run the narrowest relevant checks before finishing and report any check that
could not be run.

- Shell changes: run `shellcheck` when available and exercise an applicable
  non-mutating command or load path.
- Home Manager changes: evaluate or build through a consuming flake when one is
  available; use `--impure` for this repository's current module.
- Editor, terminal, browser, and userscript changes: validate the native syntax
  where tooling exists and manually inspect the affected load path or command.
- Documentation-only changes: verify referenced paths, commands, option names,
  and platform statements against the repository.

Do not activate a Home Manager generation, overwrite user files, install
packages, or run destructive setup operations merely to validate a change
unless the user explicitly asks for it.
