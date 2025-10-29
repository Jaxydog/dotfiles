#!/usr/bin/env bash

declare -r script_path="$(realpath "$0")"
declare -r script_name="$(basename --suffix=.sh "$script_path")"
declare -r script_directory="$(dirname "$script_path")"
declare -r script_version="0.1.0"

if ! source "$script_directory/utility.sh"; then
    echo 'Failed to source utility script'
    exit 1
fi

log debug 'checking installed system'

if [ ! -f '/etc/arch-release' ] && ! uname -r | grep --quiet --ignore-case 'arch'; then
    log error 'this script should only be run on Arch linux'
fi

function echo_usage() {
    local indent='  '

    echo
    echo \
        "$(style get bold fg-bright-cyan)${script_name}$(style get reset)" \
        "$(style get fg-white)v${script_version}$(style get reset)"
    echo \
        "$(style get italic)${indent}Applies the files within this repository to your system$(style get reset)"
    echo
    echo \
        "$(style get bold fg-bright-green)Usage:$(style get reset)" \
        "$(style get fg-bright-cyan)${script_name}.sh$(style get reset)" \
        "$(style get fg-cyan)[OPTION]...$(style get reset)"
    echo
    echo \
        "$(style get bold fg-bright-green)Options:$(style get reset)"
    echo -e \
        "$(style get fg-bright-cyan)${indent}-n$(style get fg-white)," \
        "$(style get fg-bright-cyan)--dry-run$(style get reset)" \
        "$(style get italic)\t\tRun the script without modifying the system$(style get reset)"
    echo -e \
        "$(style get fg-bright-cyan)${indent}-z$(style get fg-white)," \
        "$(style get fg-bright-cyan)--enable-debug$(style get reset)" \
        "$(style get italic)\t\tEnable debug logging for the current run$(style get reset)"
    echo
    echo -e \
        "$(style get fg-bright-cyan)${indent}-h$(style get fg-white)," \
        "$(style get fg-bright-cyan)--help$(style get reset)" \
        "$(style get italic)\t\t\tPrint the script's usage and exit$(style get reset)"
    echo -e \
        "$(style get fg-bright-cyan)${indent}-V$(style get fg-white)," \
        "$(style get fg-bright-cyan)--version$(style get reset)" \
        "$(style get italic)\t\tPrint the script's version and exit$(style get reset)"
    echo
}

for ((index = 1; index <= "$#"; index += 1)); do
    argument="${!index:-}"

    if [[ "$argument" =~ ^- ]]; then
        log debug "visiting command-line argument '$argument'"
    else
        log debug "encountered positional argument '$argument', cancelling argument parse loop"

        break 1
    fi

    case "$argument" in
    '-z' | '--debug-enabled')
        log debug 'enabling debug logging'
        log set debug-enabled 1
        ;;
    '-n' | '--dry-run')
        log debug 'enabling dry run, system will not be modified'
        call set dry-run 1
        ;;
    '-h' | '--help')
        echo_usage
        exit 0
        ;;
    '-V' | '--version')
        echo "$script_name v$script_version"
        exit 0
        ;;
    '--')
        log debug 'encountered positional separator, cancelling argument parse loop'
        index="$((index + 1))"
        break 1
        ;;
    '')
        log error "$(scriptmsg 'missing-argument' "$index")"
        exit 2
        ;;
    *)
        log error "$(scriptmsg 'invalid-argument' "$index" "$argument")"
        exit 2
        ;;
    esac

    unset argument
done

declare -a script_positionals=()

for (( ; index <= "$#"; index += 1)); do
    script_positionals+=("${!index:-}")
done

if [ "${#script_positionals[@]}" -gt 0 ]; then
    log error 'positional arguments are not supported'
    exit 2
fi

unset print_help

directory set config nvim "$(directory get system config)/nvim"

log info 'checking for system updates'

call group open 'system-update'
call eval sudo pacman -Syu
call group close

call group require closed
