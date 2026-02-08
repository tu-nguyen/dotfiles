#!/usr/bin/env bash
# ===================================================================== #
# DIRENV SETUP
# ===================================================================== #
# ------------------------------------------
# Prep
# ------------------------------------------
DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
[[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"

TEMP_CONFIG_DIR=$(mktemp -d)

# Copy starship config
STARSHIP_SRC_DIR="$DOTFILES_REPO_DIR/setup/bash/starship"
STARSHIP_DEST_DIR="$HOME/.config"

# Loop through all starship .toml files in the source directory
for template in "$STARSHIP_SRC_DIR"/starship*.toml; do
    # Get just the filename (e.g., starship.gruvbox.toml)
    filename=$(basename "$template")
    temp_output="$TEMP_CONFIG_DIR/$filename"
    dest_output="$STARSHIP_DEST_DIR/$filename"

    if [[ "$OS_TYPE" == "macos" ]]; then
        _convert_hex_to_ansi "$template" "$temp_output"
    else
        # Using -q for quiet preprocessing
        cpp -q "$template" "$temp_output"
    fi
    cpp "$temp_output" "$dest_output"
done
t OK "Transfer of starship tomls complete."

rm -fr "$TEMP_CONFIG_DIR"

if [[ ! -f "$STARSHIP_DEST_DIR/starship.toml" ]]; then
    t "starship.toml not found. Initializing with default theme.."
    cpp "$STARSHIP_DEST_DIR/starship.tu.toml" "$STARSHIP_DEST_DIR/starship.toml"
fi
