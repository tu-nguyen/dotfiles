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
        echo "[INFO] Configuration loaded from $DOTFILE_CONFIG_FILE"
        source "$DOTFILES_CONFIG_FILE"
        ENV_LOADED=true
    fi
fi

DEFAULT_DOTFILES_REPO="https://github.com/tu-nguyen/dotfiles.git"
DEFAULT_DOTFILES_REPO_DIR="$(pwd)"
DEFAULT_GITSTATUS_DIR="$HOME/.gitstatus"
DEFAULT_DOTFILES_CONFIG_FILE="$HOME/.bash_extras/.dotfile_config"
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

t "Setting up configuration files.."
reset_pre
reset_bashrc
reset_vimrc
reset_git_config
reset_vscode_config
reset_powerline_config
reset_firefox

if [[ "$OS_TYPE" == "linux" ]]; then
    t "Setting up Linux specific configurations.."
    # Add any Linux-specific setup here

elif [[ "$OS_TYPE" == "wsl" ]]; then
    t "Setting up WSL specific configurations.."
    # Add any WSL-specific setup here
    reset_wsl_config
elif [[ "$OS_TYPE" == "macos" ]]; then
    t "Setting up macOS specific configurations.."
    # Add any macOS-specific setup here
fi
# reset_post


t SUCCESS "All done! You may need to exit and reopen!"
