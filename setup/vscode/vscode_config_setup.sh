#!/bin/bash

# --- Load Configuration ---
DOTFILES_CONFIG_FILE="$HOME/.bash_extras/.dotfile_config"
if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    source "$DOTFILES_CONFIG_FILE"
else
    t Error "Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi

t "Copying settings.json for VSCode"
src=$DOTFILES_REPO_DIR/setup/vscode/vscode-settings.json

if [[ "$OS_TYPE" == "linux" ]]; then
    t "TBD"

elif [[ "$OS_TYPE" == "wsl" ]]; then
    raw_win_appdata=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:APPDATA" | tr -d '\r\n')
    raw_win_userprofile=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:USERPROFILE" | tr -d '\r\n')

    if [ -n "$raw_win_appdata" ]; then
        profile_base_path=$(wslpath -u "$raw_win_appdata")/Roaming/Code/User
    elif [ -n "$raw_win_userprofile" ]; then
        profile_base_path=$(wslpath -u "$raw_win_userprofile")/AppData/Roaming/Code/User
    else
        t ERROR "Could not determine Windows USERPROFILE paths." >&2
        exit 1
    fi

    dest=$profile_base_path/settings.json

elif [[ "$OS_TYPE" == "macos" ]]; then
    dest="$HOME/Library/Application\ Support/Code/User/settings.json"

fi

cp $src $dest
