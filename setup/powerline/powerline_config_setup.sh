#!/bin/bash

if [[ -f "$HOME/.config/powerline/config.json" ]]; then
    t "Replacing config.json for powerline-shell"
else
    t "Copying config.json for powerline-shell"
fi

sudo cp $DOTFILE_PATH/setup/powerline/powerline-shell-config.json  $HOME/.config/powerline/config.json
