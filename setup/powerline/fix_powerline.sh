#!/bin/bash

# --- Load Configuration ---
DOTFILES_CONFIG_FILE="$HOME/.bash_extras/.dotfile_config"
if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    source "$DOTFILES_CONFIG_FILE"
else
    echo Error "Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi

POWERLINE_PATH=$(pip show powerline-status 2>/dev/null | grep '^Location:' | cut -d' ' -f2-)
file_path="$POWERLINE_PATH/powerline/bindings/config.py"

incorrect_line="TMUX_VAR_RE = re.compile('\$(_POWERLINE_\w+)')"
correct_line="TMUX_VAR_RE = re.compile(r'\$(_POWERLINE_\w+)')"

if grep -q "$incorrect_line" "$file_path"; then
    echo "Found incorrect line in $file_path. Correcting it..."
    sudo sed -i "s#${incorrect_line}#${correct_line}#g" "$file_path"
    echo "Correction complete."
else
    echo "The line is already correct or not found. No changes made."
fi
