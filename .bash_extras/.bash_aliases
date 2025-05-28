# ~/.bash_extras/.bash_aliases

# internet check
alias p4="ping 4.2.2.2 -c 4"

## aliases cause you're a lazy piece of shit smfh
## ls
alias ls='ls --color=auto'
alias ll="ls -alh"
alias la="ls -A"
#alias l="ls -CF1h"
alias l="ls"
alias lsd="ls -a1F | grep /$"
alias lt="la -lt"

## cd
#alias c="cd" # was too annoying
alias ..="cd .."
alias ~="cd ~"
alias ...="cd ../.."
alias ....="cd ../../.."

## installer
alias p="sudo pacman"
alias y="yaourt"

## utils
alias diskspace="du -S | sort -n -r | more"
alias folder="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"

## other
alias c='clear'
alias h='history'
alias x='exit'
alias v='vim'
# timeout not on macos, so gtimeout
if [[ "$(uname)" == "Darwin" ]]; then
  alias timeout=gtimeout
fi
alias mv='timeout 8 mv -iv'
alias rm='timeout 3 rm -Iv --one-file-system'
alias so0="cmatrix"
alias myip="curl icanhazip.com"
function r() {
  ln -sv $(pwd) ~/.bash_extras
  ln -sv $(pwd)/../.bashrc ~/.bashrc
source ~/.bashrc
  source ~/.bashrc
}












