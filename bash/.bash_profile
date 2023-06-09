# Use vi commands
set -o vi

if [ -f /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
fi

if [ -f /usr/local/etc/bash_completion.d ]; then
  . /usr/local/etc/bash_completion.d
fi

if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"

# if [ -z "$TMUX" ]; then
#     tmux attach || tmux
# fi

export EDITOR=vim

if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if command -v gpg &>/dev/null; then
  export GPG_TTY=$(tty)
  gpgconf --launch gpg-agent &>/dev/null
fi
