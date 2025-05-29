# git config --global user.name "Tu Nguyen"
# git config --global user.email "tu.t.nguyen93@gmail.com"

git config --global core.editor "vim"

# git config --global merge.tool kdiff3
# git config --global mergetool.kdiff3.path "/usr/local/bin/kdiff3"

git config --global alias.s "status -s"
git config --global alias.st status
git config --global alias.co "checkout"
git config --global alias.cob "checkout -b"
git config --global alias.coB "checkout -B"

git config --global alias.b "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'"
git config --global alias.br branch
git config --global alias.a "add"
git config --global alias.ap "add -p"

git config --global alias.d "diff"
git config --global alias.ds "diff --stat"
git config --global alias.dc "diff --cached"

git config --global alias.c "commit --verbose"
git config --global alias.ca "commit -a --verbose"
git config --global alias.cm "commit -m"
git config --global alias.cam "commit -a -m"
git config --global alias.m "commit --amend --verbose"



git config --global alias.l 'log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short'
git config --global alias.la "!git config -l | grep alias | cut -c 7-"

