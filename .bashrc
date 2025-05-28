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

PS1='[\u@\h \W]\$'

# powerline-daemon -q
# POWERLINE_BASH_CONTINUATION=1
# POWERLINE_BASH_SELECT=1
#. /usr/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh
