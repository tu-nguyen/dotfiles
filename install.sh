#!/bin/bash
set -e

get_os_type() {
    if [ -z "$OS_TYPE" ]; then
        echo "[INFO] Detecting OS.." >&2
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if grep -qi microsoft /proc/version; then
                OS_TYPE="wsl"
            else
                OS_TYPE="linux"
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            OS_TYPE="macos"
        else
            echo "[ERROR] Unsupported OS: $OSTYPE"
            exit 1
        fi
    fi

    echo "$OS_TYPE"
}


ENV_LOADED=false
if [ -f .env ]; then
    echo "[INFO] Configuration loaded from .env"
    source .env
    ENV_LOADED=true
else
    DOTFILES_CONFIG_FILE="$HOME/.bash_extras/.dotfile_config"
    if [[ -f "$DOTFILES_CONFIG_FILE" ]]; then
        echo "[INFO] Configuration loaded from $DOTFILES_CONFIG_FILE"
        source "$DOTFILES_CONFIG_FILE"
        ENV_LOADED=true
    fi
fi

DEFAULT_DOTFILES_REPO="https://github.com/tu-nguyen/dotfiles.git"
DEFAULT_DOTFILES_REPO_DIR="$(pwd)"
DEFAULT_GITSTATUS_DIR="$HOME/.gitstatus"
DEFAULT_EXTRAS=$HOME/.bash_extras
DEFAULT_DOTFILES_CONFIG_FILE="$DEFAULT_EXTRAS/.dotfile_config"
DEFAULT_OS_TYPE=$(get_os_type)
GITSTATUS_DIR="$HOME/.gitstatus"

if [[ "$ENV_LOADED" == "false" ]]; then
    echo "[WARNING] .env and .dotfile_config files not found. Script will rely on defaults."
    : "${DOTFILES_REPO:="$DEFAULT_DOTFILES_REPO"}"
    : "${DOTFILES_REPO_DIR:="$DEFAULT_DOTFILES_REPO_DIR"}"
    : "${DOTFILES_CONFIG_FILE:="$DEFAULT_DOTFILES_CONFIG_FILE"}"
    : "${OS_TYPE:=$DEFAULT_OS_TYPE}"
fi

if [ -z "$DOTFILES_REPO_DIR" ] || [ "$DOTFILES_REPO_DIR" == "/home/user/path/to/dotfiles" ]; then
    echo "[WARNING] 'DOTFILES_REPO_DIR' was not set, falling to default $DEFAULT_DOTFILES_REPO_DIR."
    : "${DOTFILES_REPO_DIR:="$DEFAULT_DOTFILES_REPO_DIR"}"
fi

if [ -z "$DOTFILES_REPO" ] || [ "$DOTFILES_REPO" == "https://github.com/YOUR_USERNAME/YOUR_DOTFILES_REPO.git" ]; then
    echo "[WARNING] 'DOTFILES_REPO' was not set, falling to default $DEFAULT_DOTFILES_REPO."
    : "${DOTFILES_REPO:="$DEFAULT_DOTFILES_REPO"}"
fi

if [ -z "$DOTFILES_CONFIG_FILE" ] || [ "$DOTFILES_CONFIG_FILE" == "/home/user/.bash_extras/path/to/.dotfile_config" ]; then
    echo "[WARNING] 'DOTFILES_CONFIG_FILE' was not set, falling to default $DEFAULT_DOTFILES_CONFIG_FILE."
    : "${DOTFILES_CONFIG_FILE:="$DEFAULT_DOTFILES_CONFIG_FILE"}"
fi

if [ -z "$OS_TYPE" ] || [ "$OS_TYPE" == "some_os" ]; then
    echo "[WARNING] 'OS_TYPE' was not set, falling to default $DEFAULT_OS_TYPE."
    : "${OS_TYPE:="$DEFAULT_OS_TYPE"}"
fi

mkdir -p "$DEFAULT_EXTRAS"
echo "DOTFILES_REPO=$DOTFILES_REPO" > "$DOTFILES_CONFIG_FILE"
echo "DOTFILES_REPO_DIR=$DOTFILES_REPO_DIR" >> "$DOTFILES_CONFIG_FILE"
echo "DOTFILES_CONFIG_FILE=$DOTFILES_CONFIG_FILE"  >> "$DOTFILES_CONFIG_FILE"
echo "OS_TYPE=$OS_TYPE" >> "$DOTFILES_CONFIG_FILE"

source "$DOTFILES_REPO_DIR/setup/bash/bash_colours" || {
    echo "Error: Could not source bash_colours.sh"
    exit 1
}
source "$DOTFILES_REPO_DIR/setup/bash/init" || {
    echo "Error: Could not source init.sh"
    exit 1
}
source "$DOTFILES_REPO_DIR/utils.sh" || {
    echo "Error: Could not source utils.sh"
    exit 1
}

# A menu function to display options
show_menu() {
    clear
    echo "======================================="
    echo "    Dotfiles Setup - Choose an Option  "
    echo "======================================="
    echo "1. Reset Pre-configuration"
    echo "2. Reset .bashrc"
    echo "3. Reset .vimrc"
    echo "4. Reset Git Config"
    echo "5. Reset VS Code Config"
    echo "6. Reset Powerline Config"
    echo "7. Reset Firefox"
    echo "8. Reset WSL Config (WSL only)"
    echo "9. Run Gaming Registry Tweaks (WSL only)"
    echo "0. Run All of the Above (Default)"
    echo "x. Exit"
    echo "======================================="
}

t "Setting up configuration files.."
# User input loop
while true; do
    show_menu
    read -p "Enter your choice (press Enter for default): " choice
    case $choice in
        1) reset_pre ;;
        2) reset_bashrc ;;
        3) reset_vimrc ;;
        4) reset_git_config ;;
        5) reset_vscode_config ;;
        6) reset_powerline_config ;;
        7) reset_firefox ;;
        8) reset_wsl_config ;;
        9) reset_registry ;;
        "" | 0)
            echo "Running all configuration resets..."
            reset_pre
            reset_bashrc
            reset_vimrc
            reset_git_config
            reset_vscode_config
            reset_powerline_config
            reset_firefox
            reset_wsl_config
            reset_registry
            break
            ;;
        x | X) break ;;
        *) echo "Invalid option, please try again." ;;
    esac
    read -p "Press Enter to continue..."
done

echo "Setup script finished."
# reset_post


t IMPORTANT "All done! You may need to exit and reopen!"
