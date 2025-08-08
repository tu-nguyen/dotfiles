#!/bin/bash

# --- Load Configuration ---
DOTFILES_CONFIG_FILE="$HOME/.bash_extras/.dotfile_config"
if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    source "$DOTFILES_CONFIG_FILE"
else
    t Error "Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi

if [[ -f "$HOME/.config/powerline/config.json" ]]; then
    t "Replacing config.json for powerline-shell"
else
    t "Copying config.json for powerline-shell"
fi

mkdir -p $HOME/.config/powerline
cp -R /usr/share/powerline/config_files/* \
      $HOME/.config/powerline/

cp $DOTFILES_REPO_DIR/setup/powerline/powerline-shell-config.json  $HOME/.config/powerline/themes/shell/default.json
