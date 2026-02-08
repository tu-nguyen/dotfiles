#!/usr/bin/env bash
# ===================================================================== #
# DIRENV SETUP
# ===================================================================== #
# ------------------------------------------
# Prep
# ------------------------------------------
DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
[[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"

# Copy dircolors for ls --color
cpp "$DOTFILES_REPO_DIR/setup/bash/dircolors/dircolors" "$DOTFILES_CONFIG_DIR/.dircolors"
