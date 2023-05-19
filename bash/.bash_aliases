alias aliases='vim "${HOME}"/.bash_aliases'
alias bnew='brew update && brew upgrade && brew cleanup'
alias c='clear'
alias c.='code .'
alias cdc='cd && clear'
alias cp='rsync -avz'
alias cwd="pwd && pwd | pbcopy && echo 'Copied!'"
alias mkdir='mkdir -pv'
alias o='open .'
alias op='oxipng -o max'
alias pip='pip3'
alias sanicbackup='sudo sysctl debug.lowpri_throttle_enabled=0'
alias ta="tmux attach"
alias v='vim'
alias vd='vimdiff'
alias xx="exit"

# SSH
alias luna='ssh luna'
alias pablo='ssh pablo'
alias rpi='ssh rpi'
alias white='ssh whiterose'
alias whiterose='ssh whiterose'

# cd into stuff
alias b='cd $HOME/bin'
alias d='cd "$HOME"/Downloads/'
alias doc='cd "$HOME"/Documents/'
alias dt='cd "$HOME/Desktop"'
alias dtop='cd "$HOME/Desktop"'
alias mu='cd "/Volumes/12TB/Music"'
alias sea='cd "$HOME/Seafile/"'
alias wel='cd ~/Documents/Web/welpo.oooo/'
alias osc='cd ~/Documents/Web/osc.garden/'
alias tabi='cd ~/Documents/Web/tabi/'

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
