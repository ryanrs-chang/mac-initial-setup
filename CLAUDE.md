# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

macOS bootstrap + dotfiles, managed by **chezmoi in symlink mode**. The live files in `~` are symlinks
into this repo, so editing `~/.config/...` or `~/.zshrc` edits the repo directly. There is no build,
lint or test suite.

Stack: AeroSpace (tiling WM) + SketchyBar + JankyBorders + Karabiner, Ghostty, Zed, zsh (Zim + Starship).

## Commands

```sh
chezmoi diff               # preview what apply would change
chezmoi apply              # create/refresh links, run run_* scripts
chezmoi verify             # exit 0 if ~ matches the source state
chezmoi managed            # list managed targets
brew bundle check --no-upgrade --file=Brewfile
gitleaks git . --redact    # repo is PUBLIC on GitHub; scan before pushing
```

Reload after editing configs: `aerospace reload-config`, `sketchybar --reload`,
`brew services restart borders`, `exec zsh`.

## Layout: two kinds of links

- `.chezmoiroot` points chezmoi at `home/` (the source state). `~/.config/chezmoi/chezmoi.toml` is
  generated from `home/.chezmoi.toml.tmpl` and sets `mode = "symlink"` and `sourceDir` = repo root.
- **Plain files** live in `home/` with chezmoi names (`dot_zshrc` → `~/.zshrc`,
  `dot_config/zed/settings.json` → `~/.config/zed/settings.json`) and become per-file symlinks.
- **Whole app dirs** live in `config/<app>/` and are linked via `home/dot_config/symlink_<app>.tmpl`
  (content: `{{ .chezmoi.workingTree }}/config/<app>`). This exists because chezmoi symlink mode
  cannot link directories, executable files, private (0600) files or templates — SketchyBar plugins
  are executable and Karabiner requires `~/.config/karabiner` itself to be the symlink.
  - New app with executables or that rewrites its own config → put it under `config/` + add a `symlink_` file.
  - New plain dotfile → `chezmoi add ~/.foo` (then strip any `private_`/`executable_` prefix if it should be a symlink), `chezmoi apply`.
- `home/.chezmoiremove` deletes stale targets from the old setup (`~/.aerospace.toml`, `~/.p10k.zsh`, ...).
  Do not recreate `~/.aerospace.toml`: AeroSpace errors when it and `~/.config/aerospace/aerospace.toml` both exist.
- `home/run_onchange_before_10-brew-bundle.sh.tmpl` embeds the Brewfile's sha256, so `chezmoi apply`
  runs `brew bundle --no-upgrade` whenever `Brewfile` changes. `run_once_after_20-start-services.sh`
  starts sketchybar/borders/AeroSpace and restarts Karabiner's user server once per machine.
- `init.sh` is the fresh-machine entry point (Homebrew, Zim, SSH key, `chezmoi init --source <repo> --apply`).

## AeroSpace ↔ SketchyBar coupling

SketchyBar workspace and layout indicators are driven by custom events that AeroSpace fires:
`config/aerospace/aerospace.toml` calls `sketchybar --trigger aerospace_workspace_change` (in
`exec-on-workspace-change`) and `--trigger aerospace_layout_change` (appended to layout/move/join
bindings and `on-focus-changed`). `config/sketchybar/sketchybarrc` declares those events and builds one
item per `aerospace list-workspaces --all`. When adding an AeroSpace binding that changes layout,
append `'exec-and-forget sketchybar --trigger aerospace_layout_change'`; when renaming events, change
both files. Workspace icons in `sketchybarrc` mirror the `on-window-detected` rules in `aerospace.toml`.

`config/aerospace/CLAUDE.md` and its `.claude/skills/aerospace-config` skill cover AeroSpace specifics.

## Secrets

Secrets go in `~/.zshrc.local` (untracked, sourced last by `.zshrc`) or are read from Keychain at
runtime (`security find-generic-password`, as `COOLIFY_TOKEN` and `claude_usage.py` do). Never write a
literal key into `home/` or `config/`.
