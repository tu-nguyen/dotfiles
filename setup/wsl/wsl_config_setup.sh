#!/usr/bin/env bash

# --- Start Load Configuration ---
if [ -z "$DOTFILES_CONFIG_DIR" ]; then
    DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
fi

if [ -z "$DOTFILES_CONFIG_FILE" ]; then
    DOTFILES_CONFIG_FILE="$DOTFILES_CONFIG_DIR/.dotfile_config"
fi

if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    source "$DOTFILES_CONFIG_FILE"
else
    echo "[ ERR  ] Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi

DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
[[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"
# --- End Load Configuration ---
SOURCE_CONF="$DOTFILES_REPO_DIR/setup/wsl/wsl.conf"
TARGET_CONF="/etc/wsl.conf"

# Check if source exists
if [ ! -f "$SOURCE_CONF" ]; then
    t ERROR "source ${FILE_F}$SOURCE_CONF${NC} not found."
    exit 1
fi

# Check if target exists
if [[ -f "$TARGET_CONF" ]]; then
    t "replacing ${FILE_F}$SOURCE_CONF${NC} for wsl"
else
    t "copying ${FILE_F}$SOURCE_CONF${NC} for wsl"
fi

sudo cpp $SOURCE_CONF $TARGET_CONF

# Verify the copy was successful
if [ $? -eq 0 ]; then
    t SUCCESS "${FILE_F}$TARGET_CONF${NC} updated."
    t INFO "reminder: run '${EXE_F}wsl.exe --shutdown${NC}' in ${EXE_F}powershell${NC} to apply changes."
else
    t ERROR "failed to copy config. Check permissions."
    exit 1
fi

t OK "wsl settings synced to: ${FILE_F}$TARGET_CONF${NC}"
