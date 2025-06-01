#!/bin/bash

install_mac_package() {
  if brew list "$1" &>/dev/null; then
    t SUCCESS "$1 is already installed via brew."
  else
    t "Installing $1.."
    brew install "$@"
  fi
}

install_linux_package() {
  if dpkg -s "$1" &>/dev/null; then
    t SUCCESS "$1 is already installed via apt."
  else
    t "Installing $1.."
    sudo apt install -y "$@"
  fi
}

if [[ "$(uname)" == "Darwin" ]]; then
  install_mac_package coreutils
  install_mac_package make
  export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
  install_mac_package lesspipe
  install_mac_package python@3.12
  install_mac_package htop

  brew unlink python@3.12 && brew link python@3.12
  export PATH="/opt/homebrew/opt/python@3.12/libexec/bin:$PATH" 
  # Check if powerline is installed via pip
  if ! pip show powerline-status &>/dev/null; then
    t "Installing Powerline via pip.."
    # sudo rm -rf /usr/local/lib/python3.12/EXTERNALLY-MANAGED
    pip install powerline-status --user --break-system-packages
  else
    t SUCCESS "Powerline is already installed (pip)."
  fi

  # clone
  git clone https://github.com/powerline/fonts.git --depth=1
  # install
  cd fonts
  ./install.sh
  # clean-up a bit
  cd ..
  sudo rm -rf fonts

  # if brew list macvim &>/dev/null; then
  #   echo "macvim is already installed."
  # else
  #   echo "Installing macvim.."
  #   brew unlink vim
  #   brew install macvim
  # fi

  brew install vim
  if brew list vim &>/dev/null; then
    t SUCCESS "vim is already installed."
  else
    t "Installing vim.."
    brew link vim
  fi

else
  install_linux_package python3-pip
  install_linux_package git
  install_linux_package powerline
  install_linux_package fonts-powerline
  install_linux_package htop
  # install_linux_package net-tools
fi

if ! pip show powerline-gitstatus &>/dev/null; then
  t "Installing Powerline Git Status via pip.."
  pip install powerline-gitstatus --user --break-system-packages
else
  t SUCCESS "Powerline Git Status is already installed (pip)."
fi

if ! pip show powerline-shell &>/dev/null; then
  t "Installing Powerline Shell via pip.."
  pip install powerline-shell --user --break-system-packages
else
  t SUCCESS "Powerline Shell is already installed (pip)."
fi
