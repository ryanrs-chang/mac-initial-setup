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
TEMP='[ -f ~/.alias.zsh ] && source ~/.alias.zsh'
if ! grep -q "$TEMP" ~/.zimrc; then
    echo "not found zimfw powerlevel10k config"
    printf "\n$TEMP\n" >>~/.zimrc
    zimfw install
fi

# ----------------------------
DOTFILE_PATH=$PWD/dotfile
HOME_DOTFILE_PATH=$HOME/.config

HISTORY_SIZE=10000000
# ----------------------------

echo "# create folder $HOME/.config .."
mkdir -p ~/.config

echo "# p10k config to ~/"
ln -s $DOTFILE_PATH/.p10k.zsh $HOME/.p10k.zsh

echo "# link yabai to $HOME/.yabairc"
ln -s $DOTFILE_PATH/.yabairc $HOME/.yabairc

echo "# create folder $HOME/.config/skhd ..."
mkdir -p $HOME_DOTFILE_PATH/skhd
ln -s $DOTFILE_PATH/.skhdrc $HOME_DOTFILE_PATH/skhd/skhdrc

echo "# modify hsitory size to $HISTORY_SIZE"
sudo sed -i '' "s/HISTSIZE=.*/HISTSIZE=$HISTORY_SIZE/g" /etc/zshrc
sudo sed -i '' "s/SAVEHIST=.*/SAVEHIST=$HISTORY_SIZE/g" /etc/zshrc

echo "# enabled custom alias"
TEMP='[ -f ~/.alias.zsh ] && source ~/.alias.zsh'
if ! grep "$TEMP" ~/.zshrc; then
    echo "not found 'custom alias' config"
    printf "\n$TEMP\n" >>~/.zshrc
    ln -s $DOTFILE_PATH/.alias.zsh $HOME/.alias.zsh
fi

echo "-----------------------------------------------------------"
