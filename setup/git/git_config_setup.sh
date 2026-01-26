#!/usr/bin/env bash

# # --- Start Load Configuration ---
# if [ -z "$DOTFILES_CONFIG_DIR" ]; then
#     DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
# fi

# if [ -z "$DOTFILES_CONFIG_FILE" ]; then
#     DOTFILES_CONFIG_FILE="$DOTFILES_CONFIG_DIR/.dotfile_config.env"
# fi

# if [ -f "$DOTFILES_CONFIG_FILE" ]; then
#     source "$DOTFILES_CONFIG_FILE"
# else
#     echo "[Error] Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
#     exit 1
# fi

DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
[[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"
# # --- End Load Configuration ---

# --- Identity ---
# Checks if user is set; if not, it uses defaults
# [[ -z "$(git config --global user.name)" ]] && git config --global user.name "Tu Nguyen"
# [[ -z "$(git config --global user.email)" ]] && git config --global user.email "tu.t.nguyen93@gmail.com"

# --- Core Settings ---
git config --global pull.rebase true                    # Keeps history linear on pull
git config --global core.editor "vim"                   # Use Vim for commit messages
git config --global init.defaultBranch main             # Standardize default branch name

# git config --global merge.tool kdiff3
# git config --global mergetool.kdiff3.path "/usr/local/bin/kdiff3"

# Push only the current branch to its matching remote (avoids accidental "push all")
git config --global push.default current

# Automatically setup remote tracking when you push a new branch
# This means you can just type 'git push' instead of 'git push -u origin branch-name'
git config --global push.autoSetupRemote true

# Prune remote-tracking branches that no longer exist on the remote when fetching
git config --global fetch.prune true

# --- Basic Aliases ---
git config --global alias.s "status -s"                 # Short status
git config --global alias.st status                     # Standard status
git config --global alias.a "add"                       # Add file
git config --global alias.ap "add -p"                   # Interactive patch add TODO: relearn
git config --global alias.cl "show --stat"              # Show changes in last commit

# --- Checkout & Branching ---
git config --global alias.co "checkout"
git config --global alias.cob "checkout -b"
git config --global alias.coB "checkout -B"
git config --global alias.br "branch -vv"  # Branch list with remote tracking info
# List branches sorted by most recent activity
git config --global alias.b "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'" --replace-all

# --- Commits & Diffs ---
git config --global alias.c "commit --verbose"
git config --global alias.ca "commit -a --verbose"
git config --global alias.cm "commit -m"
git config --global alias.cam "commit -a -m"
git config --global alias.m "commit --amend --verbose"   # Amend the last commit
git config --global alias.d "diff"
git config --global alias.ds "diff --stat"               # Summary of changes
git config --global alias.dc "diff --cached"             # Diff of staged changes

# --- Reset & Cleanup ---
git config --global alias.undo "reset --soft HEAD~1"     # Un-commit but keep changes
git config --global alias.rr "reset --hard"              # Wipe all local changes
git config --global alias.p "pull --rebase --autostash"  # Pull and re-apply local work
git config --global alias.conflicts "diff --name-only --diff-filter=U" # List files with conflicts

# --- Logging & Visualization ---
git config --global alias.l "log -1"                     # Show only the very last commit
git config --global alias.g "log --oneline --graph --decorate --all --color"
git config --global alias.graph "log --oneline --graph --decorate --all --color"

# The ultimate "Pretty Log" graph
git config --global alias.ll "log --graph --pretty=format:'%C(#ffd1dc)%h%Creset -%C(#689d6a)%d%Creset %s %C(#928374)(%cr) %C(#689d6a)[%an]%Creset' --abbrev-commit"
# List all your aliases
git config --global alias.la "!git config -l | grep alias | cut -c 7-"

# --- UI & Colors ---
git config --global color.ui true
# Branch Colors
git config --global color.branch.current "#ffc0cb bold"  # Pink (Current)
git config --global color.branch.local "#689d6a"         # Aqua (Local)
git config --global color.branch.remote "#e75480"        # Dark Pink (Remote)
# Diff Colors
git config --global color.diff.meta "#ffd1dc"            # Diff header info
git config --global color.diff.frag "#ff10f0"            # Line numbers/hunks

t OK "Git configuration updated!"
