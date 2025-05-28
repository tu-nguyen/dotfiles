# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

BASHRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRAS_DIR="$BASHRC_DIR/.bash_extras"

shopt -s dotglob nullglob  # enable dotfiles and skip empty globs
if [ -d "$EXTRAS_DIR" ]; then
  for file in "$EXTRAS_DIR"/*; do
    [ -f "$file" ] && . "$file"
  done
fi
shopt -u dotglob nullglob  # optional: reset settings

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


# powerline-daemon -q
# POWERLINE_BASH_CONTINUATION=1
# POWERLINE_BASH_SELECT=1
#. /usr/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh

function r() {
  if [[ "$(pwd)" == *"/dotfiles" ]]; then
    if [[ -d "~/.bash_extras" ]]; then
      echo "bash_extras exists"
    else
      mkdir ~/.bash_extras
    fi
    ln -sv $(pwd)/.bash_extras/.bash_aliases ~/.bash_extras/bash_aliases
    ln -sv $(pwd)/.bash_extras/.bash_docker_functions ~/.bash_extras/bash_docker_functions
    ln -sv $(pwd)/.bash_extras/.bash_exports ~/.bash_extras/bash_exports
    ln -sv $(pwd)/.bash_extras/.bash_functions ~/.bash_extras/bash_functions
    ln -sv $(pwd)/.bash_extras/.bash_other ~/.bash_extras/bash_other
    ln -sv $(pwd)/.bash_extras/.bash_tt ~/.bash_extras/bash_tt
    ln -sv $(pwd).bashrc ~/.bashrc
  fi
  source ~/.bashrc
}
