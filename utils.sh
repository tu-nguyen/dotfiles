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

install_pip_package() {
    if ! pip3 show "$1" &>/dev/null; then
        t SUCCESS "$1 is already installed via pip."
    else
        t "Installing $1.."
        pip3 install "$@" --user --break-system-packages 
    fi
}

cp_and_source() {
    local file="$1"
    local target="$2"

    if [[ -z "$file" || -z "$target" ]]; then
        echo "Usage: cp_and_source <file> <target>"
        return 1
    fi

    if [[ -f "$target" ]]; then
        t WARNING "File $target exists. Removing it before copying."
        rm "$target"
    fi

    t "Copying $file to $target"
    cp "$file" "$target"

    if [[ -f "$target" ]]; then
        t SUCCESS "Copied $file to $target successfully."
        source "$target"
    else
        t ERROR "Failed to copy $file to $target."
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
        install_mac_package lesspipe
        install_mac_package python@3.12
        install_mac_package htop
        install_mac_package vim

        brew unlink python@3.12 && brew link python@3.12
        export PATH="/opt/homebrew/opt/python@3.12/libexec/bin:$PATH" 
        export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
        install_pip_package powerline-status

        # Check if Powerline font is already installed
        if [[ -f "$HOME/Library/Fonts/DejaVu Sans Mono for Powerline.ttf" ]]; then
            t SUCCESS "Powerline fonts already installed."
        else
            # clone
            git clone https://github.com/powerline/fonts.git --depth=1
            # install
            cd fonts
            ./install.sh
            # clean-up a bit
            cd ..
            sudo rm -rf fonts
        fi
    elif [[ "$OS" == "linux" || "$OS" == "wsl" ]]; then
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

    install_pip_package powerline-gitstatus
    # install_pip_package powerline-shell
    install_pip_package powerline-status

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

    cp_and_source "$(pwd)/setup/bash/bash_colours" "$HOME/.bash_extras/.bash_colours"
    cp_and_source "$(pwd)/setup/bash/init" "$HOME/.bash_extras/.init"

    cp_and_source "$(pwd)/setup/bash/bash_aliases" "$HOME/.bash_extras/.bash_aliases"
    cp_and_source "$(pwd)/setup/bash/bash_docker_functions" "$HOME/.bash_extras/.bash_docker_functions"
    cp_and_source "$(pwd)/setup/bash/bash_functions" "$HOME/.bash_extras/.bash_functions"
    cp_and_source "$(pwd)/setup/bash/bash_exports" "$HOME/.bash_extras/.bash_exports"
    cp_and_source "$(pwd)/setup/bash/bash_motd" "$HOME/.bash_extras/.bash_motd"
    cp_and_source "$(pwd)/setup/bash/bash_other" "$HOME/.bash_extras/.bash_other"
    cp_and_source "$(pwd)/setup/bash/bash_tt" "$HOME/.bash_extras/.bash_tt"

    cp_and_source "$(pwd)/setup/bash/bashrc" "$HOME/.bashrc"

    t SUCCESS "Bash setup completed!"
}

reset_vimrc() {
    prompt "reset the .vimrc"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ -f "$HOME/.vimrc" ]]; then
        t WARNING "Deleting old .vimrc"
        rm $HOME/.vimrc
    fi

    if [[ -d "$HOME/.vim/bundle" ]]; then
        t WARNING "Deleting old .vim/bundle"
        rm -rf $HOME/.vim/bundle
    fi


    cp  "$(pwd)/setup/vim/vimrc" "$HOME/.vimrc"
    t SUCCESS "Linked $(pwd)/setup/vim/vimrc to $HOME/.vimrc successfully."

    t "Installing Vundle and plugins.."
    VUNDLE_PATH="$HOME/.vim/bundle/Vundle.vim"
    sudo rm -rf "$VUNDLE_PATH"

    t "Installed Vundle.."
    git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_PATH"
    t SUCCESS "Vundle installed at $VUNDLE_PATH"

    vim +PluginInstall +qall

    t SUCCESS "Vim setup completed!"
}

reset_git_config() {
    prompt "reset the .gitconfig"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILE_PATH/setup/git/git_config_setup.sh
    $DOTFILE_PATH/setup/git/git_config_setup.sh

    t SUCCESS "Git configuration reset completed!"
}

reset_vscode_config() {
    prompt "reset the VSCode configuration"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILE_PATH/setup/vscode/vscode_config_setup.sh
    bash -i $DOTFILE_PATH/setup/vscode/vscode_config_setup.sh

    t SUCCESS "VSCode configuration reset completed!"
}

reset_wsl_config() {
    prompt "reset the WSL configuration"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS" != "wsl" ]]; then
        t ERROR "This function is only for WSL. Skipping WSL configuration reset."
        return
    fi

    chmod +x $DOTFILE_PATH/setup/wsl/wsl_config_setup.sh
    bash -i $DOTFILE_PATH/setup/wsl/wsl_config_setup.sh
    t SUCCESS "WSL configuration reset completed!"
}

reset_powerline_config() {
    prompt "reset the Powerline configuration"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILE_PATH/setup/powerline/powerline_config_setup.sh
    bash -i $DOTFILE_PATH/setup/powerline/powerline_config_setup.sh
    t SUCCESS "Powerline configuration reset completed!"
}

