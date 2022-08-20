#!/usr/bin/env bash

# ------------------------------
# Post-Install module configuration
# ------------------------------

FILE=~/.ssh/id_rsa
if ! test -f "$FILE"; then
    echo "$FILE isn't exists."
    echo "## gen private sshkey"
    ssh-keygen -q -N '' -f $FILE
fi

## Setup nodejs

if ! command -v npm &>/dev/null; then
    echo "'npm' couldn't be found."
    exit 1
fi

sudo npm install -g yarn
# https://www.npmjs.com/package/n
sudo npm install -g n
sudo npm install -g nvm
sudo n install 16
# https://www.npmjs.com/package/npm-check-updates
sudo npm install -g npm-check-updates

# setup fzf

$(brew --prefix)/opt/fzf/install

# setup yabai

brew services start yabai
brew services start skhd
