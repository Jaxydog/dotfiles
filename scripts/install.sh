#!/usr/bin/env bash

declare -r script_directory="$(dirname "$(realpath "$0")")"

if ! source "$script_directory/utility.sh"; then
    echo 'Error: failed to source utility script'

    exit 1
fi

while getopts 'h' argument; do
    case $argument in
    h)
        echo 'no way'
        exit 0
        ;;
    *)
        echo 'what'
        exit 2
        ;;
    esac
done
