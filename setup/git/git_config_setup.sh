#!/bin/bash

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
# # --- End Load Configuration ---

# git config --global user.name "Tu Nguyen"
# git config --global user.email "tu.t.nguyen93@gmail.com"

git config --global pull.rebase true
git config --global core.editor "vim"

# git config --global merge.tool kdiff3
# git config --global mergetool.kdiff3.path "/usr/local/bin/kdiff3"

git config --global alias.undo "reset --soft HEAD~1"
git config --global alias.s "status -s"
git config --global alias.st status
git config --global alias.co "checkout"
git config --global alias.cob "checkout -b"
git config --global alias.coB "checkout -B"
git config --global alias.rr "reset --hard"
git config --global alias.p "pull --rebase --autostash"

git config --global alias.b "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'" --replace-all
git config --global alias.br "branch -vv"
git config --global alias.a "add"
git config --global alias.ap "add -p"
git config --global alias.cl "show --stat"

git config --global alias.d "diff"
git config --global alias.ds "diff --stat"
git config --global alias.dc "diff --cached"

git config --global alias.c "commit --verbose"
git config --global alias.ca "commit -a --verbose"
git config --global alias.cm "commit -m"
git config --global alias.cam "commit -a -m"
git config --global alias.m "commit --amend --verbose"

git config --global alias.l "log -1"
git config --global alias.ll "log --graph --pretty=format:'%C(#ffd1dc)%h%Creset -%C(#689d6a)%d%Creset %s %C(#928374)(%cr) %C(#689d6a)[%an]%Creset' --abbrev-commit"
git config --global alias.la "!git config -l | grep alias | cut -c 7-"

git config --global color.ui true
git config --global color.branch.current "#ffv0cb bold" # Pink for where you are
git config --global color.branch.local "#689d6a"        # Aqua for other branches
git config --global color.branch.remote "#e75480"       # Dark Pink for the cloud

git config --global alias.conflicts "diff --name-only --diff-filter=U"
git config --global color.diff.meta "#ffd1dc"
git config --global color.diff.frag "#ff10f0"
echo -e "Git configuration updated!"
