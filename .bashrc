# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi
shopt -s dotglob nullglob  # enable dotfiles and skip empty globs

BASHRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRAS_DIR="$BASHRC_DIR/.bash_extras"

if [ -d "$EXTRAS_DIR" ]; then
  if [ -f "$$EXTRAS_DIR/.bash_setup" ]; then
    . "$$EXTRAS_DIR/.bash_setup"
  fi
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

is_powerline_enabled() {
    pgrep -f powerline-daemon >/dev/null && return 0
    type _powerline_prompt 2>/dev/null | grep -q "function" && return 0
    echo "$PS1" | grep -q "powerline" && return 0
    return 1
}

# Try to detect where powerline is installed
POWERLINE_SITE=$(python3 -m site --user-site)/powerline/bindings/bash/powerline.sh
if [[ -f "$POWERLINE_SITE" ]]; then
    if command -v powerline-daemon >/dev/null 2>&1; then
      POWERLINE_PATH=$(pip show powerline-status 2>/dev/null | grep '^Location:' | cut -d' ' -f2-)
      if [[ -n "$POWERLINE_PATH" ]]; then
              powerline-daemon -q
              POWERLINE_BASH_CONTINUATION=1
              POWERLINE_BASH_SELECT=1
              source /usr/share/powerline/bindings/bash/powerline.sh
              # echo "Restart the terminal to see powerline!"
              if is_powerline_enabled; then
                  echo "Powerline is enabled"
              else
                  echo "Restart the terminal to see powerline!"
              fi
      fi
    else
      echo "Powerline not found. Skipping powerline setup."
    fi
else
    echo "powerline-status not found. Skipping powerline setup."
fi


