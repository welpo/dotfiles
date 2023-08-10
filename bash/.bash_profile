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

# Uncomment below if you wish to start tmux automatically.
# if [ -z "$TMUX" ]; then
#     tmux attach || tmux
# fi

# Homebrew setup.
if command -v brew &>/dev/null; then
    eval "$(brew shellenv)"
fi

# GPG setup.
if command -v gpg &>/dev/null; then
    export GPG_TTY=$(tty)
    gpgconf --launch gpg-agent &>/dev/null
fi

# Mamba setup.
export MAMBA_EXE="/opt/homebrew/opt/micromamba/bin/micromamba";
export MAMBA_ROOT_PREFIX="/Users/osc/micromamba";
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [[ $? -eq 0 ]]; then
    eval "$__mamba_setup"
else
    source_if_exists "/Users/osc/micromamba/etc/profile.d/micromamba.sh"
    # Only add to PATH if source fails
    [[ $? -ne 0 ]] && export PATH="/Users/osc/micromamba/bin:$PATH"
fi
unset __mamba_setup
