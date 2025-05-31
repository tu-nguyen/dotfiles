#!/bin/bash

set -e

VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"

sudo rm -rf "$VUNDLE_DIR"

echo "[INFO] Installed Vundle.."
git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"
echo "[Info] Vundle installed at $VUNDLE_DIR"

vim +PluginInstall +qall
