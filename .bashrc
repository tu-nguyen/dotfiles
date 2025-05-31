# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi
shopt -s dotglob nullglob  # enable dotfiles and skip empty globs

INIT_FILE="$HOME/.bash_extras/.bash_init"

if [[ -n "${BASH_SOURCE[0]}" ]]; then
  DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  mkdir -p "$HOME/.bash_extras"
  echo "DOTFILE_DIR=$(pwd)" > "$INIT_FILE"
else
  CURRENT_DIR="$(pwd)"
  if [[ "$CURRENT_DIR" != "$HOME" ]]; then
    DOTFILE_DIR="$CURRENT_DIR"
    mkdir -p "$HOME/.bash_extras"
    echo "DOTFILE_DIR=$(pwd)" > "$INIT_FILE"
  else
    echo "[WARNING] Falling back logic for DOTFILE_DIR"
    if [[ -f "$INIT_FILE" ]]; then
      grep '^DOTFILE_DIR=' "$INIT_FILE" | cut -d'=' -f2-
    else
      echo "[WARNING] No saved directory found at $INIT_FILE"
      echo "[WARNING] Hardcoding.."
      DOTFILE_DIR="$HOME/workplace/repo/dotfiles" 
    fi
  fi
fi

EXTRAS_DIR="$DOTFILE_DIR/.bash_extras"
INIT="$EXTRAS_DIR/init"

if [ -n "$INIT/.bash_setup" ]; then
  . "$INIT/.bash_setup"
fi

if [ -n "$INIT/.bash_exports" ]; then
  . "$INIT/.bash_exports"
fi

if [ -n "$INIT/.bash_powerline" ]; then
  . "$INIT/.bash_powerline"
fi

if [ -d "$EXTRAS_DIR" ]; then
  for file in "$EXTRAS_DIR"/*; do
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