#!/usr/bin/env bash

# identity
# checks if user is set; if not, it uses defaults
# [[ -z "$(git config --global user.name)" ]] && git config --global user.name "Tu Nguyen"
# [[ -z "$(git config --global user.email)" ]] && git config --global user.email "tu.t.nguyen93@gmail.com"

# ------------------------------------------
# Core Settings
# ------------------------------------------
git config --global pull.rebase true                    # keeps history linear on pull
git config --global rebase.autoStash true               # enable autostash by default
git config --global core.editor "vim"                   # use Vim for commit messages
git config --global init.defaultBranch main             # standardize default branch name
git config --global rebase.autoStash true               # reuse recorded resolution

# ------------------------------------------
# Aliases
# ------------------------------------------
# basic aliases
git config --global alias.s "status -s"                 # short status
git config --global alias.st status                     # standard status
git config --global alias.a "add"                       # add file
git config --global alias.ap "add -p"                   # interactive patch add TODO: relearn
git config --global alias.cl "show --stat"              # show changes in last commit

# checkout & branching aliases
git config --global alias.co "checkout"
git config --global alias.cob "checkout -b"
git config --global alias.coB "checkout -B"
git config --global alias.br "branch -vv"               # branch list with remote tracking info

# list branches sorted by most recent activity
git config --global alias.b "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'" --replace-all

# commits & diffs aliases
git config --global alias.c "commit --verbose"
git config --global alias.ca "commit -a --verbose"
git config --global alias.cm "commit -m"
git config --global alias.cam "commit -a -m"
git config --global alias.m "commit --amend --verbose"   # amend the last commit
git config --global alias.d "diff"
git config --global alias.ds "diff --stat"               # summary of changes
git config --global alias.dc "diff --cached"             # diff of staged changes

# reset & cleanup aliases
git config --global alias.undo "reset --soft HEAD~1"     # un-commit but keep changes
git config --global alias.rr "reset --hard"              # wipe all local changes
git config --global alias.p "pull --rebase --autostash"  # pull and re-apply local work
git config --global alias.conflicts "diff --name-only --diff-filter=U"  # list files with conflicts

# logging & visualization aliases
git config --global alias.l "log -1"                     # show only the very last commit
git config --global alias.g "log --oneline --graph --decorate --all --color"
git config --global alias.graph "log --oneline --graph --decorate --all --color"

# The ultimate "pretty log" graph
git config --global alias.ll "log --graph --pretty=format:'%C(#ffd1dc)%h%Creset -%C(#689d6a)%d%Creset %s %C(#928374)(%cr) %C(#689d6a)[%an]%Creset' --abbrev-commit"

# list all your aliases
git config --global alias.la "!git config -l | grep alias | cut -c 7-"

# ------------------------------------------
# Merge
# ------------------------------------------
git config --global merge.conflictstyle  diff3
git config --global merge.tool vscode
# git config --global mergetool.kdiff3.path "/usr/local/bin/kdiff3"

# ------------------------------------------
# UI & Colors
# ------------------------------------------
# ui color
git config --global color.ui true

# branch colors
git config --global color.branch.current "#ffc0cb bold"  # pink (current)
git config --global color.branch.local "#689d6a"         # aqua (local)
git config --global color.branch.remote "#e75480"        # dark pink (remote)

# diff colors
git config --global color.diff.meta "#ffd1dc"            # diff header info
git config --global color.diff.frag "#ff10f0"            # line numbers/hunks

# ------------------------------------------
# Other
# ------------------------------------------
# push only the current branch to its matching remote (avoids accidental "push all")
git config --global push.default current

# automatically setup remote tracking when you push a new branch
# this means you can just type 'git push' instead of 'git push -u origin branch-name'
git config --global push.autoSetupRemote true

# prune remote-tracking branches that no longer exist on the remote when fetching
git config --global fetch.prune true

t OK "Git configuration updated!"
