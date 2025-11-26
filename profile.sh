#!/usr/bin/env bash

# -----------------------------------------------------------------------------

# Returns `0` if the given command exists.
function command_exists() {
    command -v "${1:?missing command}" >/dev/null
}

# Calls `source` on the given path if it exists.
function source_if_present() {
    local path="${1:?missing path}"

    path="$(realpath "$path")"

    # shellcheck disable=SC1090
    [ -f "$path" ] && source "$path"
}

# Prepends the given directory to the `PATH` environment variable if it exists.
function prepend_path_if_present() {
    local directory="${1:?missing directory}"

    directory="$(realpath "$directory")"

    [ -d "$directory" ] && export PATH="$directory:$PATH"
}

# Prints a color escape sequence.
function color_escape() {
    case "${1:?missing color name}" in
    reset) tput sgr0 ;;
    black) tput setaf 8 ;;
    red) tput setaf 9 ;;
    green) tput setaf 10 ;;
    yellow) tput setaf 11 ;;
    blue) tput setaf 12 ;;
    magenta) tput setaf 13 ;;
    cyan) tput setaf 14 ;;
    white) tput setaf 15 ;;
    *) return 1 ;;
    esac
}

# -----------------------------------------------------------------------------

# Set up local binary directory.
prepend_path_if_present "$HOME/.local/bin"

# Add hardware-accelerated rendering when running under WSL.
if command_exists wslinfo; then
    export GALLIUM_DRIVER=d3d12
    export LIBVA_DRIVER_NAME=d3d12
fi

# Use the terminal for GPG password entry.
GPG_TTY="$(tty)"
export GPG_TTY

# Set up Cargo.
source_if_present "$HOME/.cargo/env"
# Set up Bob.
source_if_present "$HOME/.local/share/bob/env/env.sh"
# Set up FNM.
export FNM_PATH="$HOME/.local/share/fnm"
prepend_path_if_present "$FNM_PATH"
command_exists fnm && eval "$(fnm env --use-on-cd --shell bash)"

# Apply aliases.
source_if_present "$(dirname "${BASH_SOURCE[0]}")/aliases.sh"

# Enable bash completions.
source_if_present "/usr/share/bash-completion/bash_completion"

# Set Neovim to the default editor.
if command_exists nvim; then
    EDITOR="$(which nvim)"
    export EDITOR
    export VISUAL="$EDITOR"
    export SYSTEMD_EDITOR="$EDITOR"
fi

# Use Bat as the default `man` pager.
if command_exists bat; then
    export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"
fi

PS1="\[$(color_escape white)\][$(
)\[$(color_escape green)\]\u$(
)\[$(color_escape white)\]@$(
)\[$(color_escape cyan)\]\h $(
)\[$(color_escape blue)\]\w$(
)\[$(color_escape white)\]]\\\$$(
)\[$(color_escape reset)\] "

# -----------------------------------------------------------------------------

unset command_exists source_if_present prepend_path_if_present color_escape
