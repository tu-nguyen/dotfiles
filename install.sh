#!/bin/bash
set -e

if [ -f .env ]; then
    echo "Sourcing .env file for configuration.."
    source .env
else
    echo "Warning: .env file not found. Script will rely on environment variables or defaults."
    # Define default values if .env is not present and variables are not set externally
    # IMPORTANT: If you don't use a .env file, you MUST set DOTFILES_REPO here.
    : "${DOTFILES_REPO:="https://github.com/YOUR_USERNAME/YOUR_DOTFILES_REPO.git"}"
    : "${DOTFILE_REPO_DIR:="/home/user/path/to/dotfiles/repo"}"
    : "${GITSTATUS_DIR:="$HOME/.gitstatus"}"
    : "${OS_TYPE:="wsl"}"
fi

DOTFILE_CONFIG_FILE="$HOME/.bash_extras/.dotfile_config"
GITSTATUS_DIR="$HOME/.gitstatus"

# Check if DOTFILES_REPO is set after sourcing .env or from defaults
if [ -z "$DOTFILES_REPO" ] || [ "$DOTFILES_REPO" == "https://github.com/YOUR_USERNAME/YOUR_DOTFILES_REPO.git" ]; then
    echo "ERROR: Please set the 'DOTFILES_REPO' variable in your .env file or directly in the script."
    exit 1
fi

# Check if DOTFILE_REPO_DIR is set after sourcing .env or from defaults
if [ -z "$DOTFILE_REPO_DIR" ] || [ "$DOTFILE_REPO_DIR" == "/home/user/path/to/dotfiles/repo" ]; then
    echo "ERROR: Please set the 'DOTFILE_REPO_DIR' variable in your .env file or directly in the script."
    if [[ -f "$DOTFILE_CONFIG_FILE" ]]; then
        echo "DOTFILE_CONFIG_FILE set to $DOTFILE_CONFIG_FILE"
    else
        echo "WARNING: No saved file found at $DOTFILE_CONFIG_FILE"
        exit 1
    fi
else
    echo "DOTFILE_REPO_DIR set to $DOTFILE_REPO_DIR"
fi

# Check if OS_TYPE is set after sourcing .env or from defaults
if [ -z "$OS_TYPE" ]; then
    echo "Detecting OS.."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -qi microsoft /proc/version; then
            OS_TYPE="wsl"
        else
            OS_TYPE="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
    else
        echo "ERROR: Unsupported OS: $OSTYPE"
        exit 1
    fi
fi

echo "OS_TYPE set to $OS_TYPE"

echo "DOTFILE_REPO_DIR=$DOTFILE_REPO_DIR" > "$DOTFILE_CONFIG_FILE"
echo "DOTFILES_REPO=$DOTFILES_REPO" >> "$DOTFILE_CONFIG_FILE"
echo "OS_TYPE=$OS_TYPE" >> "$DOTFILE_CONFIG_FILE"
export DOTFILE_REPO_DIR="$DOTFILE_REPO_DIR"
export BASHRC_EXTRAS_PATH="$DOTFILE_REPO_DIR/.bash_extras"
export BASHRC_INIT="$BASHRC_EXTRAS_PATH/init"

source "$DOTFILE_REPO_DIR/setup/bash/bash_colours" || {
    echo "Error: Could not source bash_colours.sh"
    exit 1
}
source "$DOTFILE_REPO_DIR/setup/bash/init" || {
    echo "Error: Could not source init.sh"
    exit 1
}
source "$DOTFILE_REPO_DIR/utils.sh" || {
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
