#!/usr/bin/env bash
# ===================================================================== #
# DIRENV SETUP
# ===================================================================== #
# ------------------------------------------
# Prep
# ------------------------------------------
DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
[[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"
TOML_FILE="$HOME/.config/direnv/direnv.toml"
PREFIX="DIRENV_PATH_"
TEMP_CONFIG_DIR=$(mktemp -d)

# ------------------------------------------
# direnv.toml
# ------------------------------------------
DIRENV_TEMPLATE_FILE="$DOTFILES_REPO_DIR/setup/bash/direnv/direnv.toml"
DIRENV_DEST_FILE="$HOME/.config/direnv/direnv.toml"
TEMP_DIRENV_TOML="$TEMP_CONFIG_DIR/direnv.toml"
mkdir -p "$(dirname "$DIRENV_DEST_FILE")"
sed "s|/home/username|$HOME|g" "$DIRENV_TEMPLATE_FILE" > "$TEMP_DIRENV_TOML"
cpp "$TEMP_DIRENV_TOML" "$DIRENV_DEST_FILE"

# ------------------------------------------
# direnvrc
# ------------------------------------------
cpp "$DOTFILES_REPO_DIR/setup/bash/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"

# ------------------------------------------
# Update direnv.toml's whitelist
# ------------------------------------------
# Extract paths using Perl-regex to handle squished variables
# This looks for the prefix, grabs everything after the '=',
# and stops right before the next prefix or the end of the line.
mapfile -t PATHS < <(grep -oP "${PREFIX}[^=]+=\K.*?(?=${PREFIX}|$)" "$DOTFILES_CONFIG_FILE")

if [[ ${#PATHS[@]} -eq 0 ]]; then
    t INFO "No paths found with prefix $PREFIX"
    exit 0
fi

# Ensure config directory exists
mkdir -p "$(dirname "$TOML_FILE")"
[[ ! -f "$TOML_FILE" ]] && touch "$TOML_FILE"

# Process each path
for raw_path in "${PATHS[@]}"; do
    # Clean whitespace and expand ~ to full home path
    clean_path="${raw_path//\"/}" # remove quotes if any
    clean_path="${clean_path//\'/}" # remove single quotes
    eval clean_path="$clean_path"  # expand ~

    if [[ -n "$clean_path" ]]; then
        # Create directory and empty .envrc
        mkdir -p "$clean_path"
        touch "$clean_path/.envrc"
        # TODO: figure out for sure if I need to add 'source_up'
        t OK "Prepared: $clean_path"
    fi
done

# Update direnv.toml whitelist
# We'll use a temp file to rebuild the [whitelist] section safely
{
    # Keep everything EXCEPT the [whitelist] and its prefix line
    # (We'll re-add it at the end to avoid duplication)
    if [[ -s "$TOML_FILE" ]]; then
        sed '/\[whitelist\]/d; /prefix = \[/d' "$TOML_FILE"
    fi

    echo -e "\n[whitelist]"

    # Generate the quoted path list for the TOML
    formatted_paths=""
    for p in "${PATHS[@]}"; do
        eval p="$p" # expand ~
        formatted_paths+="\"$p\", "
    done
    # Strip trailing comma and space
    formatted_paths="${formatted_paths%, }"

    echo "prefix = [$formatted_paths]"
} > "${TOML_FILE}.tmp" && mv "${TOML_FILE}.tmp" "$TOML_FILE"

rm -fr "$TEMP_CONFIG_DIR"

t OK "Whitelist updated in $TOML_FILE"

t OK "direnv configuration updated!"
