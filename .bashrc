# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi
shopt -s dotglob nullglob  # enable dotfiles and skip empty globs

mkdir -p "$HOME/.bash_extras"
INIT_FILE="$HOME/.bash_extras/.bash_init"
if [[ -f "$INIT_FILE" ]]; then
    DOTFILE_DIR=$(grep '^DOTFILE_DIR=' "$INIT_FILE" | cut -d'=' -f2-)
    if [[ -d "$DOTFILE_DIR" ]]; then
        echo "[INFO] Found saved DOTFILE_DIR: $DOTFILE_DIR"
    else
        echo "[WARNING] Saved DOTFILE_DIR does not exist: $DOTFILE_DIR"
        DOTFILE_DIR=""
    fi
else
  echo "[WARNING] No saved file found at $INIT_FILE"
fi

if [[ -z "$DOTFILE_DIR" ]]; then
    CURRENT_DIR="$(pwd)"
    if [[ "$CURRENT_DIR" != "$HOME" ]]; then
        DOTFILE_DIR="$CURRENT_DIR"
    else
        echo "[WARNING] Hardcoding DOTFILE_DIR.."
        DOTFILE_DIR="$HOME/workplace/repo/dotfiles" 
    fi   
else
    echo "DOTFILE_DIR is set to: $DOTFILE_DIR"
fi
echo "DOTFILE_DIR=$DOTFILE_DIR" > "$INIT_FILE"

EXTRAS_DIR="$DOTFILE_DIR/.bash_extras"
INIT="$EXTRAS_DIR/init"
if [ -f "$INIT/.bash_setup" ]; then
    . "$INIT/.bash_setup"
fi

if [ -f "$INIT/.bash_exports" ]; then
    . "$INIT/.bash_exports"
fi

if [ -f "$INIT/.bash_powerline" ]; then
    . "$INIT/.bash_powerline"
fi

if [ -d "$EXTRAS_DIR" ]; then
    for file in "$EXTRAS_DIR"/*; do
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
