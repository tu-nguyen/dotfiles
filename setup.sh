#!/bin/bash

install_mac_package() {
  if brew list "$1" &>/dev/null; then
    echo "$1 is already installed via brew."
  else
    echo "Installing $1..."
    brew install "$@"
  fi
}

install_linux_package() {
  if dpkg -s "$1" &>/dev/null; then
    echo "$1 is already installed via apt."
  else
    echo "Installing $1..."
    sudo apt install -y "$@"
  fi
}

if [[ "$(uname)" == "Darwin" ]]; then
  install_mac_package coreutils
  install_mac_package python@3.12
  # Check if powerline is installed via pip
  if ! pip show powerline-status &>/dev/null; then
    echo "Installing Powerline via pip..."
    pip install --user git+git://github.com/powerline/powerline
  else
    echo "Powerline is already installed (pip)."
  fi

  if brew list macvim &>/dev/null; then
    echo "macvim is already installed."
  else
    echo "Installing macvim..."
    brew install macvim --env-std --with-override-system-vim
  fi

else
  install_linux_package python3-pip
  install_linux_package git
  install_linux_package powerline
  install_linux_package fonts-powerline
fi

# # Font
# wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
# mkdir -p ~/.fonts/ && mv PowerlineSymbols.otf ~/.fonts/
# fc-cache -vf ~/.fonts
# mkdir -p ~/.config/fontconfig/conf.d/ && mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/















