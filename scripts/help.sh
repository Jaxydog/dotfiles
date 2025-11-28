#!/usr/bin/env bash

script_path="$(realpath "$0")"
script_name="$(basename --suffix=.sh "$script_path")"
script_version='0.1.0'

if ! source "$(dirname "$script_path")/utility.sh"; then
    echo 'Failed to source utility script'
    exit 1
fi

unset script_path

function echo_usage() {
    log debug 'printing help listing'

    local arguments=(
        '--set-name' "$script_name"
        '--set-version' "$script_version"
        '--set-description' 'Create and display help listings'

        '--add-option' '' 'set-name' 'Sets the command name used within the listing'
        '--add-option' '' 'set-version' 'Sets the command version used within the listing'
        '--add-option' '' 'set-description' 'Sets the command description used within the listing'
        '--add-option' '' 'set-indent' 'Sets the indentation used within the listing'
        '--add-option' '' 'set-margin' 'Sets the margin used to separate arguments and their descriptions'
        '--add-option' '' 'add-option' 'Adds an option entry to the listing'
        '--add-option' '' 'add-subcommand' 'Adds a subcommand entry to the listing'
        '--add-option' 'z' 'debug-enabled' 'Enable debug logging for the current run'
        '--add-option' 'h' 'help' "Prints the script's usage and exits"
        '--add-option' 'V' 'version' "Prints the script's version and exits"
    )

    if [ "$(log get debug-enabled)" == 1 ]; then
        arguments+=('--debug-enabled')
    fi

    "$0" "${arguments[@]}"
}

declare list_name=
declare list_version=
declare list_description=
declare list_indent='  '
declare -i list_margin=40
declare -a list_subcommands=()
declare -a list_subcommand_descriptions=()
declare -a list_options_long=()
declare -a list_options_short=()
declare -a list_option_descriptions=()

for ((index = 1; index <= "$#"; index += 1)); do
    argument="${!index:-}"

    log debug "visiting command-line argument '$argument'"

    case "$argument" in
    '--set-name')
        index="$((index + 1))"

        [[ "$index" -gt "$#" ]] && log error "$(scriptmsg 'missing-argument' "$index")"

        argument="${!index:-}"

        log debug "setting name to \"$argument\""

        list_name="$argument"
        ;;
    '--set-version')
        index="$((index + 1))"

        [[ "$index" -gt "$#" ]] && log error "$(scriptmsg 'missing-argument' "$index")"

        argument="${!index:-}"

        log debug "setting version to \"$argument\""

        list_version="$argument"
        ;;
    '--set-description')
        index="$((index + 1))"

        [[ "$index" -gt "$#" ]] && log error "$(scriptmsg 'missing-argument' "$index")"

        argument="${!index:-}"

        log debug "setting description to \"$argument\""

        list_description="$argument"
        ;;
    '--set-indent')
        index="$((index + 1))"

        [[ "$index" -gt "$#" ]] && log error "$(scriptmsg 'missing-argument' "$index")"

        argument="${!index:-}"

        log debug "setting indentation to \"$argument\""

        list_indent="$argument"
        ;;
    '--set-margin')
        index="$((index + 1))"

        [[ "$index" -gt "$#" ]] && log error "$(scriptmsg 'missing-argument' "$index")"

        argument="${!index:-}"

        log debug "setting margin to \"$argument\""

        list_margin="$argument"
        ;;
    '--add-option')
        index="$((index + 1))"

        [[ "$index" -gt "$#" ]] && log error "$(scriptmsg 'missing-argument' "$index")"

        argument="${!index:-}"

        log debug "adding short option \"$argument\""

        list_options_short+=("$argument")

        index="$((index + 1))"

        [[ "$index" -gt "$#" ]] && log error "$(scriptmsg 'missing-argument' "$index")"

        argument="${!index:-}"

        log debug "adding long option \"$argument\""

        list_options_long+=("$argument")

        index="$((index + 1))"

        [[ "$index" -gt "$#" ]] && log error "$(scriptmsg 'missing-argument' "$index")"

        argument="${!index:-}"

        log debug "adding option description \"$argument\""

        list_option_descriptions+=("$argument")
        ;;
    '--add-subcommand')
        index="$((index + 1))"

        [[ "$index" -gt "$#" ]] && log error "$(scriptmsg 'missing-argument' "$index")"

        argument="${!index:-}"

        log debug "adding subcomand \"$argument\""

        list_subcommands+=("$argument")

        index="$((index + 1))"

        [[ "$index" -gt "$#" ]] && log error "$(scriptmsg 'missing-argument' "$index")"

        argument="${!index:-}"

        log debug "adding subcomand description \"$argument\""

        list_subcommand_descriptions+=("$argument")
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
    '')
        log error "$(scriptmsg 'missing-argument' "$index")"
        exit 2
        ;;
    *)
        log error "$(scriptmsg 'invalid-argument' "$index" "$argument")"
        exit 2
        ;;
    esac
done

if [ -z "$list_name" ]; then
    log error "a list name must be specified (use '--set-name <name>')"
    exit 2
fi

log debug 'printing help list header'

echo
echo -n "$(style get bold fg-bright-cyan)${list_name}$(style get reset)"

if [ -n "$list_version" ]; then
    echo " $(style get fg-white)v${list_version}$(style get reset)"
else
    echo
fi

if [ -n "$list_description" ]; then
    echo "$(style get italic)${list_indent}${list_description}$(style get reset)"
fi

echo
echo -n \
    "$(style get bold fg-bright-green)Usage:$(style get reset)" \
    "$(style get fg-bright-cyan)${list_name}$(style get reset)"

if [ "${#list_options_long[@]}" -gt 0 ] || [ "${#list_subcommands[@]}" -gt 0 ]; then
    echo " $(style get fg-cyan)[OPTION]...$(style get reset)"
else
    echo
fi

if [ "${#list_options_long[@]}" -gt 0 ]; then
    echo
    echo "$(style get bold fg-bright-green)Options:$(style get reset)"
fi

for ((index = 0; index < "${#list_options_long[@]}"; index += 1)); do
    list_option_short="${list_options_short[index]}"
    list_option_long="${list_options_long[index]}"
    list_option_description="${list_option_descriptions[index]}"

    if [ -n "$list_option_short" ]; then
        echo -n "$(style get fg-bright-cyan)${list_indent}-${list_option_short}$(style get fg-white), "
    else
        echo -n "$(style get fg-bright-cyan)${list_indent}    "
    fi

    echo -n "$(style get fg-bright-cyan)--${list_option_long}$(style get reset)"

    if [ -n "$list_option_description" ]; then
        list_subcommand_description_indent="$(("$list_margin" - "${#list_indent}" - "${#list_option_long}" - 6))"

        if [ "$list_subcommand_description_indent" -lt 0 ]; then
            list_subcommand_description_indent=1
        fi

        for ((i = 0; i < "$list_subcommand_description_indent"; i++)); do
            echo -n ' '
        done

        echo "$(style get italic)${list_option_description}$(style get reset)"
    else
        echo
    fi
done

unset list_option_short list_option_long list_option_description list_subcommand_description_indent

if [ "${#list_subcommands[@]}" -gt 0 ]; then
    echo
    echo "$(style get bold fg-bright-green)Commands:$(style get reset)"
fi

for ((index = 0; index < "${#list_subcommands[@]}"; index += 1)); do
    list_subcommand="${list_subcommands[index]}"
    list_subcommand_description="${list_subcommand_descriptions[index]}"

    echo -n "$(style get fg-bright-cyan)${list_indent}${list_subcommand}$(style get reset)"

    if [ -n "$list_subcommand_description" ]; then
        list_subcommand_description_indent="$(("$list_margin" - "${#list_indent}" - "${#list_subcommand}"))"

        if [ "$list_subcommand_description_indent" -lt 0 ]; then
            list_subcommand_description_indent=1
        fi

        for ((i = 0; i < "$list_subcommand_description_indent"; i++)); do
            echo -n ' '
        done

        echo "$(style get italic)${list_subcommand_description}$(style get reset)"
    else
        echo
    fi
done

unset list_subcommand list_subcommand_description list_subcommand_description_indent

echo
