#!/usr/bin/env bash

# --- Start Load Configuration ---
if [ -z "$DOTFILES_CONFIG_DIR" ]; then
    DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
fi

if [ -z "$DOTFILES_CONFIG_FILE" ]; then
    DOTFILES_CONFIG_FILE="$DOTFILES_CONFIG_DIR/.dotfile_config.env"
fi

if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    source "$DOTFILES_CONFIG_FILE"
else
    echo "[Error] Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi

DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
[[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"
# --- End Load Configuration ---

src=$DOTFILES_REPO_DIR/setup/powershell/Microsoft.PowerShell_profile.ps1

raw_profile=$(powershell.exe -NoProfile -NonInteractive -Command "\$PROFILE" | tr -d '\r\n')

dest=$raw_profile

if [[ -f "$dest" ]]; then
    t "Replacing profile.ps1 for PowerShell"
else
    t "Copying profile.ps1 for PowerShell"
fi

cp "$src" "$dest"
t OK "PS1 settings synced to: ${VAL_F}$dest${NC}"
