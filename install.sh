#!/bin/bash
set -e

unset DOTFILES_LOADED
unset BASH_STYLE_LOADED

_get_os_type() {
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
    . .env
    ENV_LOADED=true
else
    DOTFILES_CONFIG_FILE="$HOME/.config/dotfiles/.dotfile_config.env"
    if [[ -f "$DOTFILES_CONFIG_FILE" ]]; then
        echo "[INFO] Configuration loaded from $DOTFILES_CONFIG_FILE"
        . "$DOTFILES_CONFIG_FILE"
        ENV_LOADED=true
    fi
fi

DEFAULT_DOTFILES_REPO="https://github.com/tu-nguyen/dotfiles.git"
DEFAULT_DOTFILES_REPO_DIR="$(pwd)"
DEFAULT_GITSTATUS_DIR="$HOME/.gitstatus"
DEFAULT_DOTFILES_CONFIG_DIR=$HOME/.config/dotfiles
DEFAULT_DOTFILES_CONFIG_FILE="$DEFAULT_DOTFILES_CONFIG_DIR/.dotfile_config.env"
DEFAULT_OS_TYPE=$(_get_os_type)
GITSTATUS_DIR="$HOME/.gitstatus"

if [[ "$ENV_LOADED" == "false" ]]; then
    echo "[WARNING] .env and .dotfile_config.env files not found. Script will rely on defaults."
    : "${DOTFILES_REPO:="$DEFAULT_DOTFILES_REPO"}"
    : "${DOTFILES_REPO_DIR:="$DEFAULT_DOTFILES_REPO_DIR"}"
    : "${DOTFILES_CONFIG_DIR:="$DEFAULT_DOTFILES_CONFIG_DIR"}"
    : "${DOTFILES_CONFIG_FILE:="$DEFAULT_DOTFILES_CONFIG_FILE"}"
    : "${OS_TYPE:=$DEFAULT_OS_TYPE}"
fi

if [ -z "$DOTFILES_REPO_DIR" ] || [ "$DOTFILES_REPO_DIR" == "/path/to/dotfiles" ]; then
    echo "[WARNING] 'DOTFILES_REPO_DIR' was not set, falling to default $DEFAULT_DOTFILES_REPO_DIR."
    : "${DOTFILES_REPO_DIR:="$DEFAULT_DOTFILES_REPO_DIR"}"
fi

if [ -z "$DOTFILES_REPO" ] || [ "$DOTFILES_REPO" == "https://github.com/YOUR_USERNAME/YOUR_DOTFILES_REPO.git" ]; then
    echo "[WARNING] 'DOTFILES_REPO' was not set, falling to default $DEFAULT_DOTFILES_REPO."
    : "${DOTFILES_REPO:="$DEFAULT_DOTFILES_REPO"}"
fi

if [ -z "$DOTFILES_CONFIG_DIR" ] || [ "$DOTFILES_CONFIG_DIR" == "/path/to/.config/dotfiles" ]; then
    echo "[WARNING] 'DOTFILES_CONFIG_DIR' was not set, falling to default $DEFAULT_DOTFILES_CONFIG_DIR."
    : "${DOTFILES_CONFIG_DIR:="$DEFAULT_DOTFILES_CONFIG_DIR"}"
fi

if [ -z "$DOTFILES_CONFIG_FILE" ] || [ "$DOTFILES_CONFIG_FILE" == "/path/to/.dotfile_config.env" ]; then
    echo "[WARNING] 'DOTFILES_CONFIG_FILE' was not set, falling to default $DEFAULT_DOTFILES_CONFIG_FILE."
    : "${DOTFILES_CONFIG_FILE:="$DEFAULT_DOTFILES_CONFIG_FILE"}"
fi

if [ -z "$OS_TYPE" ] || [ "$OS_TYPE" == "some_os" ]; then
    echo "[WARNING] 'OS_TYPE' was not set, falling to default $DEFAULT_OS_TYPE."
    : "${OS_TYPE:="$DEFAULT_OS_TYPE"}"
fi

mkdir -p "$DOTFILES_CONFIG_DIR"
echo "DOTFILES_REPO=$DOTFILES_REPO" > "$DOTFILES_CONFIG_FILE"
echo "DOTFILES_REPO_DIR=$DOTFILES_REPO_DIR" >> "$DOTFILES_CONFIG_FILE"
echo "DOTFILES_CONFIG_DIR=$DOTFILES_CONFIG_DIR"  >> "$DOTFILES_CONFIG_FILE"
echo "DOTFILES_CONFIG_FILE=$DOTFILES_CONFIG_FILE"  >> "$DOTFILES_CONFIG_FILE"
echo "OS_TYPE=$OS_TYPE" >> "$DOTFILES_CONFIG_FILE"

unset BASH_STYLE_LOADED
. "$DOTFILES_REPO_DIR/setup/bash/bash_style" || {
    echo "Error: Could not source bash_style"
    exit 1
}
. "$DOTFILES_REPO_DIR/setup/bash/init" || {
    echo "Error: Could not source init"
    exit 1
}
. "$DOTFILES_REPO_DIR/utils.sh" || {
    echo "Error: Could not source utils.sh"
    exit 1
}

_sudo_keep

# A menu function to display options
show_menu() {
    clear
    printf "${HDR_F}==========================================${NC}\n"
    printf "    ${HDR_F}Dotfiles Setup -- Choose an Option${NC}    \n"
    printf "${HDR_F}==========================================${NC}\n"
    printf "${SEL_F}[1]${NC} Reset Pre-configuration\n"
    printf "${SEL_F}[2]${NC} Reset .bashrc\n"
    printf "${SEL_F}[3]${NC} Reset .vimrc\n"
    printf "${SEL_F}[4]${NC} Reset Git Config\n"
    printf "${SEL_F}[5]${NC} Reset VS Code Config\n"
    printf "${SEL_F}[6]${NC} Reset Firefox\n"
    printf "${SEL_F}[7]${NC} Reset WSL Config ${SUB_F}(WSL only)${NC}\n"
    printf "${SEL_F}[8]${NC} Run Gaming Registry Tweaks ${SUB_F}(WSL only)${NC}\n"
    printf "${SEL_F}[9]${NC} Reset PowerShell profile ${SUB_F}(WSL only)${NC}\n"
    printf "${SEL_F}[0]${NC} Run All of the Above ${SUB_F}(Default)${NC}\n"
    printf "${BOLD}${RED}[x] Exit${NC}\n"
    printf "${BOLD}${WHITE}==========================================x${NC}\n"
}

t "Setting up configuration files.."

# if [[ -z "$target" ]]; then
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
            x | X) break ;;
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

t OK "${SUCCESS}All done! You may need to exit and reopen!${NC}"
