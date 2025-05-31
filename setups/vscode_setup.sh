#!/bin/bash

if [[ "$(uname)" == "Darwin" ]]; then
    t "Copying settings.json for VSCode"
    cp $1/setups/files/vscode-settings.json  $HOME/Library/Application\ Support/Code/User/settings.json
else
    t "TBD"
fi