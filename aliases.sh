#!/usr/bin/env bash

# -----------------------------------------------------------------------------

if ! command -v command_exists >/dev/null; then
    command_exists_initialized_here=1

    # Returns `0` if the given command exists.
    function command_exists() {
        command -v "${1:?missing command}" >/dev/null
    }
fi

# -----------------------------------------------------------------------------

alias grep='grep --color=auto'

if command_exists fvr; then
    alias ls='fvr list'
    alias lsa='fvr list --all --resolve-symlinks --mode=show --size=base-2 --modified=simple --user --group'
    alias tree='fvr tree'
    alias treea='fvr tree --all --resolve-symlinks'
else
    alias lsa='ls -lAh --group-directories-first'
fi

alias cl='clear'
alias cls='cl; ls'
alias clsa='cl; lsa'

if command_exists git; then
    alias gcl='cl; git status'
    alias gcls='cls; echo; git status'
    alias gclsa='clsa; echo; git status'
fi

if command_exists tree; then
    alias ctree='cl; tree'
    alias ctreea='cl; treea'

    if command_exists git; then
        alias gctree='ctree; echo; git status'
        alias gctreea='ctreea; echo; git status'
    fi
fi

if command_exists bat; then
    alias cat='bat'
    alias catdiff='git diff --name-only --relative --diff-filter=d -z | xargs -0 bat --diff'
fi

# -----------------------------------------------------------------------------

if [ "$command_exists_initialized_here" == 1 ]; then
    unset command_exists
fi
