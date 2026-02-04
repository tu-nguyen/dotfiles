#!/usr/bin/env bash
# ===================================================================== #
# install dotfiles script
# ===================================================================== #
set -e

# ------------------------------------------
# Pre-checks
# ------------------------------------------
# Keep sudo alive
# See: https://gist.github.com/cowboy/3118588
if ! command -v sudo &> /dev/null; then
    t Error "${ERR}sudo${NC} is not installed. Please install sudo or run as root."
    exit 1
fi

# Ask for administrator password up-front
sudo -v || true

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Get OS
if [ -z "$OS_TYPE" ]; then
    echo "[ INFO ] Detecting OS.." >&2
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -qi microsoft /proc/version; then
            OS_TYPE="wsl"
        else
            OS_TYPE="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
    else
        echo "[ ERR  ] Unsupported OS: $OSTYPE"
        exit 1
    fi
fi

# Check for modern bash
if ((BASH_VERSINFO[0] < 4)); then
    echo "[ WARN ] You are running ${BASH_VERSION}. Let's fix that."
    if [ "$OS_TYPE" = 'linux' ]; then
        echo "[ INFO ] Attempting to upgrade Bash.."
        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt install bash -y
        elif command -v dnf &>/dev/null; then
            sudo dnf install bash -y
        elif command -v pacman &>/dev/null; then
            sudo pacman -S bash --noconfirm
        fi

        echo "[ INFO ] Relaunching script with updated Bash.."
        exec bash "$0" "$@"
    elif [ "$OS_TYPE" = 'macos' ]; then
        if ! command -v brew &>/dev/null; then
            echo "[ INFO ] Homebrew not found. Installing.."
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
        fi

        # Find the brew bash path
        BREW_BASH=$(brew --prefix)/bin/bash

        # Install bash if brew doesn't have it yet
        [[ ! -f "$BREW_BASH" ]] && brew install bash

        # Add it to the shells list
        if ! grep -q "$BREW_BASH" /etc/shells; then
            echo "$BREW_BASH" | sudo tee -a /etc/shells
        fi

        # Change your default shell to the new Bash
        sudo chsh -s "$BREW_BASH" "$USER"

        echo "[ INFO ] Shell changed to $(brew --prefix)/bin/bash."
        echo "[ INFO ] Relaunching script with modern Bash.."
        exec "$BREW_BASH" "$0" "$@"
    fi
fi

# Defaults / Fallbacks
: ${DOTFILES_REPO:="https://github.com/tu-nguyen/dotfiles.git"}
: ${DOTFILES_CONFIG_DIR:="$HOME/.config/dotfiles"}
: ${DOTFILES_CONFIG_FILE:="$DOTFILES_CONFIG_DIR/.dotfile_config"}
: ${DOTFILES_REPO_DIR:=$(pwd)}
# : ${OS_TYPE:=$OS_TYPE}  # Already set from above
mkdir -p $DOTFILES_CONFIG_DIR

# Helper to update or add a variable in your .dotfile_config
# Copied from bash_functions
_set_config() {
    local key="$1"
    local value="$2"

    if [[ -z "$key" || -z "$value" ]]; then
        t ERR "Usage: _set_config <KEY> <VALUE>"
        return 1
    fi

    if grep -q "^$key=" "$DOTFILES_CONFIG_FILE"; then
        # Line exists: Replace it
        # Using '|' as a delimiter to safely handle paths/slashes in values
        sed -i "s|^$key=.*|$key=$value|" "$DOTFILES_CONFIG_FILE"
    else
        # Line missing: Append it
        echo "$key=$value" >> "$DOTFILES_CONFIG_FILE"
    fi
}

# ------------------------------------------
# Load env
# ------------------------------------------
DOTFILES_ENV_LOADED=false
if [ -f .env ]; then
    echo "[ INFO ] Configuration loaded from .env"
    if [ "$OS_TYPE" = 'linux' ]; then
        export $(grep -v '^#' .env | xargs -d '\n')
    elif [ "$OS_TYPE" = 'macos' ]; then
        export $(grep -v '^#' .env | xargs -0)
    fi
    DOTFILES_ENV_LOADED=true
else
    if [[ -f "$DOTFILES_CONFIG_FILE" ]]; then
        echo "[ INFO ] Configuration loaded from $DOTFILES_CONFIG_FILE"
        . "$DOTFILES_CONFIG_FILE"
        DOTFILES_ENV_LOADED=true
    fi
fi

# Temp fallback / Legacy
if [[ "$DOTFILES_ENV_LOADED" == "false" ]]; then
    OLD_DOTFILES_CONFIG_FILE="$DOTFILES_CONFIG_DIR/.dotfile_config.env"
    if [[ -f "$OLD_DOTFILES_CONFIG_FILE" ]]; then
        echo "[ INFO ] Configuration loaded from $OLD_DOTFILES_CONFIG_FILE"
        . "$OLD_DOTFILES_CONFIG_FILE"

        mv -f "$OLD_DOTFILES_CONFIG_FILE" "$DOTFILES_CONFIG_FILE"

        _set_config "DOTFILES_CONFIG_FILE" "$DOTFILES_CONFIG_FILE"
        . "$DOTFILES_CONFIG_FILE"
        DOTFILES_ENV_LOADED=true
    fi
fi

if [[ "$DOTFILES_ENV_LOADED" == "false" ]]; then
    echo "[ WARN ] .env and .dotfile_config files not found. Script will rely on defaults."

    if [[ ! -f "$DOTFILES_CONFIG_FILE" ]]; then
        echo "[ INFO ] Creating new config file $DOTFILES_CONFIG_FILE"
        touch $DOTFILES_CONFIG_FILE
    fi

    _set_config "DOTFILES_REPO" "$DOTFILES_REPO"
    _set_config "DOTFILES_CONFIG_DIR" "$DOTFILES_CONFIG_DIR"
    _set_config "DOTFILES_CONFIG_FILE" "$DOTFILES_CONFIG_FILE"
    _set_config "DOTFILES_REPO_DIR" "$DOTFILES_REPO_DIR"
    _set_config "OS_TYPE" "$OS_TYPE"
fi

# ------------------------------------------
# Pre-reqs
# ------------------------------------------
# init should source bash_style and bash_functions (for t)
. "$DOTFILES_REPO_DIR/setup/bash/init" || {
    echo "Error: Could not source init"
    exit 1
}
. "$DOTFILES_REPO_DIR/utils.sh" || {
    echo "Error: Could not source utils.sh"
    exit 1
}

# ------------------------------------------
# Main
# ------------------------------------------
# A menu function to display options
show_menu() {
    clear
    printf "${HDR_F}==========================================${NC}\n"
    printf "              ${HDR_F}dotfiles setup              ${NC}\n"
    printf "${HDR_F}==========================================${NC}\n"
    printf "${SEL_F}[1]${NC} reset pre-configuration\n"
    printf "${SEL_F}[2]${NC} reset .bashrc\n"
    printf "${SEL_F}[3]${NC} reset .vimrc\n"
    printf "${SEL_F}[4]${NC} reset gitconfig\n"
    printf "${SEL_F}[5]${NC} reset vs code config\n"
    printf "${SEL_F}[6]${NC} reset firefox\n"
    printf "${SEL_F}[7]${NC} reset wsl config ${SUB_F}(wsl only)${NC}\n"
    printf "${SEL_F}[8]${NC} run gaming registry tweaks ${SUB_F}(wsl only)${NC}\n"
    printf "${SEL_F}[9]${NC} reset powerShell profile ${SUB_F}(wsl only)${NC}\n"
    printf "${BOLD}${CYAN}[0] run all of the above (default)${NC}\n"
    printf "${BOLD}${RED}[x] exit${NC}\n"
    printf "${BOLD}${WHITE}==========================================${NC}\n"
}

if [[ $# -eq 0 ]]; then
    # User input loop
    while true; do
        show_menu
        read -p "Enter your choice (press ${HDR_F}Enter${NC} for default): " choice
        case $choice in
            1) reset_pre ;;
            2) reset_bashrc ;;
            3) reset_vimrc ;;
            4) reset_git_config ;;
            5) reset_vscode_config ;;
            6) reset_firefox ;;
            7) reset_wsl_config ;;
            8) reset_registry ;;
            9) reset_ps ;;
            "" | 0)
                echo "Running ${RED}all${NC} dotfiles resets.."
                reset_pre
                reset_bashrc
                reset_vimrc
                reset_git_config
                reset_vscode_config
                reset_firefox
                reset_wsl_config
                reset_registry
                reset_ps
                break
                ;;
            x | X | q | Q)
                clear
                exit 0 ;;
            *) t WARN "${WARN}Invalid${NC} option, please try again." ;;
        esac
        read -p "Press ${HDR_F}Enter${NC} to continue.."
    done

    echo "${OK}Setup script finished.${NC}"
    # reset_post
else
    # DIRECT COMMAND MODE (e.g., 'r bash' or 'r -f vim')
    clear
    t WARN "${WARN}Forcing bashrc reset..${NC}"
    reset_bashrc
fi

t OK "${SUCCESS}All done! Relaunching bash!${NC}"
exec bash "$0" "$@"
