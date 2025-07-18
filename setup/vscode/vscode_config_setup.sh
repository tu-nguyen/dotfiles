#!/bin/bash

if [[ "$(uname)" == "Darwin" ]]; then
    t "Copying settings.json for VSCode"
    cp $DOTFILE_REPO_DIR/setup/vscode/vscode-settings.json  $HOME/Library/Application\ Support/Code/User/settings.json
else
    t "TBD"
fi