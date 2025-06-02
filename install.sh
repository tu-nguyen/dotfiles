#!/usr/bin/env bash
set -e

DOTFILES_PATH="$(cd "$(dirname "$0")" && pwd)"
export DOTFILE_PATH="$DOTFILES_PATH"
source "$DOTFILE_PATH/setup/bash/bash_colours" || {
    echo "Error: Could not source bash_colours.sh"
    exit 1
}
source "$DOTFILE_PATH/setup/bash/init" || {
    echo "Error: Could not source init.sh"
    exit 1
}
source "$DOTFILE_PATH/utils.sh" || {
    echo "Error: Could not source utils.sh"
    exit 1
}

t "Detecting OS.."
detect_os

t "Setting up configuration files.."
reset_pre
reset_bashrc
reset_vimrc
reset_git_config
reset_vscode_config
reset_powerline_config

if [[ "$OS" == "linux" ]]; then
    t "Setting up Linux specific configurations.."
    # Add any Linux-specific setup here

elif [[ "$OS" == "wsl" ]]; then
    t "Setting up WSL specific configurations.."
    # Add any WSL-specific setup here
    reset_wsl_config
elif [[ "$OS" == "macos" ]]; then
    t "Setting up macOS specific configurations.."
    # Add any macOS-specific setup here
fi
# reset_post


t SUCCESS "All done!"
