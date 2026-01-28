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

# Check twork
if [[ -f "$DOTFILES_CONFIG_DIR/.bash_twork" ]]; then
    t WARN "Work environment detected (.twork exists). Bypassing SSL checks..."

    # Use jq to temporarily set SSL bypass in the actual config file
    if command -v jq >/dev/null; then
        jq '.["http.proxyStrictSSL"] = false | .["http.systemCertificates"] = true' "$settings_wsl" > "${settings_wsl}.tmp" && mv "${settings_wsl}.tmp" "$settings_wsl"
    else
        # Fallback if jq isn't installed yet: overwrite with a minimal bypass config
        echo '{"http.proxyStrictSSL": false, "http.systemCertificates": true}' > "$settings_wsl"
    fi

    export NODE_TLS_REJECT_UNAUTHORIZED=0
fi

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

for ext in "${extensions[@]}"; do
    if code --list-extensions | grep -qi "$ext"; then
        t OK "${HDR_F}$ext${NC} is already installed."
    else
        t "Installing ${HDR_F}$ext${NC}.."
        code --install-extension "$ext" --force --ignore-certificate-errors
    fi
done

# Cleanup
if [[ -n "$ssl_flag" ]]; then
    unset NODE_TLS_REJECT_UNAUTHORIZED
    t SUCCESS "SSL Bypass disabled. Extensions synced."
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
