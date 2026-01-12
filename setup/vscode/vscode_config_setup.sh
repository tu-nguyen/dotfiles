#!/bin/bash

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
# --- End Load Configuration ---

if [[ -z "$DOTFILES_LOADED" ]]; then
    export DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"

    [[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"

    export DOTFILES_LOADED=1
fi

t "Copying settings.json for VSCode"
src=$DOTFILES_REPO_DIR/setup/vscode/vscode-settings.json

if [[ "$OS_TYPE" == "linux" ]]; then
    profile_base_path="$HOME/.config/Code/User"
    dest="$profile_base_path/settings.json"
elif [[ "$OS_TYPE" == "wsl" ]]; then
    raw_win_appdata=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:APPDATA" | tr -d '\r\n')

    if [ -n "$raw_win_appdata" ]; then
        profile_base_path=$(wslpath -u "$raw_win_appdata")/Code/User
    else
        raw_win_userprofile=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:USERPROFILE" | tr -d '\r\n')
        profile_base_path=$(wslpath -u "$raw_win_userprofile")/AppData/Roaming/Code/User
    fi
    dest=$profile_base_path/settings.json
elif [[ "$OS_TYPE" == "macos" ]]; then
    profile_base_path="$HOME/Library/Application Support/Code/User"
    dest="$profile_base_path/settings.json"
fi

mkdir -p "$(dirname "$dest")"

# if [ -f "$dest" ]; then
#     cp "$dest" "${dest}.bak"
#     t INFO "Backed up existing VS Code settings to settings.json.bak"
# fi

cpp -q "$src" "$dest"
t OK "VS Code settings synced to: ${VAL_F}$dest${NC}"
