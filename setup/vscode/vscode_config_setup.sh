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
    echo "[Error] Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi

DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
[[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"
# --- End Load Configuration ---

# VS Code Extension installation
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
)

if [[ -f "$DOTFILES_CONFIG_DIR/.bash_twork" ]]; then
    t WARN "Work environment detected (.twork exists). Sideloading.."
    DOWNLOAD_DIR="$./vscode_extensions_tmp"
    mkdir -p "$DOWNLOAD_DIR"
    t INFO "Starting Offline Extension Sync..."
fi

for ext in "${extensions[@]}"; do
    if code --list-extensions | grep -qi "$ext"; then
        t OK "${HDR_F}$ext${NC} is already installed."
    else
        t "Installing ${HDR_F}$ext${NC}.."
        if [[ -f "$DOTFILES_CONFIG_DIR/.bash_twork" ]]; then
            local pub=$(echo $ext | cut -d. -f1)
            local name=$(echo $ext | cut -d. -f2)

            local url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${pub}/vsextensions/${name}/latest/vspackage"
            local target="$dl_dir/${ext}.vsix"

            curl -fkLs -H "User-Agent: Mozilla/5.0" "$url" -o "$target"

            # Check if the file is actually a ZIP (VSIX) and not a text/html error page
            if file "$target" | grep -q "Zip archive data"; then
                t SUCCESS "${HDR_F}$ext${NC} download valid. Installing..."
                code --install-extension "$target" --force
            else
                t ERR "Download failed for ${HDR_F}$ext${NC}. The firewall likely blocked the file."
                # Debug: show the first few lines of what we actually downloaded
                head -n 5 "$target"
            fi
        else
            code --install-extension "$ext" --force
        fi
    fi
done

# Cleanup
if [[ -d "$$DOWNLOAD_DIR" ]]; then
    rmdir "$DOWNLOAD_DIR"
fi

t SUCCESS "VS Code extensions synced!"

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
