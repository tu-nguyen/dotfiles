#!/usr/bin/env bash

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -qi microsoft /proc/version; then
            OS="wsl"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
    echo "Detected OS: $OS"
}

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

link_and_source() {
    local file="$1"
    local target="$2"

    if [[ -z "$file" || -z "$target" ]]; then
        echo "Usage: link <file> <target>"
        return 1
    fi

    if [[ -f "$target" ]]; then
        t "File $target exists. Removing it before linking."
        rm "$target"
    fi

    t "Linking $file to $target"
    ln -sv "$file" "$target"

    if [[ -f "$target" ]]; then
        t SUCCESS "Linked $file to $target successfully."
        source "$target"
    else
        t ERROR "Failed to link $file to $target."
    fi
}

prompt() {
    RETURN=0
    local config="$1"

    if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to ${GREEN}$config${NC}? This will ${RED}erase existing data${NC}, might want to create a backup! [y/N] " -n 1 -r
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        t "Exiting.."
        RETURN=1
        return 
      fi
  fi
  echo ""
}

install_packages() {
    if [[ "$OS" == "macos" ]]; then
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

        brew install vim
        if brew list vim &>/dev/null; then
            t SUCCESS "vim is already installed."
        else
            t "Installing vim.."
            brew link vim
        fi
    elif [[ "$OS" == "linux" ]]; then
        if ! command -v apt &>/dev/null; then
            t ERROR "apt package manager not found. Please install it first."
            return 1
        fi
        install_linux_package coreutils
        install_linux_package make
        install_linux_package less
        install_linux_package python3
        install_linux_package htop
        install_linux_package python3-pip
        install_linux_package vim
        install_linux_package powerline
        install_linux_package fonts-powerline
        install_linux_package git
        install_linux_package curl
        install_linux_package wget
        install_linux_package tree
        # install_linux_package net-tools
    else
        t ERROR "Unsupported OS: $OS. Please install the required packages manually."
        return 1
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

    t SUCCESS "All required packages installed successfully."
    return
}

reset_pre() {
    prompt "pre_setup"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    install_packages

    t SUCCESS "Pre-setup completed!"
}

reset_bashrc() {
    prompt "reset the .bashrc"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    link_and_source "$(pwd)/bash/bash_colours" "$HOME/.bash_extras/.bash_colours"
    link_and_source "$(pwd)/bash/init" "$HOME/.bash_extras/.init"

    link_and_source "$(pwd)/bash/bash_aliases" "$HOME/.bash_extras/.bash_aliases"
    link_and_source "$(pwd)/bash/bash_docker_functions" "$HOME/.bash_extras/.bash_docker_functions"
    link_and_source "$(pwd)/bash/bash_functions" "$HOME/.bash_extras/.bash_functions"
    link_and_source "$(pwd)/bash/bash_other" "$HOME/.bash_extras/.bash_other"
    link_and_source "$(pwd)/bash/bash_tt" "$HOME/.bash_extras/.bash_tt"

    link_and_source "$(pwd)/.bashrc" "$HOME/.bashrc"
}


