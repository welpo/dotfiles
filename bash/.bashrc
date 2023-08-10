# Function to source files if they exist
source_if_exists() {
    [ -f "$1" ] && source "$1"
}

# Setting PATH.
PATH="$HOME/bin:$PATH"
export PATH

# Interactive shell check.
if [[ $- == *i* ]]; then
    # Disable flow control to use Ctrl+S to search forward in history.
    [ -t 0 ] && stty -ixon
    
    # Check if starship is installed. If yes, use it, else set up the prompt based on UID.
    if command -v starship > /dev/null 2>&1; then
        eval "$(starship init bash)"
    else
        if [ $(id -u) -eq 0 ]; then
            # Display the root username and hostname in red.
            PS1='\[\e]0;\w\a\]\n\[\e[31m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '
        else
            # Display the username and hostname in green.
            PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '
        fi
    fi

    # Source files.
    source_if_exists ~/bin/sensible.bash
    source_if_exists ~/.bash_aliases
    source_if_exists "$HOME/.cargo/env"
fi

export LC_ALL=en_GB.UTF-8
export LANG=en_GB.UTF-8
