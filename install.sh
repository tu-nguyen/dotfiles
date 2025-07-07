#!/bin/bash
set -e

if [ -f .env ]; then
    echo "Sourcing .env file for configuration..."
    source .env
else
    echo "Warning: .env file not found. Script will rely on environment variables or defaults."
    # Define default values if .env is not present and variables are not set externally
    # IMPORTANT: If you don't use a .env file, you MUST set DOTFILES_REPO here.
    : "${DOTFILES_REPO:="https://github.com/YOUR_USERNAME/YOUR_DOTFILES_REPO.git"}"
    : "${DOTFILES_DIR:="/home/user/path/to/dotfiles"}"
    # : "${GITSTATUS_DIR:="$HOME/.gitstatus"}"
fi

DOTFILE_CONFIG_FILE="$HOME/.bash_extras/.dotfile_config"

# Check if DOTFILES_REPO is set after sourcing .env or from defaults
if [ -z "$DOTFILES_REPO" ] || [ "$DOTFILES_REPO" == "/home/user/path/to/dotfiles" ]; then
    echo "ERROR: Please set the 'DOTFILES_REPO' variable in your .env file or directly in the script."
    exit 1
fi

# Check if DOTFILE_PATH is set after sourcing .env or from defaults
if [ -z "$DOTFILE_PATH" ] || [ "$DOTFILE_PATH" == "https://github.com/YOUR_USERNAME/YOUR_DOTFILES_REPO.git" ]; then
    echo "ERROR: Please set the 'DOTFILE_PATH' variable in your .env file or directly in the script."
    if [[ -f "$DOTFILE_CONFIG_FILE" ]]; then
        DOTFILE_PATH=$(grep '^DOTFILE_PATH=' "$DOTFILE_CONFIG_FILE" | cut -d'=' -f2-)
        if [[ -d "$DOTFILE_PATH" ]]; then
            echo "DOTFILE_PATH loaded from $DOTFILE_CONFIG_FILE"
        else
            echo "ERROR: Saved DOTFILE_PATH does not exist in $DOTFILE_CONFIG_FILE"
            exit 1
        fi
    else
        echo "WARNING: No saved file found at $DOTFILE_CONFIG_FILE"
        exit 1
    fi
else
    echo "DOTFILE_PATH set to $DOTFILE_PATH"
fi

echo "DOTFILE_PATH=$DOTFILE_PATH" > "$DOTFILE_CONFIG_FILE"
echo "DOTFILES_REPO=$DOTFILES_REPO" >> "$DOTFILE_CONFIG_FILE"
export DOTFILE_PATH="$DOTFILE_PATH"
export BASHRC_EXTRAS_PATH="$DOTFILE_PATH/.bash_extras"
export BASHRC_INIT="$BASHRC_EXTRAS_PATH/init"

source "$DOTFILE_PATH/setup/bash/bash_colours" || {
    echo "Error: Could not source bash_colours.sh"
    exit 1
}
source "$DOTFILE_PATH/setup/bash/init" || {
    echo "Error: Could not source init.sh"
    exit 1
}
source "$DOTFILE_PATH/utils.sh" || {
    echo "Error: Could not source utils.sh"
    exit 1
}

t "Detecting OS.."
detect_os

t "Setting up configuration files.."
reset_pre
reset_bashrc
reset_vimrc
reset_git_config
reset_vscode_config
reset_powerline_config

if [[ "$OS" == "linux" ]]; then
    t "Setting up Linux specific configurations.."
    # Add any Linux-specific setup here

elif [[ "$OS" == "wsl" ]]; then
    t "Setting up WSL specific configurations.."
    # Add any WSL-specific setup here
    reset_wsl_config
elif [[ "$OS" == "macos" ]]; then
    t "Setting up macOS specific configurations.."
    # Add any macOS-specific setup here
fi
# reset_post


t SUCCESS "All done! You may need to exit and reopen!"
