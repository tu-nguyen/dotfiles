#!/bin/bash

is_powerline_enabled() {
    pgrep -f powerline-daemon >/dev/null && return 0
    type _powerline_prompt 2>/dev/null | grep -q "function" && return 0
    echo "$PS1" | grep -q "powerline" && return 0
    return 1
}

enable_powerline() {
    POWERLINE_PATH=$(pip show powerline-status 2>/dev/null | grep '^Location:' | cut -d' ' -f2-)
    if [[ -n "$POWERLINE_PATH" ]]; then
        powerline-daemon -q
        POWERLINE_BASH_CONTINUATION=1
        POWERLINE_BASH_SELECT=1
        source "$POWERLINE_PATH/powerline/bindings/bash/powerline.sh"
        if is_powerline_enabled; then
            t SUCCESS "Powerline is enabled"
        else
            t INFO "Restart the terminal to see powerline!"
        fi
    fi
}

# Try to detect where powerline is installed
if [[ "$(uname)" == "Darwin" ]]; then
    export PATH="/opt/homebrew/opt/python@3.12/libexec/bin:$PATH" 
    export PATH="$HOME/Library/Python/3.12/bin:$PATH"
    if pip show powerline-status &>/dev/null; then
        enable_powerline
    else
        t WARNING "Powerline not found. Skipping powerline setup.."
    fi
else
    if [ -f "$(python3 -m site --user-site)/powerline/bindings/bash/powerline.sh" ]; then
        if command -v powerline-daemon >/dev/null 2>&1; then
            enable_powerline
        else
            t WARNING"Powerline not found. Skipping powerline setup.."
        fi
    else
        t WARNING "powerline-status not found. Skipping powerline setup.."
    fi
fi
