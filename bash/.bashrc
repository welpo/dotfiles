if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

export PATH="/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin:$PATH"
export PATH="$HOME/Library/Python/3.6/bin:$PATH"
export PATH="$HOME/Library/Python/3.7/bin:$PATH"

if [ -f ~/bin/sensible.bash ]; then
    source ~/bin/sensible.bash
fi

MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"

if [ $(id -u) -eq 0 ]; then
    # Display the username and hostname in red.
    PS1='\[\e]0;\w\a\]\n\[\e[31m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '
else
    # Display the username and hostname in green.
    PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

export LC_ALL=en_GB.UTF-8
export LANG=en_GB.UTF-8

# Disable flow control to use Ctrl+S to search forward in history.
[[ $- == *i* ]] && stty -ixon
