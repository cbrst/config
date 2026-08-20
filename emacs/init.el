;; -*- lexical-binding: t; -*-
;; This configuration mirrors the repository's Neovim workflow with native Emacs tools.

;; Keep generated and transient files out of the configuration directory.
(setq backup-directory-alist `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t))
      create-lockfiles nil)
(make-directory (expand-file-name "backups/" user-emacs-directory) t)
(make-directory (expand-file-name "auto-save/" user-emacs-directory) t)

;; Match Neovim's editing defaults: line numbers, two-column tabs, clipboard, and splits.
(setq-default indent-tabs-mode t
              tab-width 2
              standard-indent 2
              fill-column 100
              display-line-numbers-type 'relative)
(setq-default show-trailing-whitespace nil)
(setq inhibit-startup-screen t
      ring-bell-function #'ignore
      use-dialog-box nil
      select-enable-clipboard t
      scroll-margin 10
      scroll-conservatively 101
      split-width-threshold 0
      split-height-threshold nil)
(when (fboundp 'menu-bar-mode)
  ;; Window-system UI controls are unavailable in some terminal-only builds.
  (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(global-auto-revert-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(global-so-long-mode 1)
(when (fboundp 'pixel-scroll-precision-mode)
  ;; Use smooth scrolling when the current Emacs build supports it.
  (pixel-scroll-precision-mode 1))
(when (eq system-type 'darwin)
  ;; Preserve common macOS shortcuts while keeping Option available for text input.
  (setq mac-command-modifier 'meta
        mac-option-modifier nil))

;; Use the same dark Monokai Pro Spectrum palette as Neovim and Ghostty.
(require 'monokai-pro-spectrum-theme)
(load-theme 'monokai-pro-spectrum t)

;; Keep frames compact while making the terminal's CommitMono face explicit in GUI Emacs.
(setq-default cursor-type 'bar
              cursor-in-non-selected-windows 'hollow
              line-spacing 0.4)
(blink-cursor-mode -1)
(defun cbrst/setup-frame (frame)
  "Apply the shared editor typography and restrained chrome to FRAME."
  (when (display-graphic-p frame)
    ;; CommitMono is already installed by Home Manager for terminal and GUI consistency.
    (when (find-font (font-spec :family "CommitMono"))
      (set-face-attribute 'default frame :family "CommitMono" :height 105))
    (set-face-attribute 'fixed-pitch frame :family "CommitMono"))
  (set-face-attribute 'line-number frame :foreground "#69676c")
  (set-face-attribute 'line-number-current-line frame :foreground "#fbf8ff" :weight 'bold)
  (set-face-attribute 'cursor frame :background "#fd9353")
  (set-face-attribute 'fringe frame :background "#222222"))
(add-hook 'after-make-frame-functions #'cbrst/setup-frame)
(cbrst/setup-frame (selected-frame))
(fringe-mode 10)
(global-hl-line-mode 1)
(window-divider-mode 1)
(setq window-divider-default-right-width 1
      window-divider-default-bottom-width 1
      window-divider-default-places t)
;; Use a single flat separator instead of Emacs' default raised divider treatment.
(dolist (face '(window-divider window-divider-first-pixel window-divider-last-pixel))
  (set-face-attribute face nil :foreground "#363537" :background "#363537"))

;; Evil supplies Vim motions, operators, visual selection, and a familiar undo model.
(setq evil-want-integration t
      evil-want-keybinding nil
      evil-undo-system 'undo-fu)
(require 'undo-fu)
(require 'undo-fu-session)
(undo-fu-session-global-mode 1)
(require 'evil)
(evil-mode 1)
(require 'evil-collection)
(evil-collection-init)
(require 'evil-surround)
(global-evil-surround-mode 1)
(require 'evil-commentary)
(evil-commentary-mode 1)

;; Completion and minibuffer tools correspond to Telescope's fuzzy search workflow.
(require 'vertico)
(vertico-mode 1)
(require 'vertico-buffer)
(require 'vertico-multiform)
(setq vertico-buffer-display-action
      '(display-buffer-in-direction (direction . below) (window-height . 0.45))
      vertico-multiform-commands
      '((consult-buffer buffer)
        (consult-ripgrep buffer)
        (consult-recent-file buffer)
        (projectile-find-file buffer)
        (projectile-switch-project buffer)))
(vertico-multiform-mode 1)
(require 'orderless)
(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides '((file (styles partial-completion)))
      orderless-matching-styles '(orderless-literal orderless-initialism orderless-flex))
(require 'marginalia)
(marginalia-mode 1)
(require 'nerd-icons-completion)
(nerd-icons-completion-mode 1)
(require 'which-key)
(setq which-key-idle-delay 0.3)
(which-key-mode 1)
(require 'corfu)
(setq corfu-auto t
      corfu-cycle t)
(global-corfu-mode 1)
(require 'nerd-icons-corfu)
(add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)
(require 'cape)
(add-to-list 'completion-at-point-functions #'cape-file)
(add-to-list 'completion-at-point-functions #'cape-dabbrev)

;; Moody keeps a compact native modeline while rendering the key states as tabs.
(require 'moody)
(setq moody-mode-line-height 24)
(set-face-attribute 'mode-line-active nil :box nil :background "#282828" :foreground "#fbf8ff")
(set-face-attribute 'mode-line-inactive nil :box nil :background "#222222" :foreground "#69676c")
(defface cbrst-mode-line-tab-edge
  '((t :background "#222222"))
  "Moody transition face matching the filename tab background.")
(defface cbrst-mode-line-normal
  '((t :foreground "#5ad4e6" :background "#2d4649" :weight bold))
  "Moody face for Evil normal state.")
(defface cbrst-mode-line-insert
  '((t :foreground "#7bd88f" :background "#344638" :weight bold))
  "Moody face for Evil insert state.")
(defface cbrst-mode-line-visual
  '((t :foreground "#fce566" :background "#4d492f" :weight bold))
  "Moody face for Evil visual state.")
(defface cbrst-mode-line-replace
  '((t :foreground "#fc618d" :background "#4d2e37" :weight bold))
  "Moody face for Evil replace state.")
(defface cbrst-mode-line-emacs
  '((t :foreground "#948ae3" :background "#393748" :weight bold))
  "Moody face for Evil Emacs state.")
(defun cbrst/mode-line-evil-ribbon (label face)
  "Return LABEL as a right-slanted Spectrum Moody ribbon using FACE.
The first modeline item needs a flat left edge, so discard Moody's left slant."
  (let ((moody-ribbon-background `(,face :background)))
    (cdr (moody-ribbon (propertize label 'face face) nil 'down
                       'cbrst-mode-line-tab-edge 'cbrst-mode-line-tab-edge))))

(defun cbrst/mode-line-evil-state ()
  "Return the current Evil state as a flat-left Spectrum-colored Moody ribbon."
  (when (bound-and-true-p evil-local-mode)
    (pcase evil-state
      ('normal (cbrst/mode-line-evil-ribbon " N " 'cbrst-mode-line-normal))
      ('insert (cbrst/mode-line-evil-ribbon " I " 'cbrst-mode-line-insert))
      ('visual (cbrst/mode-line-evil-ribbon " V " 'cbrst-mode-line-visual))
      ('replace (cbrst/mode-line-evil-ribbon " R " 'cbrst-mode-line-replace))
      (_ (cbrst/mode-line-evil-ribbon " E " 'cbrst-mode-line-emacs)))))
(defun cbrst/mode-line-buffer-name ()
  "Return the filename tab joined directly to the preceding Evil ribbon."
  (cdr (moody-tab (concat (or (nerd-icons-icon-for-mode major-mode) "") " " (buffer-name)) 24 'down)))
(defun cbrst/mode-line-vc ()
  "Return Git branch and file status as a Moody ribbon when available."
  (when vc-mode
    (let* ((file (buffer-file-name))
           ;; `vc-state' is nil for an unmodified file and reports Git changes otherwise.
           (status (and file (vc-state file)))
           (label (concat (string-trim-left vc-mode)
                          (pcase status
                            ('edited " *")
                            ('added " +")
                            ('removed " -")
                            ('unregistered " ?")
                            ('conflict " !")
                            ('needs-merge " !")
                            (_ "")))))
      (moody-ribbon label nil 'up))))
;; Evil otherwise injects its own <N>/<I>/... tag beside the custom ribbon.
(setq evil-mode-line-format nil)
(defconst cbrst/mode-line-format
  '((:eval (cbrst/mode-line-evil-state))
    (:eval (cbrst/mode-line-buffer-name))
    " " mode-line-process
    " " (:eval (cbrst/mode-line-vc))
    "  " flycheck-mode-line
    "  " mode-name
    "  " mode-line-position)
  "Minimal Moody modeline shared by editor and tool buffers.")
(setq-default mode-line-format cbrst/mode-line-format)
(dolist (buffer (buffer-list))
  ;; Update early buffers that Evil initialized before this modeline was installed.
  (with-current-buffer buffer
    (setq-local mode-line-format cbrst/mode-line-format)))

;; Project, Git, tree, diagnostics, and language tooling match the Neovim plugins.
(require 'projectile)
(projectile-mode 1)
(require 'treemacs)
(require 'treemacs-evil)
(require 'treemacs-nerd-icons)
(setq treemacs-width 32
      treemacs-is-never-other-window t
      treemacs-show-hidden-files nil
      treemacs-sorting 'alphabetic-asc
      treemacs-no-png-images nil)
(treemacs-load-theme "nerd-icons")
;; Keep file navigation quiet: no line numbers or oversized root text.
(defun cbrst/treemacs-appearance ()
  "Apply the focused side-pane appearance to the current Treemacs buffer."
  (display-line-numbers-mode -1)
  (face-remap-add-relative 'default :background "#1b1b1b")
  (face-remap-add-relative 'fringe :background "#1b1b1b"))
(add-hook 'treemacs-mode-hook #'cbrst/treemacs-appearance)
(set-face-attribute 'treemacs-root-face nil :underline nil :height 1.0 :weight 'bold)
(set-face-attribute 'treemacs-window-background-face nil :background "#1b1b1b")
(set-face-attribute 'treemacs-hl-line-face nil :background "#282828")
(require 'magit)
(defun cbrst/shade-tool-buffer ()
  "Distinguish transient tool buffers from editable source buffers."
  (face-remap-add-relative 'default :background "#1b1b1b")
  (face-remap-add-relative 'fringe :background "#1b1b1b"))
(add-hook 'magit-mode-hook #'cbrst/shade-tool-buffer)
(require 'nerd-icons-dired)
(add-hook 'dired-mode-hook #'nerd-icons-dired-mode)
(require 'diff-hl)
(global-diff-hl-mode 1)
(require 'diff-hl-flydiff)
(diff-hl-flydiff-mode 1)
(require 'flycheck)
(global-flycheck-mode 1)
(require 'format-all)
(add-hook 'prog-mode-hook #'format-all-mode)
(require 'lsp-mode)
(setq lsp-enable-suggest-server-download nil
      lsp-headerline-breadcrumb-enable nil)
(dolist (hook '(lua-mode-hook php-mode-hook typescript-mode-hook js-mode-hook js-ts-mode-hook web-mode-hook))
  ;; Start LSP only for language modes covered by the Neovim setup.
  (add-hook hook #'lsp-deferred))
(require 'lsp-ui)
(setq lsp-ui-doc-enable nil
      lsp-ui-sideline-show-diagnostics t)
(require 'treesit)
(require 'treesit-auto)
(add-to-list 'treesit-extra-load-path "@emacsTreeSitterGrammars@")
(setq treesit-auto-install nil)
(global-treesit-auto-mode 1)
(require 'smartparens-config)
(smartparens-global-mode 1)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook 'markdown-mode-hook #'visual-line-mode)

;; Use vterm for terminal applications and Agent Shell's ACP integration for OpenCode.
(require 'vterm)
(require 'vterm-toggle)
(setq vterm-shell (or (getenv "SHELL") shell-file-name)
      vterm-toggle-scope 'project
      vterm-toggle-project-root t
      vterm-toggle-hide-method 'delete-window)
(defun cbrst/vterm-appearance ()
  "Apply tool-buffer styling and terminal-friendly Evil behavior to vterm."
  (display-line-numbers-mode -1)
  (face-remap-add-relative 'default :background "#1b1b1b")
  (face-remap-add-relative 'fringe :background "#1b1b1b")
  (evil-insert-state))
(add-hook 'vterm-mode-hook #'cbrst/vterm-appearance)
(evil-define-key 'insert vterm-mode-map (kbd "C-w") #'evil-normal-state)

(require 'agent-shell)
(require 'agent-shell-opencode)
(setq agent-shell-opencode-authentication (agent-shell-opencode-make-authentication :none t)
      agent-shell-preferred-agent-config (agent-shell-opencode-make-agent-config)
      agent-shell-prefer-viewport-interaction t)
(add-hook 'agent-shell-mode-hook #'cbrst/shade-tool-buffer)
(evil-define-key 'insert agent-shell-mode-map (kbd "RET") #'newline)
(evil-define-key 'normal agent-shell-mode-map (kbd "RET") #'comint-send-input)

;; Compile Multi presents project commands through the existing Vertico interface.
(require 'compile-multi)
(setq compile-multi-config
      '((t . (("Build" . "make")
              ("Test" . "make test")
              ("Lint" . "make lint")
              ("Nix check" . "nix flake check")))))

(defun cbrst/show-task-output ()
  "Show the most recent project task output buffer."
  (interactive)
  (if-let ((buffer (get-buffer "*compilation*")))
      (pop-to-buffer buffer)
    (user-error "No task output is available")))

(defun cbrst/clear-task-output ()
  "Clear the most recent project task output without deleting its buffer."
  (interactive)
  (if-let ((buffer (get-buffer "*compilation*")))
      (with-current-buffer buffer
        ;; Compilation output is read-only, so temporarily allow the buffer to be erased.
        (let ((inhibit-read-only t))
          (erase-buffer)))
    (user-error "No task output is available")))

;; Keep a small command layer so multiple leader bindings can share exact behavior.
(defun cbrst/consult-ripgrep-at-point ()
  "Search the current project for the symbol at point."
  (interactive)
  (consult-ripgrep nil (thing-at-point 'symbol t)))

(defun cbrst/find-emacs-config ()
  "Open the declarative Emacs configuration directory."
  (interactive)
  (find-file user-emacs-directory))

(defun cbrst/opencode ()
  "Start or reuse the OpenCode Agent Shell session for this project."
  (interactive)
  (agent-shell))

;; Define Neovim-compatible leader bindings in Evil normal and visual states.
(defvar cbrst/leader-map (make-sparse-keymap)
  "Commands reached through the Space leader key.")
(evil-define-key '(normal visual) 'global (kbd "SPC") cbrst/leader-map)
(keymap-set cbrst/leader-map "s f" #'projectile-find-file)
(keymap-set cbrst/leader-map "s g" #'consult-ripgrep)
(keymap-set cbrst/leader-map "s w" #'cbrst/consult-ripgrep-at-point)
(keymap-set cbrst/leader-map "s /" #'consult-line-multi)
(keymap-set cbrst/leader-map "s ." #'consult-recent-file)
(keymap-set cbrst/leader-map "s n" #'cbrst/find-emacs-config)
(keymap-set cbrst/leader-map "SPC" #'consult-buffer)
(keymap-set cbrst/leader-map "/" #'consult-line)
(keymap-set cbrst/leader-map "f" #'format-all-buffer)
(keymap-set cbrst/leader-map "v d" #'flycheck-list-errors)
(keymap-set cbrst/leader-map "v t" #'treemacs)
(keymap-set cbrst/leader-map "v o" #'consult-imenu)
(keymap-set cbrst/leader-map "v w" #'whitespace-mode)
(keymap-set cbrst/leader-map "g s" #'magit-status)
(keymap-set cbrst/leader-map "h p" #'diff-hl-show-hunk)
(keymap-set cbrst/leader-map "h r" #'diff-hl-revert-hunk)
(keymap-set cbrst/leader-map "a t" #'cbrst/opencode)
(keymap-set cbrst/leader-map "a c" #'agent-shell-prompt-compose)
(keymap-set cbrst/leader-map "a i" #'agent-shell-interrupt)
(keymap-set cbrst/leader-map "r n" #'lsp-rename)
(keymap-set cbrst/leader-map "c a" #'lsp-execute-code-action)
(keymap-set cbrst/leader-map "d s" #'consult-imenu)
(keymap-set cbrst/leader-map "q" #'flycheck-list-errors)
(keymap-set cbrst/leader-map "Q Q" #'save-buffers-kill-emacs)
(keymap-set cbrst/leader-map "p p" #'projectile-switch-project)
(keymap-set cbrst/leader-map "b b" #'consult-buffer)
(keymap-set cbrst/leader-map "t t" #'vterm-toggle-cd)
(keymap-set cbrst/leader-map "t n" #'vterm)
(keymap-set cbrst/leader-map "t f" #'vterm-toggle)
(keymap-set cbrst/leader-map "o r" #'compile-multi)
(keymap-set cbrst/leader-map "o t" #'cbrst/show-task-output)
(keymap-set cbrst/leader-map "o a" #'recompile)
(keymap-set cbrst/leader-map "o c" #'cbrst/clear-task-output)
(global-set-key (kbd "C-.") #'vterm-toggle-cd)

;; Replace raw command symbols and anonymous prefixes with useful leader-map labels.
(which-key-add-keymap-based-replacements
 cbrst/leader-map
 "s" "search"
 "s f" "project files"
 "s g" "ripgrep project"
 "s w" "ripgrep symbol"
 "s /" "search open buffers"
 "s ." "recent files"
 "s n" "Emacs config"
 "SPC" "switch buffer"
 "/" "search buffer"
 "f" "format buffer"
 "v" "view"
 "v d" "diagnostics"
 "v t" "file tree"
 "v o" "document outline"
 "v w" "toggle whitespace"
 "g" "git"
 "g s" "status"
 "h" "hunks"
 "h p" "preview hunk"
 "h r" "revert hunk"
 "a" "OpenCode"
  "a t" "terminal"
 "a c" "compose prompt"
 "a i" "interrupt request"
 "r" "refactor"
 "r n" "rename symbol"
 "c" "code"
 "c a" "code action"
 "d" "document"
 "d s" "symbols"
 "q" "diagnostics list"
 "Q" "quit"
 "Q Q" "quit Emacs"
 "p" "project"
 "p p" "switch project"
 "b" "buffer"
 "b b" "switch buffer"
 "t" "terminal"
 "t t" "toggle project terminal"
 "t n" "new terminal"
 "t f" "focus or hide terminal"
 "o" "tasks"
 "o r" "run task"
 "o t" "task output"
 "o a" "rerun task"
 "o c" "clear output")

;; Preserve Neovim's direct LSP and split-navigation keys.
(evil-define-key 'normal 'global (kbd "g d") #'xref-find-definitions)
(evil-define-key 'normal 'global (kbd "g r") #'xref-find-references)
(evil-define-key 'normal 'global (kbd "g I") #'lsp-find-implementation)
(evil-define-key 'normal 'global (kbd "g D") #'lsp-find-declaration)
(global-set-key (kbd "C-h") #'windmove-left)
(global-set-key (kbd "C-j") #'windmove-down)
(global-set-key (kbd "C-k") #'windmove-up)
(global-set-key (kbd "C-l") #'windmove-right)
(evil-define-key 'normal 'global (kbd "] c") #'diff-hl-next-hunk)
(evil-define-key 'normal 'global (kbd "[ c") #'diff-hl-previous-hunk)

;; Highlight yanked text just as Neovim does after a copy operation.
(defun cbrst/highlight-yank ()
  "Briefly highlight the most recently yanked region."
  (pulse-momentary-highlight-region (region-beginning) (region-end)))
(add-hook 'kill-ring-save-hook #'cbrst/highlight-yank)
