# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi
shopt -s dotglob nullglob  # enable dotfiles and skip empty globs

BASHRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRAS_DIR="$BASHRC_DIR/.bash_extras"

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


# powerline-daemon -q
# POWERLINE_BASH_CONTINUATION=1
# POWERLINE_BASH_SELECT=1
#. /usr/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh

function reset_vimrc() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to reset the .vimrc? This will erase existing data, might want to create a backup! [y/N] " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting.."
        return
      fi
  fi
  echo "[WARNING] Deleting old .vimrc"
  rm ~/.vimrc
  echo "[INFO] linking .vimrc.."
  ln -sv $(pwd)/.vimrc ~/.vimrc
  echo "[INFO] linking successful, sourcing .vimrc.."
  source ~/.vimrc
  echo "You are all set!"
}

function reset_bashrc() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to reset the .bashrc? This will erase existing data, might want to create a backup! [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Exiting.."
      return
    fi
  fi

  echo "[WARNING] Deleting old .bashrc"
  rm ~/.bashrc
  if [[ -d "$HOME/.bash_extras" ]]; then
    echo "[INFO] $HOME/.bash_extras exists, deleting stock .bash files within.."
    rm ~/.bash_extras/.bash_aliases
    rm ~/.bash_extras/.bash_docker_functions
    rm ~/.bash_extras/.bash_exports
    rm ~/.bash_extras/.bash_functions
    rm ~/.bash_extras/.bash_other
    rm ~/.bash_extras/.bash_tt
  else
    echo "[WARNING] $HOME/.bash_extras does not exist, creating.."
    echo "[WARNING] For twork setup, be sure to create a .bash_twork file"
    mkdir ~/.bash_extras
  fi
  
  echo "[INFO] linking .bash_extras files.."
  ln -sv $(pwd)/.bash_extras/.bash_aliases ~/.bash_extras/.bash_aliases
  ln -sv $(pwd)/.bash_extras/.bash_docker_functions ~/.bash_extras/.bash_docker_functions
  ln -sv $(pwd)/.bash_extras/.bash_exports ~/.bash_extras/.bash_exports
  ln -sv $(pwd)/.bash_extras/.bash_functions ~/.bash_extras/.bash_functions
  ln -sv $(pwd)/.bash_extras/.bash_other ~/.bash_extras/.bash_other
  ln -sv $(pwd)/.bash_extras/.bash_tt ~/.bash_extras/.bash_tt
  echo "[INFO] linking .bashrc.."
  ln -sv $(pwd)/.bashrc ~/.bashrc
  echo "[INFO] linking successful, sourcing.."
  source ~/.bashrc
  if [[ ! -f "$EXTRAS_DIR/.bash_twork" ]]; then
    printf "[WARNING].bash_twork does not exist inside .bash_extras, considering creating it!\n"
  else
    printf "[INFO].bash_twork exists!\n"
  fi
  echo "You are all set!"
}

function reset_vimrc() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to reset the .vimrc? This will erase existing data, might want to create a backup! [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Exiting.."
      return
    fi
  fi
  echo "[WARNING] Deleting old .vimrc"
  rm ~/.vimrc
  echo "[INFO] linking .vimrc.."
  ln -sv $(pwd)/.vimrc ~/.vimrc
  echo "[INFO] linking successful, sourcing .vimrc.."
  source ~/.vimrc
  echo "You are all set!"
}

function r() {
  if [[ "$(pwd)" == *"/dotfiles" ]]; then
    echo "Resetting settings.."
    reset_bashrc
    reset_vimrc
  else
    echo "[ERROR] You are not in the root of the dotfiles project! Exiting.."
    return
  fi
}
