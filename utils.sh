#!/usr/bin/env bash

# Function to check for sudo availability
check_sudo() {
    if ! command -v sudo &> /dev/null; then
        t Error "sudo is not installed. Please install sudo or run as root."
        exit 1
    fi
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
        t WARNING "Homebrew not found. Installing Homebrew.."
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
        # tmp remove --user --break-system-packages
        pip3 install "$@"
    fi
}

# Function to install packages based on OS
install_package() {
    local package_name="$1"
    t "Installing $package_name.."
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        install_linux_package "$package_name"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            t WARNING "Homebrew not found. Installing Homebrew.."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add Homebrew to PATH for current session
            eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
        fi
        if ! brew install "$package_name"; then
            t Warning "Failed to install $package_name using brew. Trying to continue."
        fi
    fi
}

# # Function to install Powerline fonts
# install_powerline_fonts() {
#     t "Installing Powerline fonts.."
#     local fonts_temp_dir=$(mktemp -d -t powerline-fonts-XXXXXX)
#     if ! git clone https://github.com/powerline/fonts.git "$fonts_temp_dir"; then
#         t "Error" "Failed to clone Powerline fonts repository."
#         rm -rf "$fonts_temp_dir"
#         exit 1
#     fi

#     t "  Running font installation script.."
#     if ! "$fonts_temp_dir/install.sh"; then
#         t "Warning: Powerline font installation script failed. You might need to install fonts manually or update font cache."
#     fi

#     t "Cleaning up temporary font directory.."
#     rm -rf "$fonts_temp_dir"
#     t "Powerline fonts installation attempted."
#     t "NOTE: You may need to configure your terminal emulator to use a Powerline-compatible font (e.g., 'Meslo LG S DZ Regular for Powerline')."
# }

# Function to install (patch) Fira font (Nerd font icons)
install_fira_font() {
    # Check if FiraCode is already installed in the font cache
    if ! fc-list | grep -qi "FiraCode"; then
        echo "FiraCode Nerd Font not found. Installing..."

        # Create directory and move into it
        mkdir -p ~/.local/share/fonts
        cd ~/.local/share/fonts || exit

        # Download and unzip
        curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
        unzip -o FiraCode.zip

        # Clean up zip and extra files
        rm FiraCode.zip

        # Update the system font cache
        fc-cache -fv
        echo "Installation complete!"
    else
        echo "FiraCode Nerd Font is already installed."
    fi

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
    #         t "Registering fonts in Windows Registry via PowerShell..."
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
install_starship() {
    t "Installing Starship.."
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        if ! command -v starship &> /dev/null; then
            echo "Starship not found. Installing now.."
            curl -sS https://starship.rs/install.sh | sh
        else
            echo "Starship is already installed at $(command -v starship)"
            starship --version
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        brew install starship
    fi
}

# Function to install uv
install_uv() {
    t "Installing uv.."

    if ! command -v uv &> /dev/null; then
        echo "uv not found. Installing now.."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        echo "uv is already installed at $(command -v starship)"
        uv --version
    fi
}

# Function to install Fast Node Manager
install_fnm() {
    t "Installing fnm.."

    if ! command -v fnm &> /dev/null; then
        echo "fnm not found. Installing now.."
        curl -fsSL https://fnm.vercel.app/install | bash
    else
        echo "fnm is already installed at $(command -v fnm)"
        fnm --version
    fi
}

# Function to install Gitstatus
install_gitstatus() {
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
        source "$target"
    else
        t ERROR "Failed to copy $file to $target."
    fi
}

prompt() {
    RETURN=0
    local config="$1"

    if [ -z "$FORCE_YES" ]; then
        read -p "Are you sure you want to ${GREEN}$config${NC}? This will ${RED}erase existing data${NC}, might want to create a backup! [y/N] " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            t "Skipping.."
            RETURN=1
            return
        fi
    fi
    echo ""
}

# Function to clone or pull dotfiles repository
clone_or_pull_dotfiles() {
    t "Managing dotfiles repository.."
    if [ -d "$DOTFILES_REPO_DIR/.git" ]; then
        t "  Dotfiles directory '$DOTFILES_REPO_DIR' already exists."
        # Navigate to the dotfiles directory
        cd "$DOTFILES_REPO_DIR" || { t Error "Failed to change directory to $DOTFILES_REPO_DIR. Aborting."; exit 1; }

        local stashed_changes=false
        # Check if there are any uncommitted changes (staged or unstaged)
        if [[ $(git status --porcelain) ]]; then
            t "  Uncommitted changes detected. Stashing them temporarily..."
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
                t "  Attempting to reapply stashed changes after pull failure..."
                git stash pop || t Warning "Failed to pop stash. You may have conflicts to resolve manually."
            fi
            # Return to home directory before exiting on error
            cd "$HOME" || { t Error "Failed to return to home directory after pull error."; }
            exit 1
        fi

        if $stashed_changes; then
            t "  Applying stashed changes..."
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

install_packages() {
    install_package git
    install_package curl
    install_package unzip
    install_package vim
    # install_package python3
    # install_package python3-pip
    install_package make
    install_package jq

    install_fira_font
    install_starship

    install_uv
    install_fnm

    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        if ! command -v apt &>/dev/null; then
            t ERROR "apt package manager not found. Please install it first."
            return 1
        fi

        install_package coreutils
        install_package less
        install_package tree

    elif [[ "$OS_TYPE" == "macos" ]]; then
        install_package lesspipe
        install_package htop
        brew install --cask font-fira-code-nerd-font

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

    install_gitstatus
    install_package htop
    install_package wget

    t SUCCESS "All required packages installed successfully."
    return
}

clone_or_pull_dotfiles

reset_pre() {
    t IMPORTANT "This should be ran at least once!"
    prompt "run pre_setup"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    install_packages

    t DEBUG "reset_pre() end"
}

reset_bashrc() {
    prompt "reset .bashrc"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_colours" "$HOME/.bash_extras/.bash_colours"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/init" "$HOME/.bash_extras/.init"

    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_aliases" "$HOME/.bash_extras/.bash_aliases"
    echo "" >> "$HOME/.bash_extras/.bash_aliases"
    echo "alias cd-dot='cd $DOTFILES_REPO_DIR'" >> "$HOME/.bash_extras/.bash_aliases"
    echo "alias cd-dotfile='cd-dot'"
    echo "alias cd-dotfiles='cd-dot'"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_docker_functions" "$HOME/.bash_extras/.bash_docker_functions"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_functions" "$HOME/.bash_extras/.bash_functions"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_exports" "$HOME/.bash_extras/.bash_exports"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_motd" "$HOME/.bash_extras/.bash_motd"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_other" "$HOME/.bash_extras/.bash_other"
    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bash_tt" "$HOME/.bash_extras/.bash_tt"

    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/bashrc" "$HOME/.bashrc"

    . "$HOME/.bashrc"

    cp_and_source "$DOTFILES_REPO_DIR/setup/bash/starship/starship.toml" "$HOME/.config/starship.toml"

    t DEBUG "reset_bashrc() end"
}

reset_vimrc() {
    prompt "reset .vimrc"
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
        echo "Vim-Plug not found. Installing..."
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        echo "Vim-Plug is already installed."
    fi

    t DEBUG "reset_vimrc() end"
}

reset_git_config() {
    prompt "reset .gitconfig"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/git/git_config_setup.sh
    $DOTFILES_REPO_DIR/setup/git/git_config_setup.sh

    t DEBUG "reset_git_config() end"
}

reset_vscode_config() {
    prompt "reset the vscode configs"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/vscode/vscode_config_setup.sh
    bash -i $DOTFILES_REPO_DIR/setup/vscode/vscode_config_setup.sh || t WARNING "Some error occured during reset_vscode_config()"

    t DEBUG "reset_vscode_config() end"
}

reset_wsl_config() {
    prompt "reset the wsl configs"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for WSL. Skipping WSL configuration reset."
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/wsl/wsl_config_setup.sh
    bash -i $DOTFILES_REPO_DIR/setup/wsl/wsl_config_setup.sh  || t WARNING "Some error occured during reset_wsl_config()"
    t DEBUG "reset_wsl_config() end"
}

reset_registry() {
    prompt "reset the registry entries"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for WSL. Skipping registry reset."
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/registry/registry_script.ps1

    powershell.exe -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"$(wslpath -w $DOTFILES_REPO_DIR/setup/registry/registry_script.ps1)\"'"  || t WARNING "Some error occured during reset_registry()"
    t DEBUG "reset_registry() end"
}

# reset_powerline_config() {
#     prompt "reset the powerline configs"
#     if [[ $RETURN -ne 0 ]]; then
#         return
#     fi

#     chmod +x $DOTFILES_REPO_DIR/setup/powerline/fix_powerline.sh
#     sudo $DOTFILES_REPO_DIR/setup/powerline/fix_powerline.sh

#     chmod +x $DOTFILES_REPO_DIR/setup/powerline/powerline_config_setup.sh
#     bash -i $DOTFILES_REPO_DIR/setup/powerline/powerline_config_setup.sh
#     t SUCCESS "Powerline configuration reset completed!"
# }

reset_firefox() {
    prompt "reset the firefox configs"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/firefox/firefox_setup.sh
    bash -i $DOTFILES_REPO_DIR/setup/firefox/firefox_setup.sh || t WARNING "Some error occured during reset_firefox()"
    t DEBUG "reset_firefox() end"
}

reset_ps() {
    prompt "reset the PowerShell profile"
    if [[ $RETURN -ne 0 ]]; then
        return
    fi

    if [[ "$OS_TYPE" != "wsl" ]]; then
        t ERROR "This function is only for WSL. Skipping WSL configuration reset."
        return
    fi

    chmod +x $DOTFILES_REPO_DIR/setup/powershell/ps1_setup.sh
    bash -i $DOTFILES_REPO_DIR/setup/powershell/ps1_setup.sh  || t WARNING "Some error occured during reset_ps()"
    t DEBUG "reset_ps() end"
}
