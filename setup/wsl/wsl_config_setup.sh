#!/bin/bash

# --- Start Load Configuration ---
if [ -z "$DOTFILES_CONFIG_FILE" ]; then
    DOTFILES_CONFIG_FILE="$HOME/.config/dotfiles/.dotfile_config.env"
fi

if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    source "$DOTFILES_CONFIG_FILE"
else
    echo "[Error] Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi
# --- End Load Configuration ---

if [[ -f "/etc/wsl.conf" ]]; then
    t "Replacing wsl.conf for WSL"
else
    t "Copying wsl.conf for WSL"
fi

sudo cp $DOTFILES_REPO_DIR/setup/wsl/wsl.conf  /etc/wsl.conf
