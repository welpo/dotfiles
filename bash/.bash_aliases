alias aliases='vim "${HOME}"/.bash_aliases'
alias bnew='brew update && brew upgrade && brew cleanup'
alias c.='code .'
alias c='clear'
alias cdc='cd && clear'
alias cp='rsync -avz'
alias cwd="pwd && pwd | pbcopy && echo 'Copied!'"
alias mkdir='mkdir -pv'
alias mm='micromamba'
alias o='open .'
alias op='oxipng -o max'
alias pip='pip3'
alias sanicbackup='sudo sysctl debug.lowpri_throttle_enabled=0'
alias ta="tmux attach"
alias v='vim'
alias vd='vimdiff'
alias xx="exit"
alias zs="zola serve"

# SSH
alias luna='ssh luna'
alias pablo='ssh pablo'
alias rpi='ssh rpi'

# cd into stuff
alias a='cd "$HOME/Library/Application Support/Anki2/osc/collection.media"'
alias b='cd $HOME/bin'
alias bun='cd ~/git/bunbu/'
alias d='cd "$HOME"/Downloads/'
alias dis="cd $HOME/git/distrokid"
alias doc='cd "$HOME"/Documents/'
alias dot='cd ~/git/doteki/'
alias dt='cd "$HOME/Desktop"'
alias dtop='cd "$HOME/Desktop"'
alias g='cd ${HOME}/git'
alias mu='cd "/Volumes/12TB/Music"'
alias osc='cd ~/git/osc.garden/'
alias sea='cd "$HOME/Seafile/"'
alias sumi='cd ~/git/git-sumi/'
alias tabi='cd ~/git/tabi/'

# Useful info
alias myip="curl ipecho.net/plain;echo | pbcopy"
alias q='df -h /Volumes/*'
alias ss="du -hs -- * | sort -h"

# cd
alias .......='cd ../../../../../..'
alias ......='cd ../../../../..'
alias .....='cd ../../../..'
alias ....='cd ../../..'
alias ...='cd ../..'
alias ..='cd ..'
alias cd-='cd -'
alias cd..='cd ..'
