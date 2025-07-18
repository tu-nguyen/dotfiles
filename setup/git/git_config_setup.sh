#!/bin/bash

# --- Load Configuration ---
# DOTFILES_CONFIG_FILE="$HOME/.bash_extras/.dotfile_config"
# if [ -f "$DOTFILES_CONFIG_FILE" ]; then
#     source "$DOTFILES_CONFIG_FILE"
# else
#     t Error "Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
#     exit 1
# fi

# git config --global user.name "Tu Nguyen"
# git config --global user.email "tu.t.nguyen93@gmail.com"

git config --global pull.rebase true 
git config --global core.editor "vim"

# git config --global merge.tool kdiff3
# git config --global mergetool.kdiff3.path "/usr/local/bin/kdiff3"

git config --global alias.s "status -s"
git config --global alias.st status
git config --global alias.co "checkout"
git config --global alias.cob "checkout -b"
git config --global alias.coB "checkout -B"

git config --global alias.b "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'" --replace-all
git config --global alias.br "branch -vv"
git config --global alias.a "add"
git config --global alias.ap "add -p"
git config --global alias.cl "show --stat"

git config --global alias.d "diff"
git config --global alias.ds "diff --stat"
git config --global alias.dc "diff --cached"
git config --global alias.rr "reset --hard"

git config --global alias.c "commit --verbose"
git config --global alias.ca "commit -a --verbose"
git config --global alias.cm "commit -m"
git config --global alias.cam "commit -a -m"
git config --global alias.m "commit --amend --verbose"

git config --global alias.l "log -1"
git config --global alias.ll 'log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short'
git config --global alias.la "!git config -l | grep alias | cut -c 7-"