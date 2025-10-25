#!/usr/bin/env bash

set -euo pipefail

declare -r start_time="$(date +%s.%N)"

function time_elapsed() {
    echo "$(date +%s.%N --date="$start_time seconds ago")"
}

function is_declared() {
    [[ -n "${!1+waow}" ]] || declare -p $1 &>/dev/null
}

function is_undeclared() {
    [[ -z "${!1+waow}" ]] && ! declare -p $1 &>/dev/null
}

declare -A style_array=()

function style_define() {
    style_array["$1"]="\e[${2}m"

    if [ -n "${3:-}" ]; then
        style_array["${1}-background"]="\e[${3}m"
    fi
    if [ -n "${4:-}" ]; then
        style_array["bright-${1}"]="\e[${4}m"
    fi
    if [ -n "${5:-}" ]; then
        style_array["bright-${1}-background"]="\e[${5}m"
    fi
}

style_define reset 0
style_define bold 1
style_define italic 3
style_define underline 4
style_define strikethrough 9
style_define black 30 40 90 100
style_define red 31 41 91 101
style_define green 32 42 92 102
style_define yellow 33 43 93 103
style_define blue 34 44 94 104
style_define magenta 35 45 95 105
style_define cyan 36 46 96 106
style_define white 37 47 97 107

function style() {
    for style_key in "$@"; do
        local style_string="${style_array["$style_key"]}"

        if [ -n "$style_string" ]; then
            echo -en "$style_string"
        else
            echo_error "invalid style '$1'"
        fi
    done

    unset style_key
}

declare -i debug_enabled=0
declare -a debug_queued=()

function debug_set_enabled() {
    if [[ "$debug_enabled" -ne "$1" ]]; then
        debug_enabled=$1
    else
        echo_debug "debug flag has already been set to '$1'"
    fi
}

function debug_flush_queue() {
    if [ $debug_enabled -eq 1 ]; then
        for queued in "${debug_queued[@]}"; do
            echo "$queued"
        done

        debug_queued=()
    else
        echo_warn 'attempted to flush debugging queue while debugging is disabled'
    fi
}

function echo_debug() {
    if [ $debug_enabled -eq 1 ] || [ "${2:-0}" == 1 ]; then
        >&2 echo -e "$(style bright-black)($(time_elapsed)s) $(style bright-magenta)Debug:$(style reset) $1"
    else
        debug_queued+=("$(echo_debug "$1" 1 2>&1)")
    fi
}

function echo_info() {
    echo -e "$(style bright-black)($(time_elapsed)s) $(style blue)Info:$(style reset) $1"
}

function echo_warn() {
    >&2 echo -e "$(style bright-black)($(time_elapsed)s) $(style yellow)Warning:$(style reset) $1"
}

function echo_error() {
    >&2 echo -e "$(style bright-black)($(time_elapsed)s) $(style red)Error:$(style reset) $1"
    exit "${2:-1}"
}
