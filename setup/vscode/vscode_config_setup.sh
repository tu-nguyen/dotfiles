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

# extension installation
extensions=(
    "zhuangtongfa.Material-theme"
    "PKief.material-icon-theme"
    "usernamehw.errorlens"
    "eamodio.gitlens"
    "tamasfe.even-better-toml"
    "esbenp.prettier-vscode"
    "ms-vscode-remote.remote-wsl"
    "christian-kohler.path-intellisense"
    "ms-python.black-formatter"
    "irongeek.vscode-env"
    "mechatroner.rainbow-csv"
    "davidanson.vscode-markdownlint"
)

failed_exts=()

for ext in "${extensions[@]}"; do
    if code --list-extensions | grep -qi "$ext"; then
        t OK "${HDR_F}$ext${NC} is already installed."
    else
        t "Attempting to install ${HDR_F}$ext${NC}.."
        # Attempt install; if it fails, add to the failed list
        if ! code --install-extension "$ext" --force; then
            t ERR "Network blocked install for ${HDR_F}$ext${NC}."
            failed_exts+=("$ext")
        fi
    fi
done

# Final Summary
if [ ${#failed_exts[@]} -ne 0 ]; then
    echo -e "\n${WARN} --- ${WARN} MANUAL ACTION REQUIRED  --- ${NC}"
    t WARN "The following extensions could not be installed automatically due to network/SSL restrictions:"
    for f in "${failed_exts[@]}"; do
        echo -e "  - $f"
    done
    echo -e "\nTo fix this, please search for them in the VS Code Marketplace UI (Ctrl+Shift+X) and click 'Install'."
    echo -e "${HDR_F}---------------------------------------------------------------------${NC}"
else
    t SUCCESS "All extensions synced successfully!"
fi

# settings.json copy
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
