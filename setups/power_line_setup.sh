#!/bin/bash

if [[ -f "~/.config/powerline-shell/config.json" ]]; then
    t "Replacing config.json for powerline-shell"
else
    t "Copying config.json for powerline-shell"
fi

sudo cp $1/setups/files/powerline-shell-config.json  ~/.config/powerline-shell/config.json