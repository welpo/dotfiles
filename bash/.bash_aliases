alias aliases='vim "${HOME}"/.bash_aliases'
alias bnew='brew update && brew upgrade && brew cleanup'
alias c.='code .'
alias c='clear'
alias cdc='cd && clear'
alias cp='rsync -avz'
alias tg='topgrade'
alias cwd="pwd && pwd | pbcopy && echo 'Copied!'"
alias dp='vim -c "set noswapfile" -c "vnew" -c "windo setlocal nobuflisted buftype=nofile noswapfile" -c "set diffopt=filler,iwhite" -c "windo diffthis" -c "wincmd h" -c "autocmd TextChanged,TextChangedI * diffupdate"'
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
alias nem='cd ~/git/nemui/'
alias d='cd "$HOME"/Downloads/'
alias dis='cd $HOME/git/distrokid'
alias doc='cd "$HOME"/Documents/'
alias dot='cd ~/git/doteki/'
alias dt='cd "$HOME/Desktop"'
alias dtop='cd "$HOME/Desktop"'
alias g='cd ${HOME}/git'
alias mu='cd "/Volumes/12TB_C/Music"'
alias nem='cd ~/git/nemui/'
alias osc='cd ~/git/osc.garden/'
alias ramu='cd $HOME/git/ramu'
alias sea='cd "$HOME/Seafile/"'
alias shu='cd $HOME/git/shuku'
alias subs='cd $HOME/Documents/Subtitles'
alias sumi='cd ~/git/git-sumi/'
alias tabi='cd ~/git/tabi/'
alias zutsu='cd $HOME/git/zutsu'

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
