export EDITOR=nano

export LESS='-R'

export CLICOLOR=1
alias la='ls -lAhG'
alias lrt='ls -lrt'
alias ll='ls -lG'
alias lah='ls -lAhG'
alias lg='ls -lAG |grep '

alias json='python3 -c "import sys, json; print(json.dumps(json.load(sys.stdin), sort_keys=True, indent=2))"'

alias ml='mise list -c'

function hex2rgb() {
  hex=$1
  printf "%d %d %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
}

function rgb2hex() {
  printf "%02x%02x%02x\n" $1 $2 $3
}

alias superclean='find . -name target -exec rm -r {} \;'

# GIT helpers
alias gatus='git status -sb'
alias gadd='git add'
alias gommit='git commit'
alias giff='git diff'
alias giffw='git diff --word-diff=color'
alias giffc='git diff --cached'
alias gpoh='git push origin HEAD'
alias gitff='git merge --ff-only'
alias gitffom='git merge --ff-only origin/main'

function gog()
{
  git log --pretty=format:'%Cblue%h%Creset%x09%Cgreen(%ad)%x09%C(bold blue)<%an>%Creset%x09%C(yellow)%d%Creset %s' --date=iso --abbr\
ev-commit $*
}

function granch()
{
  for k in `git branch $*|grep -v "HEAD \->"|grep -v "(no branch)"|sed s/^..//`;do echo -e `git log -1 --pretty=format:"%Cgreen%ci %C(bold blue)%cr%Creset" "$k"`\\t"$k";done | sort | column -s $'\t' -t
}

function cu {
  if [ $# -eq 0 ]; then
	cd ../
  else
	cd `yes "../" |head -n$1 | perl -ne 'chomp and print'`
  fi
}
