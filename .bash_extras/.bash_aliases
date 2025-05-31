# ~/.bash_extras/.bash_aliases

## aliases cause you're a lazy piece of shit smfh
# if user is not root, pass all commands via sudo #
if [ $UID -ne 0 ]; then
    alias reboot='sudo reboot'
    alias update='sudo apt-get upgrade'
fi

# timeout not on macos, so gtimeout
if [[ "$(uname)" == "Darwin" ]]; then
  alias timeout=gtimeout
fi

# set some defaults
alias c='clear'
alias cls='clear && ls'
alias clss='clear && lsa'
alias h='history'
alias j='jobs -l'
alias x='exit'
alias v='vim'
alias df='df -H'
alias du='du -ch'
alias top='htop'
alias top10='ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 11'
alias uptime='uptime -p'
alias cp='cp -i'
alias mv='timeout 8 mv -iv'
alias rm='timeout 3 rm -Iv --one-file-system --preserve-root'
alias ln='ln -i'
alias mkdir='mkdir -pv'
alias mkcd='mkdir -p $1 && cd $1'
# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
# root
alias root='sudo -i'
alias su='sudo -i'

## ls
alias ls='ls --color=auto'
alias ll="ls -alh"
alias la="ls -A"
alias l="ls"
alias lsa="ls -la"
alias lsd="ls -a1F | grep /$"
alias lt="la -lt"
alias l.='ls -d .* --color=auto'

## cd
#alias c="cd" # was too annoying
alias ~="cd ~"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

# git
alias ga='git a'
alias gb='git b'
alias gbr='git br'
alias gc='git cam'
alias gcl='git cl'
alias gl="git l"
alias gll="git ll"
alias grr="git rr"
alias gs='git st'


## grep
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

## vim
alias vi=vim
alias svi='sudo vi'
alias vis='vim "+set si"'
alias edit='vim'

## installer
alias p="sudo pacman"
alias y="yaourt"

## utils
# internet check
alias myip="curl icanhazip.com"
alias ping='ping -c 5'
alias p4="ping 4.2.2.2 -c 4"
alias fastping='ping -c 100 -s.2'
alias ports='netstat -tulanp'
## shortcut  for iptables and pass it via sudo#
alias ipt='sudo /sbin/iptables'
# display all rules #
alias iptlist='sudo /sbin/iptables -L -n -v --line-numbers'
alias iptlistin='sudo /sbin/iptables -L INPUT -n -v --line-numbers'
alias iptlistout='sudo /sbin/iptables -L OUTPUT -n -v --line-numbers'
alias iptlistfw='sudo /sbin/iptables -L FORWARD -n -v --line-numbers'
alias firewall=iptlist
# get web server headers #
alias header='curl -I'
# find out if remote server supports gzip / mod_deflate or not #
alias headerc='curl -I --compress'
## All of our servers eth1 is connected to the Internets via vlan / router etc  ##
alias dnstop='dnstop -l 5  eth1'
alias vnstat='vnstat -i eth1'
alias iftop='iftop -i eth1'
alias tcpdump='tcpdump -i eth1'
alias ethtool='ethtool eth1'
# work on wlan0 by default #
# Only useful for laptop as all servers are without wireless interface
alias iwconfig='iwconfig wlan0'

if [[ "$(uname)" == "Darwin" ]]; then
    alias diskspace="du | sort -n -r | more"
  else
    alias diskspace="du -S | sort -n -r | more"
fi
alias dmesg10='dmesg | tail -n 10'
alias folder="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"
alias path='echo -e ${PATH//:/\\n}'
alias wc='wc -l -w -c'
alias nowtime='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'

## other
alias so0="cmatrix"

# install  colordiff package
# alias diff='colordiff'