#!/usr/bin/env bash

declare -r script_path="$(realpath "$0")"
declare -r script_name="$(basename --suffix=.sh "$script_path")"
declare -r script_directory="$(dirname "$script_path")"
declare -r script_version="0.1.0"

if ! source "$script_directory/utility.sh"; then
    echo -e '\e[90m(0.000000000s) \e[31mError:\e[0m failed to source utility script'

    exit 1
fi

function echo_usage() {
    local indent="  "

    echo -e "$(style bold)$script_name v$script_version$(style reset)"
    echo -e "${indent}$(style italic)Applies this repository's configuration to your system$(style reset)"
    echo
    echo -e "$(style bold)Usage:$(style reset) ${script_name}.sh [OPTION]..."
    echo
    echo -e "$(style bold)Options:$(style reset)"
    echo -e "${indent}${indent}${indent}--debug\t\t\tEnable debug logging for the current run"
    echo
    echo -e "${indent}-h, --help\t\t\tPrint the script's usage and exit"
    echo -e "${indent}-V, --version\t\t\tPrint the script's version and exit"
}

while [[ -n "${1:-}" && "$1" =~ ^- && ! "$1" == "--" ]]; do
    echo_debug "visiting argument '$1'"

    case "$1" in
    --debug)
        debug_set_enabled 1
        debug_flush_queue
        ;;
    -h | --help)
        echo_usage
        exit 0
        ;;
    -V | --version)
        echo "$script_name v$script_version"
        exit 0
        ;;
    *)
        echo_error "unknown argument '$1', use '--help' for a list of valid options"
        ;;
    esac

    shift 1
done

unset print_help

function directory_define() {
    local array_name="directory_array_$1"

    if is_undeclared "$array_name"; then
        declare -gA $array_name
    fi

    if [ -n "${3:-}" ]; then
        echo_debug "setting directory '$1/$2' to '$3'"
    elif [ -n "${4:-}" ]; then
        echo_debug "setting directory '$1/$2' to fallback '$4'"
    else
        echo_warn "no value provided to directory '$1/$2'"

        return 1
    fi

    eval "$array_name[$2]=\"${3:-"${4:-}"}\""
}

function directory() {
    local array_name="directory_array_$1"

    if is_undeclared "$array_name"; then
        echo_error "unknown directory category '$1'"
    fi

    local value="$(eval "echo \"\${$array_name[$2]}\"")"

    if [ -n "$value" ]; then
        echo -n "$value${3:-}"
    else
        echo_error "unknown directory '$1/$2'"
    fi
}

directory_define 'system' 'cache' "${XDG_CACHE_HOME:-}" "$HOME/.cache"
directory_define 'system' 'config' "${XDG_CONFIG_HOME:-}" "$HOME/.config"
directory_define 'system' 'data' "${XDG_DATA_HOME:-}" "$HOME/.local/share"
directory_define 'system' 'state' "${XDG_STATE_HOME:-}" "$HOME/.local/state"
directory_define 'config' 'nvim' "$(directory system config '/.nvim')"
