# LazyGit

`lazygit/config.yml` is linked to `$XDG_CONFIG_HOME/lazygit` by
`home-manager/default.nix`. Home Manager installs LazyGit and the configuration
uses the current `git.diffRenderers` format to render diffs with Delta.

## Configuration

The configuration keeps the existing rounded interface, Nerd Font 3 icons,
custom spinner, two-column tabs, and Delta's dark, non-paging renderer. The
schema directive enables validation and completion in YAML-aware editors.

```yaml
git:
  diffRenderers:
    # Name identifies the renderer in LazyGit's renderer switcher.
    - name: delta
      command: "DELTA_FEATURES=lazygit delta --dark --paging=never"
```

## Maintenance

Check the installed version and validate the linked configuration after a Home
Manager switch:

```sh
lazygit --version
lazygit --use-config-file="$XDG_CONFIG_HOME/lazygit/config.yml"
```

Run the second command inside a Git repository. It should start without a
configuration error; quit with `q`. Refer to LazyGit's current configuration
schema before adding options, since deprecated settings such as `git.paging`
are not supported by current releases.
