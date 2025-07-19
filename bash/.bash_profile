# Use vi commands.
set -o vi

# Set default editor.
export EDITOR=vim

# Function to source files if they exist.
source_if_exists() {
    [ -f "$1" ] && source "$1"
}

# Source stuff.
source_if_exists /usr/local/etc/bash_completion
source_if_exists /usr/local/etc/bash_completion.d
source_if_exists "$HOME/.bashrc"
source_if_exists "$HOME/.cargo/env"
source_if_exists "$HOME/.secrets"

# Uncomment below if you wish to start tmux automatically.
# if [ -z "$TMUX" ]; then
#     tmux attach || tmux
# fi

# Add Homebrew's bin directory to PATH.
export PATH="/opt/homebrew/bin:$PATH"

# Homebrew setup.
if command -v brew &>/dev/null; then
    eval "$(brew shellenv)"
fi

# GPG setup.
if command -v gpg &>/dev/null; then
    export GPG_TTY=$(tty)
    gpgconf --launch gpg-agent &>/dev/null
fi
