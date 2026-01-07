#!/bin/bash

# --- Start Load Configuration ---
if [ -z "$DOTFILES_CONFIG_FILE" ]; then
    DOTFILES_CONFIG_FILE="$HOME/.config/dotfiles/.dotfile_config.env"
fi

if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    source "$DOTFILES_CONFIG_FILE"
else
    t Error "Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi
# --- End Load Configuration ---

src=$DOTFILES_REPO_DIR/setup/powershell/Microsoft.PowerShell_profile.ps1

raw_profile=$(powershell.exe -NoProfile -NonInteractive -Command "\$PROFILE" | tr -d '\r\n')

dest=$raw_profile

if [[ -f "$dest" ]]; then
    t "Replacing profile.ps1 for PowerShell"
else
    t "Copying profile.ps1 for PowerShell"
fi

cp $src $dest
