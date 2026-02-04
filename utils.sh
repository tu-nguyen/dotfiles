#!/usr/bin/env bash


# ------------------------------------------
# Helper functions
# ------------------------------------------
# generic prompt
_prompt() {
    local config="$1"

    # If FORCE_YES is set, we skip the prompt and return success (0)
    [[ -n "$FORCE_YES" ]] && return 0

    # -p: prompt, -r: raw, -n 1: read only one character
    read -p "Are you sure you want to ${H}$config${NC}? This may ${RED}erase existing data${NC}. [y/N] " -r -n 1

    # move to a new line immediately after the keypress so the next output is clean
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        t "Skipping.."
        return 1
    fi

    t OK "${OK}Starting ${H}$config${OK} reset.${NC}"
    return 0
}

# function to copy and source (cpp from setup/bash/bash_functions)
_cp_and_src() {
    cpp -s "$@"
}

# function to convert hex to 0-5 scale for ansi cube
_hex_to_256() {
    local hex=$(echo "$1" | sed 's/#//')
    local r=$((16#${hex:0:2} * 5 / 255))
    local g=$((16#${hex:2:2} * 5 / 255))
    local b=$((16#${hex:4:2} * 5 / 255))
    echo $((16 + 36*r + 6*g + b))
}

# function to convert color, mainly for starship atm
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


# ------------------------------------------
# Helper functions generic install
# ------------------------------------------
# function to linux packages via apt install
# TODO: add support for arch yoart
_install_linux_package() {
    if dpkg -s "$1" &>/dev/null; then
        t SUCCESS "${HDR_F}$1${NC} is already installed via apt."
    else
        t "Installing ${HDR_F}$1${NC}.."
        sudo apt install -y "$@"
    fi
}

# function to install brew
_install_brew() {
    if ! command -v brew &> /dev/null; then
        t INFO "${HDR_F}homebrew${NC} not found. Installing ${HDR_F}homebrew${NC}.."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add Homebrew to PATH for current session
        eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
    fi
}

# function to mac packages via brew
_install_mac_package() {
    _install_brew
    if brew list "$1" &>/dev/null; then
        t SUCCESS "${HDR_F}$1${NC} is already installed via brew."
    else
        t "Installing ${HDR_F}$1${NC}.."
        brew install "$@"
    fi
}

# function to install packages based on os; uses above helper functions
_install_package() {
    local package_name="$1"
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        _install_linux_package "$package_name"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        _install_mac_package "$package_name"
    fi
}


# ------------------------------------------
# Helper functions specific install
# ------------------------------------------
# function to install (patch) fira code (nerd font icons)
_install_fira_font() {
    local font_name="FiraCode Nerd Font"
    local fira_font_installed=0

    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        if command -v fc-list >/dev/null; then
            if fc-list : family | grep -iq "$font_name"; then
                t SUCCESS "${HDR_F}${font_name,,}${NC} found in Linux font cache."
                fira_font_installed=1
            fi
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        if system_profiler SPFontsDataType | grep -iq "$font_name"; then
            fira_font_installed=1
        fi
    fi

    if [[ "$OS_TYPE" == "wsl" ]]; then
        # check registry for Font registration (more reliable than 'dir' in Fonts folder)
        if powershell.exe -NoProfile -Command "Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' | Get-Member | Where-Object Name -like '*FiraCode*'" &>/dev/null; then
            t SUCCESS "${HDR_F}${font_name,,}${NC} found in Windows Registry."
            font_installed=1
        else
            t WARN "${HDR_F}${font_name,,}${NC} ${ERR}NOT${NC} detected on Windows side."
            font_installed=0  # force reinstall/install if Windows side is missing
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

        t INFO "Downloading ${HDR_F}${font_name,,}${NC} zip.."
        curl -fLo "./FiraCode.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip

        unzip -o "./FiraCode.zip" -d "$font_dir" && rm "./FiraCode.zip"
        [ -x "$(command -v fc-cache)" ] && fc-cache -f

        # if WSL, also trigger the windows side (chocolatey)
        if [[ "$OS_TYPE" == "wsl" ]]; then
            t INFO "Installing Chocolatey and Fira Code.."

            # detect the mount point to find where to write the temp file
            local win_temp="/c/Users/Public"
            [ -d "/mnt/c/Windows" ] && win_temp="/mnt/c/Users/Public"
            local ps1_path="$win_temp/install_choco_fira.ps1"
            local win_ps1_path="C:\\Users\\Public\\install_choco_fira.ps1"

            # write the ps1 file using a 'quoted' heredoc (qat << 'EOF')
            # this ensures bash does NOT touch any backslashes or variables inside.
            qat << 'EOF' > "$ps1_path"
Set-Location C:\
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Install Chocolatey if missing
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
    $installScript = (New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1")
    Invoke-Expression $installScript
}

# Update Path for the current process
$env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"

# Install Font
Write-Host "Installing Fira Code Nerd Font..." -ForegroundColor Cyan
& choco install firacodenf -y
EOF
            # elevate and Run
            # Set-Location C:\ is added to the initial call to kill the UNC/WSL path warning
            powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
                Set-Location C:\\;
                Start-Process powershell -ArgumentList '-NoProfile', '-ExecutionPolicy Bypass', '-File', '$win_ps1_path' -Verb RunAs -Wait
            "

            # cleanup and verification
            rm "$ps1_path"
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-fira-code-nerd-font
    fi
    t SUCCESS "${SUCCESS}Installation complete!${NC}"
}

# function to install starship
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

# function to install uv
_install_uv() {
    if ! command -v uv &> /dev/null; then
        t "Installing ${HDR_F}uv${NC}.."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        t OK "${HDR_F}$(uv --version)${NC} is already installed at $(command -v uv)"
    fi

    # update the uv binary itself
    uv self update
    # ensure ~/.local/bin is in your PATH
    uv tool update-shell
    # ensure python and python3 points to uv's python
    uv python install 3.13 --default
    # ensure python vmersion upgrades to latest supported patch release
    uv python upgrade
    # update all tools installed via 'uv tool install' (uv-secure, ruff, etc.)
    uv tool upgrade --all

    # list of tools to install via 'uv tool' (for python-based)
    # or system packages/binary downloads
    local python_tools=("uv-secure" "ruff" "trufflehog")

    for tool in "${python_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            t "Installing ${HDR_F}$tool${NC} via uv.."
            uv tool install "$tool"
        else
            t OK "${HDR_F}$tool${NC} is already available."
        fi
    done
}

# function to install fast node manager
_install_fnm() {
    if ! command -v fnm &> /dev/null; then
        t "Installing ${HDR_F}fnm${NC}.."
        curl -fsSL https://fnm.vercel.app/install | bash
    else
        t OK "${HDR_F}$(fnm --version)${NC} is already installed at $(command -v fnm)"
    fi
}

# function to install gitstatus
_install_gitstatus() {
    local original_dir=$(pwd)
    local installed_or_updated="installed"
    if [ -d "$GITSTATUS_DIR/.git" ]; then
        t OK "${SUB_F}gitstatus${NC} directory '$GITSTATUS_DIR' already exists. Pulling latest changes.."
        cd "$GITSTATUS_DIR"
        if ! git pull origin master &> /dev/null; then
            t Warning "Failed to pull ${SUB_F}gitstatus${NC}. Using existing version."
        fi
        # printf "\033[1A\r\033[K"
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


# ------------------------------------------
# Main
# ------------------------------------------
# main install packages function
_install_packages() {
    local core_packages=("curl" "vim" "git" "make" "jq" "colordiff" "wget" "tree" "bat")

    for core_package in "${core_packages[@]}"; do
        _install_package "$core_package"
    done

    _install_gitstatus
    _install_fira_font
    _install_starship
    _install_uv
    _install_fnm

    # for both linux & wsl only
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        # TODO: Remove when we crawl back to arch
        if ! command -v apt &>/dev/null; then
            t ERROR "apt package manager not found. Please install it first."
            return 1
        fi

        _install_package coreutils
        _install_package less
        _install_package iptables

        # post bat stuff
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/batcat ~/.local/bin/bat
    # macos only
    elif [[ "$OS_TYPE" == "macos" ]]; then
        _install_package lesspipe
        _install_package htop
        _install_package rsync
        _install_package python@3.13
    else
        t ERROR "Unsupported OS: ${ERR}$OS_TYPE${NC}. Please install the required packages manually."
        return 1
    fi

    t SUCCESS "${SUCCESS}All required packages installed successfully.${NC}"
    return 0
}

clone_or_pull_dotfiles

reset_pre() {
    t IMPORTANT "This should be ran at least once!"
    _prompt "run pre_setup"
    if [[ $RETURN -ne 0 ]]; then
        return 0
    fi

    mkdir -p "$HOME/.config"
    # mkdir -p "$HOME/workplace"
    # mkdir -p "$HOME/workplace/repo"

    _install_packages

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_pre()${SUCCESS} completed!!${NC}"
}

reset_bashrc() {
    _prompt "reset .bashrc" "$1"
    if [[ $RETURN -ne 0 ]]; then
        return 0
    fi

    _cp_and_src "$DOTFILES_REPO_DIR/setup/bash/bash_style" "$DOTFILES_CONFIG_DIR/.bash_style"
    _cp_and_src "$DOTFILES_REPO_DIR/setup/bash/init" "$DOTFILES_CONFIG_DIR/.init"
    _cp_and_src "$DOTFILES_REPO_DIR/setup/bash/bash_aliases" "$DOTFILES_CONFIG_DIR/.bash_aliases"
    _cp_and_src "$DOTFILES_REPO_DIR/setup/bash/bash_docker" "$DOTFILES_CONFIG_DIR/.bash_docker"
    _cp_and_src "$DOTFILES_REPO_DIR/setup/bash/bash_functions" "$DOTFILES_CONFIG_DIR/.bash_functions"
    _cp_and_src "$DOTFILES_REPO_DIR/setup/bash/bash_exports" "$DOTFILES_CONFIG_DIR/.bash_exports"
    _cp_and_src "$DOTFILES_REPO_DIR/setup/bash/bash_motd" "$DOTFILES_CONFIG_DIR/.bash_motd"
    _cp_and_src "$DOTFILES_REPO_DIR/setup/bash/bash_tt" "$DOTFILES_CONFIG_DIR/.bash_tt"
    _cp_and_src "$DOTFILES_REPO_DIR/setup/bash/bashrc" "$HOME/.bashrc"
    _cp_and_src "$DOTFILES_REPO_DIR/setup/bash/bash_profile" "$HOME/.bash_profile"
    echo "" >> "$DOTFILES_CONFIG_DIR/.bash_aliases"
    echo "alias cd-dot='cd $DOTFILES_REPO_DIR'" >> "$DOTFILES_CONFIG_DIR/.bash_aliases"
    echo "alias cd-dotfile='cd-dot'" >> "$DOTFILES_CONFIG_DIR/.bash_aliases"
    echo "alias cd-dotfiles='cd-dot'" >> "$DOTFILES_CONFIG_DIR/.bash_aliases"
    if ! command -v graphviz &> /dev/null; then
        echo "alias dot='cd-dot'" >> "$DOTFILES_CONFIG_DIR/.bash_aliases"
    fi

    . "$HOME/.bashrc"

    TEMP_CONFIG_DIR=$(mktemp -d)

    # copy direnv config
    DIRENV_TEMPLATE_FILE="$DOTFILES_REPO_DIR/setup/bash/direnv/direnv.toml"
    DIRENV_DEST_FILE="$HOME/.config/direnv/direnv.toml"
    TEMP_DIRENV_TOML="$TEMP_CONFIG_DIR/direnv.toml"
    mkdir -p "$(dirname "$DIRENV_DEST_FILE")"
    sed "s|/home/username|$HOME|g" "$DIRENV_TEMPLATE_FILE" > "$TEMP_DIRENV_TOML"
    cpp -q "$TEMP_DIRENV_TOML" "$DIRENV_DEST_FILE"

    # copy starship config
    STARSHIP_SRC_DIR="$DOTFILES_REPO_DIR/setup/bash/starship"
    STARSHIP_DEST_DIR="$HOME/.config"

    # loop through all starship .toml files in the source directory
    for template in "$STARSHIP_SRC_DIR"/starship*.toml; do
        # get just the filename (e.g., starship.gruvbox.toml)
        filename=$(basename "$template")
        temp_output="$TEMP_CONFIG_DIR/$filename"
        dest_output="$STARSHIP_DEST_DIR/$filename"

        if [[ "$OS_TYPE" == "macos" ]]; then
            _convert_hex_to_ansi "$template" "$temp_output"
        else
            # using -q for quiet preprocessing
            cpp -q "$template" "$temp_output"
        fi

        # final move/copy to destination
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
    # TODO: replace with nvim?
    if ! _prompt "reset .vimrc"; then
        return 0
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
    if ! _prompt "reset .gitconfig"; then
        return 0
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/git/git_config_setup.sh
    $DOTFILES_REPO_DIR/setup/git/git_config_setup.sh

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_git_config()${SUCCESS} completed!${NC}"
}

reset_vscode_config() {
    if ! _prompt "reset the vscode configs"; then
        return 0
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/vscode/vscode_config_setup.sh
    $DOTFILES_REPO_DIR/setup/vscode/vscode_config_setup.sh || t WARNING "Some error occured during reset_vscode_config()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_vscode_config()${SUCCESS} completed!!${NC}"
}

reset_wsl_config() {
    if ! _prompt "reset the wsl configs"; then
        return 0
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t WARN "This function is only for ${RED}WSL${NC}. Skipping WSL configuration reset."
        return 0
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/wsl/wsl_config_setup.sh
    $DOTFILES_REPO_DIR/setup/wsl/wsl_config_setup.sh  || t WARNING "Some error occured during reset_wsl_config()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_wsl_config()${SUCCESS} completed!!${NC}"
}

reset_registry() {
    if ! _prompt "reset the registry entries"; then
        return 0
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t WARN "This function is only for ${RED}WSL${NC}. Skipping registry reset."
        return 0
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/registry/registry_script.ps1

    powershell.exe -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"$(wslpath -w $DOTFILES_REPO_DIR/setup/registry/registry_script.ps1)\"'"  || t WARNING "Some error occured during reset_registry()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_registry()${SUCCESS} completed!!${NC}"
}

reset_firefox() {
    if ! _prompt "reset the firefox configs"; then
        return 0
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/firefox/firefox_setup.sh
    $DOTFILES_REPO_DIR/setup/firefox/firefox_setup.sh || t WARNING "Some error occured during reset_firefox()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_firefox()${SUCCESS} completed!!${NC}"
}

reset_ps() {
    if ! _prompt "reset the PowerShell profile"; then
        return 0
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for ${ERR}WSL${NC}. Skipping WSL configuration reset."
        return 0
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/powershell/ps1_setup.sh
    $DOTFILES_REPO_DIR/setup/powershell/ps1_setup.sh  || t WARNING "Some error occured during reset_ps()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_ps()${SUCCESS} completed!!${NC}"
}
