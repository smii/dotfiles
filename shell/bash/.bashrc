# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# =========================================
# Standalone shell configuration (no Omarchy)
# =========================================

# Path
export PATH="$HOME/.local/bin:$PATH"

# Default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
alias dots='cd ~/.dotfiles'

# Prompt (simple git-aware prompt)
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '

# History
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Bash completion
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi
