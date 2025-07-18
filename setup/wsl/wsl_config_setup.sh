#!/bin/bash

if [[ -f "/etc/wsl.conf" ]]; then
    t "Replacing wsl.conf for WSL"
else
    t "Copying wsl.conf for WSL"
fi

sudo cp $DOTFILE_REPO_DIR/setup/wsl/wsl.conf  /etc/wsl.conf