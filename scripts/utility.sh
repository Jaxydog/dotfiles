#!/usr/bin/env bash

set -euo pipefail

function scriptmsg() {
    local argument="${1:-}"

    case "$argument" in
    'missing-argument')
        echo "missing argument #${2:-1} for function '${FUNCNAME[1]}' (called from '${FUNCNAME[2]:-<?>}')"
        ;;
    'invalid-argument')
        echo "invalid argument #${2:-1} '${3:-?}' for function '${FUNCNAME[1]}' (called from '${FUNCNAME[2]:-<?>}')"
        ;;
    '')
        log error "$(scriptmsg 'missing-argument' 1)"
        return 1
        ;;
    *)
        log error "$(scriptmsg 'invalid-argument' 1 "$argument")"
        return 1
        ;;
    esac
}

function var() {
    local argument="${1:-}"

    case "$argument" in
    'assigned')
        [[ -n "${!2+waow}" ]] || declare -p "$2" &>/dev/null
        ;;
    'unassigned')
        [[ -z "${!2+waow}" ]] && ! declare -p "$2" &>/dev/null
        ;;
    '')
        log error "$(scriptmsg 'missing-argument' 1)"
        return 1
        ;;
    *)
        log error "$(scriptmsg 'invalid-argument' 1 "$argument")"
        return 1
        ;;
    esac
}

declare -A SCRIPT_STYLE_MAP=()
declare -i SCRIPT_STYLE_INITIALIZED=0

function style() {
    local argument="${1:-}"

    case "$argument" in
    'get')
        shift 1

        if [ "$#" -eq 0 ]; then
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
        fi

        for key in "$@"; do
            if [ -z "$key" ]; then
                log error "$(scriptmsg 'invalid-argument' 2 '')"
                return 1
            fi

            local value="${SCRIPT_STYLE_MAP["$key"]:-}"

            if [ -n "$value" ]; then
                echo -ne "$value"
            else
                log error "$(scriptmsg 'invalid-argument' 2 "$key")"
                return 1
            fi
        done
        ;;
    'set')
        local key="${2:-}"
        local value="${3:-}"

        if [ -z "$key" ]; then
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
        fi
        if [ -z "$value" ]; then
            log error "$(scriptmsg 'missing-argument' 3)"
            return 1
        fi

        if [ "$SCRIPT_STYLE_INITIALIZED" -eq 1 ]; then
            log debug "setting style '$key' to ANSI code '$value'"
        fi

        SCRIPT_STYLE_MAP["$key"]="\e[${value}m"
        ;;
    '')
        log error "$(scriptmsg 'missing-argument' 1)"
        return 1
        ;;
    *)
        log error "$(scriptmsg 'invalid-argument' 1 "$argument")"
        return 1
        ;;
    esac
}

style set reset 0
style set bold 1
style set faint 2
style set italic 3
style set underline 4
style set blink 5
style set strike 9
style set fg-black 30
style set bg-black 40
style set fg-bright-black 90
style set bg-bright-black 100
style set fg-red 31
style set bg-red 41
style set fg-bright-red 91
style set bg-bright-red 101
style set fg-green 32
style set bg-green 42
style set fg-bright-green 92
style set bg-bright-green 102
style set fg-yellow 33
style set bg-yellow 43
style set fg-bright-yellow 93
style set bg-bright-yellow 103
style set fg-blue 34
style set bg-blue 44
style set fg-bright-blue 94
style set bg-bright-blue 104
style set fg-magenta 35
style set bg-magenta 45
style set fg-bright-magenta 95
style set bg-bright-magenta 105
style set fg-cyan 36
style set bg-cyan 46
style set fg-bright-cyan 96
style set bg-bright-cyan 106
style set fg-white 37
style set bg-white 47
style set fg-bright-white 97
style set bg-bright-white 107
style set fg-reset 39
style set bg-reset 49
style set super 73
style set sub 74

SCRIPT_STYLE_INITIALIZED=1

declare -r SCRIPT_TIMER_START="$(date +%s.%N)"

function timer() {
    local argument="${1:-}"

    case "$argument" in
    'start')
        echo "$SCRIPT_TIMER_START"
        ;;
    'elapsed')
        echo "$(date +%s.%N --date="$SCRIPT_TIMER_START seconds ago")"
        ;;
    '')
        log error "$(scriptmsg 'missing-argument' 1)"
        return 1
        ;;
    *)
        log error "$(scriptmsg 'invalid-argument' 1 "$argument")"
        return 1
        ;;
    esac
}

declare -a SCRIPT_LOG_DEBUG_QUEUE=()
declare -i SCRIPT_LOG_INITIALIZED=0
declare -A SCRIPT_LOG_SETTINGS=()

function log() {
    local argument="${1:-}"

    case "$argument" in
    'get')
        local key="${2:-}"

        if [ -z "$key" ]; then
            log error "$(scriptmsg 'invalid-argument' 2 '')"
            return 1
        fi

        local value="${SCRIPT_LOG_SETTINGS["$key"]:-}"

        if [ -n "$value" ]; then
            echo -ne "$value"
        else
            log error "$(scriptmsg 'invalid-argument' 2 "$key")"
            return 1
        fi
        ;;
    'set')
        local key="${2:-}"
        local value="${3:-}"

        if [ -z "$key" ]; then
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
        fi
        if [ -z "$value" ]; then
            log error "$(scriptmsg 'missing-argument' 3)"
            return 1
        fi

        if [ "$SCRIPT_LOG_INITIALIZED" -eq 1 ]; then
            log debug "setting logging option '$key' to value '$value'"
        fi

        SCRIPT_LOG_SETTINGS["$key"]="$value"

        if [ "$key" == 'debug-enabled' ] && [ "$value" -eq 1 ]; then
            for queued_log in "${SCRIPT_LOG_DEBUG_QUEUE[@]}"; do
                >&2 echo "$queued_log"
            done

            SCRIPT_LOG_DEBUG_QUEUE=()
        fi
        ;;
    'info')
        shift 1

        if [ "$#" -eq 0 ]; then
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
        fi

        echo -e \
            "$(style get fg-bright-black)[$(timer elapsed)s]$(style get reset)" \
            "$(style get fg-bright-blue)(info)$(style get reset)" \
            $@
        ;;
    'warn')
        shift 1

        if [ "$#" -eq 0 ]; then
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
        fi

        >&2 echo -e \
            "$(style get fg-bright-black)[$(timer elapsed)s]$(style get reset)" \
            "$(style get fg-bright-yellow)(warn)$(style get reset)" \
            $@
        ;;
    'error')
        shift 1

        if [ "$#" -eq 0 ]; then
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
        fi

        >&2 echo -e \
            "$(style get fg-bright-black)[$(timer elapsed)s]$(style get reset)" \
            "$(style get fg-bright-red)(error)$(style get reset)" \
            $@
        ;;
    'debug')
        shift 1

        if [ "$#" -eq 0 ]; then
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
        fi

        if [ "${SCRIPT_LOG_FORCE_DEBUG:-0}" -eq 1 ] || [ "$(log get debug-enabled)" -eq 1 ]; then
            echo -e \
                "$(style get fg-bright-black)[$(timer elapsed)s]$(style get reset)" \
                "$(style get fg-magenta)(debug)$(style get reset)" \
                "$(style get fg-white)$@$(style get reset)"
        else
            SCRIPT_LOG_DEBUG_QUEUE+=("$(SCRIPT_LOG_FORCE_DEBUG=1 log debug "$@")")
        fi
        ;;
    '')
        log error "$(scriptmsg 'missing-argument' 1)"
        return 1
        ;;
    *)
        log error "$(scriptmsg 'invalid-argument' 1 "$argument")"
        return 1
        ;;
    esac
}

log set debug-enabled 0

SCRIPT_LOG_INITIALIZED=1

function directory() {
    local argument="${1:-}"

    case "$argument" in
    'get')
        local category="${2:-}"
        local key="${3:-}"

        if [ -z "$category" ]; then
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
        fi
        if [ -z "$key" ]; then
            log error "$(scriptmsg 'missing-argument' 3)"
            return 1
        fi

        local global_variable_name="SCRIPT_DIRECTORY_ARRAY_${category^^}"

        if var unassigned "$global_variable_name"; then
            log error "unknown directory category '$category'"
            return 1
        fi

        local value="$(eval "echo \"\${$global_variable_name[$key]}\"")"

        if [ -z "$value" ]; then
            log error "unknown directory '$category/$key'"
            return 1
        fi

        echo -n "$value"
        ;;
    'set')
        local category="${2:-}"
        local key="${3:-}"
        local value="${4:-}"

        if [ -z "$category" ]; then
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
        fi
        if [ -z "$key" ]; then
            log error "$(scriptmsg 'missing-argument' 3)"
            return 1
        fi
        if [ -z "$value" ]; then
            log error "$(scriptmsg 'missing-argument' 4)"
            return 1
        else
            value="$(realpath -ms "$value")"

            case "$value" in
            *[!/]*/)
                value="${value%\"${x##*[!/]}}"
                ;;
            *[/])
                value="/"
                ;;
            esac
        fi

        local global_variable_name="SCRIPT_DIRECTORY_ARRAY_${category^^}"

        if var unassigned "$global_variable_name"; then
            declare -gA "$global_variable_name"
        fi

        log debug "setting directory '$category/$key' to path '$value'"

        eval "$global_variable_name[$key]='$value'"
        ;;
    '')
        log error "$(scriptmsg 'missing-argument' 1)"
        return 1
        ;;
    *)
        log error "$(scriptmsg 'invalid-argument' 1 "$argument")"
        return 1
        ;;
    esac
}

directory set system cache "${XDG_CACHE_HOME:-"$HOME/.cache"}"
directory set system config "${XDG_CONFIG_HOME:-"$HOME/.config"}"
directory set system data "${XDG_DATA_HOME:-"$HOME/.local/share"}"
directory set system state "${XDG_STATE_HOME:-"$HOME/.local/state"}"

declare -i SCRIPT_CALL_GROUP_CONTINUE=0
declare -a SCRIPT_CALL_GROUP_HEIRARCHY=()
declare -A SCRIPT_CALL_SETTINGS=()

function call() {
    local argument="${1:-}"

    case "$argument" in
    'get')
        local key="${2:-}"

        if [ -z "$key" ]; then
            log error "$(scriptmsg 'invalid-argument' 2 '')"
            return 1
        fi

        local value="${SCRIPT_CALL_SETTINGS["$key"]:-}"

        if [ -n "$value" ]; then
            echo -ne "$value"
        else
            log error "$(scriptmsg 'invalid-argument' 2 "$key")"
            return 1
        fi
        ;;
    'set')
        local key="${2:-}"
        local value="${3:-}"

        if [ -z "$key" ]; then
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
        fi
        if [ -z "$value" ]; then
            log error "$(scriptmsg 'missing-argument' 3)"
            return 1
        fi

        log debug "setting call option '$key' to value '$value'"

        SCRIPT_CALL_SETTINGS["$key"]="$value"
        ;;
    'group')
        argument="${2:-}"

        case "$argument" in
        'require')
            argument="${3:-}"

            case "$argument" in
            'opened')
                if [ "${#SCRIPT_CALL_GROUP_HEIRARCHY[@]}" -eq 0 ]; then
                    log error 'no call group is currently opened'
                    return 1
                fi

                local group_name="${4:-}"

                if [ -n "$group_name" ] && [ "${SCRIPT_CALL_GROUP_HEIRARCHY[-1]}" != "$group_name" ]; then
                    log error "current group '${SCRIPT_CALL_GROUP_HEIRARCHY[-1]}' does not match '$group_name'"
                    return 1
                fi
                ;;
            'closed')
                if [ "${#SCRIPT_CALL_GROUP_HEIRARCHY[@]}" -gt 0 ]; then
                    log error "current group '${SCRIPT_CALL_GROUP_HEIRARCHY[-1]}' is still open"
                    return 1
                fi
                ;;
            '')
                log error "$(scriptmsg 'missing-argument' 3)"
                return 1
                ;;
            *)
                log error "$(scriptmsg 'invalid-argument' 3 "$argument")"
                return 1
                ;;
            esac
            ;;
        'open')
            local value="${3:-}"

            if [ -z "$value" ]; then
                log error "$(scriptmsg 'missing-argument' 3)"
                return 1
            fi

            log debug "creating new call group '$value'"

            SCRIPT_CALL_GROUP_HEIRARCHY+=("$value")

            if [ "$(call get print-group)" -eq 1 ]; then
                local indent="$(
                    indent="$(call get print-indent)"
                    count="$(("${#SCRIPT_CALL_GROUP_HEIRARCHY[@]}" - 1))"

                    for ((i = 0; i < "$count"; i++)); do echo -n "$indent"; done
                )"

                if [ "$SCRIPT_CALL_GROUP_CONTINUE" -eq 0 ]; then
                    echo
                fi

                echo "$indent$(style get bold fg-bright-white)$value:$(style get reset)"
            fi

            SCRIPT_CALL_GROUP_CONTINUE=0
            ;;
        'close')
            call group require opened

            log debug "closing call group '${SCRIPT_CALL_GROUP_HEIRARCHY[-1]}'"

            unset 'SCRIPT_CALL_GROUP_HEIRARCHY[${#SCRIPT_CALL_GROUP_HEIRARCHY[@]}-1]'

            if [ "${#SCRIPT_CALL_GROUP_HEIRARCHY[@]}" -eq 0 ]; then
                SCRIPT_CALL_GROUP_CONTINUE=0
            fi
            ;;
        '')
            log error "$(scriptmsg 'missing-argument' 2)"
            return 1
            ;;
        *)
            log error "$(scriptmsg 'invalid-argument' 2 "$argument")"
            return 1
            ;;
        esac
        ;;
    'eval')
        shift 1

        if [ "${#SCRIPT_CALL_GROUP_HEIRARCHY[@]}" -gt 0 ] && [ "$SCRIPT_CALL_GROUP_CONTINUE" -eq 0 ]; then
            echo
            SCRIPT_CALL_GROUP_CONTINUE=1
        fi

        if [ "$(call get print-command)" -eq 1 ]; then
            local indent="$(
                indent="$(call get print-indent)"
                count="$(("${#SCRIPT_CALL_GROUP_HEIRARCHY[@]}" - 1))"

                for ((i = 0; i < "$count"; i++)); do echo -n "$indent"; done
            )"

            echo "$indent$(style get fg-white)> $@$(style get reset)"
            echo
        fi

        local indent="$(
            indent="$(call get print-indent)"
            count="${#SCRIPT_CALL_GROUP_HEIRARCHY[@]}"

            for ((i = 0; i < "$count"; i++)); do echo -n "$indent"; done
        )"

        if [ "$(call get dry-run)" -eq 1 ]; then
            echo "$indent$(style get fg-bright-black italic)command disabled due to dry run"
            echo
        else
            log debug "evaluating command '$@'"

            local output
            set +e
            output=$(
                > >(
                    trap '' INT TERM
                    while read line; do printf "$indent%s\n" "$line"; done
                ) 2> >(
                    trap '' INT TERM
                    while read line; do >&2 printf "$indent%s\n" "$line"; done
                ) $@ | tee -p --output-error=exit /dev/tty

                exit_code="$?"
                echo -e '.'
                exit "$exit_code"
            )

            local exit_code="$?"
            set -e

            log debug "command exited with a value of '$exit_code'"

            if [[ "${output%.}" != *$'\n\n' ]]; then
                echo
            fi

            if [ "$exit_code" -ne 0 ]; then
                log error "command failed with a code of '$exit_code'"

                exit 1
            fi
        fi
        ;;
    '')
        log error "$(scriptmsg 'missing-argument' 1)"
        return 1
        ;;
    *)
        log error "$(scriptmsg 'invalid-argument' 1 "$argument")"
        return 1
        ;;
    esac
}

call set dry-run 0
call set print-indent '  '
call set print-group 1
call set print-command 1
