# shellcheck shell=bash

source .install/vars.sh

confirm_prompt () {
    local prompt="$1 [y/N] "
    local REPLY

    # sets the default response var to $REPLY
    # -n reads 1 char and doesnt need to press enter
    read -r -p "$prompt" -n 1 REPLY || return 1
    echo

    # =~ is for regex match
    # this will already return 0 if true or 1 if not true
    [[ $REPLY =~ ^[Yy]$ ]]
}

run_catch_error () {
    if ! "$@"; then
        echo "Error: Installation failed: $@" >&2
        exit 1
    fi
}
