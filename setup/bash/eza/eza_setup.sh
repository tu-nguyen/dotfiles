#!/usr/bin/env bash
# ===================================================================== #
# EZA SETUP
# ===================================================================== #
# ------------------------------------------
# Prep
# ------------------------------------------
DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
[[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"

mkdir -p "$HOME/.config/eza"
cpp "$DOTFILES_REPO_DIR/setup/bash/eza/theme.yml" "$HOME/.config/eza/theme.yml"

t OK "eza configuration updated!"
