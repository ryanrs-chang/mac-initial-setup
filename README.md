# Mac Initial Setup

Dotfiles + bootstrap for macOS, managed by [chezmoi](https://www.chezmoi.io/) in **symlink mode**.
Stack: AeroSpace + SketchyBar + JankyBorders + Karabiner, Ghostty, Zed, zsh (Zim + Starship).

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
  dot_config/          # starship.toml, zed, zsh/aliasrc, git/ignore
  dot_config/symlink_* # whole-dir symlinks into config/
  .chezmoiremove       # stale paths deleted on apply (~/.aerospace.toml, ~/.p10k.zsh, ...)
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
| Check health | `chezmoi verify`, `chezmoi doctor`, `brew bundle check` |
| Add a package | add it to `Brewfile`, `chezmoi apply` (runs `brew bundle` automatically) |
| Find packages not in Brewfile | `brew bundle cleanup` (add `--force` to uninstall them) |
| Reload after edits | `aerospace reload-config`, `sketchybar --reload`, `brew services restart borders`, `exec zsh` |
| Scan for leaked secrets | `gitleaks git . --redact` (this repo is public) |

## Secrets

Never commit keys. Put them in `~/.zshrc.local` (untracked, sourced last by `.zshrc`) or read them
from Keychain at runtime, e.g. `export FOO=$(security find-generic-password -s foo -w)`.
