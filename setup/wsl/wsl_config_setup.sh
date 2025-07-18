#!/bin/bash

# --- Load Configuration ---
# DOTFILES_CONFIG_FILE="$HOME/.bash_extras/.dotfile_config"
# if [ -f "$DOTFILES_CONFIG_FILE" ]; then
#     source "$DOTFILES_CONFIG_FILE"
# else
#     t Error "Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
#     exit 1
# fi

if [[ -f "/etc/wsl.conf" ]]; then
    t "Replacing wsl.conf for WSL"
else
    t "Copying wsl.conf for WSL"
fi

sudo cp $DOTFILES_REPO_DIR/setup/wsl/wsl.conf  /etc/wsl.conf