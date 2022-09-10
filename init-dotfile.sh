#!/usr/bin/env bash

# ----------------- EnvVar Setting -----------------

DOTFILE_PATH=$PWD/dotfile
HOME_DOTFILE_PATH=$HOME/.config

HISTORY_SIZE=10000000

# --------------------------------------------------

init_dotfile() {
  file_name=$1 # .pk10k.zsh
  file_path=$2 # ~/

  echo "# initial dotfile '$file_path/$file_name'."
  if [ ! -d "$file_path" ]; then
    echo "# folder creating $file_path ..."
    mkdir -p $file_path
  fi
  ln -s $DOTFILE_PATH/$file_name $file_path/$file_name
  echo ""
  echo "---------------------------------------"
}

echo "# create folder $HOME/.config .."
mkdir -p ~/.config

##
## initial dotfile ..
init_dotfile .p10k.zsh $HOME
init_dotfile yabairc $HOME_DOTFILE_PATH/yabai
init_dotfile skhdrc $HOME_DOTFILE_PATH/skhd
init_dotfile spacebarrc $HOME_DOTFILE_PATH/spacebar
init_dotfile aliasrc $HOME_DOTFILE_PATH/alias

## -------------------------------------------------

echo "#"
echo "# modify hsitory size to $HISTORY_SIZE"
sudo sed -i '' "s/HISTSIZE=.*/HISTSIZE=$HISTORY_SIZE/g" /etc/zshrc
sudo sed -i '' "s/SAVEHIST=.*/SAVEHIST=$HISTORY_SIZE/g" /etc/zshrc

echo "#"
echo "# enabled custom alias"
TEMP='[ -f ~/.config/aliasrc/aliasrc ] && source ~/.config/aliasrc/aliasrc'
if ! grep "$TEMP" ~/.zshrc; then
  echo "Not found 'custom alias' config"
  printf "\n$TEMP\n" >>~/.zshrc
fi

echo ''
echo "configuration completed"
echo "-----------------------------------------------------------"
