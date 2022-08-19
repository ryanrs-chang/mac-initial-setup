#!/usr/bin/env bash

# Install Homebrew
echo "Installing.. Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install zim
# https://github.com/zimfw/zimfw#automatic-installation
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

# Install powerlevel10k
# https://github.com/romkatv/powerlevel10k
echo "zmodule romkatv/powerlevel10k --use degit" >> ~/.zimrc
zimfw install
cp ./.p10k.zsh ~/

########################################################################################################################

brew install neofetch
brew install wget
brew install git
brew install --cask iterm2

# Insatll nodejs
brew install nodejs
## Setup nodejs
sudo npm insatll -g yarn
sudo npm insatll -g n
sudo n install 16

# Install jq
echo "Installing.. jq"
brew install jq

# Install wget
echo "Installing.. wget"


# fzf
echo "Installing.. fzf"
brew install fzf
$(brew --prefix)/opt/fzf/install

# Launcher

brew install --cask raycast

# Swticher

brew install --cask alt-tab

# Install Window manager
## https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)
brew install koekeishiya/formulae/yabai
sudo yabai --install-sa
sudo yabai --load-sa

## Sample: https://github.com/koekeishiya/yabai/blob/master/examples/yabairc
cp ./.yabairc ~/
brew services start yabai


# Install skhd
# https://github.com/koekeishiya/skhd#install
brew install koekeishiya/formulae/skhd
brew services start skhd
# sample: https://github.com/koekeishiya/yabai/blob/master/examples/skhdrc
cp ./.skhdrc ~/
skhd --reload

# VS Code
brew install --cask visual-studio-code

#####
neofetch