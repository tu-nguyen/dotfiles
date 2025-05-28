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

##
alias diskspace="du -S | sort -n -r | more"
alias folder="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"

##
alias so0="cmatrix"
alias myip="curl icanhazip.com"
alias r="source ~/.bashrc"












