#!/usr/bin/env bash
# Bootstrap a fresh Mac: Homebrew, Zim, SSH key, then hand off to chezmoi.
# Usage: git clone https://github.com/ryanrs-chang/mac-initial-setup ~/mac-initial-setup && ~/mac-initial-setup/init.sh
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Zim framework: https://github.com/zimfw/zimfw (modules are listed in ~/.zimrc)
if [ ! -d "${ZDOTDIR:-$HOME}/.zim" ]; then
  echo "Installing Zim..."
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
fi

if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -q -t ed25519 -N '' -f ~/.ssh/id_ed25519
fi

command -v chezmoi &>/dev/null || brew install chezmoi

# Writes ~/.config/chezmoi/chezmoi.toml (symlink mode, sourceDir = this repo),
# then runs brew bundle and links every dotfile.
chezmoi init --source "$REPO" --apply
