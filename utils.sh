#!/usr/bin/env bash

# Function to check for sudo availability
check_sudo() {
    if ! command -v sudo &> /dev/null; then
        t Error "sudo is not installed. Please install sudo or run as root."
        exit 1
    fi
}

# Function to detect the OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -qi microsoft /proc/version; then
            OS="wsl"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        t ERROR "Unsupported OS: $OSTYPE"
        exit 1
    fi
    t "Detected OS: $OS"
}

install_linux_package() {
    check_sudo
    if dpkg -s "$1" &>/dev/null; then
        t SUCCESS "$1 is already installed via apt."
    else
        t "Installing $1.."
        sudo apt install -y "$@"
    fi
}

install_mac_package() {
    if ! command -v brew &> /dev/null; then
        t WARNING "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add Homebrew to PATH for current session
        eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
    fi

    if brew list "$1" &>/dev/null; then
        t SUCCESS "$1 is already installed via brew."
    else
        t "Installing $1.."
        brew install "$@"
    fi
}

install_pip_package() {
    if ! pip3 show "$1" &>/dev/null; then
        t SUCCESS "$1 is already installed via pip."
    else
        t "Installing $1.."
        pip3 install "$@" --user --break-system-packages
    fi
}

# Function to install packages based on OS
install_package() {
    local package_name="$1"
    t "Installing $package_name..."
    if [[ "$OS" == "Linux" || "$OS" == "WSL" ]]; then
        install_linux_package "$package_name"
    elif [[ "$OS" == "macOS" ]]; then
        if ! command -v brew &> /dev/null; then
            t WARNING "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add Homebrew to PATH for current session
            eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
        fi
        if ! brew install "$package_name"; then
            t Warning "Failed to install $package_name using brew. Trying to continue."
        fi
    fi
}

# Function to install Powerline fonts
install_powerline_fonts() {
    t "Installing Powerline fonts..."
    local fonts_temp_dir=$(mktemp -d -t powerline-fonts-XXXXXX)
    if ! git clone https://github.com/powerline/fonts.git "$fonts_temp_dir"; then
        t "Error" "Failed to clone Powerline fonts repository."
        rm -rf "$fonts_temp_dir"
        exit 1
    fi

    t "  Running font installation script..."
    if ! "$fonts_temp_dir/install.sh"; then
        t "Warning: Powerline font installation script failed. You might need to install fonts manually or update font cache."
    fi

    t "Cleaning up temporary font directory..."
    rm -rf "$fonts_temp_dir"
    t "Powerline fonts installation attempted."
    t "NOTE: You may need to configure your terminal emulator to use a Powerline-compatible font (e.g., 'Meslo LG S DZ Regular for Powerline')."
}

# Function to install Gitstatus
install_gitstatus() {
    t "Installing Gitstatus..."
    if [ -d "$GITSTATUS_DIR/.git" ]; then
        t "  Gitstatus directory '$GITSTATUS_DIR' already exists. Pulling latest changes..."
        cd "$GITSTATUS_DIR"
        if ! git pull origin master; then
            t Warning "Failed to pull Gitstatus. Using existing version."
        fi
    else
        t "  Cloning Gitstatus repository to '$GITSTATUS_DIR'..."
        if ! git clone https://github.com/romkatv/gitstatus.git "$GITSTATUS_DIR"; then
            t Error" Failed to clone Gitstatus repository."
            exit 1
        fi
    fi
    cd "$HOME" # Return to home directory
    t "Gitstatus installed/updated successfully."
}

cp_and_source() {
    local file="$1"
    local target="$2"

    if [[ -z "$file" || -z "$target" ]]; then
        t ERROR "Usage: cp_and_source <file> <target>"
        return 1
    fi

    if [[ -f "$target" ]]; then
        t WARNING "File $target exists. Removing it before copying."
        rm "$target"
    fi

    t "Copying $file to $target"
    cp "$file" "$target"

    if [[ -f "$target" ]]; then
        t SUCCESS "Copied $file to $target successfully."
        source "$target"
    else
        t ERROR "Failed to copy $file to $target."
    fi
}

prompt() {
    RETURN=0
    local config="$1"

    if [ -z "$FORCE_YES" ]; then
        read -p "Are you sure you want to ${GREEN}$config${NC}? This will ${RED}erase existing data${NC}, might want to create a backup! [y/N] " -n 1 -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            t "Exiting.."
            RETURN=1
            return 
        fi
    fi
  echo ""
}

# Function to clone or pull dotfiles repository
clone_or_pull_dotfiles() {
    t "Managing dotfiles repository..."
    if [ -d "$DOTFILE_DIR/.git" ]; then
        t "  Dotfiles directory '$DOTFILE_DIR' already exists. Pulling latest changes..."
        cd "$DOTFILE_DIR"
        if ! git pull origin $(git rev-parse --abbrev-ref HEAD); then
            t Error "Failed to pull dotfiles from '$DOTFILES_REPO'. Please check your network or repository access."
            exit 1
        fi
    else
        t "  Cloning dotfiles repository '$DOTFILES_REPO' to '$DOTFILE_DIR'..."
        mkdir -p "$DOTFILE_DIR" # Ensure parent directory exists
        if ! git clone "$DOTFILES_REPO" "$DOTFILE_DIR"; then
            t Error "Failed to clone dotfiles from '$DOTFILES_REPO'. Please check the URL and your network."
            exit 1
        fi
    fi
    cd "$HOME" # Return to home directory
}

install_packages() {
    install_package git
    install_package curl
    install_package vim
    install_package python3
    install_package python3-pip
    install_package make
    install_pip_package powerline-status

    install_powerline_fonts
    install_gitstatus

    if [[ "$OS" == "linux" || "$OS" == "wsl" ]]; then
        if ! command -v apt &>/dev/null; then
            t ERROR "apt package manager not found. Please install it first."
            return 1
        fi

        install_linux_package coreutils
        install_linux_package less
        install_linux_package htop
        install_linux_package powerline
        install_linux_package wget
        install_linux_package tree
    elif [[ "$OS" == "macos" ]]; then
        install_mac_package lesspipe
        install_mac_package htop

        # Check for python3, but do NOT install it
        if ! command -v python3 &>/dev/null; then
            t ERROR "python3 is required but not installed. Please install Python 3 manually."
            exit 1
        else
            t SUCCESS "python3 is already installed."
        fi

    else
        t ERROR "Unsupported OS: $OS. Please install the required packages manually."
        return 1
    fi

    t SUCCESS "All required packages installed successfully."
    return
}

clone_or_pull_dotfiles

reset_pre() {
    prompt "pre_setup"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    install_packages

    t SUCCESS "Pre-setup completed!"
}

reset_bashrc() {
    prompt "reset the .bashrc"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    cp_and_source "$DOTFILE_DIR/setup/bash/bash_colours" "$HOME/.bash_extras/.bash_colours"
    cp_and_source "$DOTFILE_DIR/setup/bash/init" "$HOME/.bash_extras/.init"

    cp_and_source "$DOTFILE_DIR/setup/bash/bash_aliases" "$HOME/.bash_extras/.bash_aliases"
    cp_and_source "$DOTFILE_DIR/setup/bash/bash_docker_functions" "$HOME/.bash_extras/.bash_docker_functions"
    cp_and_source "$DOTFILE_DIR/setup/bash/bash_functions" "$HOME/.bash_extras/.bash_functions"
    cp_and_source "$DOTFILE_DIR/setup/bash/bash_exports" "$HOME/.bash_extras/.bash_exports"
    cp_and_source "$DOTFILE_DIR/setup/bash/bash_motd" "$HOME/.bash_extras/.bash_motd"
    cp_and_source "$DOTFILE_DIR/setup/bash/bash_other" "$HOME/.bash_extras/.bash_other"
    cp_and_source "$DOTFILE_DIR/setup/bash/bash_tt" "$HOME/.bash_extras/.bash_tt"

    cp_and_source "$DOTFILE_DIR/setup/bash/bashrc" "$HOME/.bashrc"

    t SUCCESS "Bash setup completed!"
}

reset_vimrc() {
    prompt "reset the .vimrc"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ -f "$HOME/.vimrc" ]]; then
        t WARNING "Deleting old .vimrc"
        rm $HOME/.vimrc
    fi

    if [[ -d "$HOME/.vim/bundle" ]]; then
        t WARNING "Deleting old .vim/bundle"
        rm -rf $HOME/.vim/bundle
    fi

    cp  "$DOTFILE_DIR/setup/vim/vimrc" "$HOME/.vimrc"
    t SUCCESS "Linked $DOTFILE_DIR/setup/vim/vimrc to $HOME/.vimrc successfully."

    t "Installing Vundle and plugins.."
    VUNDLE_PATH="$HOME/.vim/bundle/Vundle.vim"
    sudo rm -rf "$VUNDLE_PATH"

    t "Installed Vundle.."
    git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_PATH"
    t SUCCESS "Vundle installed at $VUNDLE_PATH"

    vim +PluginInstall +qall

    t SUCCESS "Vim setup completed!"
}

reset_git_config() {
    prompt "reset the .gitconfig"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILE_DIR/setup/git/git_config_setup.sh
    $DOTFILE_DIR/setup/git/git_config_setup.sh

    t SUCCESS "Git configuration reset completed!"
}

reset_vscode_config() {
    prompt "reset the VSCode configuration"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILE_DIR/setup/vscode/vscode_config_setup.sh
    bash -i $DOTFILE_DIR/setup/vscode/vscode_config_setup.sh

    t SUCCESS "VSCode configuration reset completed!"
}

reset_wsl_config() {
    prompt "reset the WSL configuration"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS" != "wsl" ]]; then
        t ERROR "This function is only for WSL. Skipping WSL configuration reset."
        return
    fi

    chmod +x $DOTFILE_DIR/setup/wsl/wsl_config_setup.sh
    bash -i $DOTFILE_DIR/setup/wsl/wsl_config_setup.sh
    t SUCCESS "WSL configuration reset completed!"
}

reset_powerline_config() {
    prompt "reset the Powerline configuration"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILE_DIR/setup/powerline/powerline_config_setup.sh
    bash -i $DOTFILE_DIR/setup/powerline/powerline_config_setup.sh
    t SUCCESS "Powerline configuration reset completed!"
}

reset_firefox() {
    prompt "reset the Firefox configuration"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILE_DIR/setup/firefox/firefox_setup.sh
    bash -i $DOTFILE_DIR/setup/firefox/firefox_setup.sh
    t SUCCESS "Firefox configuration reset completed!"
}

