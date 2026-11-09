# Mac Initial Setup

Dotfiles + bootstrap for macOS, managed by [chezmoi](https://www.chezmoi.io/) in **symlink mode**.
Stack: AeroSpace + SketchyBar + JankyBorders + Karabiner, Ghostty, Zed, zsh (Zim + p10k).

## Fresh machine

```sh
git clone https://github.com/ryanrs-chang/mac-initial-setup ~/mac-initial-setup
~/mac-initial-setup/init.sh
```

Then grant permissions manually: Accessibility for AeroSpace, Input Monitoring for Karabiner.

## Layout

```
.chezmoiroot           # tells chezmoi the source state lives in home/
Brewfile               # brew bundle; re-applied automatically when it changes
init.sh                # Homebrew, Zim, SSH key, chezmoi init --apply
home/                  # chezmoi source state (dot_zshrc -> ~/.zshrc, ...)
  dot_config/symlink_* # whole-dir symlinks into config/
  run_*                # brew bundle (on Brewfile change), start services (once)
config/                # app config dirs linked as a whole:
  aerospace sketchybar borders karabiner
```

Why two kinds of links: chezmoi symlink mode only links plain files, not directories or
executables. SketchyBar plugins are executable and Karabiner requires its whole directory to be
a symlink, so those app dirs live in `config/` and are linked via `symlink_<name>.tmpl`.

## Daily use

| Task | Command |
|---|---|
| Edit a config | edit `~/.config/...` or `~/.zshrc` directly (they're symlinks into the repo), then `git commit` |
| Add a new plain dotfile | `chezmoi add ~/.foo && chezmoi apply` |
| Add a new app config dir | move it to `config/<app>`, add `home/dot_config/symlink_<app>.tmpl`, `chezmoi apply` |
| Preview / apply | `chezmoi diff` / `chezmoi apply` |
| Check health | `chezmoi doctor`, `brew bundle check` |
| Find packages not in Brewfile | `brew bundle cleanup` (add `--force` to uninstall them) |

Secrets and machine-only exports go in `~/.zshrc.local` (untracked, sourced last by `.zshrc`).
