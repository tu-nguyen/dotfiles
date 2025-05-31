#!/bin/bash

set -e

VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"

if [ -d "$VUNDLE_DIR" ]; then
    echo "[Info] Vundle is already installed at $VUNDLE_DIR"
else
    echo "[INFO] Installed Vundle.."
    git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"
    echo "[Info] Vundle installed at $VUNDLE_DIR"
fi

vim +PluginInstall +qall
