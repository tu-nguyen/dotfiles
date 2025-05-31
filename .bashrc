# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi
shopt -s dotglob nullglob  # enable dotfiles and skip empty globs

# Text Colors (Foreground)
BLACK=$(tput setaf 0 2>/dev/null || echo -e '\033[0;30m')
RED=$(tput setaf 1 2>/dev/null || echo -e '\033[0;31m')
GREEN=$(tput setaf 2 2>/dev/null || echo -e '\033[0;32m')
YELLOW=$(tput setaf 3 2>/dev/null || echo -e '\033[0;33m')
BLUE=$(tput setaf 4 2>/dev/null || echo -e '\033[0;34m')
MAGENTA=$(tput setaf 5 2>/dev/null || echo -e '\033[0;35m')
CYAN=$(tput setaf 6 2>/dev/null || echo -e '\033[0;36m')
WHITE=$(tput setaf 7 2>/dev/null || echo -e '\033[0;37m')
GRAY=$(tput setaf 8 2>/dev/null || echo -e '\033[0;90m')

# Bright Colors (if your terminal supports them)
BRIGHT_RED=$(tput setaf 9 2>/dev/null || echo -e '\033[1;31m')
BRIGHT_GREEN=$(tput setaf 10 2>/dev/null || echo -e '\033[1;32m')
BRIGHT_YELLOW=$(tput setaf 11 2>/dev/null || echo -e '\033[1;33m')
BRIGHT_BLUE=$(tput setaf 12 2>/dev/null || echo -e '\033[1;34m')
BRIGHT_MAGENTA=$(tput setaf 13 2>/dev/null || echo -e '\033[1;35m')
BRIGHT_CYAN=$(tput setaf 14 2>/dev/null || echo -e '\033[1;36m')
BRIGHT_WHITE=$(tput setaf 15 2>/dev/null || echo -e '\033[1;37m')

# Text Formatting
BOLD=$(tput bold 2>/dev/null || echo -e '\033[1m')
UNDERLINE=$(tput smul 2>/dev/null || echo -e '\033[4m')
RESET=$(tput sgr0 2>/dev/null || echo -e '\033[0m')
NC=$RESET

# Example usage
# echo "${RED}This is red text${RESET}"
# echo "${BOLD}${BLUE}This is bold blue text${RESET}"

t() {
  # t "System started"                  # [INFO] System started
  # t WARNING "Disk space low"          # [WARNING] Disk space low
  # t ERROR "Failed to connect to DB"   # [ERROR] Failed to connect to DB
  # t                                   # Hello world
  local severity message color

  if [[ $# -eq 0 ]]; then
    echo -e "${GREEN}Hello world${NC}"
    return
  elif [[ $# -eq 1 ]]; then
    severity="INFO"
    message="$1"
  else
    severity="${1^^}"  # Convert to uppercase
    message="$2"
  fi

  # Determine color and label
  case "$severity" in
    info|INFO)
      echo -e "${BRIGHT_BLUE}[INFO]${NC} $message"
      ;;
    warn|warning|WARNING)
      echo -e "${YELLOW}[WARNING]${NC} $message"
      ;;
    err|error|ERR|ERROR)
      echo -e "${RED}[ERROR]${NC} $message"
      ;;
    success|ok|SUCCESS|OK)
      echo -e "${GREEN}[SUCCESS]${NC} $message"
      ;;
    debug|DEBUG)
      echo -e "${CYAN}[DEBUG]${NC} $message"
      ;;
    *)
      echo -e "${NC}[UNKNOWN] $severity: $message"
      ;;
  esac
}

mkdir -p "$HOME/.bash_extras/init"
BASH_INIT_FILE="$HOME/.bash_extras/init/.bash_init"
if [[ -f "$BASH_INIT_FILE" ]]; then
    DOTFILE_PATH=$(grep '^DOTFILE_PATH=' "$BASH_INIT_FILE" | cut -d'=' -f2-)
    if [[ -d "$DOTFILE_PATH" ]]; then
        t INFO "Found saved DOTFILE_PATH: $DOTFILE_PATH"
    else
        t WARNING "Saved DOTFILE_PATH does not exist: $DOTFILE_PATH"
        DOTFILE_PATH=""
    fi
else
  t WARNING "No saved file found at $BASH_INIT_FILE"
fi

if [[ -z "$DOTFILE_PATH" ]]; then
    CURRENT_PATH="$(pwd)"
    if [[ "$CURRENT_PATH" != "$HOME" ]]; then
        DOTFILE_PATH="$CURRENT_PATH"
    else
        t WARNING "Hardcoding DOTFILE_PATH.."
        DOTFILE_PATH="$HOME/workplace/repo/dotfiles" 
    fi   
else
    t INFO "DOTFILE_PATH is set to: $DOTFILE_PATH"
fi
echo "DOTFILE_PATH=$DOTFILE_PATH" > "$BASH_INIT_FILE"
export DOTFILE_PATH="$DOTFILE_PATH"

export BASHRC_EXTRAS_PATH="$DOTFILE_PATH/.bash_extras"
export BASHRC_INIT="$BASHRC_EXTRAS_PATH/init"

if [ -f "$BASHRC_INIT/.bash_setup" ]; then
    . "$BASHRC_INIT/.bash_setup"
fi

if [ -f "$BASHRC_INIT/.bash_exports" ]; then
    . "$BASHRC_INIT/.bash_exports"
fi

if [ -f "$BASHRC_INIT/.bash_powerline" ]; then
    . "$BASHRC_INIT/.bash_powerline"
fi

if [ -d "$BASHRC_EXTRAS_PATH" ]; then
    for file in "$BASHRC_EXTRAS_PATH"/*; do
        [ -f "$file" ] && . "$file"
    done
fi 

if [ -d "$HOME/.bash_extras" ]; then
    for file in "$HOME/.bash_extras"/*; do
        [ -f "$file" ] && . "$file"
    done
fi  

# PS1='[\u@\h \W]\$'
RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
MAGENTA="\[$(tput setaf 5)\]"
CYAN="\[$(tput setaf 6)\]"
WHITE="\[$(tput setaf 7)\]"
GRAY="\[$(tput setaf 8)\]"
BOLD="\[$(tput bold)\]"

# Set colors/font-weights.
CUSER=$MAGENTA
CPATH=$CYAN
BOLD=$BOLD
RESET="\[$(tput sgr0)\]"
CCOLOR=$YELLOW

# Custom prompt.
export PS1="${CUSER}\u@\h${RESET}:${CPATH}${BOLD}\w${RESET}#"
