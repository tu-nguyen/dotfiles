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
    pip install powerline-status
  else
    echo "Powerline is already installed (pip)."
  fi

  # clone
  git clone https://github.com/powerline/fonts.git --depth=1
  # install
  cd fonts
  ./install.sh
  # clean-up a bit
  cd ..
  rm -rf fonts

  if brew list macvim &>/dev/null; then
    echo "macvim is already installed."
  else
    echo "Installing macvim..."
    brew unlink vim
    brew install macvim
  fi

else
  install_linux_package python3-pip
  install_linux_package git
  install_linux_package powerline
  install_linux_package fonts-powerline
fi