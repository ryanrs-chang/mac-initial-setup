#!/usr/bin/env bash

# Install Homebrew

if ! command -v brew &>/dev/null; then
  echo "Homebrew could not be found"
  echo "Installing.. Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install zim
# https://github.com/zimfw/zimfw#automatic-installation
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

# Install powerlevel10k
# https://github.com/romkatv/powerlevel10k
TEMP='[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh'
if ! grep -q "$TEMP" ~/.zimrc; then
  echo "not found zimfw powerlevel10k config"
  printf "\n$TEMP\n" >>~/.zimrc
  zimfw install
fi
