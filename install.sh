#!/usr/bin/env bash
set -e

DOTFILES_PATH="$(cd "$(dirname "$0")" && pwd)"
export DOTFILE_PATH="$DOTFILES_PATH"
source "$DOTFILE_PATH/bash/bash_colours" || {
    echo "Error: Could not source bash_colours.sh"
    exit 1
}
source "$DOTFILE_PATH/bash/init" || {
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


t SUCCESS "All done!"
