#!/bin/bash

# --- Load Configuration ---
DOTFILES_CONFIG_FILE="$HOME/.bash_extras/.dotfile_config"
if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    source "$DOTFILES_CONFIG_FILE"
else
    t Error "Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi

if [[ "$OS_TYPE" == "macos" ]]; then
    t "Copying settings.json for VSCode"
    cp $DOTFILES_REPO_DIR/setup/vscode/vscode-settings.json  $HOME/Library/Application\ Support/Code/User/settings.json
else
    t "TBD"
fi