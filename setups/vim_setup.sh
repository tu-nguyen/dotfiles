#!/bin/bash

set -e

VUNDLE_PATH="$HOME/.vim/bundle/Vundle.vim"

sudo rm -rf "$VUNDLE_PATH"

t "Installed Vundle.."
git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_PATH"
t SUCCESS "Vundle installed at $VUNDLE_PATH"

vim +PluginInstall +qall
