#!/usr/bin/env bash

# --- Start Load Configuration ---
if [ -z "$DOTFILES_CONFIG_DIR" ]; then
    DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
fi

if [ -z "$DOTFILES_CONFIG_FILE" ]; then
    DOTFILES_CONFIG_FILE="$DOTFILES_CONFIG_DIR/.dotfile_config.env"
fi

if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    . "$DOTFILES_CONFIG_FILE"
else
    echo "[Error] Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi
# --- End Load Configuration ---

# Function to keep sudo alive
# See: https://gist.github.com/cowboy/3118588
_sudo_keep() {
    if ! command -v sudo &> /dev/null; then
        t Error "sudo is not installed. Please install sudo or run as root."
        exit 1
    fi

    # Ask for administrator password up-front
    sudo -v

    # Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Function to linux packages via apt install
# TODO: Add support for arch yoart
_install_linux_package() {
    if dpkg -s "$1" &>/dev/null; then
        t SUCCESS "$1 is already installed via apt."
    else
        t "Installing $1.."
        sudo apt install -y "$@"
    fi
}

_install_brew() {
    if ! command -v brew &> /dev/null; then
        t INFO "Homebrew not found. Installing Homebrew.."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add Homebrew to PATH for current session
        eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
    fi
}

_install_mac_package() {
    _install_brew
    if brew list "$1" &>/dev/null; then
        t SUCCESS "$1 is already installed via brew."
    else
        t "Installing $1.."
        brew install "$@"
    fi
}

_install_pip_package() {
    if ! pip3 show "$1" &>/dev/null; then
        t SUCCESS "$1 is already installed via pip."
    else
        t "Installing $1.."
        # tmp remove --user --break-system-packages
        pip3 install "$@"
    fi
}

# Function to install packages based on OS
_install_package() {
    local package_name="$1"
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        _install_linux_package "$package_name"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        _install_mac_package "$package_name"
    fi
}

# Function to install (patch) Fira Code (Nerd Font icons)
_install_fira_font() {
    t "Installing Fira Code Nerd Font.."
    local FONT_NAME="FiraCode Nerd Font"
    local INSTALLED=0

    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        if command -v fc-list >/dev/null; then
            if fc-list : family | grep -iq "$FONT_NAME"; then
                INSTALLED=1
            fi
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        if system_profiler SPFontsDataType | grep -iq "$FONT_NAME"; then
            INSTALLED=1
        fi
    fi

    if [[ "$INSTALLED" -eq 1 ]]; then
        t SUCCESS "${FONT_NAME} is already installed. Skipping.."
        return 0
    fi

    t INFO "${FONT_NAME} not found. Starting installation..."
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        local font_dir="$HOME/.local/share/fonts"
        mkdir -p "$font_dir"

        t INFO "Downloading FiraCode Nerd Font zip..."
        curl -fLo "/tmp/FiraCode.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip

        unzip -o "/tmp/FiraCode.zip" -d "$font_dir"
        rm "/tmp/FiraCode.zip"

        if command -v fc-cache >/dev/null; then
            fc-cache -f
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-fira-code-nerd-font
    fi
    t SUCCESS "Installation complete!"

    # TODO: fix windows font installation
    # if [[ "$OS_TYPE" == "wsl" ]]; then
    #     # If this didn't work, manually move Fira Font
    #     # explorer.exe .
    #     # explorer.exe shell:fonts
    #     WIN_FONT_DIR_RAW=$(cmd.exe /c "echo %SystemRoot%\Fonts" 2>/dev/null | tr -d '\r')
    #     WIN_FONT_DIR=$(wslpath "$WIN_FONT_DIR_RAW")

    #     cp -n ~/.local/share/fonts/*FiraCode*Nerd*.ttf "$WIN_FONT_DIR" 2>/dev/null

    #     if [ $? -ne 0 ]; then
    #         t WARNING  "Warning: Could not copy fonts to C:\Windows\Fonts."
    #         t WARNING  "Try running your Terminal as Administrator."
    #     else
    #         t "Registering fonts in Windows Registry via PowerShell.."
    #         powershell.exe -ExecutionPolicy Bypass -Command "
    #             \$FontsFolder = 'C:\\Windows\\Fonts'
    #             Get-ChildItem -Path \$FontsFolder -Filter '*FiraCode*Nerd*.ttf' | ForEach-Object {
    #                 \$RegistryPath = 'HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts'
    #                 \$Name = \$_.Name.Replace('.ttf', ' (TrueType)')
    #                 if (-not (Get-ItemProperty -Path \$RegistryPath -Name \$Name -ErrorAction SilentlyContinue)) {
    #                     New-ItemProperty -Path \$RegistryPath -Name \$Name -Value \$_.Name -PropertyType String
    #                 }
    #             }
    #         "
    #         t SUCCESS "Windows registration complete."
    #     fi
    # fi
}

# Function to install Starship
_install_starship() {
    t "Installing Starship.."
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        if ! command -v starship &> /dev/null; then
            t INFO "Starship not found. Installing now.."
            curl -sS https://starship.rs/install.sh | sh
        else
            t OK "Starship is already installed at $(command -v starship)"
            starship --version
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        brew install starship
    fi
}

# Function to install uv
_install_uv() {
    t "Installing uv.."

    if ! command -v uv &> /dev/null; then
        t INFO "uv not found. Installing now.."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        echo "uv is already installed at $(command -v starship)"
        uv --version
    fi
}

# Function to install Fast Node Manager
_install_fnm() {
    t "Installing fnm.."

    if ! command -v fnm &> /dev/null; then
        t INFO "fnm not found. Installing now.."
        curl -fsSL https://fnm.vercel.app/install | bash
    else
        echo "fnm is already installed at $(command -v fnm)"
        fnm --version
    fi
}

# Function to install Gitstatus
_install_gitstatus() {
    t "Installing Gitstatus.."
    if [ -d "$GITSTATUS_DIR/.git" ]; then
        t "  Gitstatus directory '$GITSTATUS_DIR' already exists. Pulling latest changes.."
        cd "$GITSTATUS_DIR"
        if ! git pull origin master; then
            t Warning "Failed to pull Gitstatus. Using existing version."
        fi
    else
        t "  Cloning Gitstatus repository to '$GITSTATUS_DIR'.."
        if ! git clone https://github.com/romkatv/gitstatus.git "$GITSTATUS_DIR"; then
            t Error" Failed to clone Gitstatus repository."
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
        . "$target"
    else
        t ERROR "Failed to copy $file to $target."
    fi
}

_prompt() {
    RETURN=0
    local config="$1"

    if [ -z "$FORCE_YES" ]; then
        read -p "Are you sure you want to ${H}$config${NC}? This will ${RED}erase existing data${NC}, might want to create a backup! [y/N] " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            t "Skipping.."
            RETURN=1
            return
        fi
    fi
    echo ""
}

# Function to clone or pull dotfiles repository
_clone_or_pull_dotfiles() {
    t "Managing dotfiles repository.."
    if [ -d "$DOTFILES_REPO_DIR/.git" ]; then
        t "  Dotfiles directory '$DOTFILES_REPO_DIR' already exists."
        # Navigate to the dotfiles directory
        cd "$DOTFILES_REPO_DIR" || { t Error "Failed to change directory to $DOTFILES_REPO_DIR. Aborting."; exit 1; }

        local stashed_changes=false
        # Check if there are any uncommitted changes (staged or unstaged)
        if [[ $(git status --porcelain) ]]; then
            t "  Uncommitted changes detected. Stashing them temporarily.."
            # Use 'git stash push' for modern git, 'save' is deprecated but works
            if git stash push -m "Temporary stash by dotfiles script before pull"; then
                stashed_changes=true
                t "  Changes stashed successfully."
            else
                t Error "Failed to stash uncommitted changes. Aborting pull."
                # Return to home directory before exiting on error
                cd "$HOME" || { t Error "Failed to return to home directory after stash error."; }
                exit 1
            fi
        fi

        t "  Pulling latest changes from '$DOTFILES_REPO'.."
        # Ensure we pull from the correct branch, or just 'git pull' if upstream is set
        local current_branch=$(git rev-parse --abbrev-ref HEAD)
        if ! git pull origin "$current_branch"; then
            t Error "Failed to pull dotfiles from '$DOTFILES_REPO'. Please check your network or repository access."
            # Attempt to reapply stash even if pull failed, so user can resolve
            if $stashed_changes; then
                t "  Attempting to reapply stashed changes after pull failure.."
                git stash pop || t Warning "Failed to pop stash. You may have conflicts to resolve manually."
            fi
            # Return to home directory before exiting on error
            cd "$HOME" || { t Error "Failed to return to home directory after pull error."; }
            exit 1
        fi

        if $stashed_changes; then
            t "  Applying stashed changes.."
            # git stash pop will fail if there are conflicts, but the user requested it.
            # We'll report if it fails.
            if git stash pop; then
                t "  Stashed changes applied successfully."
            else
                t Warning "Failed to pop stash. You may have conflicts to resolve manually in '$DOTFILES_REPO_DIR'."
            fi
        fi

    else # Repository does not exist, clone it
        t "  Cloning dotfiles repository '$DOTFILES_REPO' to '$DOTFILES_REPO_DIR'.."
        mkdir -p "$DOTFILES_REPO_DIR" # Ensure parent directory exists
        if ! git clone "$DOTFILES_REPO" "$DOTFILES_REPO_DIR"; then
            t Error "Failed to clone dotfiles from '$DOTFILES_REPO'. Please check the URL and your network."
            exit 1
        fi
    fi
    # Always return to home directory at the end of the function
    cd "$HOME" || { t Error "Failed to return to home directory."; exit 1; }
}

# Function to convert hex to 0-5 scale for ANSI cube
_hex_to_256() {
    local hex=$(echo "$1" | sed 's/#//')
    local r=$((16#${hex:0:2} * 5 / 255))
    local g=$((16#${hex:2:2} * 5 / 255))
    local b=$((16#${hex:4:2} * 5 / 255))
    echo $((16 + 36*r + 6*g + b))
}

# Function to convert color, mainly for starship atm
_convert_hex_to_ansi() {
    local input_file="$1"
    local output_file="${2:-$input_file.converted}"

    # Create a copy to work on
    cp "$input_file" "$output_file"

    echo "Converting Hex to ANSI 256 for: $input_file"

    grep -oE '#[0-9a-fA-F]{6}' "$input_file" | sort -u | while read -r hex; do
        ansi=$(hex_to_ansi_256 "$hex")
        echo "Replacing $hex with $ansi"
        sed -i '' "s|$hex|$ansi|g" "$output_file"
    done
}

_install_packages() {
    _install_package git
    _install_package curl
    _install_package unzip
    _install_package vim
    # _install_package python3
    # _install_package python3-pip
    _install_package make
    _install_package jq
    _install_package colordiff

    _install_fira_font
    _install_starship

    _install_uv
    _install_fnm

    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        if ! command -v apt &>/dev/null; then
            t ERROR "apt package manager not found. Please install it first."
            return 1
        fi

        _install_package coreutils
        _install_package less
        _install_package tree

    elif [[ "$OS_TYPE" == "macos" ]]; then
        _install_package lesspipe
        _install_package htop


        # Check for python3, but do NOT install it
        if ! command -v python3 &>/dev/null; then
            t ERROR "python3 is required but not installed. Please install Python 3 manually."
            exit 1
        else
            t SUCCESS "python3 is already installed."
        fi

    else
        t ERROR "Unsupported OS: $OS_TYPE. Please install the required packages manually."
        return 1
    fi

    _install_gitstatus
    _install_package htop
    _install_package wget

    t SUCCESS "All required packages installed successfully."
    return
}

_clone_or_pull_dotfiles

reset_pre() {
    t IMPORTANT "This should be ran at least once!"
    _prompt "run pre_setup"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    _install_packages

    t SUCCESS "reset_pre() completed!"
}

reset_bashrc() {
    _prompt "reset .bashrc" "$1"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_style" "$DOTFILES_CONFIG_DIR/.bash_style"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/init" "$DOTFILES_CONFIG_DIR/.init"

    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_aliases" "$DOTFILES_CONFIG_DIR/.bash_aliases"
    echo "" >> "$DOTFILES_CONFIG_DIR/.bash_aliases"
    echo "alias cd-dot='cd $DOTFILES_REPO_DIR'" >> "$DOTFILES_CONFIG_DIR/.bash_aliases"
    echo "alias cd-dotfile='cd-dot'"
    echo "alias cd-dotfiles='cd-dot'"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_docker_functions" "$DOTFILES_CONFIG_DIR/.bash_docker_functions"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_functions" "$DOTFILES_CONFIG_DIR/.bash_functions"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_exports" "$DOTFILES_CONFIG_DIR/.bash_exports"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_motd" "$DOTFILES_CONFIG_DIR/.bash_motd"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_other" "$DOTFILES_CONFIG_DIR/.bash_other"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_tt" "$DOTFILES_CONFIG_DIR/.bash_tt"

    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bashrc" "$HOME/.bashrc"

    . "$HOME/.bashrc"

    if [[ "$OS_TYPE" == "macos" ]]; then
        convert_hex_to_ansi "$DOTFILES_REPO_DIR/setup/bash/starship/starship.toml" "$HOME/.config/starship.toml"
    else
        cp "$DOTFILES_REPO_DIR/setup/bash/starship/starship.toml" "$HOME/.config/starship.toml"
    fi

    t SUCCESS "reset_bashrc() completed!"
}

reset_vimrc() {
    _prompt "reset .vimrc"
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

    cp  "$DOTFILES_REPO_DIR/setup/vim/vimrc" "$HOME/.vimrc"
    t SUCCESS "Linked $DOTFILES_REPO_DIR/setup/vim/vimrc to $HOME/.vimrc successfully."

    t "Installing Vim-Plug.."
    if [ ! -f ~/.vim/autoload/plug.vim ]; then
        t INFO "Vim-Plug not found. Installing.."
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        echo "Vim-Plug is already installed."
    fi

    t SUCCESS "reset_vimrc() completed!"
}

reset_git_config() {
    _prompt "reset .gitconfig"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/git/git_config_setup.sh
    $DOTFILES_REPO_DIR/setup/git/git_config_setup.sh

    t SUCCESS "reset_git_config() completed!"
}

reset_vscode_config() {
    _prompt "reset the vscode configs"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/vscode/vscode_config_setup.sh
    bash -i $DOTFILES_REPO_DIR/setup/vscode/vscode_config_setup.sh || t WARNING "Some error occured during reset_vscode_config()"

    t SUCCESS "reset_vscode_config() completed!"
}

reset_wsl_config() {
    _prompt "reset the wsl configs"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for WSL. Skipping WSL configuration reset."
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/wsl/wsl_config_setup.sh
    bash -i $DOTFILES_REPO_DIR/setup/wsl/wsl_config_setup.sh  || t WARNING "Some error occured during reset_wsl_config()"

    t SUCCESS "reset_wsl_config() completed!"
}

reset_registry() {
    _prompt "reset the registry entries"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for WSL. Skipping registry reset."
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/registry/registry_script.ps1

    powershell.exe -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"$(wslpath -w $DOTFILES_REPO_DIR/setup/registry/registry_script.ps1)\"'"  || t WARNING "Some error occured during reset_registry()"

    t SUCCESS "reset_registry() completed!"
}

reset_firefox() {
    _prompt "reset the firefox configs"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/firefox/firefox_setup.sh
    bash -i $DOTFILES_REPO_DIR/setup/firefox/firefox_setup.sh || t WARNING "Some error occured during reset_firefox()"

    t SUCCESS "reset_firefox() completed!"
}

reset_ps() {
    _prompt "reset the PowerShell profile"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for WSL. Skipping WSL configuration reset."
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/powershell/ps1_setup.sh
    bash -i $DOTFILES_REPO_DIR/setup/powershell/ps1_setup.sh  || t WARNING "Some error occured during reset_ps()"

    t SUCCESS "reset_ps() completed!"
}
