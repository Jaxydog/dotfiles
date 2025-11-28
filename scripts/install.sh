#!/usr/bin/env bash

script_path="$(realpath "$0")"
script_name="$(basename --suffix=.sh "$script_path")"
script_directory="$(dirname "$script_path")"
script_version='0.1.0'

if ! source "$script_directory/utility.sh"; then
    echo 'Failed to source utility script'
    exit 1
fi

path set script path "$script_path"
path set script directory "$script_directory"
path set script root "$(dirname "$script_directory")"

log debug 'checking installed system'

if [ ! -f '/etc/arch-release' ] && ! uname -r | grep --quiet --ignore-case 'arch'; then
    log error 'this script should only be run on Arch linux'
fi

function echo_usage() {
    log debug 'printing help listing'

    local arguments=(
        '--set-name' "$script_name"
        '--set-version' "$script_version"
        '--set-description' 'Applies the files within this repository to your system'

        '--add-option' 'n' 'dry-run' 'Run the script without modifying the system'
        '--add-option' 'z' 'debug-enabled' 'Enable debug logging for the current run'
        '--add-option' 'h' 'help' "Prints the script's usage and exits"
        '--add-option' 'V' 'version' "Prints the script's version and exits"
    )

    if [ "$(log get debug-enabled)" == 1 ]; then
        arguments+=('--debug-enabled')
    fi

    "$(path get script directory)/help.sh" "${arguments[@]}"
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
    '-n' | '--dry-run')
        log debug 'enabling dry run, system will not be modified'
        call set dry-run 1
        ;;
    '-z' | '--debug-enabled')
        log debug 'enabling debug logging'
        log set debug-enabled 1
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

path set config nvim "$(path get system config)/nvim"

log info 'checking for system updates'

call group open 'system-update'
call eval sudo pacman -Syu
call group close

call group require closed
