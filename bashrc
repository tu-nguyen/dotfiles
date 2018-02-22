
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# internet check
alias p4='ping 4.2.2.2 -c 4'

## aliases cause you're a lazy piece of shit smfh
### ls
alias ll='ls -alh'
alias la='ls -A'
#alias l='ls -CF1h'
alias l='ls'
alias lsd="ls -a1F | grep /$"
alias lt='la -lt'

### cd
#alias c='cd' # was too annoying 
alias ..='cd ..'
#alias /='cd /' # invalid
alias ~='cd ~'
alias ...='cd ../..'
alias ....='cd ../../..'

### installer
alias p="sudo pacman"
alias y="yaourt"

###
alias diskspace="du -S | sort -n -r | more"
alias folder="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"

### 
alias qs="ssh valcrune@users.cs.umb.edu"
alias op="startx"
alias c='clear'
alias h='history'
alias x='exit'
alias v='vim'
alias mv='timeout 8 mv -iv'
alias rm='timeout 3 rm -Iv --one-file-system'

###
alias so0="cmatrix"


## functions

# extract
extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1    ;;
           *.tar.gz)    tar xvzf $1    ;;
           *.bz2)       bunzip2 $1     ;;
           *.rar)       unrar x $1       ;;
           *.gz)        gunzip $1      ;;
           *.tar)       tar xvf $1     ;;
           *.tbz2)      tar xvjf $1    ;;
           *.tgz)       tar xvzf $1    ;;
           *.zip)       unzip $1       ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
 }

#Display a PDF of a given man page
function pdfman() {
        man -t $@ | pstopdf -i -o /tmp/$1.pdf && open /tmp/$1.pdf
}

export VISUAL="vim"
export JAVA_HOME="/usr/"
export ANDROID_HOME=/opt/android-sdk

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$'

