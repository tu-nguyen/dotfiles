#!/usr/bin/env bash
# ===================================================================== #
# UTILS FOR INSTALLATION
# ===================================================================== #

# ------------------------------------------
# Pre-Reqs
# ------------------------------------------
# init should source bash_functions and bash_style (for t)
. "$DOTFILES_REPO_DIR/setup/bash/init" || {
    echo "Error: Could not source init"
    exit 1
}

# ------------------------------------------
# Helper Functions
# ------------------------------------------
# Generic reset prompt
_reset_prompt() {
    local config="$1"

    _prompt "Are you sure you want to ${H}$config${NC}? This may ${RED}erase existing data${NC}."
}

# Function to copy and source (cpp from setup/bash/bash_functions)
_cp_and_src() {
    cpp -s "$@"
}

# Function to convert color, mainly for starship atm
_convert_hex_to_ansi() {
    local input_file="$1"
    local output_file="${2:-$input_file.converted}"

    # create a copy to work on
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
# Helper Functions Generic install
# ------------------------------------------
# Function to linux packages via apt install
# TODO: add support for arch yoart
_install_linux_packages() {
    local missing_pkgs=()

    # Find what's actually missing
    for pkg in "$@"; do
        if dpkg -s "$pkg" &>/dev/null; then
            t SUCCESS "${HDR_F}$pkg${NC} is already installed!"
        else
            missing_pkgs+=("$pkg")
        fi
    done

    # If missing packages, install them in one batch
    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        t "Installing missing packages: ${HDR_F}${missing_pkgs[*]}${NC}.."

        # update once before batch installing to ensure we get latest versions
        sudo apt update -y
        sudo apt install -y "${missing_pkgs[@]}"
    fi
}

# Function to install brew
_install_brew() {
    if ! command -v brew &> /dev/null; then
        t INFO "${HDR_F}homebrew${NC} not found. Installing ${HDR_F}homebrew${NC}.."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add Homebrew to PATH for current session
        eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
    fi
}

# Function to mac packages via brew
_install_mac_packages() {
    # Ensure brew is available before proceeding
    _install_brew

    local missing_pkgs=()

    # Identify which packages aren't installed yet
    for pkg in "$@"; do
        if brew list "$pkg" &>/dev/null; then
            t SUCCESS "${HDR_F}$pkg${NC} is already installed via brew."
        else
            missing_pkgs+=("$pkg")
        fi
    done

    # Install the missing ones in a single batch
    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        t "Installing missing brew packages: ${HDR_F}${missing_pkgs[*]}${NC}.."

        brew install "${missing_pkgs[@]}"

        t SUCCESS "Installation of ${HDR_F}${missing_pkgs[*]}${NC} complete."
    fi
}

# Function to install packages based on os; uses above helper functions
_install_packages() {
    [[ $# -eq 0 ]] && return

    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        _install_linux_packages "$@"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        _install_mac_packages "$@"
    fi
}


# ------------------------------------------
# Helper Functions Specific install
# ------------------------------------------
# Function to install (patch) fira code (nerd font icons)
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
        # Check registry for Font registration (more reliable than 'dir' in Fonts folder)
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

        # If WSL, also trigger the windows side (chocolatey)
        if [[ "$OS_TYPE" == "wsl" ]]; then
            t INFO "Installing Chocolatey and Fira Code.."

            # Detect the mount point to find where to write the temp file
            local win_temp="/c/Users/Public"
            [ -d "/mnt/c/Windows" ] && win_temp="/mnt/c/Users/Public"
            local ps1_path="$win_temp/install_choco_fira.ps1"
            local win_ps1_path="C:\\Users\\Public\\install_choco_fira.ps1"

            # Write the ps1 file using a 'quoted' heredoc (qat << 'EOF')
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
            # Elevate and Run
            # Set-Location C:\ is added to the initial call to kill the UNC/WSL path warning
            powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
                Set-Location C:\\;
                Start-Process powershell -ArgumentList '-NoProfile', '-ExecutionPolicy Bypass', '-File', '$win_ps1_path' -Verb RunAs -Wait
            "

            # Cleanup and verification
            rm "$ps1_path"
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-fira-code-nerd-font
    fi
    t SUCCESS "${SUCCESS}Installation complete!${NC}"
}

# Function to install starship
_install_starship() {
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        if ! command -v starship &> /dev/null; then
            t "Installing ${HDR_F}Starship${NC}.."
            curl -sS https://starship.rs/install.sh | sh
        else
            t OK "${HDR_F}$(starship -V)${NC} is already installed at ${SUB_F}$(command -v starship)${NC}"
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
        t OK "${HDR_F}$(uv --version)${NC} is already installed at ${SUB_F}$(command -v uv)${NC}"
    fi
}

_install_uv_tools() {
    # List of tools to install via 'uv tool' (for python-based)
    # or system packages/binary downloads
    local python_tools=("uv-secure" "ruff" "trufflehog")

    # Removed "thefuck" since 3.13 broke it, tf

    for tool in "${python_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            t "Installing ${HDR_F}$tool${NC} via uv.."
            uv tool install "$tool"
        else
            t OK "${HDR_F}$tool${NC} is already available."
        fi
    done
}

# Function to install fast node manager
_install_fnm() {
    if ! command -v fnm &> /dev/null; then
        t "Installing ${HDR_F}fnm${NC}.."
        curl -fsSL https://fnm.vercel.app/install | bash
    else
        t OK "${HDR_F}$(fnm --version)${NC} is already installed at ${SUB_F}$(command -v fnm)${NC}"
    fi
}

# Function to install gitstatus
_install_gitstatus() {
    local original_dir=$(pwd)
    local installed_or_updated="installed"
    GITSTATUS_DIR="$HOME/.gitstatus"
    if [ -d "$GITSTATUS_DIR/.git" ]; then
        t OK "${HDR_F}gitstatus${NC} directory '${SUB_F}$GITSTATUS_DIR${NC}' already exists. Pulling latest changes.."
        cd "$GITSTATUS_DIR"
        if ! git pull origin master &> /dev/null; then
            t Warning "Failed to pull ${HDR_F}gitstatus${NC}. Using existing version."
        fi
        # printf "\033[1A\r\033[K"
        local installed_or_updated="updated"
    else
        t "Cloning ${HDR_F}gitstatus${NC} repository to '${SUB_F}$GITSTATUS_DIR${NC}'.."
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
# clone_or_pull_dotfiles

reset_pre() {
    t IMPORTANT "This should be ran at least once!"
    _reset_prompt "run pre_setup"
    if [[ $RETURN -ne 0 ]]; then
        return 0
    fi
    t OK "${OK}Starting ${H}pre-config${OK} reset.${NC}"

    mkdir -p "$HOME/.config"
    # mkdir -p "$HOME/workplace"
    # mkdir -p "$HOME/workplace/repo"

    local core_packages=("curl" "vim" "git" "make" "jq" "colordiff" "wget" "tree" "bat")
    _install_packages "${core_packages[@]}"

    _install_gitstatus
    _install_fira_font
    _install_starship
    _install_uv
    _update_uv
    _install_uv_tools
    _install_fnm

    # For both linux & wsl only
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        # TODO: Remove when we crawl back to arch
        if ! command -v apt &>/dev/null; then
            t ERROR "apt package manager not found. Please install it first."
            return 1
        fi

        local linux_packages=("coreutils" "less" "iptables")
        _install_packages "${linux_packages[@]}"

        # Post bat stuff
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/batcat ~/.local/bin/bat
    # macos only
    elif [[ "$OS_TYPE" == "macos" ]]; then
        # NOTE: python@3.13 removed in favor of uv
        local mac_packages=("lesspipe" "htop" "rsync")
        _install_packages "${linux_packages[@]}"
    else
        t ERROR "Unsupported OS: ${ERR}$OS_TYPE${NC}. Please install the required packages manually."
        return 1
    fi

    t SUCCESS "${SUCCESS}All required packages installed successfully.${NC}"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_pre()${SUCCESS} completed!!${NC}"
}

reset_bashrc() {
    _reset_prompt "reset .bashrc" "$1"
    if [[ $RETURN -ne 0 ]]; then
        return 0
    fi
    t OK "${OK}Starting ${H}bash${OK} reset.${NC}"

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

    . "$DOTFILES_CONFIG_DIR/.bash_aliases"

    . "$HOME/.bashrc"

    TEMP_CONFIG_DIR=$(mktemp -d)

    # Copy direnv config
    DIRENV_TEMPLATE_FILE="$DOTFILES_REPO_DIR/setup/bash/direnv/direnv.toml"
    DIRENV_DEST_FILE="$HOME/.config/direnv/direnv.toml"
    TEMP_DIRENV_TOML="$TEMP_CONFIG_DIR/direnv.toml"
    mkdir -p "$(dirname "$DIRENV_DEST_FILE")"
    sed "s|/home/username|$HOME|g" "$DIRENV_TEMPLATE_FILE" > "$TEMP_DIRENV_TOML"
    cpp "$TEMP_DIRENV_TOML" "$DIRENV_DEST_FILE"
    cpp "$DOTFILES_REPO_DIR/setup/bash/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"

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
        cpp "$temp_output" "$dest_output"
    done
    t OK "Transfer of starship tomls complete."

    rm -fr "$TEMP_CONFIG_DIR"

    if [[ ! -f "$STARSHIP_DEST_DIR/starship.toml" ]]; then
        t "starship.toml not found. Initializing with default theme.."
        cpp "$STARSHIP_DEST_DIR/starship.tu.toml" "$STARSHIP_DEST_DIR/starship.toml"
    fi

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_bashrc()${SUCCESS} completed!!${NC}"
}

reset_vimrc() {
    # TODO: replace with nvim?
    if ! _reset_prompt "reset .vimrc"; then
        return 0
    fi
    t OK "${OK}Starting ${H}vim${OK} reset.${NC}"

    cpp "$DOTFILES_REPO_DIR/setup/vim/vimrc" "$HOME/.vimrc"

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
    if ! _reset_prompt "reset .gitconfig"; then
        return 0
    fi
    t OK "${OK}Starting ${H}git${OK} reset.${NC}"

    chmod +x $DOTFILES_REPO_DIR/setup/git/git_config_setup.sh
    $DOTFILES_REPO_DIR/setup/git/git_config_setup.sh

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_git_config()${SUCCESS} completed!${NC}"
}

reset_vscode_config() {
    if ! _reset_prompt "reset the vscode configs"; then
        return 0
    fi
    t OK "${OK}Starting ${H}vscode${OK} reset.${NC}"

    chmod +x $DOTFILES_REPO_DIR/setup/vscode/vscode_config_setup.sh
    $DOTFILES_REPO_DIR/setup/vscode/vscode_config_setup.sh || t WARNING "Some error occured during reset_vscode_config()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_vscode_config()${SUCCESS} completed!!${NC}"
}

reset_wsl_config() {
    if ! _reset_prompt "reset the wsl configs"; then
        return 0
    fi
    t OK "${OK}Starting ${H}wsl${OK} reset.${NC}"

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t WARN "This function is only for ${RED}wsl${NC}. Skipping wsl configuration reset."
        return 0
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/wsl/wsl_config_setup.sh
    $DOTFILES_REPO_DIR/setup/wsl/wsl_config_setup.sh  || t WARNING "Some error occured during reset_wsl_config()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_wsl_config()${SUCCESS} completed!!${NC}"
}

reset_registry() {
    if ! _reset_prompt "reset the registry entries"; then
        return 0
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERR "This function is only for ${RED}wsl${NC}. Skipping registry reset."
        return 0
    fi
    t OK "${OK}Starting ${H}registry${OK} reset.${NC}"

    chmod +x $DOTFILES_REPO_DIR/setup/registry/registry_script.ps1

    powershell.exe -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"$(wslpath -w $DOTFILES_REPO_DIR/setup/registry/registry_script.ps1)\"'"  || t WARNING "Some error occured during reset_registry()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_registry()${SUCCESS} completed!!${NC}"
}

reset_ps() {
    if ! _reset_prompt "reset the ps profile"; then
        return 0
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for ${ERR}WSL${NC}. Skipping WSL configuration reset."
        return 0
    fi
    t OK "${OK}Starting ${H}ps${OK} reset.${NC}"

    chmod +x $DOTFILES_REPO_DIR/setup/powershell/ps1_setup.sh
    $DOTFILES_REPO_DIR/setup/powershell/ps1_setup.sh  || t WARNING "Some error occured during reset_ps()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_ps()${SUCCESS} completed!!${NC}"
}

reset_firefox() {
    if ! _reset_prompt "reset the firefox configs"; then
        return 0
    fi
    t OK "${OK}Starting ${H}firefox config${OK} reset.${NC}"

    chmod +x $DOTFILES_REPO_DIR/setup/firefox/firefox_setup.sh
    $DOTFILES_REPO_DIR/setup/firefox/firefox_setup.sh || t WARNING "Some error occured during reset_firefox()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_firefox()${SUCCESS} completed!!${NC}"
}

reset_macos_config() {
    if ! _reset_prompt "reset the macos configs"; then
        return 0
    fi

    if [[ "$OS_TYPE" != "macos" ]]; then
        t WARN "This function is only for ${RED}macos${NC}. Skipping macos configuration reset."
        return 0
    fi
    t OK "${OK}Starting ${H}macos${OK} reset.${NC}"

    chmod +x $DOTFILES_REPO_DIR/setup/macos/macos_config_setup.sh
    $DOTFILES_REPO_DIR/setup/macos/macos_config_setup.sh  || t WARNING "Some error occured during reset_macos_config()"

    t SUCCESS "${SUCCESS}Function to ${HDR_F}reset_macos_config()${SUCCESS} completed!!${NC}"
}
