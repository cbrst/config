# Emacs

Home Manager installs Emacs declaratively through
`home-manager/default.nix`. Linux uses the standard `emacs` package. macOS uses
`emacs-macport`, the native macOS build with proper window-system integration.
The Nix package wrapper also supplies all ELisp dependencies, so Emacs does not
bootstrap or mutate a `package.el` package directory.

The editable source is `emacs/init.el`; Home Manager generates
`~/.emacs.d/init.el` from it with the Nix-built Tree-sitter parser path. Do not
edit the generated file in the home directory.

## Behavior

The configuration mirrors the Neovim setup where Emacs has an equivalent:

- Evil, Evil Collection, Evil Surround, and Evil Commentary provide Vim states,
  motions, text objects, surround commands, and commenting.
- CommitMono is the explicit 10-point GUI font, matching the terminal font that
  hosts Neovim. Extra line spacing keeps the smaller type readable. Monokai Pro
  Spectrum is the dark palette, matching Neovim and Ghostty.
- Moody provides a compact native modeline with a flat-left,
  Spectrum-colored Evil ribbon, Nerd Font mode icons, flat one-pixel window
  separators, Git branch icon, concise Flycheck diagnostics, right-aligned
  cursor position, highlighted active line, readable fringes, and unobtrusive
  Treemacs. Git buffers also show their current branch and cached worktree
  status: `+N` staged, `~N` unstaged, `?N` untracked, and `!N` conflicted
  files. Emacs refreshes the summary after saving or reverting a file.
- Relative line numbers, two-column literal tabs, clipboard
  integration, persistent undo and history, cursor margin, right/below
  splitting, and yank highlighting match the editor defaults.
- Vertico, Orderless, Marginalia, Consult, and Embark replace Telescope's fuzzy
  searching and action workflow. Orderless flex matching supports fzf-style
  in-order fuzzy input; use `~` to explicitly force flex matching for one
  component. Large file, buffer, project, grep, and recent-file prompts use
  Vertico Buffer, while short prompts remain in the minibuffer. Nerd Icons add
  candidate, Corfu, Dired, Treemacs, and modeline icons. Corfu and Cape provide
  in-buffer completion.
- Projectile, Treemacs, Magit, Diff-hl, Flycheck, LSP Mode, Format All,
  Tree-sitter Auto, Smartparens, and Rainbow Delimiters cover project search,
  tree browsing, Git hunks, diagnostics, language tools, formatting, syntax,
  auto-pairs, and bracket highlighting.

Emacs 30's built-in Tree-sitter support is active through `treesit-auto`.
Home Manager builds a platform-correct parser directory for Bash, CSS, HTML,
JavaScript, JSON, KDL, Lua, Markdown, Nix, PHP, TSX, TypeScript, and YAML; it
does not download or compile grammars at Emacs startup. Use
`M-x treesit-parser-list` in a buffer to confirm its attached parser.

LSP starts for Lua, PHP, TypeScript, JavaScript, and web buffers. It deliberately
does not download language servers. Put the relevant server executable on
`PATH`, such as `lua-language-server`, `phpactor`, or
`typescript-language-server`; this follows the existing Neovim configuration's
separation between editor configuration and language-server provisioning.

KDL files use `kdl-mode`, with the Nix-provided KDL parser attached for syntax
structure. `SPC f` runs `kdlfmt format --stdin` on the current KDL buffer; it
only replaces the buffer after a successful formatter result.

## Keymaps

Evil normal and visual states use Space as the leader. Press Space and wait for
Which Key to show the available bindings. The closest Neovim equivalents are:

- `SPC s f`, `SPC s g`, `SPC s w`: project files, ripgrep, or ripgrep the symbol
  at point.
- `SPC s n`, `SPC SPC`: Emacs configuration directory or open buffers.
- `SPC /`, `SPC s /`: search the current buffer or all open buffers.
- `gd`, `gr`, `gI`, `gD`: definition, references, implementation, declaration.
- `SPC rn`, `SPC ca`, `SPC ds`: rename, code action, document symbols.
- `SPC f`: format the current buffer.
- `SPC vd`, `SPC vt`, `SPC vo`, `SPC vw`: diagnostics, file tree, outline, or
  whitespace rendering.
- `SPC gs`, `SPC hp`, `SPC hr`, `]c`, `[c`: Magit status, preview or revert the
  current Git hunk, and next or previous hunk.
- `SPC at`: start or reuse the project OpenCode session.
- `SPC ac`, `SPC ai`: compose an OpenCode prompt or interrupt its current
  request. OpenCode uses Agent Shell over ACP, not a terminal emulator.
- `SPC pp`, `SPC bb`: switch projects or buffers.
- `SPC tt`, `SPC tn`, `SPC tf`, `C-.`: toggle a project terminal, start a new
  terminal, focus or hide it, or toggle the project terminal from anywhere.
- `SPC or`, `SPC ot`, `SPC oa`, `SPC oc`: choose a project task, show task
  output, rerun the last task, or clear its output.
- `C-h`, `C-j`, `C-k`, `C-l`: move among split windows.

Treemacs uses Nerd Font icons, no line numbers, and a compact root heading.
Treemacs and Magit buffers are shaded slightly darker than editable source
buffers. Which Key supplies descriptions for all configured leader groups and
commands rather than showing raw command names.

## Agents And Tasks

Agent Shell starts `opencode acp` and communicates through the Agent Client
Protocol. It reuses project sessions, supports Emacs-native prompts, tracks
agent edits and permissions, and avoids rendering OpenCode's full-screen TUI in
an Emacs terminal. Its buffer opens in a 42% right-side vertical split and is
reused for the active session. Authenticate OpenCode once outside Emacs with its
normal `opencode auth login` command.

Vterm is the general interactive terminal for shells, SSH, LazyGit, and other
full-screen terminal applications. It uses a project-local terminal buffer and
opens in the project root.

Compile Multi is the project task runner. It exposes Build, Test, Lint, and Nix
check through Vertico. Projects can replace or extend these defaults with
`compile-multi-dir-local-config` in `.dir-locals.el`.

```elisp
;; .dir-locals.el: add project-specific Compile Multi tasks.
((nil . ((compile-multi-dir-local-config
          . ((t . (("Unit tests" . "npm test")
                   ("Type check" . "npm run typecheck"))))))))
```

## Maintenance

Apply the shared Home Manager profile after changing either the Nix package list
or `emacs/init.el`:

```sh
# Rebuild the configured user environment and relink the Emacs init file.
home-manager switch --flake /etc/nixos#cbrst@asgard
```

Alternatively, run `nixie home`, which refreshes the `dotfiles` input before
applying Home Manager.

Verify that Emacs loads the declarative configuration without opening a frame:

```sh
# Evaluate the installed init file in batch mode.
emacs --batch --load ~/.emacs.d/init.el
```
