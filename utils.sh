#!/usr/bin/env bash

# --- Start Load Configuration ---
if [ -z "$DOTFILES_CONFIG_DIR" ]; then
    DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
fi

if [ -z "$DOTFILES_CONFIG_FILE" ]; then
    DOTFILES_CONFIG_FILE="$DOTFILES_CONFIG_DIR/.dotfile_config"
fi

if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    . "$DOTFILES_CONFIG_FILE"
else
    echo "[Error] Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi

DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
[[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"
# --- End Load Configuration ---

# Function to keep sudo alive
# See: https://gist.github.com/cowboy/3118588
_sudo_keep() {
    if ! command -v sudo &> /dev/null; then
        t Error "${ERR}sudo${NC} is not installed. Please install sudo or run as root."
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
        t SUCCESS "${HDR_F}$1${NC} is already installed via apt."
    else
        t "Installing ${HDR_F}$1${NC}.."
        sudo apt install -y "$@"
    fi
}

_install_brew() {
    if ! command -v brew &> /dev/null; then
        t INFO "${HDR_F}homebrew${NC} not found. Installing ${HDR_F}homebrew${NC}.."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add Homebrew to PATH for current session
        eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
    fi
}

_install_mac_package() {
    _install_brew
    if brew list "$1" &>/dev/null; then
        t SUCCESS "${HDR_F}$1${NC} is already installed via brew."
    else
        t "Installing ${HDR_F}$1${NC}.."
        brew install "$@"
    fi
}

_install_pip_package() {
    if ! pip3 show "$1" &>/dev/null; then
        t SUCCESS "${HDR_F}$1${NC} is already installed via pip."
    else
        t "Installing ${HDR_F}$1${NC}.."
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
    local font_name="FiraCode Nerd Font"
    local fira_font_installed=0

    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        if command -v fc-list >/dev/null; then
            if fc-list : family | grep -iq "$font_name"; then
                fira_font_installed=1
            fi
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        if system_profiler SPFontsDataType | grep -iq "$font_name"; then
            fira_font_installed=1
        fi
    fi

    if [[ "$fira_font_installed" -eq 1 ]]; then
        t SUCCESS "${HDR_F}${font_name,,}${NC} is already installed."
        return 0
    fi

    t "Installing ${HDR_F}${font_name,,}${NC}.."
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        local font_dir="$HOME/.local/share/fonts"
        mkdir -p "$font_dir"

        t INFO "Downloading ${font_name,,} zip.."
        curl -fLo "/tmp/FiraCode.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip

        unzip -o "/tmp/FiraCode.zip" -d "$font_dir"
        rm "/tmp/FiraCode.zip"

        if command -v fc-cache >/dev/null; then
            fc-cache -f
        fi

        if [[ "$OS_TYPE" == "wsl" ]]; then
            # If this didn't work, manually move Fira Font
            # explorer.exe .
            # explorer.exe shell:fonts
            win_font_dir_raw=$(cmd.exe /c "echo %SystemRoot%\Fonts" 2>/dev/null | tr -d '\r')
            win_font_dir=$(wslpath "$win_font_dir_raw")

            cpp "$font_dir"/*.ttf "$win_font_dir/"

            if [ $? -ne 0 ]; then
                t WARNING  "Warning: Could not copy fonts to C:\Windows\Fonts."
                t WARNING  "Try running your Terminal as Administrator."
            else
                t "Registering Fira Code in Windows Registry via PowerShell.."
                powershell.exe -Command "
                    \$src = '$(wslpath -w "$font_dir")';
                    \$fonts = Get-ChildItem -Path \$src -Include *.ttf, *.otf -Recurse;
                    foreach (\$font in \$fonts) {
                        \$targetPath = 'C:\\Windows\\Fonts\\' + \$font.Name;
                        if (!(Test-Path \$targetPath)) {
                            Copy-Item \$font.FullName -Destination \$targetPath;
                            # Registering the font in the Registry so Windows 'sees' it
                            New-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts' \
                            -Name \$font.Name -PropertyType String -Value \$font.Name -Force | Out-Null;
                        }
                    }
                "
                t SUCCESS "Windows registration complete."
            fi
        fi

    elif [[ "$OS_TYPE" == "macos" ]]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-fira-code-nerd-font
    fi
    t SUCCESS "${SUCCESS}Installation complete!${NC}"
}

# Function to install Starship
_install_starship() {
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        if ! command -v starship &> /dev/null; then
            t "Installing ${HDR_F}Starship${NC}.."
            curl -sS https://starship.rs/install.sh | sh
        else
            t OK "${HDR_F}$(starship -V)${NC} is already installed at $(command -v starship)"
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        _install_mac_package starship
    fi
}

# Function to install uv
_install_uv() {
    if ! command -v uv &> /dev/null; then
        t "Installing ${HDR_F}uv${NC}.."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        t OK "${HDR_F}$(uv --version)${NC} is already installed at $(command -v uv)"
    fi
}

# Function to install Fast Node Manager
_install_fnm() {
    if ! command -v fnm &> /dev/null; then
        t "Installing ${HDR_F}fnm${NC}.."
        curl -fsSL https://fnm.vercel.app/install | bash
    else
        t OK "${HDR_F}$(fnm --version)${NC} is already installed at $(command -v fnm)"
    fi
}

# Function to install Gitstatus
_install_gitstatus() {
    local original_dir=$(pwd)
    local installed_or_updated="installed"
    if [ -d "$GITSTATUS_DIR/.git" ]; then
        t OK "${SUB_F}gitstatus${NC} directory '$GITSTATUS_DIR' already exists. Pulling latest changes.."
        cd "$GITSTATUS_DIR"
        if ! git pull origin master &> /dev/null; then
            t Warning "Failed to pull ${SUB_F}gitstatus${NC}. Using existing version."
        fi
        printf "\033[1A\r\033[K"
        local installed_or_updated="updated"
    else
        t "Cloning Gitstatus repository to '$GITSTATUS_DIR'.."
        if ! git clone https://github.com/romkatv/gitstatus.git "$GITSTATUS_DIR"; then
            t Error"Failed to clone ${ERR}gitstatus${NC} repository."
        fi
        local installed_or_updated=installed
    fi
    cd "$original_dir"
    printf "\033[1A\r\033[K"
    t OK "${HDR_F}gitstatus${NC} $installed_or_updated successfully!"
}

cp_and_source() {
    local quiet=false
    local src=""
    local dest=""

    if [[ "$1" == "-q" ]]; then
        quiet=true
        src="$2"
        dest="$3"
    else
        src="$1"
        dest="$2"
    fi

    if [[ -z "$src" || -z "$dest" ]]; then
        t ERROR "Usage: cp_and_source [-q] <source> <destination>"
        return 1
    fi

    if [[ "$quiet" == false ]]; then
        cpp "$src" "$dest"
    else
        cpp -q "$src" "$dest"
    fi

    if [[ -f "$dest" ]]; then
        . "$dest"
    else
        t ERROR "Failed to copy $src to $dest."
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
        t OK "${OK}Starting ${H}$config${OK} reset.${NC}"
    fi
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
    cpp "$input_file" "$output_file"

    t OK "Converting Hex to ANSI 256 for: $(basename "$input_file")"

    grep -oE '#[0-9a-fA-F]{6}' "$input_file" | sort -u | while read -r hex; do
        ansi=$(_hex_to_256 "$hex")
        t OK "Replacing $hex with $ansi"
        sed -i '' "s|$hex|$ansi|g" "$output_file"
    done

    t OK "Hex to ANSI 256 conversion for $(basename $input_file) completed!"
}

_install_packages() {
    _install_package git
    _install_package curl
    _install_package unzip
    _install_package vim
    _install_package make
    _install_package jq
    _install_package colordiff
    _install_package wget
    _install_package direnv
    _install_package tree

    _install_gitstatus
    _install_fira_font
    _install_starship

    _install_uv
    _install_fnm

    # For both Linux & WSL only
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        if ! command -v apt &>/dev/null; then
            t ERROR "apt package manager not found. Please install it first."
            return 1
        fi

        _install_package coreutils
        _install_package less
        _install_package iptables

    # macOS only
    elif [[ "$OS_TYPE" == "macos" ]]; then
        _install_package lesspipe
        _install_package htop
        _install_package rsync

        # Check for python3, but do NOT install it
        if ! command -v python3 &>/dev/null; then
            t ERROR "${ERR}python3${NC} is required but not installed. Please install Python 3 manually."
            exit 1
        else
            t SUCCESS "${HDR_F}python3${NC} is already installed."
        fi

    else
        t ERROR "Unsupported OS: ${ERR}$OS_TYPE${NC}. Please install the required packages manually."
        return 1
    fi

    t SUCCESS "${SUCCESS}All required packages installed successfully.${NC}"
    return
}

clone_or_pull_dotfiles

reset_pre() {
    t IMPORTANT "This should be ran at least once!"
    _prompt "run pre_setup"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/workplace"
    mkdir -p "$HOME/workplace/repo"

    _install_packages

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_pre()${SUCCESS} completed!!${NC}"
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
    echo "alias cd-dotfile='cd-dot'" >> "$DOTFILES_CONFIG_DIR/.bash_aliases"
    echo "alias cd-dotfiles='cd-dot'" >> "$DOTFILES_CONFIG_DIR/.bash_aliases"
    if ! command -v graphviz &> /dev/null; then
        echo "alias dot='cd-dot'" >> "$DOTFILES_CONFIG_DIR/.bash_aliases"
    if

    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_docker_functions" "$DOTFILES_CONFIG_DIR/.bash_docker_functions"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_functions" "$DOTFILES_CONFIG_DIR/.bash_functions"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_exports" "$DOTFILES_CONFIG_DIR/.bash_exports"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_motd" "$DOTFILES_CONFIG_DIR/.bash_motd"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_other" "$DOTFILES_CONFIG_DIR/.bash_other"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_tt" "$DOTFILES_CONFIG_DIR/.bash_tt"

    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bashrc" "$HOME/.bashrc"

    . "$HOME/.bashrc"

    TEMP_CONFIG_DIR=$(mktemp -d)

    # Copy direnv config
    DIRENV_TEMPLATE_FILE="$DOTFILES_REPO_DIR/setup/bash/direnv/direnv.toml"
    DIRENV_DEST_FILE="$HOME/.config/direnv/direnv.toml"
    TEMP_DIRENV_TOML="$TEMP_CONFIG_DIR/direnv.toml"
    mkdir -p "$(dirname "$DIRENV_DEST_FILE")"
    sed "s|/home/username|$HOME|g" "$DIRENV_TEMPLATE_FILE" > "$TEMP_DIRENV_TOML"
    cpp -q "$TEMP_DIRENV_TOML" "$DIRENV_DEST_FILE"

    # Copy starship config
    STARSHIP_SRC_DIR="$DOTFILES_REPO_DIR/setup/bash/starship"
    STARSHIP_DEST_DIR="$HOME/.config"

    # Loop through all starship .toml files in the source directory
    for template in "$STARSHIP_SRC_DIR"/starship*.toml; do
        # Get just the filename (e.g., starship.gruvbox.toml)
        filename=$(basename "$template")
        temp_output="$TEMP_CONFIG_DIR/$filename"
        dest_output="$STARSHIP_DEST_DIR/$filename"

        if [[ "$OS_TYPE" == "macos" ]]; then
            _convert_hex_to_ansi "$template" "$temp_output"
        else
            # Using -q for quiet preprocessing
            cpp -q "$template" "$temp_output"
        fi

        # Final move/copy to destination
        if [[ ! -f "$dest_output" ]]; then
            cpp "$temp_output" "$dest_output"
        fi
    done
    t OK "Transfer of starship tomls complete."

    rm -fr "$TEMP_CONFIG_DIR"

    if [[ ! -f "$STARSHIP_DEST_DIR/starship.toml" ]]; then
        t "starship.toml not found. Initializing with default theme.."
        cpp -q "$STARSHIP_DEST_DIR/starship.tu.toml" "$STARSHIP_DEST_DIR/starship.toml"
    fi

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_bashrc()${SUCCESS} completed!!${NC}"
}

reset_vimrc() {
    _prompt "reset .vimrc"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    cpp -q "$DOTFILES_REPO_DIR/setup/vim/vimrc" "$HOME/.vimrc"

    if [ ! -f ~/.vim/autoload/plug.vim ]; then
        t "Installing ${HDR_F}Vim-Plug${NC}.."
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        t OK "${HDR_F}Vim-Plug${NC} is already installed."
    fi

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_vimrc()${SUCCESS} completed!!${NC}"
}

reset_git_config() {
    _prompt "reset .gitconfig"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/git/git_config_setup.sh
    $DOTFILES_REPO_DIR/setup/git/git_config_setup.sh

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_git_config()${SUCCESS} completed!${NC}"
}

reset_vscode_config() {
    _prompt "reset the vscode configs"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/vscode/vscode_config_setup.sh
    $DOTFILES_REPO_DIR/setup/vscode/vscode_config_setup.sh || t WARNING "Some error occured during reset_vscode_config()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_vscode_config()${SUCCESS} completed!!${NC}"
}

reset_wsl_config() {
    _prompt "reset the wsl configs"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for ${ERR}WSL${NC}. Skipping WSL configuration reset."
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/wsl/wsl_config_setup.sh
    $DOTFILES_REPO_DIR/setup/wsl/wsl_config_setup.sh  || t WARNING "Some error occured during reset_wsl_config()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_wsl_config()${SUCCESS} completed!!${NC}"
}

reset_registry() {
    _prompt "reset the registry entries"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for ${ERR}WSL${NC}. Skipping registry reset."
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/registry/registry_script.ps1

    powershell.exe -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"$(wslpath -w $DOTFILES_REPO_DIR/setup/registry/registry_script.ps1)\"'"  || t WARNING "Some error occured during reset_registry()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_registry()${SUCCESS} completed!!${NC}"
}

reset_firefox() {
    _prompt "reset the firefox configs"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/firefox/firefox_setup.sh
    $DOTFILES_REPO_DIR/setup/firefox/firefox_setup.sh || t WARNING "Some error occured during reset_firefox()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_firefox()${SUCCESS} completed!!${NC}"
}

reset_ps() {
    _prompt "reset the PowerShell profile"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for ${ERR}WSL${NC}. Skipping WSL configuration reset."
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/powershell/ps1_setup.sh
    $DOTFILES_REPO_DIR/setup/powershell/ps1_setup.sh  || t WARNING "Some error occured during reset_ps()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_ps()${SUCCESS} completed!!${NC}"
}
