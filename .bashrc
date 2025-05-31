# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi
shopt -s dotglob nullglob  # enable dotfiles and skip empty globs

BASHRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRAS_DIR="$BASHRC_DIR/.bash_extras"
INIT="$EXTRAS_DIR/init"

if [ -f "$$INIT/.bash_setup" ]; then
  . "$$INIT/.bash_setup"
fi
if [ -f "$$INIT/.bash_exports" ]; then
  . "$$INIT/.bash_exports"
fi
if [ -f "$$INIT/.bash_powerline" ]; then
  . "$$INIT/.bash_powerline"
fi

if [ -d "$EXTRAS_DIR" ]; then
  for file in "$EXTRAS_DIR"/*; do
    [ -f "$file" ] && . "$file"
  done
fi

# old
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